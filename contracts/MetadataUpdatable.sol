//SPDX-License-Identifier: Unlicense

/// @notice MetadataUpadable
/// @author Aureliano Arcon <@aurelarcon> <aurelianoa.eth>
/// @dev This will handle all the necesary functions for the metadata be dynamic

pragma solidity ^0.8.17;

abstract contract MetadataUpdatable {
    
    bool private isRevealed = false;
    string private _contractURI = "";
    string private tokenBaseURI = "";
    string private tokenRevealedBaseURI = "";
    string private tokenBucketURI = "";
    string private fileExtension = "";

    /// @dev struct of a variant
    struct Variant {
        /// @dev the seed of the metadata (CID)
        string seed;

        /// @dev price if aplicable
        uint256 price;

        /// @dev if is active for swap
        bool active;
    }

    /// @dev  mapping (key => variant)
    mapping(string => Variant) private variantMetadata;
    /// @dev mapping(tokenId => key)
    mapping(uint256 => string) private selectedVariant;

    /// events
    event VariantUpdated(uint256 tokenId, string variant);
    event ContractURIUpdated(address indexed _account);
    event BaseURIUpdated(address indexed _account);
    event IsRevealedBaseURI(address indexed _account);

    /// errors
    error NotValidVariantProvided(string variant);

    /// middleware to be overriden
    /// @notice this will be called by all the administrative functions
    /// @dev this will be overriden by the child contract
    function middleware() internal virtual returns (bool) {}

    /// Modifier to be applied in some adminnistrative functions
    modifier onlyPermisioned() {
        require(middleware(), "Not permisioned");
        _;
    }

    /// Set the variant for a token
    /// @param tokenId uint256
    /// @param variant string
    function _setSelectedVariant(uint256 tokenId, string memory variant) internal {
        if(!isValidVariant(variant)) {
            revert NotValidVariantProvided(variant);
        }
        selectedVariant[tokenId] = variant;

        emit VariantUpdated(tokenId, variant);
    }

    /// Get seed by variant
    /// @param variant string
    /// @return string
    function getSeedByVariant(string memory variant) internal view returns (string memory) {
        return variantMetadata[variant].seed;
    }

    /// will construct the resulted metadata URI String
    /// @notice this will be called by the tokenUri
    /// @param tokenId uint256
    function getTokenURI(uint256 tokenId) internal view returns (string memory) {
        if(!isRevealed) {
            return tokenBaseURI;
        } 
        string memory key = selectedVariant[tokenId];
        string memory bucketURI = tokenBucketURI;
        string memory postURI = "";
        string memory tokenIdString = uint2str(tokenId);
        if(bytes(bucketURI).length > 0) {
            postURI = string(abi.encodePacked(tokenBucketURI, "/"));
        }
        return string(abi.encodePacked(
            tokenRevealedBaseURI,  
            variantMetadata[key].seed, 
            "/", 
            postURI,
            tokenIdString,
            fileExtension
            ));
    }

    /// EXTERNAL FUNCTIONS

    /// create or edit a variant
    /// @param variant string
    /// @param seed string
    /// @param price uint256
    function setVariant(string memory variant, string memory seed, uint256 price, bool active) external onlyPermisioned {
        Variant memory _variant = Variant (
            seed,
            price,
            active
        );
        variantMetadata[variant] = _variant;
    }

    /// Set file extension
    /// @param _fileExtension string
    function setFileExtension(string memory _fileExtension) external onlyPermisioned {
        fileExtension = _fileExtension;
    }

    /// Set if the metadata is revealed
    /// @param _isRevealed bool
    function setReveal(bool _isRevealed) external onlyPermisioned {
        isRevealed = _isRevealed;
    }

    /// Set the contract URI
    /// @param uri string
    function setContractURI(string calldata uri) external onlyPermisioned {
        _contractURI = uri;

        emit ContractURIUpdated(msg.sender);
    }

    /// set the base URI
    /// @param uri string
    function setBaseURI(string calldata uri) external onlyPermisioned {
        tokenBaseURI = uri;

        emit BaseURIUpdated(msg.sender);
    }

    /// set the revealed base URI
    /// @param revealedBaseURI string
    function setRevealedBaseURI(string calldata revealedBaseURI) external onlyPermisioned {
        tokenRevealedBaseURI = revealedBaseURI;

        emit IsRevealedBaseURI(msg.sender);
    }

    /// set the revealed bucket URI
    /// @param bucketURI string
    function setRevealedBucketURI(string calldata bucketURI) external onlyPermisioned {
        tokenBucketURI = bucketURI;
    }
    /// get the contract URI
    /// @return string
    /// @dev this was required by OpenSea in the past. Will be deprecated in later versions
    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    /// HELPERS

    /// @dev check if the variant is valid
    /// @param variant string
    /// @return bool
    function isValidVariant(string memory variant) internal view returns (bool) {
        return variantMetadata[variant].active;
    }

    /// get the variant price
    /// @param variant string
    /// @return uint256
    function getVariantPrice(string memory variant) internal view returns (uint256) {
        return variantMetadata[variant].price;
    }
    
    /// chek if the metadata is revealed
    /// @return bool
    function isMetadataRevealed() public view returns (bool) {
        return isRevealed;
    }

    /// @dev internal function to convert uint to string
    /// @param _i uint
    /// @return _uintAsString string
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}