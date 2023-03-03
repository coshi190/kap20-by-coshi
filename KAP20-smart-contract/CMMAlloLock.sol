// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./KAP20interface.sol";

contract CMMAlloLock {

    IKAP20 public token;
    address public beneficiary;
    uint256 public releaseTime;

    constructor(IKAP20 _token, address _beneficiary, uint256 _releaseTime) {
        require(_releaseTime > block.timestamp, "TokenTimelock: release time is before current time");
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }

    function release() external {
        require(block.timestamp >= releaseTime, "TokenTimelock: current time is before release time");

        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        token.transfer(beneficiary, amount);
    }

}
