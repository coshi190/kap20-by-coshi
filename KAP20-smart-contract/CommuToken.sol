// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./KAP20.sol";

contract CommuToken is KAP20, IKAP20AdminApprove {
    modifier onlySuperAdminOrAdmin() {
        require(adminRouter.isSuperAdmin(msg.sender, PROJECT) || adminRouter.isAdmin(msg.sender, PROJECT), "Restricted only super admin or admin");
        _;
    }

    uint256 public constant HARD_CAP = 10_000_000 ether;

    constructor(
        address _adminRouter,
        address _kyc,
        address _committee,
        address _transferRouter,
        uint256 _acceptedKycLevel
    ) KAP20("Commu Token", "CMM", 18, _adminRouter, _committee, _kyc, _acceptedKycLevel, _transferRouter) {}

    function mint(address _to, uint256 _amount) external whenNotPaused onlySuperAdmin returns (bool) {
        _mint(_to, _amount);
        return true;
    }

    function _mint(address _account, uint256 _amount) internal override {
        require(totalSupply + _amount <= HARD_CAP, "KAP20: totalSupply exceeds HARD_CAP");
        KAP20._mint(_account, _amount);
    }

    function burn(uint256 _amount) external whenNotPaused returns (bool) {
        _burn(msg.sender, _amount);
        return true;
    }

    function adminApprove(
        address _owner,
        address _spender,
        uint256 _amount
    ) external override onlySuperAdminOrAdmin returns (bool) {
        require(kyc.kycsLevel(_owner) >= acceptedKycLevel && kyc.kycsLevel(_spender) >= acceptedKycLevel, "KAP20: Owner or spender address is not a KYC user");

        _approve(_owner, _spender, _amount);
        return true;
    }
}
