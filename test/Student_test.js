// test/Student_test.js

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StudentSmartContract", function () {
    let StudentSmartContract;
    let studentContract;
    let owner;
    let addr1, addr2, instituteAddr;

    beforeEach(async function () {
        // Get the ContractFactory and signers
        StudentSmartContract = await ethers.getContractFactory("StudentSmartContract");
        [owner, addr1, addr2, instituteAddr] = await ethers.getSigners();

        // Deploy a new contract before each test
        studentContract = await StudentSmartContract.deploy();
        await studentContract.waitForDeployment();
        addOrUpdateCertificateTx = await studentContract.addOrUpdateCertificate(1, instituteAddr);
        await addOrUpdateCertificateTx.wait();
    });

    describe("Deployment", function () {
        it("Should set the right studentOwner", async function () {
            // Verify the owner is the same as the deployer
            expect(await studentContract.getOwner()).to.equal(owner.address);
        });
    });

    describe("StudentSmartContract Functionality", function () {
        // Add and Update Certificate
        describe("Add and Update Certificate", function () {
            it("Should add a new certificate", async function () {
                const certificateId = 2;
                await studentContract.addOrUpdateCertificate(certificateId, instituteAddr);
                const cert = await studentContract.getCertificate(certificateId);
                expect(cert.exists).to.equal(true);
                expect(cert.institutionAddress).to.equal(instituteAddr);
            });

            it("Should update an existing certificate", async function () {
                const certificateId = 2;
                const newInstitutionAddress = addr2.address;
                await studentContract.addOrUpdateCertificate(certificateId, newInstitutionAddress);
                const cert = await studentContract.getCertificate(certificateId);
                expect(cert.institutionAddress).to.equal(newInstitutionAddress);
            });

            it("Should not allow unauthorized updates", async function () {
                const certificateId = 2;
                await expect(studentContract.connect(addr1).addOrUpdateCertificate(certificateId, instituteAddr))
                    .to.be.revertedWith("Only the student owner can add or update certificates");
            });
        });

        // Remove Certificate
        describe("Remove Certificate", function () {
            it("Should remove a certificate", async function () {
                const certificateId = 1;
                await studentContract.removeCertificate(certificateId);
                await expect(studentContract.getCertificate(certificateId)).to.be.reverted;
            });

            it("Should not allow unauthorized removal", async function () {
                const certificateId = 1;
                await expect(studentContract.connect(addr1).removeCertificate(certificateId))
                    .to.be.revertedWith("Only the student owner can remove certificates");
            });
        });

        // Query Certificate Details
        describe("Query Certificate Details", function () {
            it("Should retrieve certificate details", async function () {
                const certificateId = 1;
                const cert = await studentContract.getCertificate(certificateId);
                expect(cert.exists).to.equal(true);
            });
        });

        // Share/Unshare Certificate
        describe("Share and Unshare Certificate", function () {
            it("Should share a certificate", async function () {
                const certificateId = 1;
                await studentContract.shareCertificate(certificateId, true);
                const cert = await studentContract.getCertificate(certificateId);
                expect(cert.isShared).to.equal(true);
            });

            it("Should unshare a certificate", async function () {
                const certificateId = 1;
                await studentContract.shareCertificate(certificateId, false);
                const cert = await studentContract.getCertificate(certificateId);
                expect(cert.isShared).to.equal(false);
            });
        });
    });

});



