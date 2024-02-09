// scripts/deploy.js

const hre = require("hardhat");

async function main() {
    console.log("Deploying EducationalInstitutionsSmartContract......")
    const EducationalInstitutions = await hre.ethers.getContractFactory("EducationalInstitutionsSmartContract");
    const educationalInstitutions = await EducationalInstitutions.deploy();

    await educationalInstitutions.waitForDeployment();
    const institutionAddr = await educationalInstitutions.getAddress();
    console.log("EducationalInstitutionsSmartContract deployed at:", institutionAddr);

    console.log("Deploying StudentSmartContract......")
    const StudentSmartContract = await hre.ethers.getContractFactory("StudentSmartContract");
    const studentSmartContract = await StudentSmartContract.deploy();

    await studentSmartContract.waitForDeployment();
    const studentAddr = await studentSmartContract.getAddress();
    console.log("StudentSmartContract deployed at:", studentAddr);

    console.log("Deploying EmployerSmartContract......")
    const EmployerSmartContract = await hre.ethers.getContractFactory("EmployerSmartContract");
    const employerSmartContract = await EmployerSmartContract.deploy();

    await employerSmartContract.waitForDeployment();
    const employerAddr = await employerSmartContract.getAddress();
    console.log("EmployerSmartContract deployed at:", employerAddr);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
