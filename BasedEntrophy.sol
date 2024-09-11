// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BasedEntrophy {
    address private immutable USDC_TOKEN = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address private immutable WETH_TOKEN = 0x4200000000000000000000000000000000000006;
    address private immutable UNI_USDC_ETH = 0xd0b53D9277642d899DF5C87A3966A349A798F224;
    address private immutable UNI_USDC_ETH_V2 = 0x88A43bbDF9D098eEC7bCEda4e2494615dfD9bB9C;
    address private immutable UNI_USDC_ETH_03 = 0x6c561B446416E1A00E8E93E221854d6eA4171372;


    function getEntropy() external view  returns (bytes32) {
        return keccak256(abi.encodePacked(
            IERC20(USDC_TOKEN).balanceOf(UNI_USDC_ETH),
            IERC20(WETH_TOKEN).balanceOf(UNI_USDC_ETH),
            IERC20(USDC_TOKEN).balanceOf(UNI_USDC_ETH_V2),
            IERC20(WETH_TOKEN).balanceOf(UNI_USDC_ETH_V2),
            IERC20(USDC_TOKEN).balanceOf(UNI_USDC_ETH_03),
            IERC20(WETH_TOKEN).balanceOf(UNI_USDC_ETH_03),
            IERC20(USDC_TOKEN).totalSupply(),
            IERC20(WETH_TOKEN).totalSupply()
        ));
    }
}