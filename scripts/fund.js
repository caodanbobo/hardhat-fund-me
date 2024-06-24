const { getNamedAccounts, ethers } = require("hardhat")

async function main() {
    const { deployer } = await getNamedAccounts()
    const fundMe = await ethers.getContract("FundMe", deployer)
    console.log("Funding Contract...")
    const tx = await fundMe.fund({ value: ethers.utils.parseEther("0.1") })
    await tx.wait(1)

    const balance = await fundMe.provider.getBalance(fundMe.address)

    console.log("Funded!")
    console.log(`contract balance ${ethers.utils.formatEther(balance)}ETH`)
}

main()
    .then(() => {
        process.exit()
    })
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
