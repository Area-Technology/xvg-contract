// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract XVGMetadata {
    struct XVGMeta {
        uint256 price;
        string name;
    }
    mapping(uint256 => XVGMeta) public xvgMeta;

    function _writeXVGMeta(
        uint256 id,
        string memory name,
        uint256 price
    ) internal {
        xvgMeta[id].name = name;
        xvgMeta[id].price = price;
    }
}
