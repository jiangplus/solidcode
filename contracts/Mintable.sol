// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Mintable is ERC721, Ownable {
    using Strings for uint256;

    string public baseURI;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER");

    uint256 private _value;

    event BaseURIChanged(string newBaseURI);
    event RootChanged(bytes32 newRoot);

    error URIQueryForNonexistentToken();

    constructor(string memory name, string memory symbol, string memory _baseURI) ERC721(name, symbol) {
        baseURI = _baseURI;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
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
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    function setTokenURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
        emit BaseURIChanged(_baseURI);
    }
}

