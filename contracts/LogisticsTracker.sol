// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


//QUESTION: Is it neccesary to have the NFT minted?

contract LogisticsTracker is ERC721, Pausable, Ownable {
    constructor() ERC721("Logistics Tracker", "LTR") {}


    struct tracker {
        address receiver;
        address sender;
        address authorized;
        bytes32 deliveryCoordinates;
        uint8 status;
    }

    //Shipment id
    uint256 id;

    //TODO: Change to private
    mapping (uint256 => tracker) public trackers;

    //CHECK: Can we use another variable type for the array (bytes32 is the coordinates in string to bytes32)
    mapping (uint256 => bytes32[]) private trackerLocationHistory;

    mapping (uint256 => uint256[]) private trackerTimeHistory;

    //1=>On transit 2=> Wharehouse 3=> Delivered
    mapping (uint256 => uint8[]) private trackerStatusHistory;

    mapping (address => uint256[]) private authorizedShipments;

    //TODO: Change to private
    mapping (address => bool) public authorized;

    //Modifier that allows to call the function only to Sender or Receiver of the shipment
    modifier OnlySenderReceiverOrAuthorized(uint256 _id)
    {
        require(msg.sender == trackers[_id].receiver || msg.sender == trackers[_id].sender || authorized[msg.sender]);
        _;
    } 

    //Modifier that allows to call the function only to the authorized addresses
    modifier Authorized()
    {
        require(authorized[msg.sender]);
        _;
    } 

    event OrderCreated(address indexed receiver, address sender, bytes32 deliveryCoordinates, uint256 indexed id); 

    event TrackerUpdated(uint256 indexed id, bytes32 indexed coordinates, uint8 status); 

    //Pause the smart contract
    function pause() public onlyOwner {
        _pause();
    }

    //Unpause the smart contract
    function unpause() public onlyOwner {
        _unpause();
    }

    //Set mapping authorized
    function setAuthorized(address addr, bool val) public onlyOwner{
        authorized[addr] = val;
    }

    //create the order when it is loaded
    function createOrder(address _receiver, address _sender, bytes32 _deliveryCoordinates, bytes32 shipmentCoordinates ) public Authorized() returns (uint256) {

        trackers[id].receiver = _receiver;
        trackers[id].sender = _sender;
        trackers[id].authorized = msg.sender;
        trackers[id].deliveryCoordinates = _deliveryCoordinates;
        trackers[id].status = 1;

        trackerLocationHistory[id].push(shipmentCoordinates);
        trackerTimeHistory[id].push(block.timestamp);
        trackerStatusHistory[id].push(1);

        authorizedShipments[msg.sender].push(id);
        

        id++;

        _safeMint(_receiver, id-1);

        emit OrderCreated(_receiver, _sender, _deliveryCoordinates, id-1);

        return id-1;
    }

    //Update tracker history with the new location coordinates
    function updateTracker(uint256 _id, bytes32 coordinates, uint8 status) public Authorized() {
        //CHECK: could we addif coordinates == to deliveryCoordinates "State: Delivered"
        trackerLocationHistory[_id].push(coordinates);
        trackerTimeHistory[_id].push(block.timestamp);
        trackerStatusHistory[_id].push(status);

        trackers[id].status = status;

        emit TrackerUpdated(_id, coordinates, status); 
    }

    //View the tracker history info. Only receiver or sender
    function getTrackerHistory(uint256 _id) public view OnlySenderReceiverOrAuthorized(_id) returns ( bytes32[] memory, uint256[] memory, uint8[] memory ){
        return (trackerLocationHistory[_id], trackerTimeHistory[_id], trackerStatusHistory[_id]);
    }

    //Get all shipments status of a logistics company
    function getAllShipments()public view Authorized() returns (uint256[] memory, uint8[] memory){
        uint256[] memory _id = authorizedShipments[msg.sender];
        uint8[] memory _status = new uint8[](_id.length);
        for(uint i = 0; i < _id.length; i++){
           _status[i] = trackers[_id[i]].status;
        }

        return (_id, _status);

    }


    // Sould bound tokens --> Block token transfers
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId, /* firstTokenId */
        uint256 batchSize
    ) internal whenNotPaused virtual override{
    require(from == address(0), "Err: token transfer is BLOCKED");   
    super._beforeTokenTransfer(from, to, tokenId, batchSize);  
    }
}