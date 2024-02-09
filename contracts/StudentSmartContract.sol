// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./EducationalInstitutionsSmartContract.sol";

contract StudentSmartContract {
    struct Certificate {
        uint256 id;
        address institutionAddress;
        bool isShared;
        bool exists; // Field to mark whether the certificate exists
    }

    address private studentOwner;
    Certificate[] private certificateArray;
    uint256 private certificateCount = 0;

    // Events
    event CertificateAdded(uint256 indexed id, address institutionAddress);
    event CertificateShared(uint256 indexed id, bool isShared);
    event CertificateUpdated(uint256 indexed id, address newInstitutionAddress);
    event CertificateRemoved(uint256 indexed id);
    event CertificateValidated(uint256 indexed certificateId, bool isValid);

    constructor() {
        studentOwner = msg.sender; // Sets the contract deployer as the student owner
    }

    // Adds a new certificate or updates an existing one based on the certificate ID
    function addOrUpdateCertificate(uint256 certificateId, address institutionAddress) public {
        require(msg.sender == studentOwner, "Only the student owner can add or update certificates");
        bool found = false;

        for (uint i = 0; i < certificateArray.length; i++) {
            if (certificateArray[i].id == certificateId) {
                certificateArray[i].institutionAddress = institutionAddress;
                certificateArray[i].exists = true; // Ensure it's marked as existing
                emit CertificateUpdated(certificateId, institutionAddress);
                found = true;
                break;
            }
        }

        if (!found) {
            certificateArray.push(Certificate(certificateId, institutionAddress, false, true));
            emit CertificateAdded(certificateId, institutionAddress);
            certificateCount++;
        }
    }

    // Removes a certificate from the array by its ID
    function removeCertificate(uint256 certificateId) public {
        require(msg.sender == studentOwner, "Only the student owner can remove certificates");

        int256 certificateIndex = -1;
        for (uint256 i = 0; i < certificateArray.length; i++) {
            if (certificateArray[i].id == certificateId) {
                certificateIndex = int256(i);
                break;
            }
        }

        require(certificateIndex >= 0, "Certificate ID not found");

        certificateArray[uint256(certificateIndex)] = certificateArray[certificateArray.length - 1];
        certificateArray.pop(); // Removes the last element

        certificateCount--; // Decrement the certificate count
        emit CertificateRemoved(certificateId); // Emit an event for certificate removal
    }

    // Retrieves a certificate's details by its ID
    function getCertificate(uint256 certificateId) public view returns (uint256 id, address institutionAddress, bool isShared, bool exists) {
        for (uint i = 0; i < certificateArray.length; i++) {
            if (certificateArray[i].id == certificateId) {
                Certificate memory cert = certificateArray[i];
                return (cert.id, cert.institutionAddress, cert.isShared, cert.exists);
            }
        }
        revert("Certificate not found.");
    }

    // Returns the current count of certificates
    function getCertificateCount() public view returns (uint256) {
        return certificateCount;
    }

    // Returns details of all certificates
    function getAllCertificates() public view returns (uint256[] memory, address[] memory, bool[] memory, bool[] memory) {
        uint256[] memory ids = new uint256[](certificateCount);
        address[] memory addresses = new address[](certificateCount);
        bool[] memory sharedStatus = new bool[](certificateCount);
        bool[] memory existsStatus = new bool[](certificateCount);

        for (uint i = 0; i < certificateArray.length; i++) {
            ids[i] = certificateArray[i].id;
            addresses[i] = certificateArray[i].institutionAddress;
            sharedStatus[i] = certificateArray[i].isShared;
            existsStatus[i] = certificateArray[i].exists;
        }

        return (ids, addresses, sharedStatus, existsStatus);
    }

    // Allows the student owner to share or unshare a certificate with employers
    function shareCertificate(uint256 certificateId, bool share) public {
        require(msg.sender == studentOwner, "Only the student owner can share certificates");

        for (uint i = 0; i < certificateArray.length; i++) {
            if (certificateArray[i].id == certificateId) {
                certificateArray[i].isShared = share;
                emit CertificateShared(certificateId, share);
                return;
            }
        }
        revert("Certificate ID not found.");
    }

    // Checks if a certificate is shared
    function isCertificateShared(uint256 certificateId) public view returns (bool) {
        for (uint i = 0; i < certificateArray.length; i++) {
            if (certificateArray[i].id == certificateId) {
                return certificateArray[i].isShared;
            }
        }
        revert("Certificate ID not found");
    }

    // Retrieves the institution address associated with a certificate
    function getInstitutionAddress(uint256 certificateId) public view returns (address) {
        for (uint i = 0; i < certificateArray.length; i++) {
            if (certificateArray[i].id == certificateId) {
                return certificateArray[i].institutionAddress;
            }
        }
        revert("Certificate ID not found");
    }

    function validateCertificate(uint256 certificateId, address payable institutionAddress, string memory certificateHash) public payable returns (bool) {
        bool validationSuccess = false;
        for (uint i = 0; i < certificateArray.length; i++) {
            if (certificateArray[i].id == certificateId && certificateArray[i].institutionAddress == institutionAddress) {
                EducationalInstitutionsSmartContract institutionContract = EducationalInstitutionsSmartContract(institutionAddress);
                
                // Call verifyCertificate on the institution contract, forwarding the msg.value
                validationSuccess = institutionContract.verifyCertificate{value: msg.value}(certificateId, certificateHash);
                break;
            }
        }
        
        // Emit the CertificateValidated event with the result
        emit CertificateValidated(certificateId, validationSuccess);

        require(validationSuccess, "Certificate validation failed");
        return validationSuccess;
    }

    function getOwner() public view returns (address) {
        return studentOwner;
    }

    receive() external payable {
        // pass
    }

    fallback() external payable {
        // pass
    }
}

