// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./EducationalInstitutionsSmartContract.sol";
import "./StudentSmartContract.sol";

/*
This contract will allow the organizations or companies to:
        Everyone:
            - create verification request of a certificate
            - Retrieve hiring information of a position
        Employees authorized as "1" and the owner:
            - Make, retrieve and update an offer
            - add new employees' information
        Employees authorized as "2" and the owner:
            - Release, retrieve and update hiring information of a position
        Owner:
            - Set employees' authority
            - Retrieve employees' information
*/

contract EmployerSmartContract {
    
    address private employerOwner;
    uint256 private nextOfferId = 1;
    uint256 private nextEmployeeId = 1;
    uint256 private nextJobId = 1;
    mapping(uint256 => EmploymentRecord) private employmentRecords; // Mapping of offer ID to EmploymentRecord
    mapping(address => Employee) private employees; // Mapping of employee address to Employee
    mapping(uint256 => HiringInfo) private hiringInfos; // Mapping of job ID to HiringInfo

    // Records that has been sent out
    struct EmploymentRecord {
        uint256 offerId;
        address studentAddress;
        string position;
        string startDate;
        string department;
        bool accepted;  //Record whether the student accepts the offer or not
    }

    // Records of employees' information
    struct Employee{
        uint256 employeeId;
        address employeeAddress;
        string position;
        string department;
        uint64 authority; //1:Make, read or update offer; 2:Release or update hiring info; 3:All other things
    }

    // Records of hiring information
    struct HiringInfo{
        uint256 jobId;
        string position;
        string jobDescription;
        string issueDate;
        uint64 state; //1:Active; 2:Inactive
    }

    // Events
    event EmploymentOfferMade(uint256 indexed offerId, address studentAddress, string position);
    event EmploymentOfferUpdated(uint256 indexed offerId, bool accepted);
    event EmployeeUpdated(uint256 indexed EmployeeId, address employeeAddress);
    event SetAuthority(uint256 indexed EmployeeId, address employeeAddress, uint64 indexed authority);
    event UpdateEmployee(uint256 indexed EmployeeId, address employeeAddress, string position, string department);
    event JobOpportunityPosted(uint256 indexed jobId, string position, uint64 indexed state);
    event JobOpportunityUpdated(uint256 indexed jobId, string position, string issueDate);
    event JobOpportunityStateChange(uint256 indexed jobId, string position, uint64 indexed state);
    event CertificateVerified(address studentContractAddress, uint256 certificateId, bool verified);

    constructor() {
        employerOwner = msg.sender; // Set the employer as the owner of the contract
    }

    // Function to verify a certificate's authenticity
    function verifyCertificate(address payable studentContractAddress, uint256 certificateId, string memory certificateHash) public payable returns (bool) {
        StudentSmartContract studentContract = StudentSmartContract(studentContractAddress);

        // Ensure the certificate is shared by the student
        require(studentContract.isCertificateShared(certificateId), "Certificate is not shared by the student");

        address payable institutionAddress = payable(studentContract.getInstitutionAddress(certificateId));
        EducationalInstitutionsSmartContract institutionContract = EducationalInstitutionsSmartContract(institutionAddress);

        // Verify the certificate's authenticity
        bool verificationResult = institutionContract.verifyCertificate{value: msg.value}(certificateId, certificateHash);

        // Emit the verification result
        emit CertificateVerified(studentContractAddress, certificateId, verificationResult);

        return verificationResult;
    }

    // Function to make an employment offer
    function makeEmploymentOffer(address studentAddress, string memory position, string memory startDate, string memory department) public {
        require(msg.sender == employerOwner || getAuthority(msg.sender) == 1, "Only the authorized can make offers");

        employmentRecords[nextOfferId] = EmploymentRecord(nextOfferId, studentAddress, position, startDate, department, false);
        emit EmploymentOfferMade(nextOfferId, studentAddress, position);

        nextOfferId++;
    }

    // Function to update the status of an employment offer
    function updateEmploymentOffer(uint256 offerId, bool accepted) public {
        require(msg.sender == employerOwner || getAuthority(msg.sender) == 1, "Only the authorized can update offers");
        require(employmentRecords[offerId].studentAddress != address(0), "Invalid offer ID");

        employmentRecords[offerId].accepted = accepted;
        emit EmploymentOfferUpdated(offerId, accepted);
        
        addEmployee(accepted, employmentRecords[offerId].studentAddress, employmentRecords[offerId].position, employmentRecords[offerId].department, 3);
    }

    // Function to retrieve an employment record
    function getEmploymentRecord(uint256 offerId) public view returns (EmploymentRecord memory) {
        require(msg.sender == employerOwner || getAuthority(msg.sender) == 1, "Only the authorized can read offers");
        require(employmentRecords[offerId].studentAddress != address(0), "Invalid offer ID");
        return employmentRecords[offerId];
    }

    //Function to retrieve an employee's authority
    function getAuthority(address employeeAddress) private view returns (uint64){
        return employees[employeeAddress].authority;
    }

    //Function to add new employee's information
    function addEmployee(bool accepted, address employeeAddress, string memory position, string memory department, uint64 authority) public{
        require(msg.sender == employerOwner || getAuthority(msg.sender) == 1, "Only the authorized can add new employees");
        require(employeeAddress != address(0), "Invalid address");
        if (accepted == true){
            employees[employeeAddress] = Employee({
            employeeId: nextEmployeeId,
            employeeAddress: employeeAddress,
            position: position,
            department: department,
            authority: authority
            });
            nextEmployeeId++;

            emit EmployeeUpdated(nextEmployeeId - 1, employeeAddress);
        }
    }

    //Function to retrieve an employee's information
    function getEmployeeInfo(address employeeAddress) public view returns (Employee memory){
        require(msg.sender == employerOwner, "Only employment owner can read employees' information");
        require(employees[employeeAddress].employeeAddress != address(0), "Employee does not exist");
        return employees[employeeAddress];
    }

    //Function to set employees' authority
    function setAuthority(address employeeAddress, uint64 authority) public returns (bool){
        require(msg.sender == employerOwner, "Only employment owner can set employees' authority");
        require(employees[employeeAddress].employeeId != 0, "Employee does not exist");

        employees[employeeAddress].authority = authority;

        emit SetAuthority(employees[employeeAddress].employeeId, employeeAddress, authority);
        return true;
    }

    //Function to update employees' information
    function updateEmployee(address employeeAddress, string memory position, string memory department) public returns (bool){
        require(msg.sender == employerOwner, "Only employment owner can set employees' information");
        require(employees[employeeAddress].employeeId != 0, "Employee does not exist");

        employees[employeeAddress].position = position;
        employees[employeeAddress].department = department;

        emit UpdateEmployee(employees[employeeAddress].employeeId, employeeAddress, position, department);
        return true;
    }

    //Function to release new hiring inofrmation
    function postJobOpportunity(string memory position, string memory description, string memory issueDate) public{
        require(msg.sender == employerOwner || getAuthority(msg.sender) == 2, "Only the authorized can post new hiring info");

        hiringInfos[nextJobId] = HiringInfo({
            jobId: nextJobId,
            position: position,
            jobDescription: description,
            issueDate: issueDate,
            state: 1});
       
        emit JobOpportunityPosted(nextJobId, position, 1);

        nextJobId++;
    }

    //Function to get hiring information
    function getJobOpportunity(uint256 jobId) public view returns (HiringInfo memory) {
        require(hiringInfos[jobId].jobId != 0, "Invalid job ID");
        return hiringInfos[jobId];
    }

    //Function to update hiring information
    function updateJobOpportunity(uint256 jobId, string memory description, string memory issueDate) public returns (bool){
        require(msg.sender == employerOwner || getAuthority(msg.sender) == 2, "Only the authorized can update hiring info");
        require(hiringInfos[jobId].jobId != 0, "Hiring information does not exist");

        hiringInfos[jobId].jobDescription = description;
        hiringInfos[jobId].issueDate = issueDate;

        emit JobOpportunityUpdated(jobId,  hiringInfos[jobId].position, issueDate);
        return true;
    }

    //Function to set hiring information state
    function setJobOpportunityState(uint256 jobId, uint64 state) public{
        require(msg.sender == employerOwner || getAuthority(msg.sender) == 2, "Only the authorized can set hiring info state");
        require(hiringInfos[jobId].jobId != 0, "Hiring information does not exist");

        hiringInfos[jobId].state = state;

        emit JobOpportunityStateChange(jobId, hiringInfos[jobId].position, state);
    }

    function getOwner() public view returns (address) {
        return employerOwner;
    }

    receive() external payable {
        // pass
    }

    fallback() external payable {
        // pass
    }
}
