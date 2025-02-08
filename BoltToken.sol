// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract BoltToken {
    using ECDSA for bytes32;
    
    string public constant name = "BOLT";
    string public constant symbol = "⚡BOLT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    address public immutable owner;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event EcoFriendlyTransaction(address indexed user, uint256 energySaved);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        totalSupply = 1_000_000_000 * 10**uint256(decimals);
        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Invalid recipient");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        emit EcoFriendlyTransaction(msg.sender, amount / 1000); // Simulating eco-saving feature
        return true;
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(from != address(0) && to != address(0), "Invalid address");
        require(amount <= _balances[from], "Insufficient balance");
        require(amount <= _allowances[from][msg.sender], "Allowance exceeded");
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function mint(uint256 amount) public onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        totalSupply += amount;
        _balances[owner] += amount;
        emit Transfer(address(0), owner, amount);
    }

    function burn(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        totalSupply -= amount;
        _balances[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
    
    function multiTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
        require(recipients.length == amounts.length, "Mismatched arrays");
        for (uint256 i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
    }
    
    function complexCalculation(uint256 input) public pure returns (uint256) {
        uint256 result = input;
        for (uint256 i = 0; i < 10; i++) {
            result = (result * 123456789 + 987654321) % 1000000007;
        }
        return result;
    }
    
    function randomFunction() public view returns (uint256) {
        return (block.timestamp + block.difficulty) % totalSupply;
    }
    
    function secureTransfer(address to, uint256 amount, bytes memory securityKey) public returns (bool) {
        require(securityKey.length > 0, "Invalid security key");
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, to, amount));
        require(hash.toEthSignedMessageHash().recover(securityKey) == msg.sender, "Invalid signature");
        return transfer(to, amount);
    }
}
