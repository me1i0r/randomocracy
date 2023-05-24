//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// Useful for debugging. Remove when deploying to a live network.
import "hardhat/console.sol";
// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
// import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * A smart contract that allows changing a state variable of the contract and tracking the changes
 * It also allows the owner to withdraw the Ether in the contract
 * @author BuidlGuidl
 */
contract YourContract {

    // State Variables
    address public immutable owner;
    string public greeting = "Building Unstoppable Apps!!!";
    bool public premium = false;
    uint256 public totalCounter = 0;
    address[] public members = [
        address(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2),
        address(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db),
        address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB),
        address(0x617F2E2fD72FD9D5503197092aC168c91465E7f2),
        address(0x17F6AD8Ef982297579C203069C1DbfFE4348c372),
        address(0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C),
        address(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678),
        address(0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7),
        address(0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C),
        address(0x0BcdF3E67bCD4D98C5Bf1669D4A4FAA084EC574D)
    ];
    uint256 public sampleSize;
    address[] public sample;
    mapping(address => uint) public userGreetingCounter;

    // Events: a way to emit log statements from smart contract that can be listened to by external parties
    event GreetingChange(address indexed greetingSetter, string newGreeting, bool premium, uint256 value);

    // Constructor: Called once on contract deployment
    // Check packages/hardhat/deploy/00_deploy_your_contract.ts
    constructor(address _owner) {
        owner = _owner;
    }

    // Modifier: used to define a set of rules that must be met before or after a function is executed
    // Check the withdraw() function
    modifier isOwner() {
        // msg.sender: predefined variable that represents address of the account that called the current function
        require(msg.sender == owner, "Not the Owner");
        _;
    }

    /**
     * Function that allows anyone to change the state variable "greeting" of the contract and increase the counters
     *
     * @param _newGreeting (string memory) - new greeting to save on the contract
     */
    function setGreeting(string memory _newGreeting) public payable {
        // Print data to the hardhat chain console. Remove when deploying to a live network.
        console.log("Setting new greeting '%s' from %s",  _newGreeting, msg.sender);

        // Change state variables
        greeting = _newGreeting;
        totalCounter += 1;
        userGreetingCounter[msg.sender] += 1;

        // msg.value: built-in global variable that represents the amount of ether sent with the transaction
        if (msg.value > 0) {
            premium = true;
        } else {
            premium = false;
        }

        // emit: keyword used to trigger an event
        emit GreetingChange(msg.sender, _newGreeting, msg.value > 0, 0);
    }

    function calculateSampleSize(uint256 numMembers) public {
        uint256 zValue = 196; // for 95% confidence interval (z-score of 1.96 * 100)
        uint256 marginOfError = 5; // 5% margin of error
        uint256 populationSize = numMembers;
        uint256 p = 50; // probability of success in the population (50% for a binary choice)
        uint256 q = 100 - p; // probability of failure in the population
        uint256 S = (zValue * zValue * p * q) / (marginOfError * marginOfError * 10000);
        uint256 m = 10000;
        sampleSize = (S * m) / (m + ((S - 1) * m) / populationSize);
    }

    function selectRandomSample() public {
        // initialize the sample array
       // address[] memory _sample = new address[](sampleSize);
        
        calculateSampleSize(members.length);
        sample = new address[](sampleSize);

        // generate a random number using keccak256 hash function
        bytes32 hashVal = keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender));

        // loop sampleSize times to select random members
        uint256 remainingMembers = members.length;

        for (uint256 i = 0; i < sampleSize; i++) {
            // generate a random index using the hash value and loop counter
            uint256 index = uint256(hashVal) % remainingMembers;

            // assign the randomly selected member to the sample array
            sample[i] = members[index];

            // swap the selected member with the last unselected member
            remainingMembers--;
            members[index] = members[remainingMembers];
            members[remainingMembers] = sample[i];

            // update the hash value for the next iteration
            hashVal = keccak256(abi.encodePacked(hashVal, i, blockhash(block.number - 1), msg.sender));
        }
    }

    /**
     * Function that allows the owner to withdraw all the Ether in the contract
     * The function can only be called by the owner of the contract as defined by the isOwner modifier
     */
    function withdraw() isOwner public {
        (bool success,) = owner.call{value: address(this).balance}("");
        require(success, "Failed to send Ether");
    }

    /**
     * Function that allows the contract to receive ETH
     */
    receive() external payable {}
}
