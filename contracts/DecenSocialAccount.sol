// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin/contracts/token/ERC721/ERC721.sol";
import "openzeppelin/contracts/access/Ownable.sol";
import "openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DecenSocialAccount is ERC721, Ownable {
    uint256 public nextTokenId;

    // Mapping to store usernames for each tokenId
    mapping(uint256 => string) private usernames;

    // To prevent duplicate usernames and map username to tokenId
    mapping(string => uint256) private usernameToTokenId;


    // Mapping to store full names for verified accounts
    mapping(uint256 => string) public verifiedNames;

    // Address of the DecenSocialToken (DST00) contract
    IERC20 public socialToken;

    // Fee for account verification in DST00 tokens
    uint256 public verificationFee;



    constructor(IERC20 _socialToken) ERC721("DecenSocialAccount", "DSA") {
        verificationFee = 5; // temporary for now
        socialToken = IERC20(_socialToken);

    }

    // Mint an NFT for a new account with a username
    function createAccount(string calldata username) external {
        require(bytes(username).length > 0, "Username cannot be empty");
        require(usernameToTokenId[username] == 0, "Username is already taken");

        uint256 tokenId = ++nextTokenId;
        _mint(msg.sender, tokenId);

        usernames[tokenId] = username;
        usernameToTokenId[username] = tokenId;
    }

    // Fetch the username of an account by tokenId
    function getUsername(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return usernames[tokenId];
    }

    // Login function to check if msg.sender owns an account with the provided username
    function login(string calldata username) external view returns (bool) {
        uint256 tokenId = usernameToTokenId[username];
        return tokenId != 0 && ownerOf(tokenId) == msg.sender;
    }

    // Optional: Deactivate account by burning the token and freeing the username
    function deactivateAccount(string calldata username) external {
        uint256 tokenId = usernameToTokenId[username];
        require(tokenId != 0 && ownerOf(tokenId) == msg.sender, "You do not own this account");

        delete usernameToTokenId[username];
        delete usernames[tokenId];

        _burn(tokenId);
    }


// Verify account by paying DST and providing a full name
    function verifyAccount(uint256 tokenId, string calldata fullName) external payable returns(bool success){
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "You do not own this account");
        require(bytes(fullName).length > 0, "Full name cannot be empty");
        require(bytes(verifiedNames[tokenId]).length == 0, "Account already verified");

        // Check allowance
        uint256 allowance = socialToken.allowance(msg.sender, address(this));
        require(allowance >= verificationFee, "Insufficient allowance for verification fee");

        // Transfer the verification fee
        success = socialToken.transferFrom(msg.sender, owner(), verificationFee);

        require(success, "Token transfer failed");

        // Store the full name as verified
        verifiedNames[tokenId] = fullName;
        return success;
    }


    // Fetch the verified name of a tokenId
    function getVerifiedName(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        require(bytes(verifiedNames[tokenId]).length > 0, "Account is not verified");
        return verifiedNames[tokenId];
    }

    // Update the verification fee (only owner)
    function setVerificationFee(uint256 fee) external onlyOwner {
        verificationFee = fee;
    }
}
