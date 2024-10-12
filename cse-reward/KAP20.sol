// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./KAP20Abstract.sol";

abstract contract KAP20 is AccessController, Pausable {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowance;
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _projectName,
        uint8 _decimals,
        address _kyc,
        address _adminProjectRouter,
        address _committee,
        address _transferRouter,
        uint256 _acceptedKycLevel
    ) {
        name = _name;
        symbol = _symbol;
        project = _projectName;
        decimals = _decimals;
        kyc = IKYCBitkubChain(_kyc);
        adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
        committee = _committee;
        transferRouter = _transferRouter;
        acceptedKycLevel = _acceptedKycLevel;
        owner = msg.sender;
    }

    function balanceOf(address _account) external view virtual override returns (uint256) {
        return _balances[_account];
    }

    function allowance(address _owner, address _spender) external view virtual override returns (uint256) {
        return _allowance[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) external virtual override returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) external virtual returns (bool) {
        _approve(msg.sender, _spender, _allowance[msg.sender][_spender] + _addedValue);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) external virtual returns (bool) {
        require(_allowance[msg.sender][_spender] >= _subtractedValue, "KAP20: decreased allowance below zero");

        unchecked { _approve(msg.sender, _spender, _allowance[msg.sender][_spender] - _subtractedValue); }
        return true;
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal virtual {
        require(_owner != address(0), "KAP20: approve from the zero address");
        require(_spender != address(0), "KAP20: approve to the zero address");

        _allowance[_owner][_spender] = _amount;

        emit Approval(_owner, _spender, _amount);
    }

    function transfer(address _recipient, uint256 _amount) external virtual override whenNotPaused returns (bool) {
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external virtual override whenNotPaused returns (bool) {
        require(_allowance[_sender][msg.sender] >= _amount, "KAP20: transfer amount exceeds allowance");

        _transfer(_sender, _recipient, _amount);
        unchecked { _approve(_sender, msg.sender, _allowance[_sender][msg.sender] - _amount); }
        return true;
    }

    function adminTransfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public virtual override onlyCommittee returns (bool) {
        if (isActivatedOnlyKycAddress) {
            require(kyc.kycsLevel(_sender) > 0 && kyc.kycsLevel(_recipient) > 0, "KAP20: only internal purpose");
        }
        uint256 senderBalance = _balances[_sender];
        require(senderBalance >= _amount, "KAP20: transfer amount exceeds balance");
        unchecked {
            _balances[_sender] = senderBalance - _amount;
        }
            _balances[_recipient] += _amount;
        emit Transfer(_sender, _recipient, _amount);
        return true;
    }

    function internalTransfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external override whenNotPaused onlySuperAdminOrTransferRouter returns (bool) {
        require(kyc.kycsLevel(_sender) >= acceptedKycLevel && kyc.kycsLevel(_recipient) >= acceptedKycLevel, "KAP20: Only internal purpose");

        _transfer(_sender, _recipient, _amount);
        return true;
    }

    function externalTransfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external override whenNotPaused onlySuperAdminOrTransferRouter returns (bool) {
        require(kyc.kycsLevel(_sender) >= acceptedKycLevel, "KAP20: Only internal purpose");

        _transfer(_sender, _recipient, _amount);
        return true;
    }

    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal virtual {
        require(_sender != address(0), "KAP20: transfer from the zero address");
        require(_recipient != address(0), "KAP20: transfer to the zero address");
        require(_balances[_sender] >= _amount, "KAP20: transfer amount exceeds balance");
        
        unchecked { _balances[_sender] -= _amount; }
        _balances[_recipient] += _amount;

        emit Transfer(_sender, _recipient, _amount);
    }

    function _mint(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "KAP20: mint to the zero address");

        totalSupply += _amount;
        _balances[_account] += _amount;

        emit Transfer(address(0), _account, _amount);
    }

    function _burn(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "KAP20: burn from the zero address");
        require(_balances[_account] >= _amount, "KAP20: burn amount exceeds balance");

        unchecked { _balances[_account] -= _amount; }
        totalSupply -= _amount;

        emit Transfer(_account, address(0), _amount);
    }
}
