// test/Employer_test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EmployerSmartContract", function () {
    let employerSmartContract;
    let owner, addr1, addr2;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        const EmployerSmartContract = await ethers.getContractFactory("EmployerSmartContract");
        employerSmartContract = await EmployerSmartContract.deploy();
        await employerSmartContract.waitForDeployment();
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await employerSmartContract.getOwner()).to.equal(owner.address);
        });
    });

    describe("Employment Offer", function () {
        it("Should allow the owner to make an employment offer", async function () {
            await expect(employerSmartContract.makeEmploymentOffer(addr1.address, "Developer", "2024-01-01", "Engineering"))
                .to.emit(employerSmartContract, "EmploymentOfferMade")
                .withArgs(1, addr1.address, "Developer");
        });

        it("Should fail if a non-authorized user tries to make an offer", async function () {
            await expect(employerSmartContract.connect(addr1).makeEmploymentOffer(addr2.address, "Tester", "2024-02-01", "QA"))
                .to.be.revertedWith("Only the authorized can make offers");
        });

        it("Should allow updating the status of an employment offer", async function () {
            await employerSmartContract.makeEmploymentOffer(addr1.address, "Developer", "2024-01-01", "Engineering");
            await expect(employerSmartContract.updateEmploymentOffer(1, true))
                .to.emit(employerSmartContract, "EmploymentOfferUpdated")
                .withArgs(1, true);
        });
    });

    describe("Employee Management", function () {
        it("Should allow the owner to add an employee", async function () {
            await expect(employerSmartContract.addEmployee(true, addr1.address, "Engineer", "Engineering", 1))
                .to.emit(employerSmartContract, "EmployeeUpdated")
                .withArgs(1, addr1.address);
        });

        it("Should update an employee's information correctly", async function () {
            await employerSmartContract.addEmployee(true, addr1.address, "Engineer", "Engineering", 1);
            await expect(employerSmartContract.updateEmployee(addr1.address, "Senior Engineer", "R&D"))
                .to.emit(employerSmartContract, "UpdateEmployee")
                .withArgs(1, addr1.address, "Senior Engineer", "R&D");
        });

        it("Should retrieve an employee's information correctly", async function () {
            await employerSmartContract.addEmployee(true, addr1.address, "Engineer", "Engineering", 1);
            const employeeInfo = await employerSmartContract.getEmployeeInfo(addr1.address);
            expect(employeeInfo.position).to.equal("Engineer");
            expect(employeeInfo.department).to.equal("Engineering");
        });
    });

    describe("Job Opportunity Management", function () {
        it("Should allow the owner or authorized user to post a job opportunity", async function () {
            await expect(employerSmartContract.postJobOpportunity("Developer", "Develop smart contracts", "2024-01-01"))
                .to.emit(employerSmartContract, "JobOpportunityPosted")
                .withArgs(1, "Developer", 1);
        });

        it("Should allow updating job opportunity information", async function () {
            await employerSmartContract.postJobOpportunity("Developer", "Develop smart contracts", "2024-01-01");
            await expect(employerSmartContract.updateJobOpportunity(1, "Develop dApps", "2024-01-02"))
                .to.emit(employerSmartContract, "JobOpportunityUpdated")
                .withArgs(1, "Developer", "2024-01-02");
        });

        it("Should retrieve job opportunity information correctly", async function () {
            await employerSmartContract.postJobOpportunity("Developer", "Develop smart contracts", "2024-01-01");
            const jobInfo = await employerSmartContract.getJobOpportunity(1);
            expect(jobInfo.position).to.equal("Developer");
            expect(jobInfo.jobDescription).to.equal("Develop smart contracts");
        });

        it("Should allow setting job opportunity state", async function () {
            await employerSmartContract.postJobOpportunity("Developer", "Develop smart contracts", "2024-01-01");
            await expect(employerSmartContract.setJobOpportunityState(1, 2))
                .to.emit(employerSmartContract, "JobOpportunityStateChange")
                .withArgs(1, "Developer", 2);
        });
    });

});

