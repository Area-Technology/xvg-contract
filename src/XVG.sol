// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {XVGStorage} from "./XVGStorage.sol";
import {XVGMetadata} from "./XVGMetadata.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract XVG is ERC721, Owned, XVGMetadata, XVGStorage {
    string private constant description = "";

    error InsufficientFunds();
    error MaxSupplyReached();

    constructor() Owned(msg.sender) ERC721("XVG", "XVG") {
        for (uint256 id = 1; id < 23; id++) {
            _mint(msg.sender, id);
        }
    }

    function mint(uint256 tokenId) public payable {
        if (msg.value < xvgMeta[tokenId].price) revert InsufficientFunds();
        _mint(msg.sender, tokenId);
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

    function writeXVGMeta(
        uint256 id,
        string memory name,
        uint256 price
    ) external onlyOwner {
        _writeXVGMeta(id, name, price);
    }

    function withdraw(address to) external onlyOwner {
        (bool success, ) = to.call{value: address(this).balance}("");
        require(success, "XVG: withdraw failed");
    }
}
