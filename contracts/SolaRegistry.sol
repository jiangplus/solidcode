// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract SolaProfile is ERC721EnumerableUpgradeable, UUPSUpgradeable, OwnableUpgradeable {
    using StringsUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;

    string public baseURI;
    uint256 public MIN_LENGTH;

    mapping(uint256 => uint256) public names;

    event NameRegistered(string name, uint256 node, address owner);

    event BaseURIChanged(string newBaseURI);

    error URIQueryForNonexistentToken();

    function initialize() initializer public {
      __ERC721_init("SolaProfile", "Profile");
      __Ownable_init();
      baseURI = "https://meta.sociallayer.im/nft/";
      _tokenIds.increment();
      MIN_LENGTH = 5;
     }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721EnumerableUpgradeable) returns (bool) {
        return interfaceId == type(ERC721EnumerableUpgradeable).interfaceId ||
            interfaceId == type(AccessControlUpgradeable).interfaceId ||
             super.supportsInterface(interfaceId);
     }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    // // return true if s contain only '0-9A-Za-z' & '-', and is not empty
    // // todo : optimize ifs
    // function validateDomain(string calldata s) internal pure returns(bool) {
    //     uint len = bytes(s).length;
    //     if (len == 0) return false;

    //     for (uint i = 0; i < len; i++) {
    //         uint8 b = uint8(bytes(s)[i]);

    //         // 0 ~ 9 -> 0x30 ~ 0x39
    //         // A ~ Z -> 0x41 ~ 0x5A
    //         // a ~ z -> 0x61 ~ 0x7A
    //         // -     -> 0x2d
    //         if (b == 0x2d) continue;

    //         if (b < 0x30) return false;
    //         if (b > 0x7A) return false;

    //         if (b <= 0x39) continue;
    //         if (b >= 0x61) continue;

    //         if ((0x41 <= b) && (b <= 0x5A)) continue;

    //         return false;
    //     }

    //     return true;
    // }

    function validateDomain(string calldata s) internal pure returns(bool) {
        uint len = bytes(s).length;
        for (uint i = 0; i < len; i++) {
            uint8 b = uint8(bytes(s)[i]);

            // 0 ~ 9 -> 0x30 ~ 0x39
            // A ~ Z -> 0x41 ~ 0x5A
            // a ~ z -> 0x61 ~ 0x7A
            // -     -> 0x2d
            if (b >= 0x30 && b <= 0x39 || b >= 0x61 && b <= 0x7A || b >= 0x41 && b <= 0x5A || b == 0x2d) continue;
            else return false;
        }

        return true;
    }

    function mint(string calldata name, address addr) external onlyOwner returns (uint256) {
        require(bytes(name).length >= MIN_LENGTH, "name too short");
        require(validateDomain(name), "name invalid");

        uint256 tokenId = _tokenIds.current();

        bytes32 label = keccak256(bytes(name));
        uint256 namehash = uint256(label);
        require(names[namehash] == 0, "name exists");
        names[namehash] = tokenId;

        _safeMint(addr, tokenId);

        emit NameRegistered(name, tokenId, addr);

        _tokenIds.increment();
        return tokenId;
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) public view virtual returns (bool) {
      return _isApprovedOrOwner(spender, tokenId);
    }

    function exists(uint256 tokenId) public view virtual returns (bool) {
        return _exists(tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId) || owner() == msg.sender, "ERC721: caller is not token owner nor minter");
        _burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    function setTokenURI(string memory _baseURI) external {
        require(owner() == msg.sender, "caller is not a minter");

        baseURI = _baseURI;
        emit BaseURIChanged(_baseURI);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }
}

