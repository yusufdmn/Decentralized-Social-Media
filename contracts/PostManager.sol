// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DecenSocialAccount.sol";

contract PostManager {
    // Reference to the DecenSocialAccount contract
    DecenSocialAccount private accountContract;

    struct Post {
        uint256 postId;
        uint256 accountId;
        string content;
        uint256 timestamp;
    }

    // Mapping from account ID to their posts
    mapping(uint256 => Post[]) private postsByAccount;

    // Total posts counter
    uint256 public totalPosts;

    // Event for new posts
    event PostCreated(
        uint256 indexed postId,
        uint256 indexed accountId,
        string content,
        uint256 timestamp
    );

    constructor(address accountContractAddress) {
        accountContract = DecenSocialAccount(accountContractAddress);
    }

    // Create a new post
    function createPost(uint256 accountId, string calldata content) external {
        // Validate that the account exists and the sender owns it
        require(accountContract.ownerOf(accountId) == msg.sender, "You do not own this account");

        // Validate post content length
        require(bytes(content).length > 0, "Post content cannot be empty");
        require(bytes(content).length <= 140, "Post content exceeds 140 characters");

        // Create the post
        uint256 postId = ++totalPosts;
        Post memory newPost = Post(postId, accountId, content, block.timestamp);
        postsByAccount[accountId].push(newPost);

        // Emit the PostCreated event
        emit PostCreated(postId, accountId, content, block.timestamp);
    }

    // Get all posts of a user by account ID
    function getPostsOfUser(uint256 accountId) external view returns (Post[] memory) {
        return postsByAccount[accountId];
    }
}
