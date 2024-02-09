// test/Interaction_test.js

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Student Contract Interaction with EducationalInstitution Contract", function () {
    let educationalContract;
    let studentContract;
    let owner, addr1, addr2, eduAddr;

    beforeEach(async function () {
        // Deploy the EducationalInstitutionsSmartContract
        const EducationalInstitutions = await ethers.getContractFactory("EducationalInstitutionsSmartContract");
        [owner, addr1, addr2] = await ethers.getSigners();
        educationalContract = await EducationalInstitutions.deploy();
        eduAddr = await educationalContract.getAddress();
        await educationalContract.waitForDeployment();

        // Deploy the StudentSmartContract
        const StudentSmartContract = await ethers.getContractFactory("StudentSmartContract");
        studentContract = await StudentSmartContract.deploy();
        await studentContract.waitForDeployment();

        // Issue a certificate from the educational institution
        const studentName = "Tim Zook";
        const degreeName = "Bachelor of Science";
        const issueDate = "2023-01-01";
        const hash = "hash-of-the-certificate";
        await educationalContract.issueCertificate(studentName, degreeName, issueDate, hash);
    });

    it("Should validate a certificate correctly", async function () {
        // The certificateId for the first issued certificate is assumed to be 1, and the hash used during issuing
        const certificateId = 1;
        const certificateHash = "hash-of-the-certificate";

        // Add the certificate to the StudentSmartContract for testing
        await studentContract.addOrUpdateCertificate(certificateId, eduAddr);

        // Validate the certificate, sending 10 ether with the transaction
        await expect(studentContract.validateCertificate(certificateId, eduAddr, certificateHash, { value: ethers.parseEther("10") }))
            .to.emit(studentContract, "CertificateValidated")
            .withArgs(certificateId, true);

    });
});

describe("EmployerSmartContract Interaction with Educational and Student Contracts", function () {
    let educationalContract, studentContract, employerContract;
    let eduInstitution, student, employer;

    beforeEach(async function () {
        [eduInstitution, student, employer] = await ethers.getSigners();

        // Deploy EducationalInstitutionsSmartContract
        const EducationalContract = await ethers.getContractFactory("EducationalInstitutionsSmartContract");
        educationalContract = await EducationalContract.connect(eduInstitution).deploy();
        eduAddr = await educationalContract.getAddress();
        await educationalContract.waitForDeployment();

        // Deploy StudentSmartContract
        const StudentContract = await ethers.getContractFactory("StudentSmartContract");
        studentContract = await StudentContract.connect(student).deploy();
        studentAddr = await studentContract.getAddress();
        await studentContract.waitForDeployment();

        // Deploy EmployerSmartContract
        const EmployerContract = await ethers.getContractFactory("EmployerSmartContract");
        employerContract = await EmployerContract.connect(employer).deploy();
        await employerContract.waitForDeployment();

        // Issue a certificate and simulate student adding it
        await educationalContract.issueCertificate("Tim Zook", "BSc Computer Science", "2023-05-01", "hash123");
        await studentContract.connect(student).addOrUpdateCertificate(1, eduAddr);
        await studentContract.connect(student).shareCertificate(1, true);
    });

    it("should successfully verify a shared certificate", async function () {
        await expect(employerContract.connect(employer).verifyCertificate(studentAddr, 1, "hash123", { value: ethers.parseEther("10") }))
            .to.emit(employerContract, "CertificateVerified")
            .withArgs(studentAddr, 1, true);
    });


    it("should revert if not enough ether is sent for verification", async function () {
        // Attempt to verify without sending enough ether
        await expect(employerContract.connect(employer).verifyCertificate(studentAddr, 1, "hash123", { value: ethers.parseEther("1") }))
            .to.be.revertedWith("Must send 10 ether to verify a certificate");
    });
});

