const ABI = [
    {
        "inputs": [
            { "internalType": "address", "name": "account", "type": "address" },
            { "internalType": "enum FoodTraceability.Role", "name": "role", "type": "uint8" }
        ],
        "name": "setRole",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },

    {
        "inputs": [
            { "internalType": "string", "name": "batchId", "type": "string" },
            { "internalType": "address", "name": "firstCustodian", "type": "address" },
            { "internalType": "bytes32", "name": "dataHash", "type": "bytes32" }
        ],
        "name": "createBatch",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },

    {
        "inputs": [
            { "internalType": "string", "name": "batchId", "type": "string" },
            { "internalType": "address", "name": "newCustodian", "type": "address" },
            { "internalType": "string", "name": "recordHash", "type": "string" }
        ],
        "name": "transferCustody",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },

    {
        "inputs": [
            { "internalType": "string", "name": "batchId", "type": "string" }
        ],
        "name": "getBatchSummary",
        "outputs": [
            {
                "components": [
                    { "internalType": "string", "name": "batchId", "type": "string" },
                    { "internalType": "address", "name": "creator", "type": "address" },
                    { "internalType": "address", "name": "currentCustodian", "type": "address" },
                    { "internalType": "bool", "name": "exists", "type": "bool" },
                    { "internalType": "uint256", "name": "createdAt", "type": "uint256" },
                    { "internalType": "string", "name": "infohashRoot", "type": "string" }
                ],
                "internalType": "struct FoodTraceability.BatchInfo",
                "name": "info",
                "type": "tuple"
            },
            {
                "components": [
                    { "internalType": "address", "name": "actor", "type": "address" },
                    { "internalType": "string", "name": "recordHash", "type": "string" },
                    { "internalType": "uint256", "name": "timestamp", "type": "uint256" }
                ],
                "internalType": "struct FoodTraceability.EventRecord[]",
                "name": "events",
                "type": "tuple[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },

    {
        "inputs": [
            { "internalType": "string", "name": "batchId", "type": "string" },
            { "internalType": "uint256", "name": "index", "type": "uint256" }
        ],
        "name": "getEvent",
        "outputs": [
            {
                "components": [
                    { "internalType": "address", "name": "actor", "type": "address" },
                    { "internalType": "string", "name": "recordHash", "type": "string" },
                    { "internalType": "uint256", "name": "timestamp", "type": "uint256" }
                ],
                "internalType": "struct FoodTraceability.EventRecord",
                "name": "",
                "type": "tuple"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];
console.log("ABI loaded", ABI);
