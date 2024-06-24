const { assert, expect } = require("chai")
const { deployments, ethers, getNamedAccounts, network } = require("hardhat")

const { developmentChains } = require("../../helper-hard-config")

developmentChains.includes(network.name)
    ? describe.skip
    : describe("FundMe", function () {
          let fundMe
          let deployer
          const sendValue = ethers.utils.parseEther("0.01")
          beforeEach(async function () {
              deployer = (await getNamedAccounts()).deployer
              fundMe = await ethers.getContract("FundMe", deployer)
          })
          it("allow people to fund and withdraw", async () => {
              //await fundMe.fund({ value: sendValue })

              //   const gasPrice = await ethers.provider.getGasPrice()
              //   const higherGasPrice = gasPrice
              //       .mul(ethers.BigNumber.from(10))
              //       .div(ethers.BigNumber.from(9))
              const tx = await fundMe.withdraw()
              const txReceipt = await tx.wait(1)
              console.log(txReceipt)

              const endingBalance = await fundMe.provider.getBalance(
                  fundMe.address
              )
              assert.equal(endingBalance.toString(), "0")
          })
      })
