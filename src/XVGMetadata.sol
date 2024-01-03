// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract XVGMetadata {
    struct XVGMeta {
        uint256 maxSupply;
        uint256 mintFee;
        string name;
        string description;
    }
    mapping(uint256 => XVGMeta) public xvgMeta;

    function _writeXVGMeta(
        uint256 id,
        string memory name,
        string memory description,
        uint256 maxSupply,
        uint256 mintFee
    ) internal {
        xvgMeta[id] = XVGMeta({
            name: name,
            description: description,
            maxSupply: maxSupply,
            mintFee: mintFee
        });
    }
}
