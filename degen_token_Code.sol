// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CustomToken {
    string public name = "Custom Token";
    string public symbol = "CTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Redeem(address indexed from, uint256 value, string prizeName);
    event Burn(address indexed from, uint256 value);

    // Mapping to store the cost of each prize
    mapping(string => uint256) public prizeCost;

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        
        // Initialize prize costs
        prizeCost["PrizeX"] = 150; // Set the cost of PrizeX
        prizeCost["PrizeY"] = 250; // Set the cost of PrizeY
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(to != address(0), "Invalid recipient address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(from != address(0), "Invalid sender address");
        require(to != address(0), "Invalid recipient address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    function mint(address to, uint256 value) public onlyOwner returns (bool success) {
        require(to != address(0), "Invalid recipient address");
        require(totalSupply + value >= totalSupply, "Overflow");
        require(balanceOf[to] + value >= balanceOf[to], "Overflow");

        totalSupply += value;
        balanceOf[to] += value;

        emit Mint(to, value);
        emit Transfer(address(0), to, value);
        return true;
    }

    function redeem(string memory prizeName) public returns (bool success) {
        require(bytes(prizeName).length > 0, "Invalid prize name");
        require(balanceOf[msg.sender] >= prizeCost[prizeName], "Insufficient balance for the selected prize");

        // Deduct the cost of the prize from the user's balance
        balanceOf[msg.sender] -= prizeCost[prizeName];

        // Log a message indicating a successful redemption
        emit Redeem(msg.sender, prizeCost[prizeName], prizeName);

        return true;
    }

    function burn(uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        totalSupply -= value;

        emit Burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
        return true;
    }
}
