# Based Randomness

BasedRandomness is a general-purpose random number generation (RNG) system designed for on-chain applications. It generates unpredictable and verifiable random numbers without depending on off-chain oracles, ensuring greater security and decentralization. With BasedRandomness, builders can now create RNG solutions for free, empowering on-chain games, decision-making processes, and a wide variety of other use cases—all without the need for centralized RNG systems.

## Randomness Security

BasedRandomness ensures unpredictability and security through several mechanisms:

1. **External Entropy**: It uses an external entropy source (BASE_ENTROPY) to add unpredictability to the random number generation process.
2. **Block Information**: The contract incorporates block data (number, hash, prevrandao) to make the randomness dependent on the blockchain state.
3. **User-Provided Data**: The initialCumulativeHash allows users to add their own additional source of randomness.
4. **Time Delay**: The requirement to wait for 4 blocks between requesting and generating random numbers and using the block hash of the 3 next blocks after the randomness request, prevents manipulation of block data to influence the outcome.
5. **Cumulative Hashing**: The contract uses a rolling hash that incorporates data from multiple blocks, making it resistant to single-block manipulations.
6. **One-Time Use**: Each request ID can only be used once, preventing replay attacks.

These features combine to create a system that is resistant to various forms of manipulation and provides a high degree of unpredictability for on-chain random number generation.

## Features

- On-chain Random Number Generation
- Unpredictability
- Multi Number Generation
- General Purposes Design

## How is it work

To achieve truly fair and unpredictable randomness, the process involves two key steps:

1. To request random numbers:
- a. Prepare an array of maxNumbers, where each maxNumber corresponds to one Request ID for a random number. The upper bound for each random number is 2**120 (VERY BIG).
- b. Optional: For more unpredictability, generate an initialCumulativeHash (can be any unique bytes32 value), or you can just use 0x0000000000000000000000000000000000000000000000000000000000000000.
- c. Call prepareRandomNumbers() with these parameters
- d. Implement a custom logic to store the returned requestIds in bytes32.

2. To generate random numbers:
- a. Wait for at least 4 blocks to pass
- b. Call generateRandomNumbers() with the stored requestIds (bytes32) to retrieve your random numbers. You can also request the numbers separately, without being required to follow the same logic as in step 1.

## How to implement

### Addresses

In every network you find and can use the Based Randomness interacting with this address: **0x656cd3a1cef30f475cbba68bc5764f7d1c4c884a**

Currently Based Randomness is deployed in:

[Base](https://basescan.org/address/0x656cd3a1cef30f475cbba68bc5764f7d1c4c884a) |
[Base Sepolia](https://sepolia.basescan.org/address/0x656cd3a1cef30f475cbba68bc5764f7d1c4c884a) |
[Optimism](https://optimistic.etherscan.io/address/0x656cd3a1cef30f475cbba68bc5764f7d1c4c884a) |
[Optimism Sepolia](https://sepolia-optimism.etherscan.io/address/0x656cd3a1cef30f475cbba68bc5764f7d1c4c884a)

### Implementation Guide

Import in your contract the IBasedRandomness interface

```solidity
import "./interfaces/IBasedRandomness.sol";
```

Declare a state variable for the BasedRandomness contract:

```solidity
IBasedRandomness public basedRandomness;
```

In your contract's constructor or an initialization function, set the address of the deployed BasedRandomness contract:

```solidity
  constructor(address _basedRandomnessAddress) {
    basedRandomness = IBasedRandomness(_basedRandomnessAddress);
}
```

1. Request Random Numbers
- You can easily request the generation of one or more random numbers, and optionally send a CumulativeHash to further enhance the level of unpredictability.
- The **maxNumbers** is a uint256 parameter that defines the upper limit of the random number generation.
- The **IncludeZero** is a boolean parameter. When set to true, it includes 0 in the range of possible outcomes during the number generation process.
- For example, if **maxNumbers** is set to 100 and **IncludeZero** true, the system will generate a number between 0 and 100.
- Store the IDs received for the step 2

```solidity
function requestRandomNumbers(uint256[] memory maxNumbers, bool includeZero) external {
    bytes32 initialCumulativeHash = 0; // Or generate a unique value for more unpredictability
    bytes32[] memory requestIds = basedRandomness.prepareRandomNumbers(maxNumbers, initialCumulativeHash, includeZero);
    
    // Store requestIds for later use
    for (uint256 i = 0; i < requestIds.length; i++) {
        // Store each requestId, e.g., in a mapping
        randomRequests[i] = requestIds[i];
    }
}
```

2. Generate Random Numbers

- After 4 blocks you can call the **generateRandomNumbers** functions with the IDs and receive the random numbers requested.

```solidity
function generateRandomNumbers() external {
    bytes32[] memory storedRequestIds = new bytes32[](/* number of stored requestIds */);
    // Populate storedRequestIds with the previously stored requestIds
    
    uint256[] memory randomNumbers = basedRandomness.generateRandomNumbers(storedRequestIds);
    
    // Use the generated random numbers
    for (uint256 i = 0; i < randomNumbers.length; i++) {
        // Process each random number
    }
}
```

### Licence
This project is licensed under the MIT License. So you can both use it and improving it freerly.

