// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBasedRandomness {
    struct RandomRequest {
        uint256 requestBlock;
        uint256 maxNumber;
        bytes32 cumulativeHash;
        address requester;
        address trigger;
        bytes32 previousBlockHash;
        bytes32 baseEntropyHash;
        bool includeZero;
    }

    function BASE_ENTROPY() external view returns (address);
    function MAX_NUMBER_LIMIT() external view returns (uint256);
    function randomRequests(uint256 requestId) external view returns (RandomRequest memory);

    function prepareRandomNumbers(uint256[] calldata maxNumbers, bytes32 initialCumulativeHash, bool includeZero) external returns (bytes32[] memory);
    function generateRandomNumbers(bytes32[] calldata requestIds) external returns (uint256[] memory);

    event RandomNumberRequested(uint256 indexed requestId, address indexed requester, uint256 maxNumber, bool includeZero);
    event RandomNumberGenerated(uint256 indexed requestId, address indexed requester, uint256 randomNumber);
}