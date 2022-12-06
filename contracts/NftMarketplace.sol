// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Imports
// -------------------------------
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// Custom Errors
// -------------------------------
error NftMarketplace__PriceMustBeAboveZero();
error NftMarketplace__NotApprovedForSelling();
error NftMarketplace__AlreadyListed(address nftAddress, uint256 tokenId);
error NftMarketplace__NotOwner();

// Contract
// -------------------------------
contract NftMarketplace {
    // Type Declarations
    struct Listing {
        uint256 price;
        address seller;
    }

    // Events
    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    // State Variables

    mapping(address => mapping(uint256 => Listing)) private s_listings;

    // Modifiers
    modifier notListed(
        address nftAddress,
        uint256 tokenId,
        address owner
    ) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price > 0) {
            revert NftMarketplace__AlreadyListed(nftAddress, tokenId);
        }
        _;
    }
    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NftMarketplace__NotOwner();
        }
        _;
    }

    // Main Functions
    // -------------------------------

    /*
      @notice Method for listing your NFT on the marketplace
      @param nftAddress: Address of the NFT Contract
      @param tokenId: The Token ID of the NFT you want to list
      @param price: sale price of the listed NFT
    */
    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external notListed(nftAddress, tokenId, msg.sender) isOwner(nftAddress, tokenId, msg.sender) {
        if (price <= 0) {
            revert NftMarketplace__PriceMustBeAboveZero();
        }

        IERC721 nft = IERC721(nftAddress);

        if (nft.getApproved(tokenId) != address(this)) {
            revert NftMarketplace__NotApprovedForSelling();
        }

        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }
}
