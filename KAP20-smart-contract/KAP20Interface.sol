// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IKAP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function adminTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IKAP20Committee is IKAP20 {
    function committee() external view returns (address);

    function setCommittee(address _committee) external;
}


interface IKAP20KYC is IKAP20 {
    function activateOnlyKycAddress() external;

    function setKYC(address _kyc) external;

    function setAcceptedKycLevel(uint256 _kycLevel) external;
}


interface IKAP20AdminApprove is IKAP20 {
    function adminApprove(
        address _owner,
        address _spender,
        uint256 _amount
    ) external returns (bool);
}


interface IKToken {
    function internalTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function externalTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}


interface IKYCBitkubChain {
    function kycsLevel(address _addr) external view returns (uint256);
}


interface IAdminProjectRouter {
    function isSuperAdmin(address _addr, string calldata _project) external view returns (bool);

    function isAdmin(address _addr, string calldata _project) external view returns (bool);
}
