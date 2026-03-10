
# Cross-Chain Messaging with Reactive Network

This project demonstrates a cross-chain messaging system using Foundry and the Reactive Network. A message sent on the Sepolia testnet triggers a callback that results in a message being received on the Base Sepolia testnet.

## Deployed Contracts

| Contract | Network | Address |
| :--- | :--- | :--- |
| **MsgNode** | Ethereum Sepolia | `0x893e290DcAC24DBD67Dfd2AC60F81D5589e35f0a` |
| **MsgNode** | Base Sepolia | `0x1c98A4c840209662EB4e8Be0cAEB298CA4ea78a4` |
| **ReactiveContract** | Reactive Lasna | `0x7317A86f1B9cF6D0838A41ad567B9B3E7D757b1f` |

---

## Core Components

-   **`MsgNode.sol`**: A simple contract deployed on two origin/destination chains (Sepolia, Base Sepolia) responsible for sending and receiving messages.
-   **`ReactiveContract.sol`**: The core logic contract deployed on the Reactive Lasna testnet. It listens for `SendMessage` events on one chain and triggers a `receiveMessage` callback on the destination chain.

---

## 1. Prerequisites

-   [Foundry](https://getfoundry.sh/): Ensure you have the latest version of Foundry installed.
-   **Node.js & npm**: Required for managing dependencies.
-   
```bash
forge --version
node --version
git clone https://github.com/narnona/Reactive-demo.git
cd Reactive-demo
```

## 2. Installation

First, install the necessary libraries using Foundry's dependency management:

```bash
forge install
```

This will download `forge-std`, `openzeppelin-contracts`, and `reactive-lib`.

## 3. Environment Configuration

Create a `.env` file in the root of the project and populate it with the following variables. This file is crucial for deploying and interacting with the contracts.

```env
# Your private key for deploying contracts
PRIVATE_KEY=0x...

# RPC URLs for the respective networks
SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/YOUR_INFURA_KEY"
BASE_SEPOLIA_RPC_URL="https://base-sepolia.infura.io/v3/YOUR_INFURA_KEY"
REACTIVE_LASNA_RPC_URL="https://lasna-rpc.rnk.dev/"

# API Key for contract verification (Etherscan/Basescan)
SCAN_API_KEY=YOUR_API_KEY
```

**Important**: Ensure the account associated with your `PRIVATE_KEY` has sufficient testnet funds on all three networks (Sepolia ETH, Base Sepolia ETH, and Lasna lREACT).

### Funding Your Lasna Account

To get `lREACT` for the Reactive Lasna testnet, send Sepolia ETH to the Reactive Faucet contract. The faucet will automatically send `lREACT` to your account on the Lasna network at a 1:100 ratio.

-   **Sepolia Faucet Address**: `0x9b9BB25f1A81078C544C829c5EB7822d747Cf434`

## 4. Deployment and Configuration

The deployment process must follow a specific order.

### Step 1: Deploy `MsgNode` Contracts

First, deploy the `MsgNode` contract to both Sepolia and Base Sepolia. The deployment script `DeployMsgNode.s.sol` automatically handles selecting the correct callback proxy for each chain.

**Deploy to Sepolia:**

```bash
forge script script/DeployMsgNode.s.sol:DeployMsgNode --rpc-url $SEPOLIA_RPC_URL --broadcast --slow --legacy
```

**Deploy to Base Sepolia:**

```bash
forge script script/DeployMsgNode.s.sol:DeployMsgNode --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --slow --legacy
```

**Note down the deployed contract addresses** from the command output for both networks. You will need them for the next step.

### Step 2: Deploy `ReactiveContract`

Now, deploy the `ReactiveContract` to the Reactive Lasna testnet.

```bash
forge script script/DeployReactive.s.sol:DeployReactive --rpc-url $REACTIVE_LASNA_RPC_URL --broadcast --slow --legacy
```

**Note down the deployed `ReactiveContract` address.**

### Step 3: Fund and Configure `ReactiveContract`

After deployment, the `ReactiveContract` needs funds to pay for its automated operations and must be configured to listen to the correct `MsgNode` contracts.

1.  **Fund the Contract**: Transfer a small amount of `lREACT` (e.g., 0.1) to your newly deployed `ReactiveContract` address to cover gas fees for callbacks.

    ```bash
    cast send YOUR_REACTIVE_CONTRACT_ADDRESS --value 0.1ether --rpc-url $REACTIVE_LASNA_RPC_URL --private-key $PRIVATE_KEY --legacy
    ```

2.  **Register Nodes**: Call `setMsgNode` on your `ReactiveContract` to register the `MsgNode` addresses from Step 1. This subscribes the reactive contract to events on both chains.

    ```bash
    # Register Sepolia MsgNode
    cast send YOUR_REACTIVE_CONTRACT_ADDRESS "setMsgNode(uint256,address)" 11155111 YOUR_SEPOLIA_MSGNODE_ADDRESS --rpc-url $REACTIVE_LASNA_RPC_URL --private-key $PRIVATE_KEY --legacy

    # Register Base Sepolia MsgNode
    cast send YOUR_REACTIVE_CONTRACT_ADDRESS "setMsgNode(uint256,address)" 84532 YOUR_BASE_SEPOLIA_MSGNODE_ADDRESS --rpc-url $REACTIVE_LASNA_RPC_URL --private-key $PRIVATE_KEY --legacy
    ```

## 5. Contract Verification

Verifying your contracts on block explorers allows for easier interaction and transparency.

### Verifying `MsgNode` (Sepolia & Base Sepolia)

Use your `SCAN_API_KEY` to verify on Etherscan/Basescan:

```bash
# Sepolia
forge verify-contract YOUR_SEPOLIA_MSGNODE_ADDRESS src/MsgNode.sol:MsgNode --chain-id 11155111 --etherscan-api-key $SCAN_API_KEY --watch

# Base Sepolia
forge verify-contract YOUR_BASE_SEPOLIA_MSGNODE_ADDRESS src/MsgNode.sol:MsgNode --chain-id 84532 --etherscan-api-key $SCAN_API_KEY --watch
```

### Verifying `ReactiveContract` (Reactive Lasna)

Reactive Network uses **Sourcify** for verification. Use the official Sourcify server for Reactive:

```bash
forge verify-contract YOUR_REACTIVE_CONTRACT_ADDRESS src/ReactiveContract.sol:ReactiveContract --chain-id 5318007 --verifier sourcify --verifier-url https://sourcify.rnk.dev/ --watch
```

## 6. Testing the Cross-Chain Flow

With everything deployed and configured, you can test the end-to-end flow.

1.  **Send a Message from Sepolia**: Call the `sendMessage` function on the `MsgNode` contract deployed on Sepolia.

    ```bash
    cast send YOUR_SEPOLIA_MSGNODE_ADDRESS "sendMessage(address,uint256,string)" 0x29c68e5d86329d8d8ab22e9113f7d44229928445 84532 "Hello World!" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --legacy
    ```

2.  **Verify the Result**:
    -   **Reactive Network**: Check [Lasna Reactscan](https://lasna.reactscan.net/) to see your `ReactiveContract` execute a `react` transaction.
    -   **Base Sepolia**: The `react` transaction will trigger a callback. Check the Base Sepolia explorer for a `receiveMessage` call on your destination `MsgNode`.
