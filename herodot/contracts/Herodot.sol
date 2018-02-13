pragma solidity ^0.4.4;

contract Herodot {
    
    struct HistoricalEvent {
        string reporter;
        uint256 date;
        string title;
        string descriptor;
        bool fake;
    }
    
    struct History {
        HistoricalEvent[] historicalEvents;
    }
    
    mapping (uint => uint[]) eventsIndexRelations;
    mapping (uint => uint[]) eventHashtags;
    mapping (string => bool) hashtagExists;
    
    HistoricalEvent[] historicalEvents;
    string[] hashtags;
    
    address owner;
    
    function Herodot() public {
        owner = msg.sender;
    }
    
    function addHashtag(string hashtag) public returns (uint index) {
        require(!hashtagExists[hashtag]);
        uint insertedIndex = hashtags.push(hashtag);
        hashtagExists[hashtag] = true;
        return insertedIndex;
    }
    
    function addEvent(string mediaName, string eventName, string eventDescription) public isOwner() returns(uint index) {
        HistoricalEvent memory newEvent = HistoricalEvent(mediaName, now, eventName, eventDescription, false);
        return historicalEvents.push(newEvent) - 1;
    }
    
    function addEventRelationship(uint firstEvent, uint secondEvent) public isOwner() {
        eventsIndexRelations[firstEvent].push(secondEvent);
        eventsIndexRelations[secondEvent].push(firstEvent);
    }
    
    function addEventHashtag(uint eventIndex, uint hashtagIndex) public isOwner() {
        eventHashtags[eventIndex].push(hashtagIndex);
    }
    
    function setFakeEvent(int index) public isOwner() {
        historicalEvents[uint(index)].fake = true;
    }
    
    function setNotFakeEvent(int index) public isOwner() {
        historicalEvents[uint(index)].fake = false;
    }
    
    function getHistoryEvent(int index) public constant returns (string reporter, uint256 date, string title, string descriptor, bool fake) {
        require(index <= getMaximalIndex());
        HistoricalEvent memory foundElement = historicalEvents[uint(index)];
        return (foundElement.reporter, foundElement.date, foundElement.title, foundElement.descriptor, foundElement.fake);
    }
    
    function getMaximalIndex() public constant returns (int) {
        if (historicalEvents.length > 0) {
            return int(historicalEvents.length - 1);
        } else {
            return -1;
        }
    }
    
    modifier isOwner() {
        require(owner == msg.sender);
        _;
    }
    
    
    
}
