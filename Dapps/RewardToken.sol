// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
    constructor() ERC20 ("Reward", "RT"){
     _mint(msg.sender, 1000000*10**18);
    }
}

/**
* 1. deploye the reward token - after deployment, copy the deployed address. - 0xb1ce3119fc514B0b9aCAbE8f58FA32F5eA74f62D
        transfer some reward tokens from owner of RT cotract to 3-4 remix account
* 2. uset the deployed address to deplye the staking smart contract 
* 2.1. paste RT address in cnistructore of Staking smart contract twice
* 3. 
* 4. transfer amount to staking.sol contract 
* 5. now start staking amount in this smart cintract - 

copy ddress af any amount and paste it in the balanceof reawardtoke.sol
claim the reward funcaation  - can withdraw rewards genaerated by staking dapps  
withdraws fuciton - is used to withdraw staked amount
*/