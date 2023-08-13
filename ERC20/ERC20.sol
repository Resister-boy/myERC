// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20 {
  mapping(address => uint) private _balances;
  mapping(address => mapping(address => uint)) private _allowances;
  mapping(address => bool) private _blackList;

  uint private _totalSupply;
  string private _name;  // ETHEREUM
  string private _symbol; // ETH
  uint8 private _decimals;
  address public owner;

  event Transfer(address indexed from, address indexed to, uint amount);
  event Approval(address indexed from, address indexed to, uint amount);

  modifier checkSenderBalance(uint256 amount) {
    require (_balances[msg.sender] > amount, "Not Sufficient Balance");
    _;
  }

  modifier checkOnlyOwner() {
    require (owner == msg.sender, "Error: Not Valid Owner");
    _;
  }

  modifier checkBlackList() {
    require (!_blackList[msg.sender], "Error: This Account is Blacklist");
    _;    
  }

  constructor(string memory _name_, string memory _symbol_, uint8 _decimals_) {
    _name = _name_;
    _symbol = _symbol_;
    _decimals = _decimals_;
    _totalSupply = 100000000 * (10 ** 18);
    owner = msg.sender;
  }

  function getName() public view returns (string memory) {
    return (_name);
  }
  
  function getSymbols() public view returns (string memory) {
    return (_symbol);
  }

  function getDecimals() public view returns (uint8) {
    return (_decimals);
  }

  function balanceOf(address account) public view returns (uint256) {
    return (_balances[account]);
  }

  function balanceOf (address to, uint256 amount) public checkSenderBalance(amount) returns (bool) {

    _balances[msg.sender] -= amount;
    _balances[to] += amount;
    
    emit Transfer(msg.sender, to, amount);
    return (true);
  }

  function allowance(address account, address spender) public view returns (uint256) {
    return (_allowances[account][spender]);
  }

  function approve(address spender, uint256 amount) public checkSenderBalance(amount) checkBlackList returns (bool) {
    _allowances[msg.sender][spender] = amount;
    
    emit Approval(msg.sender, spender, amount);
    return (true);
  }

  function transfer(address to, uint256 amount) public checkSenderBalance(amount) returns (bool) {
    _balances[msg.sender] -= amount;
    _balances[to] += amount;

    emit Transfer(msg.sender, to, amount);
    return (true);
  }

  function mintToken(address to, uint amount) public checkOnlyOwner returns (address) {
    _balances[to] = amount;
    _totalSupply += amount;
    return (to);
  }

  function burnToken (address to, uint amount) public checkOnlyOwner {
    _balances[to] -= amount;
    _totalSupply -= amount;
  }

  function burnTokenByUser(uint amount) public {
    transfer(address(0), amount);
    _totalSupply -= amount;    
  }

  function setBlackList(address to) public checkOnlyOwner {
    _blackList[to] = true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public checkSenderBalance(amount) checkOnlyOwner checkBlackList returns (bool) {
   
    require(_allowances[from][to] > amount, "Not Allowed Amount");

    _balances[from] -= amount;
    _balances[to] += amount;
    emit Transfer(from, to, amount);
    return (true);
  }
}