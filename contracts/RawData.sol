// SPDX-License-Identifier: MIT

pragma solidity ~0.8.17;


contract RawData {

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function arrayBytes32ToString(bytes32[] memory _bytes32) public pure returns (string[] memory) {
        string[] memory coordinates = new string[](_bytes32.length);

        for (uint256 i = 0; i < _bytes32.length; i++)
        {
            coordinates[i] = bytes32ToString(_bytes32[i]);
        }
      
        return coordinates;
    }

    //Input coordinates with format xxx.xxxxx,yyy.yyyyy
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
   
}