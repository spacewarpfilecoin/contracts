// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


contract NameServiceSplychain{
   

  mapping(string => address) private domains;

  constructor(){
  }

    function register(string calldata name) public {
        require(domains[name] == address(0), "name not available");

        domains[name] = msg.sender;

    }

    function getAddress(string calldata name) public view returns (address) {
      return domains[name];
    }

    function checkAvailability(string calldata name) public view returns (bool){
        if(domains[name] == address(0)){
            return true;
        }
        else{
            return false;
        }
    }

}