// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";



contract MintableUpgradeable is ERC721Upgradeable, OwnableUpgradeable {
    using StringsUpgradeable for uint256;

    string public baseURI;

    uint256 private _value;

    event BaseURIChanged(string newBaseURI);
    event RootChanged(bytes32 newRoot);

    error URIQueryForNonexistentToken();

    function initialize(string memory name, string memory symbol, string memory uri) initializer public {
        __ERC721_init(name, symbol);
        __Ownable_init();
        baseURI = uri;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable) returns (bool) {
        return
            super.supportsInterface(interfaceId);
    }

    function mint(address to) external onlyOwner {
        _value += 1;
        _safeMint(to, _value);
    }

    function exists(uint256 tokenId) public view virtual returns (bool) {
        return _exists(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    function setTokenURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
        emit BaseURIChanged(_baseURI);
    }
}


contract MintableUpgradeableV2 is ERC721Upgradeable, OwnableUpgradeable {
    using StringsUpgradeable for uint256;

    string public baseURI;

    uint256 private _value;

    event BaseURIChanged(string newBaseURI);
    event RootChanged(bytes32 newRoot);

    error URIQueryForNonexistentToken();

    function initialize(string memory name, string memory symbol, string memory uri) initializer public {
        __ERC721_init(name, symbol);
        __Ownable_init();
        baseURI = uri;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable) returns (bool) {
        return
            super.supportsInterface(interfaceId);
    }

    function mint(address to) external onlyOwner {

        _value += 1;
        _safeMint(to, _value);
    }

    function mintMany(address to, uint256 amount) external onlyOwner {

        for (uint256 i = 0; i < amount; i+=1) {
            _value += 1;
            _safeMint(to, _value);
        }
    }

    function mintBatch(address[] calldata addrs) external onlyOwner {

        for (uint256 i = 0; i < addrs.length; i+=1) {
            _value += 1;
            _safeMint(addrs[i], _value);
        }
    }

    function exists(uint256 tokenId) public view virtual returns (bool) {
        return _exists(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return 'nope';
    }

    function setTokenURI(string memory _baseURI) external onlyOwner {

        baseURI = _baseURI;
        emit BaseURIChanged(_baseURI);
    }
}

