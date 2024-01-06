// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract XVGMetadata {
    struct XVGMeta {
        uint256 price;
        string name;
    }
    mapping(uint256 => XVGMeta) public xvgMeta;

    function _writeXVGMeta(uint256 id, string memory name) internal {
        xvgMeta[id].name = name;
    }

    function _writeXVGPrice(uint256 id, uint256 price) internal {
        xvgMeta[id].price = price;
    }
}
