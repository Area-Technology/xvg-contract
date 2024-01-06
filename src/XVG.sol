// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {XVGStorage} from "./XVGStorage.sol";
import {XVGMetadata} from "./XVGMetadata.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract XVG is ERC721, Owned, XVGMetadata, XVGStorage {
    string private constant description = "placeholder";
    bool public MINT_OPEN;

    error InvalidMessageValue();
    error MintNotOpen();
    error MaxSupplyReached();

    constructor() Owned(msg.sender) ERC721("XVG", "XVG") {
        for (uint256 id = 1; id <= 23; id++) {
            _mint(address(this), id);
        }
    }

    function mint(uint256 tokenId) public payable {
        if (!MINT_OPEN) revert MintNotOpen();
        if (xvgMeta[tokenId].price == 0) revert MintNotOpen();
        if (msg.value != xvgMeta[tokenId].price) revert InvalidMessageValue();
        transferFrom(address(this), msg.sender, tokenId);
    }

    /* -------------------------------------------------------------------------- */
    /*                                    DATA                                    */
    /* -------------------------------------------------------------------------- */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "',
            xvgMeta[tokenId].name,
            '", "description": "',
            description,
            '", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(readXVG(tokenId))),
            '"}'
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    /* -------------------------------------------------------------------------- */
    /*                                    OWNER                                   */
    /* -------------------------------------------------------------------------- */
    function writeXVG(
        uint256 id,
        bytes calldata data,
        uint32 size
    ) external onlyOwner {
        _writeXVG(id, data, size);
    }

    function writeXVGMeta(uint256 id, string memory name) external onlyOwner {
        _writeXVGMeta(id, name);
    }

    function writeXVGPrice(uint256 id, uint256 price) external onlyOwner {
        _writeXVGPrice(id, price);
    }

    function setMintOpen(bool open) external onlyOwner {
        MINT_OPEN = open;
    }

    function withdraw(address to) external onlyOwner {
        (bool success, ) = to.call{value: address(this).balance}("");
        require(success, "XVG: withdraw failed");
    }
}
