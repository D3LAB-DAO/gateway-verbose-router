const {
  ethers
} = require("hardhat");

async function main() {
  const verboseRouter = await ethers.deployContract("VerboseRouter", []);

  await verboseRouter.waitForDeployment();

  console.log("verboseRouter address: ", await verboseRouter.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
// verboseRouter address:  0x17760E8C32BC6AB8907fBE5568D88D67E7386EDb