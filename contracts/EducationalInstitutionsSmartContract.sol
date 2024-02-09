// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/*
Example C: 
    Public schools and universities issues graduation certificates or 
degrees to students.  Students rely on these certificates or degrees 
to seek employment.  Potential employers check the certificates/degrees 
to decide whether to give jobs to the students.   This scenario involves 
a few smart contracts.  One smart contract is from the schools or 
universities.   One smart contract represents the students. The third 
smart contract represents companies and organizations.
*/

// ===========================================================
//           Contract for Educational Institutions
// ===========================================================

contract EducationalInstitutionsSmartContract {

    // For keepping the records of certificate / degree of the student graduated from this institution
    struct Certificate {
        uint256 cid;
        string studentName;
        string degreeName;
        string issueDate;
        string hash; // Hash of the certificate for verification
        bool isValid;
    }

    // Store all the records in a mapping: id(key) - certficate(value)
    mapping(uint => Certificate) private certificates;
    // The owner of the contract, i.e., NTU
    address private owner; 
    // Automatically assign an id for a certificate, initialized to 1 at the beginning
    uint256 private currentCertificateId = 1;

    constructor() {
        // Set the owner of the contract to the account that deploys it
        owner = msg.sender; 
    }

    // Events
    event CertificateIssued(uint256 indexed id, string studentName, string degreeName);
    event CertificateRevoked(uint256 indexed id);
    event CertificateUpdated(uint256 indexed id, string newHash);

    /*
    This contract will allow the institution to:
        - Issue a certificate (for owner use)
        - Revoke a certificate (for owner use)
        - Update a certificate (for owner use)
        - Verify a certificate (for external personnel use)
        - transfer tokens from this SC to the address of this institution
    */

    // Function to issue a certificate
    function issueCertificate
        (string memory studentName, string memory degreeName, string memory issueDate, string memory hash) public {
        
        // must be for example someone from the institution
        require(msg.sender == owner, "Only the owner can issue certificates");
        
        // create a new isntance of a certificate record
        certificates[currentCertificateId] = Certificate(currentCertificateId, studentName, degreeName, issueDate, hash, true);
        emit CertificateIssued(currentCertificateId, studentName, degreeName);

        // update next ID
        currentCertificateId++;
        
    }

    // Function to revoke a certificate
    function revokeCertificate(uint256 certificateId) public {

        // must be for example someone from the institution
        require(msg.sender == owner, "Only the owner can revoke certificates");
        // must be valid before
        require(certificates[certificateId].isValid, "Certificate is already invalid");

        // change the state to 'false'
        certificates[certificateId].isValid = false;
        emit CertificateRevoked(certificateId);

    }

    // Function to update a certificate's hash
    function updateCertificate(uint256 certificateId, string memory newHash) public {
        // ******************************************************************
        // consider to introduce more paramaters to change other attributes
        // *******************************************************************
        require(msg.sender == owner, "Only the owner can update certificates");
        require(certificates[certificateId].isValid, "Cannot update an invalid certificate");

        certificates[certificateId].hash = newHash;
        emit CertificateUpdated(certificateId, newHash);
    }

    // Function to verify a certificate
    function verifyCertificate(uint256 certificateId, string memory hash) public payable returns (bool) {
        // Check if the sent value is equal to 10 ether
        require(msg.value == 10 ether, "Must send 10 ether to verify a certificate");

        Certificate memory cert = certificates[certificateId];
        bool isCertValid = keccak256(abi.encodePacked(cert.hash)) == keccak256(abi.encodePacked(hash));
        return isCertValid;
    }

    function withdraw() public {
        // only owner can call this function
        require(msg.sender == owner, "Only the owner can withdraw");

        // get the current balance of this SC
        uint amount = address(this).balance;

        // transfer all the tokens from this SC to the owner's address
        // Using transfer instead of call to mitigate reentrancy risks
        payable(owner).transfer(amount);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getCertificate(uint256 certificateId) public view returns (Certificate memory) {
        return certificates[certificateId];
    }

    receive() external payable {
        // pass
    }

    fallback() external payable {
        // pass
    }

}