contract SolaBadge is ERC721EnumerableUpgradeable {
    using StringsUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;

    event BadgeMetaUpdated(uint256 indexed tokenId, address indexed addr, address indexed profileAddr, uint256 profileId, bool transferable, bool revocable);
    event BadgeUpdated(uint256 indexed tokenId, address indexed addr, uint64 expirationTime, uint64 notBefore, uint64 weight);
    event WeightChanged(uint256 indexed tokenId, address indexed addr, uint64 amount);

    string public baseURI;
    address public profileAddr;
    uint256 public profileId;
    bool public transferable;
    bool public revocable;

    struct MetaRecord {
        uint64 expirationTime;
        uint64 notBefore;
        uint64 weight;
    }

    mapping(uint256 => MetaRecord) public metatable;

    function initialize(address _profileAddr, uint256 _profileId, bool _transferable, bool _revocable) initializer public {
        __ERC721_init("SolaBadge", "badge");
        baseURI = "https://meta.sociallayer.im/nft/";
        _tokenIds.increment();
        profileAddr = _profileAddr;
        profileId = _profileId;
        transferable = _transferable;
        revocable = _revocable;
     }

     function isController(address addr) public view returns (bool) {
        return SolaProfile(profileAddr).isApprovedOrOwner(addr, profileId);
     }

    function mint(address receiver) external returns (uint256) {
        require(isController(_msgSender()), "not controller");

        uint256 tokenId = _tokenIds.current();

        _safeMint(receiver, tokenId);

        _tokenIds.increment();
        return tokenId;
    }

    function mintWithData(address receiver, uint64 _expirationTime, uint64 _notBefore, uint64 _weight) external returns (uint256) {
        require(isController(_msgSender()), "not controller");
        require(_expirationTime >= _notBefore, "invalid expirationTime");

        uint256 tokenId = _tokenIds.current();

        _safeMint(receiver, tokenId);
        metatable[tokenId].expirationTime = _expirationTime;
        metatable[tokenId].notBefore = _notBefore;
        metatable[tokenId].weight = _weight;
        emit BadgeUpdated(tokenId, _msgSender(), _expirationTime, _notBefore, _weight);

        _tokenIds.increment();
        return tokenId;
    }

    function exists(uint256 tokenId) public view virtual returns (bool) {
        return _exists(tokenId);
    }

    function expirationTime(uint256 tokenId) public view virtual returns (uint64) {
        return metatable[tokenId].expirationTime;
    }

    function notBefore(uint256 tokenId) public view virtual returns (uint64) {
        return metatable[tokenId].notBefore;
    }

    function weight(uint256 tokenId) public view virtual returns (uint64) {
        return metatable[tokenId].weight;
    }

    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }

    function revoke(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(revocable, "token not revocable");
        require(isController(_msgSender()), "not controller");
        _burn(tokenId);
    }

    function reduceWeight(uint256 tokenId, uint64 amount) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId)
            || revocable && isController(_msgSender()), "ERC721: caller is not token owner or approved");
        uint64 _weight = metatable[tokenId].weight;
        require(_weight >= amount && amount > 0, "invalid amount");

        unchecked {
            metatable[tokenId].weight = _weight - amount;
        }

        emit WeightChanged(tokenId, _msgSender(), amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        // if (!transferable && to != address(0)) {
        //     revert("non-transferable");
        // }
        require(transferable || to == address(0) || from == address(0), "token not transferable");
    }
}

