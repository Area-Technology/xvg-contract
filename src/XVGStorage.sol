// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {SSTORE2} from "solady/utils/SSTORE2.sol";
import {InflateLib} from "inflate-sol/InflateLib.sol";

contract XVGStorage {
    struct XVGAsset {
        uint32 size;
        address[] slots;
    }
    mapping(uint256 => XVGAsset) public xvgData;

    function _writeXVG(uint256 id, bytes calldata data, uint32 size) internal {
        xvgData[id].size = size;

        uint32 partSize = 24_000;
        uint32 zippedSize = uint32(data.length);
        uint32 numParts = (zippedSize + partSize - 1) / partSize;

        for (uint32 i; i < numParts; i++) {
            uint32 start = i * partSize;
            uint32 end = start + partSize > zippedSize
                ? zippedSize
                : start + partSize;
            xvgData[id].slots.push(
                SSTORE2.write(_sliceBytes(data, start, end))
            );
        }
    }

    function readXVG(uint256 id) public view returns (string memory) {
        bytes memory svg;
        for (uint256 i; i < xvgData[id].slots.length; i++) {
            svg = bytes.concat(svg, SSTORE2.read(xvgData[id].slots[i]));
        }
        (, bytes memory output) = InflateLib.puff(svg, xvgData[id].size);
        return string(output);
    }

    function _sliceBytes(
        bytes calldata strBytes,
        uint32 startIndex,
        uint32 endIndex
    ) private pure returns (bytes memory) {
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return result;
    }
}
