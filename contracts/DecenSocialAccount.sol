// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin/contracts/token/ERC721/ERC721.sol";
import "openzeppelin/contracts/access/Ownable.sol";

contract DecenSocialAccount is ERC721, Ownable {
    uint256 public nextTokenId;

    // Mapping to store usernames for each tokenId
    mapping(uint256 => string) private usernames;

    // To prevent duplicate usernames and map username to tokenId
    mapping(string => uint256) private usernameToTokenId;

    constructor() ERC721("DecenSocialAccount", "DSA") {}

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
}
