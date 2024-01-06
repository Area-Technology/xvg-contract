// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {XVG} from "../src/XVG.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract XVGTest is Test {
    XVG xvg;

    function setUp() public {
        xvg = new XVG();
    }

    function testCompress() public {
        uint256 unzippedLength = 0;
        uint256 zippedLength = 0;
        for (uint i = 2; i < 22; i++) {
            if (i == 4 || i == 6) continue;
            string memory svgFile = vm.readFile(
                string.concat("./svgs/", Strings.toString(i), ".svg")
            );

            unzippedLength += bytes(svgFile).length;
            bytes memory zipped = _zip(bytes(svgFile));
            zippedLength += zipped.length;
        }
        console2.log("total unzipped length", unzippedLength);
        console2.log("total zipped length", zippedLength);
    }

    function testUpload() public {
        for (uint i = 2; i < 22; i++) {
            if (i == 4 || i == 6) continue;
            string memory svgFile = vm.readFile(
                string.concat("./svgs/", Strings.toString(i), ".svg")
            );

            bytes memory zipped = _zip(bytes(svgFile));
            xvg.writeXVG(i, zipped, uint32(bytes(svgFile).length));
            xvg.writeXVGMeta(i, "Test Token 0", 0.001 ether);
        }
    }

    // zipping functions from zipped-contracts
    function _zip(bytes memory data) internal returns (bytes memory zipped) {
        string memory compressScript = "./compress.py";
        if (!_doesFileExist(compressScript, "text/x-script.python")) {
            compressScript = "./lib/zipped-contracts/compress.py";
        }
        string[] memory args = new string[](4);
        args[0] = "env";
        args[1] = "python3";
        args[2] = compressScript;
        args[3] = vm.toString(data);
        return vm.ffi(args);
    }

    function _doesFileExist(
        string memory path,
        string memory mimeType
    ) private returns (bool) {
        string[] memory args = new string[](4);
        args[0] = "file";
        args[1] = "--mime-type";
        args[2] = "-b";
        args[3] = path;
        return keccak256(vm.ffi(args)) == keccak256(bytes(mimeType));
    }
}
