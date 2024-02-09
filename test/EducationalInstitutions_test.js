// test/EducationalInstitutions_test.js

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EducationalInstitutionsSmartContract", function () {
    let contract, owner, addr1, addr2;

    beforeEach(async function () {
        // Deploy the contract before each test
        [owner, addr1, addr2] = await ethers.getSigners();
        const ContractFactory = await ethers.getContractFactory("EducationalInstitutionsSmartContract");
        contract = await ContractFactory.deploy();
        await contract.waitForDeployment();
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await contract.getOwner()).to.equal(owner.address);
        });
    });

    describe("EducationalInstitutionsSmartContract Functionality", function () {
        describe("Issue Certificate", function () {
            it("Should allow the owner to issue a certificate", async function () {
                await contract.issueCertificate("Tim Zook", "Bachelor of Science", "2021-05-15", "hashvalue");
                const certificate = await contract.getCertificate(1);
                expect(certificate.studentName).to.equal("Tim Zook");
                expect(certificate.isValid).to.be.true;
            });

            it("Should fail if a non-owner tries to issue a certificate", async function () {
                await expect(contract.connect(addr1).issueCertificate("Tom Zook", "Master of Science", "2022-06-18", "hashvalue"))
                    .to.be.revertedWith("Only the owner can issue certificates");
            });
        });

        describe("Revoke Certificate", function () {
            beforeEach(async function () {
                // Issue a certificate for testing revocation
                await contract.issueCertificate("Tim Zook", "Bachelor of Science", "2021-05-15", "hashvalue");
            });

            it("Should allow the owner to revoke a certificate", async function () {
                await contract.revokeCertificate(1);
                const certificate = await contract.getCertificate(1);
                expect(certificate.isValid).to.be.false;
            });

            it("Should fail if a non-owner tries to revoke a certificate", async function () {
                await expect(contract.connect(addr1).revokeCertificate(1))
                    .to.be.revertedWith("Only the owner can revoke certificates");
            });

        });

        describe("Update Certificate", function () {
            beforeEach(async function () {
                // Issue a certificate for testing update
                await contract.issueCertificate("Tim Zook", "Master of Arts", "2022-06-18", "hash_original");
            });

            it("Should allow the owner to update a certificate's hash", async function () {
                await contract.updateCertificate(1, "hash_updated");
                const certificate = await contract.getCertificate(1);
                expect(certificate.hash).to.equal("hash_updated");
            });

            it("Should fail if a non-owner tries to update a certificate", async function () {
                await expect(contract.connect(addr1).updateCertificate(1, "hash_updated"))
                    .to.be.revertedWith("Only the owner can update certificates");
            });

        });

        describe("Verify Certificate", function () {
            let payment;

            beforeEach(async function () {
                // Issue a certificate for testing verification
                await contract.issueCertificate("Tim Zook", "Bachelor of Science", "2021-05-15", "hash_here");
                payment = { value: ethers.parseEther("10") }; // Prepare 10 Ether payment
            });

            it("Should verify a valid certificate with correct payment", async function () {
                // Execute the verifyCertificate function with correct parameters and payment
                await expect(await contract.connect(addr1).verifyCertificate(1, "hash_here", payment))
                    .to.changeEtherBalance(contract, ethers.parseEther("10")); // Check if 10 Ether was transferred to the contract
            });

            it("Should fail to verify without sending 10 ether", async function () {
                // Attempt to verify without sending 10 Ether
                const insufficientPayment = { value: ethers.parseEther("1") }; // Only sending 1 Ether
                await expect(contract.connect(addr1).verifyCertificate(1, "hash_here", insufficientPayment))
                    .to.be.revertedWith("Must send 10 ether to verify a certificate");
            });
        });


    })
});
