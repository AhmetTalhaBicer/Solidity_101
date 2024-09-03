// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

contract FundMe {

    mapping(address => uint256) public funders;

    function fund() public payable {
        require(msg.value > 1e18, "Didn't send enough ETH");
        funders[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 amount = funders[msg.sender];
        require(amount > 0, "No funds to withdraw");
        funders[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}