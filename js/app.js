const CONTRACT_ADDRESS = '0x1B46a0887c0fe1d8A04ec7D425005c65F818e5D5';

let provider;
let signer;
let contract;

console.log("Using contract:", CONTRACT_ADDRESS);

async function initApp() {
    const provider = await detectEthereumProvider();
    if(provider) {
        startApp(provider); // Initialize 
    } else {
        console.log('Please install MetaMask!');
    }
}

async function testConnection() {
    try {
        const code = await provider.getCode(CONTRACT_ADDRESS);
        document.getElementById("testResult").innerText = 
            code === "0x" ? 
            "No contract found at this address!" :
            "Contract detected!";
    } catch (err) {
        console.error(err);
    }
}


async function connect() {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

    document.getElementById("status").innerText = "Wallet Connected";

    console.log("Signer:", await signer.getAddress());
    console.log("Provider:", provider);
    console.log("Network:", await provider.getNetwork());

}

async function setRole() {
    const account = v("roleAccount");
    const role = parseInt(v("roleSelect")); // Assuming role is selected as a number

    const tx = await contract.setRole(account, role);
    await tx.wait();
    msg("Role set: " + tx.hash);
}


async function createBatch() {
    const id = v("batchId");
    const cust = v("custodian");
    const raw = v("hash");

    if (!id || !cust || !raw) {
        msg("All fields are required.");
        return;
    }

    let hash;
    try {
        hash = ethers.utils.formatBytes32String(raw); // safer for short strings like "3kgApple"
    } catch (e) {
        hash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(raw));
    }

    try {
        const tx = await contract.createBatch(id, cust, hash, { gasLimit: 300000 });
        await tx.wait();
        msg("Batch created: " + tx.hash);
    } catch (error) {
        console.error("Error creating batch:", error);
        const errMsg = error && error.error && error.error.message ? error.error.message : (error.message || String(error));
        msg("Error creating batch: " + errMsg);
    }
}

async function transferCustody() {
    const id = v("tBatch");
    const newC = v("tCustodian");
    const h = v("tHash");

    const tx = await contract.transferCustody(id, newC, h);
    await tx.wait();
    msg("Transferred: " + tx.hash);
}

async function getSummary() {
    const id = v("sBatch");
    const [info, events] = await contract.getBatchSummary(id);

    document.getElementById("output").innerHTML =
        `<b>Creator:</b> ${info.creator}<br>
         <b>Custodian:</b> ${info.currentCustodian}<br>
         <b>Events:</b> ${events.length}`;
}

// ---- small helpers ----
const v = (id) => document.getElementById(id).value.trim();
const msg = (t) => document.getElementById("status").innerText = t;

window.onload = connect;
