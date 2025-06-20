pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Send ETH to buy tokens");

        uint256 amountToBuy = msg.value * tokensPerEth;
        uint256 vendorBalance = yourToken.balanceOf(address(this));
        require(vendorBalance >= amountToBuy, "Vendor has insufficient token balance");

        bool sent = yourToken.transfer(msg.sender, amountToBuy);
        require(sent, "Token transfer failed");

        emit BuyTokens(msg.sender, msg.value, amountToBuy);
    }

    function withdraw() public onlyOwner {
        uint256 vendorBalance = address(this).balance;
        require(vendorBalance > 0, "No ETH to withdraw");

        (bool sent, ) = msg.sender.call{value: vendorBalance}("");
        require(sent, "Withdraw failed");
    }

    function sellTokens(uint256 tokenAmount) public {
        require(tokenAmount > 0, "Specify an amount of token to sell");

        uint256 amountOfETH = tokenAmount / tokensPerEth;
        uint256 vendorETHBalance = address(this).balance;
        require(vendorETHBalance >= amountOfETH, "Vendor has insufficient ETH");

        // Transfer tokens from user to Vendor
        bool received = yourToken.transferFrom(msg.sender, address(this), tokenAmount);
        require(received, "Token transfer failed");

        // Send ETH to user
        (bool sent, ) = msg.sender.call{value: amountOfETH}("");
        require(sent, "ETH transfer to user failed");

        emit SellTokens(msg.sender, tokenAmount, amountOfETH);
    }
}
