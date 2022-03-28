//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./LabelContract.sol";

contract HonestFilter {
    address public factory;
    uint256 public labelsRequired; 
    uint256 public valuesRequired;
    address private labelContract;

    constructor() {
        factory = msg.sender; //to check later if the msg sender is valid 
        require(factory != address(0), "FACTORY DOES NOT EXIST.");
        console.log("Deploying FilterContract.");
    }

    //  Called once by the factory at time of deployment
    function initialize(uint256 _labelsRequired, uint256 _valuesRequired, address _labelContract) external {
        require(msg.sender == factory, "FORBIDDEN");
        labelsRequired = _labelsRequired;
        valuesRequired = _valuesRequired;
        labelContract = _labelContract;
    }

    //returns a uint256 representing the required values that have yet to be audited 
    function getUnknowns(address assetAddress) external view returns (uint256) {
        uint256 labelData = LabelContract(labelContract).getLabelData(assetAddress);
        string[] memory proofs = LabelContract(labelContract).getProofs(assetAddress);
        uint256 _labelsRequired = labelsRequired;
        uint256 unknowns = 0;
        uint256 mask = 1;
        uint256 i = 0;
        while (_labelsRequired > 0) {
            bool currRequired = _labelsRequired & 1 != 0;
            if (currRequired && 
                //proof doesn't exist 
                (i >= proofs.length || 
                    (keccak256(abi.encode(proofs[0])) == keccak256(abi.encode("")))
                )
            ) {
                    unknowns &= mask;
            } 

            //prepare for next bit
            _labelsRequired >>= 1;
            labelData >>= 1;
            mask <<= 1;
        }
        return unknowns;
    }

    //if it passes the filter, this will return 0. 
    function getMissedCriteria(address assetAddress) public view returns (uint256) {
        uint256 labelData = LabelContract(labelContract).getLabelData(assetAddress);
        uint256 rawDataFilterDiff = labelData ^ valuesRequired; // all differences, including nonrequired values
        return rawDataFilterDiff & labelsRequired;
    }

    function assetPassesFilter(address assetAddress) external view returns (bool) {
        return getMissedCriteria(assetAddress) == 0;
    }
}
