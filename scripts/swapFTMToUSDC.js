const {
  ethers
} = require("hardhat");

async function main() {
  const deployer = (await ethers.getSigners())[0];
  console.log("deployer address: ", deployer.address);
  const verboseRouter = await ethers.getContractAt("VerboseRouter", "0x17760E8C32BC6AB8907fBE5568D88D67E7386EDb");

  const tx = await verboseRouter.swapExactFTMForTokens(
    [
      "0xf1277d1Ed8AD466beddF92ef448A132661956621",
      "0xbcC3f3d152D0A66035355BBd91787ccFa7399eD6",
    ],
    deployer.address,
    { value: "1" + "0".repeat(17) },
  );
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