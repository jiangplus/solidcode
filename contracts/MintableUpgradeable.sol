// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";


contract MintableUpgradeable is ERC721Upgradeable, AccessControlUpgradeable {
    using StringsUpgradeable for uint256;

    string public baseURI;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER");

    uint256 private _value;

    event BaseURIChanged(string newBaseURI);
    event RootChanged(bytes32 newRoot);

    error URIQueryForNonexistentToken();

    function initialize(string memory name, string memory symbol, string memory uri) initializer public {
    // constructor(string memory name, string memory symbol, string memory _baseURI) ERC721(name, symbol) {
        __ERC721_init(name, symbol);
        __AccessControl_init();
        baseURI = uri;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return
            super.supportsInterface(interfaceId);
    }

    function mint(address to) external {
        require(hasRole(MINTER_ROLE, msg.sender), "caller is not a minter");

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

    function setTokenURI(string memory _baseURI) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "caller is not a minter");

        baseURI = _baseURI;
        emit BaseURIChanged(_baseURI);
    }
}


contract MintableUpgradeableV2 is ERC721Upgradeable, AccessControlUpgradeable {
    using StringsUpgradeable for uint256;

    string public baseURI;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER");

    uint256 private _value;

    event BaseURIChanged(string newBaseURI);
    event RootChanged(bytes32 newRoot);

    error URIQueryForNonexistentToken();

    function initialize(string memory name, string memory symbol, string memory uri) initializer public {
    // constructor(string memory name, string memory symbol, string memory _baseURI) ERC721(name, symbol) {
        __ERC721_init(name, symbol);
        __AccessControl_init();
        baseURI = uri;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return
            super.supportsInterface(interfaceId);
    }

    function mint(address to) external {
        require(hasRole(MINTER_ROLE, msg.sender), "caller is not a minter");

        _value += 1;
        _safeMint(to, _value);
    }

    function mintMany(address to, uint256 amount) external {
        require(hasRole(MINTER_ROLE, msg.sender), "caller is not a minter");

        for (uint256 i = 0; i < amount; i+=1) {
            _value += 1;
            _safeMint(to, _value);
        }
    }

    function mintBatch(address[] calldata addrs) external {
        require(hasRole(MINTER_ROLE, msg.sender), "caller is not a minter");

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

    function setTokenURI(string memory _baseURI) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "caller is not a minter");

        baseURI = _baseURI;
        emit BaseURIChanged(_baseURI);
    }
}

