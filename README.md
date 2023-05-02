# Meta Data Updatable

This package will help ERC721 Smart contracts to easiliy handle metadata updates

Setup:


```shell
yarn add aurelianoa/meta-data-updatable
npm install aurelianoa/meta-data-updatable
pnpm install aurelianoa/meta-data-updatable
```

In your ERC721 Solitidy Smart Contract:

```shell
import { MetadataUpdatable } from "./meta-data-updatable/contracts/MetadataUpdatable.sol";
```

And then usen the functions 


```shell
/// Update variant
/// @notice the holder can update the gender metadata of the given token
/// @param tokenId uint256
/// @param variant string
function updateVariant(uint256 tokenId, string memory variant) external payable {
    require(isMetadataRevealed(), "Metadata not revealed yet");
    require(ownerOf(tokenId) == msg.sender, "you dont own this token");
    require(msg.value == getVariantPrice(variant), "wrong ETH Sent");
    _setSelectedVariant(tokenId,  variant);
}

/// get tokenMetadata
/// @notice it will use the MetadataUpdatable
/// @param tokenId uint256
/// @return string
function tokenURI(uint256 tokenId) public view override(ERC721A, IERC721A) returns (string memory) {
    require(_exists(tokenId), "Token does not exist");

    return getTokenURI(tokenId);
}
```
Then manage the variants and url metadata with the functions:

```shell
function setBaseURI(string calldata uri)
```

```shell
function setVariant(string memory variant, string memory seed, uint256 price, bool active)
```

```shell
function setRevealedBaseURI(string calldata revealedBaseURI)
```

```shell
function setReveal(bool _isRevealed)
```

Note: you can add a price to each vartiant if you wan to ecourage "variant payable upgrades"

