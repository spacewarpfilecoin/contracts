// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";


contract LogisticsTracker is Ownable {
    constructor()  {}

    struct tracker {
        address receiver;
        address sender;
        address authorized;
        bytes32 deliveryCoordinates;
        uint8 status;
    }

    //Shipment id
    uint256 id;

    bool public paused;

    mapping (uint256 => tracker) private trackers;

    mapping (uint256 => bytes32[]) private trackerLocationHistory;

    mapping (uint256 => uint256[]) private trackerTimeHistory;

    //1=>On transit 2=> Wharehouse 3=> Try to deliver 4=Delivered
    mapping (uint256 => uint8[]) private trackerStatusHistory;

    mapping (address => uint256[]) private authorizedShipments;

    mapping (address => bool) private authorized;

    mapping(address => mapping(address => bool)) ApprovedForDelivery;

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

    modifier ReceiverOrApproved(uint256 _id)
    {
        require(msg.sender == trackers[_id].receiver || ApprovedForDelivery[trackers[_id].receiver][msg.sender]);
        _;
    }

    event OrderCreated(address indexed receiver, address sender, bytes32 deliveryCoordinates, uint256 indexed id); 

    event TrackerUpdated(uint256 indexed id, bytes32 indexed coordinates, uint8 status); 

    event ApprovalForDelivery(address indexed owner, address indexed operator, bool approved);


    //Set mapping authorized
    function setAuthorized(address addr, bool val) public onlyOwner{
        authorized[addr] = val;
    }

    //Puse and unpause the create order
    function setPaused(bool val) public onlyOwner{
        paused = val;
    }

    //Set approved addreses to confirm delivery
    function setDeliveryApproval(address operator, bool approved) public {
        require(msg.sender != operator, "The operator should be different address");
        ApprovedForDelivery[msg.sender][operator] = approved;

        emit ApprovalForDelivery(msg.sender, operator, approved);

    } 

    //create the order when it is loaded
    function createOrder(address _receiver, address _sender, bytes32 _deliveryCoordinates, bytes32 shipmentCoordinates ) public Authorized() returns (uint256) {
        require (!paused, "Create orders is paused");

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

        emit OrderCreated(_receiver, _sender, _deliveryCoordinates, id-1);

        return id-1;
    }

    //Update tracker history with the new location coordinates
    function updateTracker(uint256 _id, bytes32 coordinates, uint8 status) public Authorized() {
        require(status == 1 || status ==2 || status == 3);

        trackerLocationHistory[_id].push(coordinates);
        trackerTimeHistory[_id].push(block.timestamp);
        trackerStatusHistory[_id].push(status);

        trackers[_id].status = status;

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

    function confirmDelivery(uint256 _id) public ReceiverOrApproved(_id){
        trackers[_id].status = 4;
        trackerStatusHistory[_id].push(4);
    }
    
}