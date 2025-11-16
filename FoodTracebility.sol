// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

contract FoodTraceability is Ownable {
    enum Role {
        None,
        Producer,
        Transporter,
        Retailer,
        Regulator
    }

    struct Batch {
        string batchId;
        address creator;
        address currentCustodian;
        bool exists;
        bool recalled;
        string recallReason;
        uint256 createdAt;
        uint256 photoroot; // the photo root hash.
    }

    struct EventRecord {
        //string eventType;
        address actor;
        // string cid;
        // bytes32 dataHash; // off chain record hash key
        // uint256 photohash; // give back the photo hash of the current transfer
        // uint256 timestamp;
        uint256 recordHash; // store everything in hash, calculated off chain
    }

    mapping(address => Role) public roles;
    mapping(bytes32 => Batch) private batches;
    mapping(bytes32 => EventRecord[]) private batchEvents; // change this to hash records.merkel root, updated each time

    event RoleUpdated(address indexed account, Role role);
    event BatchCreated(
        string batchId,
        address indexed creator,
        address indexed custodian,
        string cid,
        bytes32 dataHash, 
        uint256 photoroot //photo root 
    );
    event EventAppended(
        string batchId,
        address indexed actor,
        string eventType,
        string cid,
        bytes32 dataHash,
        uint256 photoHash // need to review
    );
    event CustodyTransferred(string batchId, address indexed from, address indexed to);
    event RecallStatusChanged(string batchId, bool recalled, string reason);
    event Eventtransmit(bytes32 key, string eventType, uint256 recordHash);

    constructor(address owner_) Ownable(owner_) {}

    function setRole(address account, Role role) external onlyOwner {
        roles[account] = role;
        emit RoleUpdated(account, role);
    }

    function createBatch(
        string calldata batchId,
        address firstCustodian,
        string calldata cid,
        bytes32 dataHash,
        uint256 initialphotoHash, // hash of the initial photo.
        uint256 rootHash // merkle root hash
    ) external onlyRole(Role.Producer) {
        require(bytes(batchId).length > 0, 'batchId required');
        require(firstCustodian != address(0), 'custodian required');
        require(_isAuthorizedWriter(firstCustodian), 'custodian must be authorized');

        bytes32 key = _batchKey(batchId);
        Batch storage batch = batches[key];
        require(!batch.exists, 'batch exists');

        batch.batchId = batchId;
        batch.creator = msg.sender;
        batch.currentCustodian = firstCustodian;
        batch.exists = true;
        batch.createdAt = block.timestamp;
        batch.photoroot= initialphotoHash; // need a merkle root function updater. 
        _recordEvent(key, 'CREATE', rootHash);

        emit BatchCreated(batchId, msg.sender, firstCustodian, cid, dataHash, initialphotoHash);
    }

    

    function transferCustody(string calldata batchId, address newCustodian, uint256 photoHash, uint256 recordHash)
        external
        onlyCustodian(batchId)
    {
        require(newCustodian != address(0), 'invalid custodian');
        require(_isAuthorizedWriter(newCustodian), 'custodian must be authorized');
        bytes32 key = _batchKey(batchId);
        Batch storage batch = batches[key];
        address previous = batch.currentCustodian;
        batch.currentCustodian = newCustodian;
        batch.photoroot=photoHash; // update the photo hash
        //_recordEvent(key, 'TRANSFER', '', bytes32(0), photoHash); // need to change
        _recordEvent(key, 'TRANSFER',recordHash);
        emit CustodyTransferred(batchId, previous, newCustodian);
    }

    function setRecall(
        string calldata batchId,
        bool recalled,
        string calldata reason
    ) external onlyRole(Role.Regulator) {
        bytes32 key = _requireBatch(batchId);
        Batch storage batch = batches[key];
        batch.recalled = recalled;
        batch.recallReason = recalled ? reason : '';
        emit RecallStatusChanged(batchId, recalled, reason);
    }

    function getBatchSummary(string calldata batchId)
        external
        view
        returns (Batch memory summary, EventRecord[] memory events)
    {
        bytes32 key = _requireBatch(batchId);
        Batch storage batch = batches[key];
        summary = batch;
        events = batchEvents[key];
    }

    function getEvent(string calldata batchId, uint256 index)
        external
        view
        returns (EventRecord memory)
    {
        bytes32 key = _requireBatch(batchId);
        require(index < batchEvents[key].length, 'index out of bounds');
        return batchEvents[key][index];
    }

    function _recordEvent(
        bytes32 key,
        string memory eventType,
        // string memory cid,
        // bytes32 dataHash,
        // uint256 photoHashrecord,
        uint256 newRecordHash
    ) internal {
        // change this to merkel root. stream to front+back
        batchEvents[key].push(
            EventRecord({
                // eventType: eventType,
                actor: msg.sender,
                // cid: cid,
                // dataHash: dataHash,
                // photohash: photoHashrecord,
                // timestamp: block.timestamp,
                recordHash: newRecordHash
            })
        );
        emit Eventtransmit(key, eventType, newRecordHash);

    }

    function _batchKey(string memory batchId) internal pure returns (bytes32) {
        return keccak256(bytes(batchId));
    }

    function _requireBatch(string calldata batchId) internal view returns (bytes32) {
        bytes32 key = _batchKey(batchId);
        require(batches[key].exists, 'batch missing');
        return key;
    }

    function _canWriteBatch(Batch storage batch, address actor) internal view returns (bool) {
        Role role = roles[actor];
        if (role == Role.Regulator) {
            return true;
        }
        return batch.currentCustodian == actor && _isAuthorizedWriter(actor);
    }

    function _isAuthorizedWriter(address account) internal view returns (bool) {
        Role role = roles[account];
        return role == Role.Producer || role == Role.Transporter || role == Role.Retailer;
    }

    modifier onlyRole(Role role) {
        require(roles[msg.sender] == role, 'role required');
        _;
    }

    modifier onlyCustodian(string calldata batchId) {
        bytes32 key = _requireBatch(batchId);
        require(batches[key].currentCustodian == msg.sender, 'not custodian');
        _;
    }

    

}
