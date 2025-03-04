# Introduction
This report provides an overview of the system design, architecture, and components
of the **decentralized social platform DecenSocial based on the Ethereum Testnet blockchain**.  
The platform includes smart contracts DecenSocialAccount, DecenSocialToken,
FollowManager, PostManager, and ReportManager. These contracts provide the creation of
ownable accounts, account verification, posting, following and unfollowing functionality, and
a reporting system.

# System Design and Architecture
The architecture consists of interconnected smart contracts, each responsible for a
specific functionality within the application. 

## The components:

### DecenSocialAccount (NFT-based Accounts)
This contract implements ERC721 to mint NFTs representing Decen Social accounts.  
It manages account creation (minting new token), login, deactivation, and account
verification.  
The contract also interacts with the ReportManager for account suspension control and the
DecenSocialToken for account verification for token payments.
### DecenSocialToken (ERC20 Token for Payments)
An ERC20 token is used within the platform for transactions such as account
verification and following fees.  
It allows users to purchase tokens in return for wei. The token price is fixed at 100 wei.
### FollowManager
This contract handles the functionality for users to follow and unfollow each other.  
It ensures the payment of a fee when following another user, using the DecenSocialToken.  
It also stores the followers and followings for each account, allowing the platform to query
user relationships.
### PostManager
The PostManager allows users to post content (up to 140 characters).  
It stores posts linked to each account and allows users to view all posts associated with an
account.
### ReportManager
The ReportManager allows users to report suspicious or inappropriate behavior, which can
lead to the suspension of accounts.  
It stores reports against users and manages suspensions, interacting with the
DecenSocialAccount and FollowManager for user and follower validation.

# Web Interface

## Login/Register
• User can create an account (mints a DSA token).  
• Users can see the DSA accounts connected to their address and login.  

![image](https://github.com/user-attachments/assets/820c4b96-355d-4ac6-a000-d69bc74171b0)  

## Home page (Feed)
• Users can create a new post and see the posts of the accounts they follow.  

![image](https://github.com/user-attachments/assets/c4335003-f583-4db2-bc0b-32b80d825f14)  

## Profile page
• Users can see the followers and followings of the account.  
• They can follow/unfollow the account.  
• They can report the account if they follow.  
• They can see the posts of the account.   

![image](https://github.com/user-attachments/assets/d887c321-e5db-4ac2-9791-ee1aa98c6b43)  


## Settings Page
• Can set follow fee in DST.   
• Can buy DST tokens in return of wei.   
• Can Verify account.   

![image](https://github.com/user-attachments/assets/4d7d1403-d3d5-422b-b274-eb04f94e0f33)  

## Additional Feature (Solidity Events)
• When a new post is created by the accounts the user follows, the notification is
shown to the followers.   

# Deployment Details
### Contract Addresses
**DecenSocialToken (DST):** 0xd0679BE76C87F8a100B8e73ba2dE3E1e2F35B958  
**DecenSocialAccount (DSA):** 0x3b34fBC6766c9B468B27bF6F5d60039339C9105d  
**FollowManager:** 0x85e3F15D4b949E0095178A5D18AD5081A386479D  
**PostManager:** 0x0C3805574d3Fa2e9670f5903D8Ad1Edcd92B5152  
**ReportManager:** 0x9F97b1d2a216E63C1c56B1Ed22A73a28A16bB272  


# Conclusion
DecenSocial provides an innovative solution for managing social identities, content sharing,
and interaction on the blockchain.   
By using NFTs for account management which makes users own their social accounts, custom ERC20 tokens for payments, and smart contracts for
managing followers, posts, and reports.  
The platform offers a decentralized and secure environment for people. The design is modular, allowing for easy future upgrades and
improvements to increase scalability, user experience, and security.
