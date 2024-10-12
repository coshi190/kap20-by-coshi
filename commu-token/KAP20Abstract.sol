// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./KAP20Interface.sol";

abstract contract KYCHandler {
    IKYCBitkubChain public kyc;
    uint256 public acceptedKycLevel;
    bool public isActivatedOnlyKycAddress;

    function _activateOnlyKycAddress() internal virtual {
        isActivatedOnlyKycAddress = true;
    }

    function _setKYC(IKYCBitkubChain _kyc) internal virtual {
        kyc = _kyc;
    }

    function _setAcceptedKycLevel(uint256 _kycLevel) internal virtual {
        acceptedKycLevel = _kycLevel;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


abstract contract Authorization {
    IAdminProjectRouter public adminRouter;
    string public constant PROJECT = "commu-token";

    modifier onlySuperAdmin() {
        require(adminRouter.isSuperAdmin(msg.sender, PROJECT), "Restricted only super admin");
        _;
    }

    modifier onlyAdmin() {
        require(adminRouter.isAdmin(msg.sender, PROJECT), "Restricted only admin");
        _;
    }

    function setAdmin(address _adminRouter) external onlySuperAdmin {
        adminRouter = IAdminProjectRouter(_adminRouter);
    }
}
