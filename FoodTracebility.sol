// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

contract FoodTraceability is Ownable {
    enum Role {
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
        uint256 createdAt;
        bytes32 infohashRoot;
    }
    
    struct EventRecord {
        address actor;
        bytes32 recordHash; // store everything in hash, calculated off chain
        address newCust;
    }

    mapping(address => Role) public roles;
    mapping(bytes32 => Batch) private batches;
    mapping(bytes32 => EventRecord[]) private batchEvents; // change this to hash records.merkel root, updated each time

    event RoleUpdated(address indexed account, Role role);

    event BatchCreated(
        string batchId,
        address indexed creator,
        address indexed custodian, // not
        bytes32 datahash 
    );

    event EventAppended(
        string batchId,
        address indexed actor,
        string eventType,
        string cid,
        bytes32 dataHash // change to uint256 from bytes32
        
    );

    event CustodyTransferred(string batchId, address indexed from, address indexed to);
   
    event Eventtransmit(bytes32 key, string eventType, bytes32 recordHash); //n 

    constructor(address owner_) Ownable(owner_) {}

    function setRole(address account, Role role) external onlyOwner {
        roles[account] = role;
        emit RoleUpdated(account, role);
    }

    function createBatch(
        string calldata batchId,
        address firstCustodian,
        bytes32 dataHash // change to uint256 from bytes32
       
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
        
        _recordEvent(key, 'CREATE', dataHash, msg.sender);

        emit BatchCreated(batchId, msg.sender, firstCustodian, dataHash);
    }


    function transferCustody(string calldata batchId, address newCustodian, bytes32 recordHash)
        external
        onlyCustodian(batchId)
    {
        require(newCustodian != address(0), 'invalid custodian');
        require(_isAuthorizedWriter(newCustodian), 'custodian must be authorized');
        bytes32 key = _batchKey(batchId);
        Batch storage batch = batches[key];
        address previous = batch.currentCustodian;
        batch.currentCustodian = newCustodian;
        batch.infohashRoot = recordHash;

        _recordEvent(key, 'TRANSFER',recordHash, newCustodian);
        emit CustodyTransferred(batchId, previous, newCustodian);
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
        bytes32 newRecordHash,
        address nAddress
    ) internal {
        
        batchEvents[key].push(
            EventRecord({
                actor: msg.sender,

                recordHash: newRecordHash,
                newCust: nAddress
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

    // merge 
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