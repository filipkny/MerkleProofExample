// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MerkleProofExample.sol";

contract MerkleProofExampleTest is Test {
    MerkleProofExample public merkleProofExample;


    string[] dataSequence = [
        "Some data", // A
        "that should", // B
        "be verifier", // C
        "by merkle" // D
    ];
    bytes32[] proof;
    bytes32[] hashedDataSequence;

    function setUp() public {
        merkleProofExample = new MerkleProofExample();
    }

    function testMerkleVerification() public {
        // Hash sequence ABCD
        for (uint256 i = 0; i < dataSequence.length; i++ ) {
            hashedDataSequence.push(keccak256(abi.encodePacked(dataSequence[i]))); // hashing function is keccak256
        }

        // Build Merkle Tree
        bytes32[] storage merkleTree = buildMerkleTree(hashedDataSequence);

        // Extract leaf
        bytes32 leaf = hashedDataSequence[1]; // h_B

        // Extract root
        bytes32 root = merkleTree[merkleTree.length - 1];

        // Create proof
        proof.push(merkleTree[0]); // A
        proof.push(merkleTree[merkleTree.length - 2]); // h_CD

        // Verify
        merkleProofExample.verifyData(proof, root, leaf);
    }

    function buildMerkleTree(bytes32[] storage hashArray) internal returns (bytes32[] storage) {
        uint count = hashArray.length;  // number of leaves
        uint offset = 0;

        while(count > 0) {
            // Iterate 2 by 2, building the hash pairs
            for(uint i = 0; i < count - 1; i += 2) {
                hashArray.push(_hashPair(hashArray[offset + i], hashArray[offset + i + 1]));
            }
            offset += count;
            count = count / 2;
        }
        return hashArray;
    }

    /**
        From MerkleProof.sol
     */
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    /**
        From MerkleProof.sol
     */
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
