// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin/contracts/token/ERC20/ERC20.sol";
import "openzeppelin/contracts/access/Ownable.sol";

contract DecenSocialToken is ERC20, Ownable {
    uint256 public tokenPrice; // Price of 1 token in wei

    constructor() ERC20("DecenSocialToken", "DST") {
        require(1 > 0, "Token price must be greater than zero");
        tokenPrice = 1; // temporary for now
        _mint(msg.sender, 1000 * 10**decimals()); // Initial supply to the contract owner // temporary for now
    }

    // Function to buy tokens
    function buyTokens() external payable {
        require(msg.value > 0, "Ether value must be greater than zero");

        uint256 amountToBuy = msg.value / tokenPrice;
        require(amountToBuy > 0, "Insufficient Ether to buy tokens");
        require(balanceOf(owner()) >= amountToBuy, "Not enough tokens available");

        _transfer(owner(), msg.sender, amountToBuy);
    }

    // Set the token price (only the owner can update it)
    function setTokenPrice(uint256 pricePerToken) external onlyOwner {
        require(pricePerToken > 0, "Token price must be greater than zero");
        tokenPrice = pricePerToken;
    }

    // Withdraw Ether from the contract (only owner)
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
