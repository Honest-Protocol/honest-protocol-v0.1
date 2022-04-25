//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./LabelContract.sol";

contract HonestFilter {
    address public factory;
    uint256 public labelsRequired;
    uint256 public valuesRequired;
    address private labelContract;
    string public name;

    constructor() {
        factory = msg.sender; //to check later if the msg sender is valid
        require(factory != address(0), "FACTORY DOES NOT EXIST.");
        console.log("Deploying FilterContract.");
    }

    function isValidRequirement(uint256 mask, uint256 numLabels)
        private
        pure
        returns (bool)
    {
        uint256 labelsUsed;
        for (labelsUsed = 0; mask > 0; mask >>= 1) labelsUsed += 1;
        return labelsUsed <= numLabels;
    }

    function valueReqsFitLabelReqs(
        uint256 _labelsRequired,
        uint256 _valuesRequired
    ) private pure returns (bool) {
        for (
            uint256 i = 1;
            i <= _labelsRequired && i <= _valuesRequired;
            i <<= 1
        ) {
            if (
                (i & _valuesRequired != 0) && (i & _labelsRequired == 0) // valueRequired is 1 for that label
            ) {
                //labelRequired is 0 for that label
                return false;
            }
        }
        return true;
    }

    //  Called by the factory at time of deployment
    function initialize(
        uint256 _labelsRequired,
        uint256 _valuesRequired,
        string calldata _name,
        address _labelContract
    ) external {
        require(msg.sender == factory, "FORBIDDEN");
        uint256 allLabels = LabelContract(_labelContract).getAllLabels().length;
        require(
            isValidRequirement(_labelsRequired, allLabels),
            "labelsRequired must use existing labels"
        );
        require(
            isValidRequirement(_valuesRequired, allLabels),
            "valuesRequired must use existing labels"
        );
        require(
            valueReqsFitLabelReqs(_labelsRequired, _valuesRequired),
            "can only require a TRUE for a required label"
        );
        labelsRequired = _labelsRequired;
        valuesRequired = _valuesRequired;
        labelContract = _labelContract;
        name = _name;
    }

    //returns a uint256 representing the required values that have yet to be audited
    function getUnknowns(address assetAddress) external view returns (uint256) {
        string[] memory allLabels = LabelContract(labelContract).getAllLabels();
        string[] memory proofs = LabelContract(labelContract).getProofs(
            assetAddress
        );
        uint256 _labelsRequired = labelsRequired;
        uint256 unknowns = 0;
        uint256 mask = 1;
        uint256 i = 0;
        while (i < allLabels.length) {
            bool currRequired = (_labelsRequired & 1) != 0;
            if (
                currRequired &&
                //proof doesn't exist
                (i >= proofs.length ||
                    (keccak256(abi.encode(proofs[i])) ==
                        keccak256(abi.encode(""))))
            ) {
                unknowns |= mask;
            }

            //prepare for next bit
            _labelsRequired >>= 1;
            mask <<= 1;
            i++;
        }
        return unknowns;
    }

    //if it passes the filter, this will return 0.
    function getMissedCriteria(address assetAddress)
        public
        view
        returns (uint256)
    {
        uint256 labelData = LabelContract(labelContract).getLabelData(
            assetAddress
        );
        uint256 rawDataFilterDiff = labelData ^ valuesRequired; // all differences, including nonrequired values
        return rawDataFilterDiff & labelsRequired;
    }

    function assetPassesFilter(address assetAddress)
        external
        view
        returns (bool)
    {
        return getMissedCriteria(assetAddress) == 0;
    }
}
