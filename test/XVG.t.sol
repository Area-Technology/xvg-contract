// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {XVG} from "../src/XVG.sol";

contract XVGTest is Test {
    XVG xvg;

    function setUp() public {
        xvg = new XVG();
    }

    function testUpload() public {
        string memory svgFile = vm.readFile("./example.svg");
        assertEq(bytes(svgFile).length, 73402);

        bytes memory zipped = _zip(bytes(svgFile));
        assertEq(zipped.length, 30228);

        xvg.writeXVG(0, zipped, uint32(bytes(svgFile).length));
        xvg.writeXVGMeta(0, "Test Token 0", "Zero", 100, 0.001 ether);
        string memory svg = xvg.readXVG(0);
        assertEq(bytes(svg), bytes(svgFile));

        console2.log(xvg.uri(0));
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
