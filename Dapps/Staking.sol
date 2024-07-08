// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

error TransferFailed();
error NeedsMoreThanZero();
contract staking is ReentrancyGuard{ 
    IERC20 public s_stakingToken;  // s_ for storage 
    IERC20 public s_rewardsToken;

    // this is rewqard token per second

    uint256 public constant REWARD_RATE=100;
    uint256 public s_lastUpdateTime;
    uint256 public s_rewarPerTokenStored;


    mapping(address => uint256) public s_userRewardPerTokenPaid;
    mapping(address => uint256) public s_rewards;

    uint256 private s_totalSupply;

    mapping(address => uint256) public s_balaces;

    event Staked(address indexed user, uint256 indexed amount);
    event withdrewStake(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);

    constructor(address stakingToken, address rewardsToken) {
        // IERC20 is skelton
        s_stakingToken = IERC20(stakingToken);
        s_rewardsToken = IERC20(rewardsToken);
    }
    
    // how much reward per token get based on how long its been in the contract
    function rewardPerToken() public view returns(uint256) {
        if(s_totalSupply == 0) {
            return s_rewarPerTokenStored;
        }

        return s_rewarPerTokenStored+(((block.timestamp-s_lastUpdateTime)*REWARD_RATE*1e18)/s_totalSupply);
        /* dayanmic reward calculator
            A stake -- 1 Jan 
            claim reward o JAN 20 
            if annual IR = 20% | 366 - 20%  
        */
    }

    function earned(address account) public view returns(uint256) {
        return ((s_balaces[account]*(rewardPerToken() - s_userRewardPerTokenPaid[account]))/1e18) + s_rewards[account];

        /**
        satked = 100 
        rewared = 20 
        total = 120 
        profit  = 120 - 100 
        */
    }


    function stake(uint256 amount) external updateReward(msg.sender) nonReentrant moreThanZero(amount) {
        s_totalSupply+=amount;
        s_balaces[msg.sender]+=amount;
        emit Staked(msg.sender, amount);
        bool success = s_stakingToken.transfer(address(this), amount);
        if(!success) {
            revert TransferFailed();
        }
    }

    function withdraw(uint256 amount) external nonReentrant updateReward(msg.sender) {
        s_totalSupply-=amount;
        s_balaces[msg.sender] -= amount;
        emit withdrewStake(msg.sender, amount);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if(!success) {
            revert TransferFailed();
        }
    }

    function claimReward() external  nonReentrant updateReward(msg.sender) {
        uint256 reward  =s_rewards[msg.sender];
        s_rewards[msg.sender] = 0;
        emit RewardsClaimed(msg.sender, reward);
        bool success = s_rewardsToken.transfer(msg.sender, reward);
        if(!success) {
            revert TransferFailed();
        }
    }

    modifier updateReward(address account) {
        s_rewarPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewarPerTokenStored;
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if(amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }

    function getStaked(address account) public view returns (uint256) {
        return s_balaces[account];
    }
}
