const {
  ethers
} = require("hardhat");

const v8sAddr = require("../config/contractAddrs.json").v8s;

async function main() {
  const verboseRouter = await ethers.getContractAt("VerboseRouter", "0x17760E8C32BC6AB8907fBE5568D88D67E7386EDb");

  const tx = await verboseRouter.setV8S(v8sAddr, 3);
  await tx.wait();

  console.log("tx hash: ", tx.hash);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
// tx hash:  0x4a7602a30747590709a22190791e34c3ec0f183871877350e8037cb0fcdc320e