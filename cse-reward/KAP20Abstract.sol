// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./KAP20Interface.sol";

abstract contract KYCHandler {
    IKYCBitkubChain public kyc;
    uint256 public acceptedKycLevel;
    bool public isActivatedOnlyKycAddress;

    function _activateOnlyKYCAddress() internal virtual {
        isActivatedOnlyKycAddress = true;
    }

    function _setKYC(address _kyc) internal virtual {
        kyc = IKYCBitkubChain(_kyc);
    }

    function _setAcceptedKYCLevel(uint256 _kycLevel) internal virtual {
        acceptedKycLevel = _kycLevel;
    }
}

abstract contract Authorization {
    IAdminProjectRouter public adminProjectRouter;
    string public project;

    modifier onlySuperAdmin() {
        require(adminProjectRouter.isSuperAdmin(msg.sender, project), "Restricted only super admin");
        _;
    }

    modifier onlyAdmin() {
        require(adminProjectRouter.isAdmin(msg.sender, project), "Restricted only admin");
        _;
    }

    function setAdmin(address _adminProjectRouter) external onlySuperAdmin {
        adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
    }
}

abstract contract Committee is IKAP20Committee {
    address public committee;

    modifier onlyCommittee() {
        require(msg.sender == committee, "KAP20: Restricted only committee");
        _;
    }

    function setCommittee(address _committee) public virtual onlyCommittee {
        emit CommitteeSet(committee, _committee, msg.sender);
        committee = _committee;
    }
}

abstract contract AccessController is KYCHandler, Authorization, Committee {
    address public transferRouter;
    address public owner;

    event TransferRouterSet(address indexed oldTransferRouter, address indexed newTransferRouter, address indexed caller);

    event AdminProjectRouterSet(address indexed oldAdminProjectRouter, address indexed newAdminProjectRouter, address indexed caller);

    modifier onlyOwner() {
        require(msg.sender == owner, "KAP20: Restricted only owner");
        _;
    }

    modifier onlyOwnerOrCommittee() {
        require(msg.sender == owner || msg.sender == committee, "KAP20: Restricted only owner or committee");
        _;
    }

    modifier onlySuperAdminOrTransferRouter() {
        require(adminProjectRouter.isSuperAdmin(msg.sender, project) || msg.sender == transferRouter, "KAP20: Restricted only super admin or transfer router");
        _;
    }

    modifier onlySuperAdminOrOwner() {
        require(adminProjectRouter.isSuperAdmin(msg.sender, project) || msg.sender == owner, "KAP20: Restricted only super admin or owner");
        _;
    }

    function activateOnlyKYCAddress() external onlyCommittee {
        _activateOnlyKYCAddress();
    }

    function setKYC(address _kyc) external onlyCommittee {
        _setKYC(_kyc);
    }

    function setAcceptedKYCLevel(uint256 _kycLevel) external onlyCommittee {
        _setAcceptedKYCLevel(_kycLevel);
    }

    function setTransferRouter(address _transferRouter) external onlyOwnerOrCommittee {
        emit TransferRouterSet(transferRouter, _transferRouter, msg.sender);
        transferRouter = _transferRouter;
    }

    function setAdminProjectRouter(address _adminProjectRouter) external onlyOwnerOrCommittee {
        require(_adminProjectRouter != address(0), "Authorization: new admin project router is the zero address");
        emit AdminProjectRouterSet(address(adminProjectRouter), _adminProjectRouter, msg.sender);
        adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
    }
}

///////////////////////////////////////////////////////////////////////////////////////

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