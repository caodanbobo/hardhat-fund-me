// SPDX-License-Identifier: MIT
//1.pragma
pragma solidity ^0.8.8;
//2.import
import "./PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "hardhat/console.sol";
//3.errors
error FundMe__NotOwner(); //2 * _

//4.natSpec
/**
 * @title A contract for crowd funding
 * @author zliu
 * @notice this contract is to demo
 * @dev This implements price feeds as our library
 */
//5.contract
contract FundMe {
    //5.1 Type Declarations
    using PriceConverter for uint256;

    // 5.2 State variables
    uint256 public constant MINIMUM_USD = 50 * 1e18; //the msg.value is in Wei
    //saving gas using 'constant'
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    //5.3 events
    //5.4 modifiers

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "sender is not owner!");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    //5.5 functions
    ///constructor
    ///receive
    /// fallback
    /// external
    ///public
    ///internal
    ///private
    ////view/pure

    constructor(address priceFeedAddr) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddr);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "not enough"
        );
        console.log("receiving fund from %s", msg.sender);
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        // as a storage array, even reset to length 0, it can be modified by 'push'/'pop'
        //if it is a memory array, once it reset to length 0, you can not add element to it.
        s_funders = new address[](0);

        //1. transfer, auto revert
        //payable (msg.sender).transfer(address(this).balance);

        //2. send, need 'require' to manually revert
        //bool success = payable (msg.sender).send(address(this).balance);
        //require(success,'send fail');

        //3. call, recommanded
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "send fail");
    }

    function cheaperWithdraw() public onlyOwner {
        address[] memory funders = s_funders;
        uint256 len = funders.length;
        for (uint256 i = 0; i < len; i++) {
            address funder = funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        // as a storage array, even reset to length 0, it can be modified by 'push'/'pop'
        //if it is a memory array, once it reset to length 0, you can not add element to it.
        s_funders = new address[](0);

        //1. transfer, auto revert
        //payable (msg.sender).transfer(address(this).balance);

        //2. send, need 'require' to manually revert
        //bool success = payable (msg.sender).send(address(this).balance);
        //require(success,'send fail');

        //3. call, recommanded
        (bool callSuccess, ) = payable(i_owner).call{
            value: address(this).balance
        }("");
        require(callSuccess, "send fail");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
