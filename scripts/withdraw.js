const { getNamedAccounts, ethers } = require("hardhat")

async function main() {
    const { deployer } = await getNamedAccounts()
    const fundMe = await ethers.getContract("FundMe", deployer)
    console.log("Withdraw Contract...")
    const startingBalance = await fundMe.provider.getBalance(deployer)
    const tx = await fundMe.withdraw()

    await tx.wait(1)

    const endingbalance = await fundMe.provider.getBalance(deployer)

    console.log("withdr!")
    console.log(
        `funded total:${ethers.utils.formatEther(
            endingbalance.sub(startingBalance)
        )}ETH`
    )
}

main()
    .then(() => {
        process.exit()
    })
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
