// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin/contracts/access/Ownable.sol";
import "./FollowManager.sol";


contract ReportManager is Ownable {
    struct Report {
        address reporter;
        address reported;
    }

    DecenSocialAccount private accountContract;
    FollowManager private followManager;

    // Mappings to manage reports and suspensions
    mapping(uint256 => address[]) private reportedBy; // Reporter -> Reported array
    mapping(uint256 => uint256) public reportCounts;
    mapping(uint256 => bool) public isSuspended;

    uint256 public suspensionDuration = 5 minutes;
    mapping(uint256 => uint256) public suspensionExpiry;

    // Record to ensure no duplicate reports
    mapping(bytes32 => bool) private reportExists;

    uint256 public minReportsForSuspension = 2;

    event UserSuspended(uint256 indexed userID, uint256 suspensionExpiry);
    event UserSuspensionLifted(uint256 indexed userID);

    constructor(address _accountContract, address _followManagerAddress) {
        accountContract = DecenSocialAccount(_accountContract);
        followManager = FollowManager(_followManagerAddress);
    }

    function reportUser(uint256 reporterId, uint256 reportedId) external {
        require(accountContract.ownerOf(reporterId)  == msg.sender, "You don't own reporter account");
        require(reporterId != reportedId, "Cannot report yourself");
        require(followManager.isFollowingUser(reporterId, reportedId), "Cannot report user you don't follow");

        bytes32 reportHash = keccak256(abi.encodePacked(reporterId, reportedId));
        require(!reportExists[reportHash], "User already reported by this reporter");

        reportExists[reportHash] = true;
        reportedBy[reportedId].push(tx.origin);
        reportCounts[reportedId]++;

        checkSuspension(reportedId); // suspend or lift suspension if necessary
    }

    function checkSuspension(uint256 userID) public returns (bool) {

        if (shouldSuspend(userID)) {
            suspendUser(userID);
            return isSuspended[userID];
        }

        if (isSuspended[userID] && block.timestamp > suspensionExpiry[userID]) {
            liftSuspension(userID);
        }

        return isSuspended[userID];
    }

    function shouldSuspend(uint256 userID) internal view returns (bool){
        uint256 followerCount = followManager.getFollowersOfUser(userID).length;

        if(reportCounts[userID] < minReportsForSuspension)
            return false;

        if (reportCounts[userID] >= followerCount / 2 && !isSuspended[userID])
            return true;
        else 
            return false;
    }

    function suspendUser(uint256 userID) internal {
        isSuspended[userID] = true;
        suspensionExpiry[userID] = block.timestamp + suspensionDuration;

        emit UserSuspended(userID, suspensionExpiry[userID]);
    }

    
    function liftSuspension(uint256 userID) internal {
        isSuspended[userID] = false; // Lift suspension
        reportCounts[userID] = 0; // Reset report counts for the user
        emit UserSuspensionLifted(userID);
    }

    

    function setSuspensionDuration(uint256 duration) external onlyOwner {
        suspensionDuration = duration;
    }

    function getReports(uint256 userID) external view returns (address[] memory) {
        return reportedBy[userID];
    }
}
