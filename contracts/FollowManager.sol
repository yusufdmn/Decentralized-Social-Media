// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DecenSocialAccount.sol";
import "openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FollowManager {
    // Reference to the DecenSocialAccount contract
    DecenSocialAccount private accountContract;

    // ERC20 token contract for payments
    IERC20 private paymentToken;

    // Mapping from user ID to their followers
    mapping(uint256 => uint256[]) private followers;

    // Mapping from user ID to their followings
    mapping(uint256 => uint256[]) private followings;

    // Event emitted when a user follows another user
    event Followed(uint256 indexed followerId, uint256 indexed followingId);

    // Event emitted when a user unfollows another user
    event Unfollowed(uint256 indexed followerId, uint256 indexed followingId);

    constructor(address accountContractAddress, address tokenAddress) {
        accountContract = DecenSocialAccount(accountContractAddress);
        paymentToken = IERC20(tokenAddress);
    }

    // Follow a user
    function follow(uint256 followerId, uint256 followingId) external {
        // Validate that both accounts exist
        require(accountContract.ownerOf(followerId) == msg.sender, "You do not own the follower account");
        require(accountContract.ownerOf(followingId) != address(0), "Following account does not exist");

        // Prevent self-follow
        require(followerId != followingId, "You cannot follow yourself");

        // Get the follow fee for the following account
        uint256 followFee = accountContract.getFollowFee(followingId);

        // Transfer follow fee from follower to following
        address followerOwner = accountContract.ownerOf(followerId);
        address followingOwner = accountContract.ownerOf(followingId);
        require(paymentToken.allowance(followerOwner, address(this)) >= followFee, "Insufficient allowance for follow fee");
        require(paymentToken.transferFrom(followerOwner, followingOwner, followFee), "Token transfer failed");

        // Add the follower to the following's list and vice versa
        followers[followingId].push(followerId);
        followings[followerId].push(followingId);

        // Emit Followed event
        emit Followed(followerId, followingId);
    }

    // Unfollow a user
    function unfollow(uint256 followerId, uint256 followingId) external {
        // Validate ownership of follower account
        require(accountContract.ownerOf(followerId) == msg.sender, "You do not own the follower account");

        // Remove the follower-following relationship
        _removeFromList(followers[followingId], followerId);
        _removeFromList(followings[followerId], followingId);

        // Emit Unfollowed event
        emit Unfollowed(followerId, followingId);
    }

    // Get followers of a user
    function getFollowersOfUser(uint256 userId) external view returns (uint256[] memory) {
        return followers[userId];
    }

    // Get followings of a user
    function getFollowingsOfUser(uint256 userId) external view returns (uint256[] memory) {
        return followings[userId];
    }

    // Internal function to remove an ID from a list
    function _removeFromList(uint256[] storage list, uint256 id) internal {
        for (uint256 i = 0; i < list.length; i++) {
            if (list[i] == id) {
                list[i] = list[list.length - 1];
                list.pop();
                break;
            }
        }
    }

    function isFollowingUser(uint256 followerId, uint256 followingId) external view returns (bool) {
        return _isInList(followings[followerId], followingId);
    }

    // Helper function to check if an ID is in a list of IDs
    function _isInList(uint256[] storage list, uint256 id) internal view returns (bool) {
        for (uint256 i = 0; i < list.length; i++) {
            if (list[i] == id) {
                return true;
            }
        }
        return false;
    }
}
    