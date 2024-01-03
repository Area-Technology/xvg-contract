// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {XVGStorage} from "./XVGStorage.sol";
import {XVGMetadata} from "./XVGMetadata.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract XVG is Ownable, ERC1155, ERC1155Supply, XVGMetadata, XVGStorage {
    error InsufficientFunds();
    error MaxSupplyReached();

    constructor() Ownable(msg.sender) ERC1155("") {}

    function mint(uint256 tokenId) public payable {
        if (msg.value < xvgMeta[tokenId].mintFee) revert InsufficientFunds();
        if (totalSupply(tokenId) >= xvgMeta[tokenId].maxSupply)
            revert MaxSupplyReached();

        _mint(msg.sender, tokenId, 1, "");
    }

    /* -------------------------------------------------------------------------- */
    /*                              ERC1155 OVERRIDES                             */
    /* -------------------------------------------------------------------------- */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    /* -------------------------------------------------------------------------- */
    /*                                    DATA                                    */
    /* -------------------------------------------------------------------------- */
    function uri(uint256 tokenId) public view override returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "',
            xvgMeta[tokenId].name,
            '", "description": "',
            xvgMeta[tokenId].description,
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
        bytes calldata zippedSVGData,
        uint32 size
    ) external onlyOwner {
        _writeXVG(id, zippedSVGData, size);
    }

    function writeXVGMeta(
        uint256 id,
        string memory name,
        string memory description,
        uint256 maxSupply,
        uint256 mintFee
    ) external onlyOwner {
        _writeXVGMeta(id, name, description, maxSupply, mintFee);
    }

    function withdraw(address to) external onlyOwner {
        (bool success, ) = to.call{value: address(this).balance}("");
        require(success, "XVG: withdraw failed");
    }
}
