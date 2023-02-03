// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract NamingService  is ERC721Enumerable {
    // this is our TLD
    string public tld;

    // map username to wallet address and call it names
    mapping (string => address) public names;

    // map username to user email
    mapping(string => string ) public userRecords;

     // used for tracking tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;



    constructor( string memory _tld) payable {
        tld = _tld;
    }

    // function to register a name
    function regName(string calldata username) public {
        string memory TokenUri = '';
        // set the tokenId
         uint256 newRecordId = _tokenIds.current();
        // ensure the user is registered before
        require(names[username] == address(0));
        // assign the username to the caller's address
        names[username] = msg.sender;

        // mint the name for the user
        _safeMint(msg.sender, newRecordId);

        // _setTokenURI(newRecordId,TokenUri); 
        // increase token count
         _tokenIds.increment();
      
    }

    // function to fetch a name
    function getName(string calldata username) public view returns (address){
       return names[username];
    }

    // function to store user details
    function setUserRecords(string calldata username, string calldata email) public{
        // ensure I am not setting someone else's data
        require(names[username] == msg.sender);
        // go ahead and set the user record
        userRecords[username] = email;
    }
 
    function getUserData(string calldata username) public view returns(string memory){
        return userRecords[username];
    }

}