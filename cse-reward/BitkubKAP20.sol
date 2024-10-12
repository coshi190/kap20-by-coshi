// SPDX-License-Identifier: MIT
// KAP-20, KAP-721 Standard: V.1.0.0
// This KAP proposes an interface standard to create token contracts on Bitkub Chain.
// This Smart Contract does not provide the basic functionality, it only provides the required standard functions that define the implementation of APIs for KAP standard.
// This Smart Contract contains a set of operations that control how to communicate on the ecosystem of Bitkub applications on Bitkub Chain.

pragma solidity ^0.8.0;
import "./KAP20.sol";

contract BitkubKAP20 is KAP20 {
    modifier onlySuperAdminOrOwnerOrHolder(address _burner) {
        require(adminProjectRouter.isSuperAdmin(msg.sender, project) || msg.sender == owner || msg.sender == _burner, "BitkubKAP20: restricted only super admin or owner or holder");
        _;
    }

    uint256 public constant HARD_CAP = 100_000_000 ether;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _projectName,
        uint8 _decimals,
        address _kyc,
        address _adminProjectRouter,
        address _committee,
        address _transferRouter,
        uint256 _acceptedKYCLevel
    )
        KAP20(
            _name,
            _symbol,
            _projectName,
            _decimals,
            _kyc,
            _adminProjectRouter,
            _committee,
            _transferRouter,
            _acceptedKYCLevel
        )
    {}

    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }

///////////////////////////////////////////////////////////////////////////////////////

    function _mint(address _account, uint256 _amount) internal override {
        require(totalSupply + _amount <= HARD_CAP, "BitkubKAP20: totalSupply exceeds HARD_CAP");
        KAP20._mint(_account, _amount);
    }

    function mint(address _to, uint256 _amount) external onlySuperAdminOrOwner whenNotPaused {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlySuperAdminOrOwnerOrHolder(_from) whenNotPaused {
        _burn(_from, _amount);
    }
}

// KAP-20, KAP-721 Standard: V.1.0.0
// This KAP proposes an interface standard to create token contracts on Bitkub Chain.
// This Smart Contract does not provide the basic functionality, it only provides the required standard functions that define the implementation of APIs for KAP standard.
// This Smart Contract contains a set of operations that control how to communicate on the ecosystem of Bitkub applications on Bitkub Chain.