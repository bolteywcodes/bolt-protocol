// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract BoltToken is ERC20, Ownable {
    using ECDSA for bytes32;

    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18;
    mapping(address => bool) public minters;
    
    event EcoFriendlyTransaction(address indexed user, uint256 energySaved);
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);
    
    modifier onlyMinter() {
        require(minters[msg.sender], "Not a minter");
        _;
    }

    constructor() ERC20("BOLT", "⚡BOLT") {
        _mint(msg.sender, MAX_SUPPLY / 2); // Počáteční mintování pro ownera (50%)
        minters[msg.sender] = true;
    }

    function addMinter(address minter) external onlyOwner {
        minters[minter] = true;
        emit MinterAdded(minter);
    }

    function removeMinter(address minter) external onlyOwner {
        minters[minter] = false;
        emit MinterRemoved(minter);
    }

    function mint(address to, uint256 amount) external onlyMinter {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function secureTransfer(address to, uint256 amount, bytes memory signature) external returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, to, amount));
        require(hash.toEthSignedMessageHash().recover(signature) == msg.sender, "Invalid signature");
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    function multiTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
        require(recipients.length == amounts.length, "Mismatched arrays");
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }
}
