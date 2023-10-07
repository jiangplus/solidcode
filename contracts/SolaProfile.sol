// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


contract SolaProfile is ERC721Upgradeable, UUPSUpgradeable, OwnableUpgradeable {
    using StringsUpgradeable for uint256;

    string public baseURI;
    uint256 public chainspace;

    uint256 private _profileCounter;
    uint256 private _chainspace_step = 256;

    event BaseURIChanged(string newBaseURI);

    error QueryForNonexistentToken();

    function initialize(string memory name, string memory symbol, string memory uri, uint256 _chainspace) initializer public {
        __ERC721_init(name, symbol);
        __Ownable_init();
        baseURI = uri;
        chainspace = _chainspace;
        _profileCounter = chainspace;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    mapping(address => bool) public profileCreatorList;
    mapping(uint256 => bytes) profileMetadataList;

    function setProfileCreator(address addr, bool status)
        onlyOwner
        external
    {
        profileCreatorList[msg.sender] = status;
    }

    function createProfile(address to, string calldata imageURI)
        external
        // override
        // whenNotPaused
        returns (uint256)
    {
        require(profileCreatorList[msg.sender], "creator not authorized");
        _profileCounter += _chainspace_step;
        uint256 profileId = ++_profileCounter;
        profileMetadataList[profileId] = bytes(imageURI);
        _mint(to, profileId);
        return profileId;
    }

    function exists(uint256 tokenId) public view virtual returns (bool) {
        return _exists(tokenId);
    }

    // function totalSupply() external view returns (uint256);

    // function burn(uint256 tokenId) external;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert QueryForNonexistentToken();

        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    function setTokenURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
        emit BaseURIChanged(_baseURI);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