contract SolaPoint is ERC20Upgradeable {

    address public profileAddr;
    uint256 public profileId;
    bool public transferable;
    bool public revocable;

    function initialize(address _profileAddr, uint256 _profileId, bool _transferable, bool _revocable) initializer public {
        __ERC20_init("SolaPoint", "point");
        profileAddr = _profileAddr;
        profileId = _profileId;
        transferable = _transferable;
        revocable = _revocable;
    }

    function isController(address addr) public view returns (bool) {
        return SolaProfile(profileAddr).isApprovedOrOwner(addr, profileId);
    }

    function mint(address receiver, uint256 amount) external {
        require(isController(_msgSender()), "not controller");
        _mint(receiver, amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function revoke(address addr, uint256 amount) public virtual {
        require(revocable, "token not revocable");
        require(isController(_msgSender()), "not controller");
        _burn(addr, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(transferable || to == address(0) || from == address(0), "token not transferable");
        // if (!transferable && to != address(0)) {
        //     revert("non-transferable");
        // }
    }
}

contract SolaERC721BadgeWrapper {
    // todo : impl IERC721ReceiverUpgradeable

    ERC721EnumerableUpgradeable public input;
    SolaBadge public output;

    mapping(uint256 => uint256) public wrapped;

    constructor(address _input, address _output) {
        input = ERC721EnumerableUpgradeable(_input);
        output = SolaBadge(_output);
    }

    function wrap(uint256 inputTokenId, address receiver) external returns (uint256) {
        // check msg sender is inputTokenId owner
        require(input.ownerOf(inputTokenId) == msg.sender, "caller is not token owner");
        input.transferFrom(input.ownerOf(inputTokenId), address(this), inputTokenId);
        uint256 newTokenId = SolaBadge(output).mint(receiver);
        wrapped[newTokenId] = inputTokenId;
        // todo : check tokenId not zero
        return newTokenId;
    }

    function unwrap(uint256 outputTokenId, address receiver) external returns (uint256) {
        // check msg sender is outputTokenId owner
        require(output.ownerOf(outputTokenId) == msg.sender, "caller is not token owner");
        uint256 inputTokenId = wrapped[outputTokenId];
        // todo : burn outputTokenId
        // todo : support SBT badge
        output.transferFrom(msg.sender, address(this), outputTokenId); // todo : burn outputTokenId
        input.transferFrom(address(this), receiver, inputTokenId);
        delete wrapped[outputTokenId];
        return inputTokenId;
    }

}

contract SolaERC20PointWrapper {
    ERC20 public input;
    SolaPoint public output;

    mapping(address => uint256) public wrapped;

    constructor(address _input, address _output) {
        input = ERC20(_input);
        output = SolaPoint(_output);
    }

    function wrap(uint256 inputAmount, address receiver) external returns (uint256) {
        // check msg sender is inputTokenId owner
        require(input.allowance(receiver, address(this)) >= inputAmount, "caller is not token owner");
        input.transferFrom(msg.sender, address(this), inputAmount);
        output.mint(receiver, inputAmount);
        wrapped[receiver] += inputAmount;
        // todo : check tokenId not zero
        return inputAmount;
    }

    function unwrap(uint256 outputAmount, address receiver) external returns (uint256) {
        require(wrapped[receiver] >= outputAmount, "caller has no sufficient amount");
        require(output.allowance(receiver, address(this)) >= outputAmount && output.balanceOf(receiver) >= outputAmount, "caller is not token owner");
        output.transferFrom(receiver, address(this), outputAmount); // todo : burn outputTokenId
        input.transfer(receiver, outputAmount);
        wrapped[receiver] -= outputAmount;
        return outputAmount;
    }
}

contract SolaERC20BadgeWrapper {
    ERC20 public input;
    SolaBadge public output;

    uint256 public rate;
    mapping(uint256 => uint256) public wrapped;

    constructor(address _input, address _output, uint256 _rate) {
        input = ERC20(_input);
        output = SolaBadge(_output);
        rate = _rate;
    }

    function wrap(address receiver) external returns (uint256) {
        // check msg sender is inputTokenId owner
        require(input.allowance(receiver, address(this)) >= rate, "caller is not token owner");
        input.transferFrom(msg.sender, address(this), rate);
        uint256 newTokenId = output.mint(receiver);
        wrapped[newTokenId] = rate;
        return newTokenId;
    }

    function unwrap(uint256 tokenId, address receiver) external returns (uint256) {
        require(wrapped[tokenId] >= 0, "tokenId is not wrapped");
        output.transferFrom(msg.sender, address(this), tokenId); // todo : burn outputTokenId
        input.transfer(receiver, wrapped[tokenId]);
        delete wrapped[tokenId];
        return tokenId;
    }

}

contract SolaBadgePointConverter {
    SolaBadge public input;
    SolaPoint public output;
    uint64 public mode;
    uint256 public rate;

    mapping(uint256 => uint256) public converted;

    constructor(address _input, address _output, uint64 _mode, uint256 _rate) {
        input = SolaBadge(_input);
        output = SolaPoint(_output);
        mode = _mode;
        rate = _rate;
    }

    // three convert mode:
    // remember
    // transfer
    // burn

    function convert(uint256 inputTokenId, address receiver) external returns (uint256) {
        if (mode == 1) {
            return transferConverter(inputTokenId, receiver);
        } else if(mode == 2) {
            return burnConverter(inputTokenId, receiver);
        } else {
            return rememberConverter(inputTokenId, receiver);
        }
    }

    function transferConverter(uint256 inputTokenId, address receiver) public returns (uint256) {
        require(input.ownerOf(inputTokenId) == msg.sender, "caller is not token owner");
        require(converted[inputTokenId] == 0, "has been converted");
        input.transferFrom(input.ownerOf(inputTokenId), address(this), inputTokenId);
        output.mint(receiver, rate);
        converted[inputTokenId] = rate;
        return inputTokenId;
    }

    function burnConverter(uint256 inputTokenId, address receiver) public returns (uint256) {
        require(input.ownerOf(inputTokenId) == msg.sender, "caller is not token owner");
        require(converted[inputTokenId] == 0, "has been converted");
        input.burn(inputTokenId);
        output.mint(receiver, rate);
        converted[inputTokenId] = rate;
        return inputTokenId;
    }

    function rememberConverter(uint256 inputTokenId, address receiver) public returns (uint256) {
        require(input.ownerOf(inputTokenId) == msg.sender, "caller is not token owner");
        require(converted[inputTokenId] == 0, "has been converted");
        output.mint(receiver, rate);
        converted[inputTokenId] = rate;
        return inputTokenId;
    }
}

contract SolaBadgeERC20Converter {

    SolaBadge public input;
    ERC20 public output;
    uint64 public mode;
    uint256 public rate;

    mapping(uint256 => uint256) public converted;

    constructor(address _input, address _output, uint64 _mode, uint256 _rate) {
        input = SolaBadge(_input);
        output = ERC20(_output);
        mode = _mode;
        rate = _rate;
    }

    // three convert mode:
    // remember
    // transfer
    // burn

    function convert(uint256 inputTokenId, address receiver) external returns (uint256) {
        if (mode == 1) {
            return transferConverter(inputTokenId, receiver);
        } else if(mode == 2) {
            return burnConverter(inputTokenId, receiver);
        } else {
            return rememberConverter(inputTokenId, receiver);
        }
    }

    function transferConverter(uint256 inputTokenId, address receiver) public returns (uint256) {
        require(input.ownerOf(inputTokenId) == msg.sender, "caller is not token owner");
        require(converted[inputTokenId] == 0, "has been converted");
        input.transferFrom(input.ownerOf(inputTokenId), address(this), inputTokenId);
        output.transfer(receiver, rate);
        converted[inputTokenId] = rate;
        return inputTokenId;
    }

    function burnConverter(uint256 inputTokenId, address receiver) public returns (uint256) {
        require(input.ownerOf(inputTokenId) == msg.sender, "caller is not token owner");
        require(converted[inputTokenId] == 0, "has been converted");
        input.burn(inputTokenId);
        output.transfer(receiver, rate);
        converted[inputTokenId] = rate;
        return inputTokenId;
    }

    function rememberConverter(uint256 inputTokenId, address receiver) public returns (uint256) {
        require(input.ownerOf(inputTokenId) == msg.sender, "caller is not token owner");
        require(converted[inputTokenId] == 0, "has been converted");
        output.transfer(receiver, rate);
        converted[inputTokenId] = rate;
        return inputTokenId;
    }

}

contract SolaBadgeSimpleMerger {

    SolaBadge public input;
    SolaBadge public output;
    uint64 public mode;
    uint256 public rate;
    uint256 public counter;

    mapping(uint256 => uint256) public converted;

    constructor(address _input, address _output, uint64 _mode, uint256 _rate) {
        input = SolaBadge(_input);
        output = SolaBadge(_output);
        mode = _mode;
        rate = _rate;
        counter = 1;
    }

    // three convert mode:
    // remember
    // transfer
    // burn

    function convert(uint256[] memory inputTokenIds, address receiver) external returns (uint256) {
        return transferConverter(inputTokenIds, receiver);
    }

    function transferConverter(uint256[] memory inputTokenIds, address receiver) public returns (uint256) {
        require(inputTokenIds.length == rate, "not enough inputs");
        for (uint256 i = 0; i < inputTokenIds.length; i+=1) {
            uint256 inputTokenId = inputTokenIds[i];
            require(input.ownerOf(inputTokenId) == msg.sender, "caller is not token owner");
            require(converted[inputTokenId] == 0, "has been converted");
            input.transferFrom(input.ownerOf(inputTokenId), address(this), inputTokenId);
            converted[inputTokenId] = counter;
        }
        counter += 1;

        uint256 newTokenId = output.mint(receiver);
        return newTokenId;
    }

}

contract SolaBadgeSeriesMerger {

    address[] public inputs;
    SolaBadge public output;
    uint64 public mode;
    uint256 public rate;
    uint256 public counter;

    mapping(address => mapping(uint256 => uint256)) public converted;

    constructor(address[] memory _inputs, address _output) {
        inputs = _inputs;
        output = SolaBadge(_output);
        counter = 1;
    }

    function convert(uint256[] memory inputTokenIds, address receiver) external returns (uint256) {
        return transferConverter(inputTokenIds, receiver);
    }

    function transferConverter(uint256[] memory inputTokenIds, address receiver) public returns (uint256) {
        require(inputTokenIds.length == inputs.length, "not enough inputs");
        for (uint256 i = 0; i < inputTokenIds.length; i+=1) {
            uint256 inputTokenId = inputTokenIds[i];
            require(SolaBadge(inputs[i]).ownerOf(inputTokenId) == msg.sender, "caller is not token owner");
            require(converted[inputs[i]][inputTokenId] == 0, "has been converted");
            SolaBadge(inputs[i]).transferFrom(SolaBadge(inputs[i]).ownerOf(inputTokenId), address(this), inputTokenId);
            converted[inputs[i]][inputTokenId] = counter;
        }
        counter += 1;

        uint256 newTokenId = output.mint(receiver);
        return newTokenId;
    }

}


contract SolaComplexBadgeMerger {


}


contract Minimal is ERC20 {
    address private _owner;

    constructor() ERC20("Minimal", "MIN") {
        _owner = msg.sender;
    }

    function mint(address addr, uint256 amount) external {
        require(msg.sender == _owner, "caller is not owner");
        _mint(addr, amount);
    }
}
