pragma solidity ^0.4.24;

import "../modules/STO/STO.sol";
import "../interfaces/ISecurityToken.sol";

/**
 * @title STO module for sample implementation of a different crowdsale module
 */
contract DummySTO is STO {

    bytes32 public constant ADMIN = "ADMIN";

    uint256 public investorCount;

    uint256 public cap;
    string public someString;

    event GenerateTokens(address _investor, uint256 _amount);

    mapping (address => uint256) public investors;

    /**
     * @notice Constructor
     * @param _securityToken Address of the security token
     * @param _polyAddress Address of the polytoken
     */
    constructor (address _securityToken, address _polyAddress) public
    Module(_securityToken, _polyAddress)
    {
    }

    /**
     * @notice Function used to intialize the differnet variables
     * @param _startTime Unix timestamp at which offering get started
     * @param _endTime Unix timestamp at which offering get ended
     * @param _cap Maximum No. of tokens for sale
     * @param _someString Any string that contails the details
     */
    function configure(uint256 _startTime, uint256 _endTime, uint256 _cap, string _someString) public onlyFactory {
        startTime = _startTime;
        endTime = _endTime;
        cap = _cap;
        someString = _someString;
    }

    /**
     * @notice This function returns the signature of configure function
     */
    function getInitFunction() public pure returns (bytes4) {
        return bytes4(keccak256("configure(uint256,uint256,uint256,string)"));
    }

    /**
     * @notice Function used to generate the tokens
     * @param _investor Address of the investor
     * @param _amount Amount of ETH or Poly invested by the investor
     */
    function generateTokens(address _investor, uint256 _amount) public withPerm(ADMIN) {
        require(!paused, "Should not be paused");
        require(_amount > 0, "Amount should be greater than 0");
        ISecurityToken(securityToken).mint(_investor, _amount);
        if (investors[_investor] == 0) {
            investorCount = investorCount + 1;
        }
        //TODO: Add SafeMath maybe
        investors[_investor] = investors[_investor] + _amount;
        emit GenerateTokens (_investor, _amount);
    }

    /**
     * @notice Returns the total no. of investors
     */
    function getNumberInvestors() public view returns (uint256) {
        return investorCount;
    }

    /**
     * @notice Returns the total no. of investors
     */
    function getTokensSold() public view returns (uint256) {
        return 0;
    }

    /**
     * @notice Returns the permissions flag that are associated with STO
     */
    function getPermissions() public view returns(bytes32[]) {
        bytes32[] memory allPermissions = new bytes32[](1);
        allPermissions[0] = ADMIN;
        return allPermissions;
    }

    function () payable {
        //Payable fallback function to allow us to test leaking ETH
    }

}
