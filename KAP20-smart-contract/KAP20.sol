// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./KAP20Abstract.sol";

contract KAP20 is IKAP20, IKAP20Committee, IKAP20KYC, IKToken, KYCHandler, Pausable, Authorization {
    modifier onlyCommittee() {
        require(msg.sender == committee, "Restricted only committee");
        _;
    }

    modifier onlySuperAdminOrTransferRouter() {
        require(adminRouter.isSuperAdmin(msg.sender, PROJECT) || msg.sender == transferRouter, "Restricted only super admin or transfer router");
        _;
    }

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowance;
    uint256 public override totalSupply;
    string public override name;
    string public override symbol;
    uint8 public override decimals;
    address public override committee;
    address public transferRouter;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _adminRouter,
        address _committee,
        address _kyc,
        uint256 _acceptedKycLevel,
        address _transferRouter
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        kyc = IKYCBitkubChain(_kyc);
        acceptedKycLevel = _acceptedKycLevel;
        adminRouter = IAdminProjectRouter(_adminRouter);
        committee = _committee;
        transferRouter = _transferRouter;
    }

    function balanceOf(address account) external view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view virtual override returns (uint256) {
        return _allowance[owner][spender];
    }

    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(msg.sender, spender, _allowance[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        require(_allowance[msg.sender][spender] >= subtractedValue, "KAP20: decreased allowance below zero");

        unchecked { _approve(msg.sender, spender, _allowance[msg.sender][spender] - subtractedValue); }
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "KAP20: approve from the zero address");
        require(spender != address(0), "KAP20: approve to the zero address");

        _allowance[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external virtual override whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override whenNotPaused returns (bool) {
        require(_allowance[sender][msg.sender] >= amount, "KAP20: transfer amount exceeds allowance");

        _transfer(sender, recipient, amount);
        unchecked { _approve(sender, msg.sender, _allowance[sender][msg.sender] - amount); }
        return true;
    }

    function adminTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external override onlyCommittee returns (bool) {
        require(_balances[sender] >= amount, "KAP20: transfer amount exceed balance");
        require(recipient != address(0), "KAP20: transfer to zero address");

        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function internalTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external override whenNotPaused onlySuperAdminOrTransferRouter returns (bool) {
        require(kyc.kycsLevel(sender) >= acceptedKycLevel && kyc.kycsLevel(recipient) >= acceptedKycLevel, "Only internal purpose");

        _transfer(sender, recipient, amount);
        return true;
    }

    function externalTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external override whenNotPaused onlySuperAdminOrTransferRouter returns (bool) {
        require(kyc.kycsLevel(sender) >= acceptedKycLevel, "Only internal purpose");

        _transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "KAP20: transfer from the zero address");
        require(recipient != address(0), "KAP20: transfer to the zero address");
        require(_balances[sender] >= amount, "KAP20: transfer amount exceeds balance");
        
        unchecked { _balances[sender] -= amount; }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "KAP20: mint to the zero address");

        totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "KAP20: burn from the zero address");
        require(_balances[account] >= amount, "KAP20: burn amount exceeds balance");

        unchecked { _balances[account] -= amount; }
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function pause() external onlyCommittee {
        _pause();
    }

    function unpause() external onlyCommittee {
        _unpause();
    }

    function activateOnlyKycAddress() external override onlyCommittee {
        _activateOnlyKycAddress();
    }

    function setKYC(address _kyc) external override onlyCommittee {
        _setKYC(IKYCBitkubChain(_kyc));
    }

    function setAcceptedKycLevel(uint256 _kycLevel) external override onlyCommittee {
        _setAcceptedKycLevel(_kycLevel);
    }

    function setCommittee(address _committee) external override onlyCommittee {
        committee = _committee;
    }

    function setTransferRouter(address _transferRouter) external onlyCommittee {
        transferRouter = _transferRouter;
    }
}
