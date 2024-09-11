// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IBasedEntrophy.sol";


// crafted with ❤️  by BasedToschi

// This contract provides a general-purpose random number generation system for on-chain use.

// It uses a combination of external entropy, block information, and user-provided data to create
// unpredictable and verifiable random numbers.

// Unpredictability is ensured by using fixed data during the request, and after four blocks, 
// the unpredictable hashes of the next three subsequent blocks.

// Thanks to this unpredictable data, the random number remains unknown at the time of the request, 
// achieving true on-chain randomization without any off-chain oracle interaction.

// Implementation guide:

// BASED RANDOMNESS IS A 2 STEPS PROCESS:

// 1. To request random numbers:
//    a. Prepare an array of maxNumbers, where each maxNumber corresponds to one Request ID for a random number. 
//      The upper bound for each random number is 2**120 (VERY BIG).
//    b. OPTIONAL: For more unpredictability, generate an initialCumulativeHash (can be any unique bytes32 value), 
//      or you can just use 0.
//    c. Call prepareRandomNumbers() with these parameters
//    d. Implement a custom logic to store the returned requestIds in bytes32.

// 2. To generate random numbers:
//    a. Wait for at least 4 blocks to pass
//    b. Call generateRandomNumbers() with the stored requestIds (bytes32) to retrieve your random numbers. 
//      You can also request the numbers separately, without being required to follow the same logic as in step 1.


contract BasedRandomness {
    address public immutable BASE_ENTROPY = 0x4E31Fb2d6070cd58A399FDd84b86d661476753b6;
    
    uint256 public constant MAX_NUMBER_LIMIT = 2**120;

    struct RandomRequest {
        uint256 requestBlock;
        address requester;
        uint256 maxNumber;
        bool includeZero;
    }

    mapping(bytes32 => RandomRequest) public randomRequests;

    event RandomNumberRequested(bytes32 indexed requestId, address indexed requester, uint256 maxNumber, bool includeZero);
    event RandomNumberGenerated(bytes32 indexed requestId, address indexed requester, uint256 randomNumber);

    function prepareRandomNumbers(uint256[] calldata maxNumbers, bytes32 initialCumulativeHash, bool includeZero) external returns (bytes32[] memory) {
        bytes32[] memory requestIds = new bytes32[](maxNumbers.length);
        bytes32 baseEntropyHash = IBasedEntrophy(BASE_ENTROPY).getEntropy();
        bytes32 previousBlockHash = blockhash(block.number - 1);
        bytes32 rollingHash = initialCumulativeHash;

        for (uint256 i = 0; i < maxNumbers.length; i++) {
            require(maxNumbers[i] > 0 && maxNumbers[i] <= MAX_NUMBER_LIMIT, "Invalid maxNumber");
            
            rollingHash = keccak256(abi.encodePacked(rollingHash, maxNumbers[i], i));
            
            bytes32 requestId = keccak256(abi.encodePacked(
                maxNumbers[i],
                rollingHash,
                msg.sender,
                tx.origin,
                previousBlockHash,
                baseEntropyHash,
                includeZero,
                block.number,
                block.prevrandao,
                i
            ));

            randomRequests[requestId] = RandomRequest({
                requestBlock: block.number,
                requester: msg.sender,
                maxNumber: maxNumbers[i],
                includeZero: includeZero
            });

            requestIds[i] = requestId;
            emit RandomNumberRequested(requestId, msg.sender, maxNumbers[i], includeZero);
        }

        return requestIds;
    }

    function generateRandomNumbers(bytes32[] calldata requestIds) external returns (uint256[] memory) {
        uint256[] memory randomNumbers = new uint256[](requestIds.length);

        for (uint256 i = 0; i < requestIds.length; i++) {
            RandomRequest memory request = randomRequests[requestIds[i]];
            require(request.requester != address(0), "Invalid request ID");
            require(request.requester == msg.sender, "Only the original requester can generate the number");
            require(block.number >= request.requestBlock + 4, "Must wait 4 blocks before generating");

            bytes32 blockHashesCumulative = bytes32(0);
            for (uint j = 1; j <= 3; j++) {
                blockHashesCumulative = keccak256(abi.encodePacked(blockHashesCumulative, blockhash(request.requestBlock + j)));
            }

            uint256 randomSource = uint256(keccak256(abi.encodePacked(
                requestIds[i],
                blockHashesCumulative
            )));

            if (request.includeZero) {
                randomNumbers[i] = randomSource % (request.maxNumber + 1);  // 0 to maxNumber (inclusive)
            } else {
                randomNumbers[i] = (randomSource % request.maxNumber) + 1;  // 1 to maxNumber (inclusive)
            }

            emit RandomNumberGenerated(requestIds[i], msg.sender, randomNumbers[i]);
            delete randomRequests[requestIds[i]];
        }

        return randomNumbers;
    }
}