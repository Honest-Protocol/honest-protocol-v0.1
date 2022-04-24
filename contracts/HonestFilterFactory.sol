pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./HonestFilter.sol";

contract FilterFactory {
    mapping(uint256 => mapping(uint256 => address)) public getFilterAddress;   //pairing of filtermap -> filtercontract address 
    address public labelContract;
    address[] private allFilters;

    event FilterCreated(uint256 labelsRequired, uint256 valuesRequired, address newFilter, uint); 

    constructor() {
        console.log("Deploying factory filter");
        labelContract = address(0); // TODO: add actual conract later 
    }

    function createFilter(uint256 labelsRequired, uint256 valuesRequired) external returns (address newFilter) {
        require(getFilterAddress[labelsRequired][valuesRequired] == address(0), "FILTER ALREADY EXISTS.");
        console.log("Creating Filter");
        bytes memory bytecode = type(HonestFilter).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(labelsRequired, valuesRequired));
        assembly {
            //new address of filter
            newFilter := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        HonestFilter(newFilter).initialize(labelsRequired, valuesRequired, labelContract);
        getFilterAddress[labelsRequired][valuesRequired] = newFilter;
        allFilters.push(newFilter);
        emit FilterCreated(labelsRequired, valuesRequired, newFilter, allFilters.length);
    }

    function getMissedCriteria(address asset, uint256 labelsRequired, uint256 valuesRequired) external view returns (uint256 passes) {
        address filter = getFilterAddress[labelsRequired][valuesRequired];
        require(filter != address(0), "FILTER DOES NOT EXIST.");
        misses = HonestFilter(filter).getMissedCriteria(asset);
    }
}
