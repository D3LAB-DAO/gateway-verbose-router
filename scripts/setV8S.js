const {
  ethers
} = require("hardhat");

const v8sAddr = require("../config/contractAddrs.json").v8s;

async function main() {
  const verboseRouter = await ethers.getContractAt("VerboseRouter", "0x17760E8C32BC6AB8907fBE5568D88D67E7386EDb");

  const tx = await verboseRouter.setV8S(v8sAddr, 6);
  await tx.wait();

  console.log("tx hash: ", tx.hash);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
// tx hash:  0x80547be158edae8c1e1c9fa69e5a15c65af13f22f24c599b00931a59a9afe772