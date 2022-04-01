pragma solidity ^0.8.0;

import "hardhat/console.sol";
//assumes that any string argument in a function is already properly formatted (ex. labelName)


contract LabelContract {
    // Each asset item will map to one of these
    struct LabelData {
        uint256 labelValues;  //Ex: 0101001010 gets converted into whether each label is "on" or "off"
        string[] proofs;     //array of pointers to storage of proofs 
    }

    mapping(string => uint256) public labelIndices;     // pairing of label name -> index storage of each label

    mapping(address => LabelData) private labelInfo;   // pairing of NFT address -> Label struct
    string[] private allLabels;                 // array storage of label - order corresponding to position of the label 
    address private owner;
    mapping(address => bool) public whiteListedAuditors;

    event NewLabelAdded(string labelName, uint256 labelIndex); 

    constructor() {
        console.log("Deploying LabelContract.");
        owner = msg.sender;
    }

    function getAllLabels() external view returns (string[] memory) {
        return allLabels;
    }

    function addWhitelistAuditor(address newAuditor) public {
        require(owner == msg.sender, "ONLY CONTRACT OWNER CAN ADD NEW AUDITORS");
        whiteListedAuditors[newAuditor] = true;
    }

    function getLabelOfAsset(address asset, uint256 labelIndex) public view returns (bool) {
        require(labelIndex < allLabels.length, "Label index does not exist.");
        uint256 labelData = getLabelData(asset);
        return ((labelData >> labelIndex) & 1) != 0; //gets nth bit, where n is labelIndex
    }

    function getLabelOfAsset(address asset, string calldata labelName) external view returns (bool) {
        require(labelExists(labelName), "No such label name exists.");
        uint256 index = labelIndices[labelName];
        return getLabelOfAsset(asset, index);
    }
    
    //_address is of the nft collection
    function getLabelData(address asset) public view returns (uint256) {
        uint256 retVal = labelInfo[asset].labelValues;
        return retVal; // Defaults to a LabelData with no real value (or proofs)
    }

    function getProofs(address asset) external view returns (string[] memory) {
        return labelInfo[asset].proofs;
    }

    function labelExists(string calldata _label) public view returns (bool) {
        //label is not the first one (but exists), or label is the first one
        return labelIndices[_label] > 0 || (
                allLabels.length > 0 && 
                keccak256(abi.encode(allLabels[0])) != keccak256(abi.encode(_label))
        );
    }

    //creates original Label 
    function addLabel(string calldata _newLabel) public {
        require(labelExists(_newLabel), "Label already exists.");  // requires that the label doesn't exist 
        require(whiteListedAuditors[msg.sender], "Auditor/contributor not whitelisted.");
        // Append
        uint256 newIndex = allLabels.length;
        labelIndices[_newLabel] = newIndex;
        allLabels.push(_newLabel);
        emit NewLabelAdded(_newLabel, newIndex);
    }

    function changeLabelValue(address asset, string calldata _label, bool _labelValue, string calldata _labelProof) private {
        uint256 index = labelIndices[_label];
        
        if (!labelExists(_label)) {
            addLabel(_label);
        }

        //add/edit labelValue
        if (_labelValue) { 
            //change to 1
            labelInfo[asset].labelValues |= 1 << index; 
        } else { 
            //change to 0
            labelInfo[asset].labelValues &= ~(1 << index); //& with a uint256 of all 1s except at the index. 
        }
        
        //make sure proofs array can accommodate if it's a new label
        while (index >= labelInfo[asset].proofs.length) {
            labelInfo[asset].proofs.push("");
        }
        //add/edit labelProof (overrides previous value)
        labelInfo[asset].proofs[index] = _labelProof;
    }

    //add/edit label to NFT collection : needs address, String label, uint256 label value, string proof 
    function editLabelData(address asset, string calldata _label, bool _labelValue, string calldata _labelProof) public { 
        require(whiteListedAuditors[msg.sender], "Auditor/contributor not whitelisted.");
        changeLabelValue(asset, _label, _labelValue, _labelProof);
    }

    //labelsToChange, newValues, and proofs must all be in the same order (index i of each refers to the same audit)
    function editMultipleLabelsForAsset(address asset, string[] calldata labelsToChange, bool[] calldata newValues, string[] calldata proofs) external {
        require(whiteListedAuditors[msg.sender], "Auditor/contributor not whitelisted.");
        require(labelsToChange.length == newValues.length, "LabelsToChange parameter array must be same length as newValues parameter array.");
        require(proofs.length == newValues.length, "Proofs parameter array must be same length as newValues parameter array.");

        for (uint256 i = 0; i < labelsToChange.length; i++) {
            changeLabelValue(asset, labelsToChange[i], newValues[i], proofs[i]);
        }
    }

    //assets, newValues, and proofs must all be in the same order (index i of each refers to the same audit)
    function editLabelForMultipleAssets(string calldata labelName, address[] calldata assets, bool[] calldata newValues, string[] calldata proofs) external {
        require(whiteListedAuditors[msg.sender], "Auditor/contributor not whitelisted.");
        require(assets.length == newValues.length, "assets parameter array must be same length as newValues parameter array.");
        require(proofs.length == newValues.length, "Proofs parameter array must be same length as newValues parameter array.");

        for (uint256 i = 0; i < assets.length; i++) {
            changeLabelValue(assets[i], labelName, newValues[i], proofs[i]);
        }
    }

    function getProof(address asset, string calldata _label) public view returns (string memory) { 
        uint256 labelIndex = labelIndices[_label];
        require(labelIndex < labelInfo[asset].proofs.length, "Label data does not exist.");
        string memory proof = labelInfo[asset].proofs[labelIndex];
        require(bytes(proof).length > 0, "Proof does not exist.");
        return proof;
    }
}
