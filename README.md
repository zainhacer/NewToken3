# NewToken3

```solidity
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
```
These variables define the basic properties of the token. The `name` variable is the name of the token, the `symbol` variable is the symbol of the token, the `decimals` variable is the number of decimals the token has, and the `totalSupply` variable is the total supply of the token.

```
address public owner;
```
This variable defines the owner of the token contract. The owner of the token contract has the ability to call certain functions on the contract, such as the `renounceOwnership()` function.

```
mapping(address => uint256) public balanceOf;
mapping(address => mapping(address => uint256)) public allowance;
```
These mappings are used to track the balances of tokens and the allowances of tokens. The `balanceOf[address]` mapping is used to track the balance of tokens for a given address. The `allowance[address][address]` mapping is used to track the allowance of tokens for a given owner and spender.

```
uint256 public buyTax;
uint256 public sellTax;
```
These variables define the buy tax and sell tax for the token. The buy tax is a percentage of the amount of tokens being bought that is sent to the burning wallet. The sell tax is a percentage of the amount of tokens being sold that is sent to the burning wallet.

```
address public burningWallet;
```
This variable defines the burning wallet address. The burning wallet is an address that is used to burn tokens, which reduces the circulating supply of the token.

```
uint256 public lastBlockBuyTax;
uint256 public lastBlockSellTax;
```
These variables are used to track the last block in which a buy or sell tax was applied. This is used to prevent the buy and sell taxes from being applied more than once per 10 blocks.

```
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
```
These events are emitted when tokens are transferred or when an allowance is approved.

```
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
```
This is the constructor for the token contract. The constructor is used to initialize the state of the contract.

```
function transfer(address recipient, uint256 amount) external returns (bool) {
  _transfer(msg.sender, recipient, amount);
  return true;
}
```
This function is used to transfer tokens from one address to another. The `_transfer()` function is called internally by the `transfer()` function.

```
function approve(address spender, uint256 amount) external returns (bool) {
  allowance[msg.sender][spender] = amount;
  emit Approval(msg.sender, spender, amount);
  return true;
}
```
This function is used to approve a spender to transfer tokens on behalf of the caller.

```
function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
  allowance[sender][msg.sender] -= amount;
  _transfer(sender, recipient, amount);
  return true;
}
```
This function is used to transfer tokens from one address to another on behalf of a third party.

```
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
