pragma solidity ^0.5.0;

import "../ModuleFactory.sol";
import "../../libraries/Util.sol";
import "../../proxy/CountTransferManagerProxy.sol";
import "../../interfaces/IBoot.sol";

/**
 * @title Factory for deploying CountTransferManager module
 */
contract CountTransferManagerFactory is ModuleFactory {

    address public logicContract;

    /**
     * @notice Constructor
     * @param _setupCost Setup cost of the module
     * @param _usageCost Usage cost of the module
     * @param _subscriptionCost Subscription cost of the module
     * @param _logicContract Contract address that contains the logic related to `description`
     */
    constructor(
        uint256 _setupCost,
        uint256 _usageCost,
        uint256 _subscriptionCost,
        address _logicContract
    ) 
        public ModuleFactory(_setupCost, _usageCost, _subscriptionCost) 
    {
        require(_logicContract != address(0), "Invalid address");
        version = "2.1.0";
        name = "CountTransferManager";
        title = "Count Transfer Manager";
        description = "Restrict the number of investors";
        compatibleSTVersionRange["lowerBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));
        compatibleSTVersionRange["upperBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));
        logicContract = _logicContract;
    }

    /**
     * @notice Used to launch the Module with the help of factory
     * @param _data Data used for the intialization of the module factory variables
     * @return address Contract address of the Module
     */
    function deploy(bytes calldata _data) external returns(address) {
        address polyToken = _takeFee();
        address countTransferManager = address(new CountTransferManagerProxy(msg.sender, polyToken, logicContract));
        require(Util.getSig(_data) == IBoot(countTransferManager).getInitFunction(), "Provided data is not valid");
        bool success;
        /*solium-disable-next-line security/no-low-level-calls*/
        (success, ) = countTransferManager.call(_data);
        require(success, "Unsuccessful call");
        /*solium-disable-next-line security/no-block-members*/
        emit GenerateModuleFromFactory(countTransferManager, getName(), address(this), msg.sender, setupCost, now);
        return countTransferManager;

    }

    /**
     * @notice Type of the Module factory
     */
    function getTypes() external view returns(uint8[] memory) {
        uint8[] memory res = new uint8[](1);
        res[0] = 2;
        return res;
    }

    /**
     * @notice Returns the instructions associated with the module
     */
    function getInstructions() external view returns(string memory) {
        return "Allows an issuer to restrict the total number of non-zero token holders";
    }

    /**
     * @notice Get the tags related to the module factory
     */
    function getTags() external view returns(bytes32[] memory) {
        bytes32[] memory availableTags = new bytes32[](2);
        availableTags[0] = "Count";
        availableTags[1] = "Transfer Restriction";
        return availableTags;
    }
}
