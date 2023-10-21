// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Token {

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;

  address public owner;

  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  uint256 public buyTax;
  uint256 public sellTax;

  address public burningWallet;

  uint256 public lastBlockBuyTax;
  uint256 public lastBlockSellTax;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    uint256 _totalSupply,
    uint256 _buyTax,
    uint256 _sellTax,
    address _burningWallet
  ) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    totalSupply = _totalSupply;

    owner = msg.sender;

    balanceOf[msg.sender] = totalSupply;

    buyTax = _buyTax;
    sellTax = _sellTax;

    burningWallet = _burningWallet;
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    allowance[sender][msg.sender] -= amount;
    _transfer(sender, recipient, amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    uint256 taxAmount;

    if (sender == burningWallet || recipient == burningWallet) {
      taxAmount = 0;
    } else if (msg.sender == owner) {
      taxAmount = 0;
    } else if (isSell(sender)) {
      if (block.number - lastBlockSellTax <= 10) {
        taxAmount = amount * sellTax / 100;
      } else {
        taxAmount = 0;
      }
    } else {
      if (block.number - lastBlockBuyTax <= 10) {
        taxAmount = amount * buyTax / 100;
      } else {
        taxAmount = 0;
      }
    }

    uint256 transferAmount = amount - taxAmount;

    balanceOf[sender] -= amount;
    balanceOf[recipient] += transferAmount;

    if (taxAmount > 0) {
      balanceOf[burningWallet] += taxAmount;
    }

    emit Transfer(sender, recipient, transferAmount);

    if (isSell(sender)) {
      lastBlockSellTax = block.number;
    } else {
      lastBlockBuyTax = block.number;
    }
  }

  function isSell(address sender) internal view returns (bool) {
    return sender != owner && sender != burningWallet;
  }

  function renounceOwnership() external onlyOwner {
    owner = address(0);
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can call this function.");
    _;
  }
}
