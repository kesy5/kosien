// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ChallengeSolution {

    struct AllData{
        string gene;
        string variant;
        string drug;
        string outcome;
        bool relation;
        bool sideEffect;
    }

    struct Data{
        string gene;
        string variant;
        string drug;
    }
    
    uint256 private ID;
    uint256[] public uniqueEntriesID;
    mapping(uint256 => Data) public uniqueEntries;
    mapping(string => uint256[]) private geneMapping;
    mapping(string => uint256[]) private variantMapping;
    mapping(string => uint256[]) private drugMapping;
    mapping(uint256 => AllData) public database;
    mapping(bytes32 => uint256) private checkIfExists;

    function insert(string memory _gene, string memory _variant, string memory _drug, string memory _outcome, bool _relation, bool _sideEffect) public {
        AllData memory entry = AllData({gene: _gene, variant: _variant, drug: _drug, outcome: _outcome, relation: _relation, sideEffect: _sideEffect});
        Data memory combine = Data({gene: _gene, variant: _variant, drug: _drug});
        bytes32 hash = keccak256(abi.encodePacked(_gene, _variant, _drug));
        if(checkIfExists[hash] == 0) {
            uniqueEntries[ID] = combine;
            uniqueEntriesID.push(ID);
        }
        geneMapping[_gene].push(ID);
        geneMapping["*"].push(ID);
        variantMapping[_variant].push(ID);
        variantMapping["*"].push(ID);
        drugMapping[_drug].push(ID);
        drugMapping["*"].push(ID);
        database[ID] = entry;
        checkIfExists[hash] = 1;
        ID = ID + 1;
    }



    function query(string memory _gene, string memory _variant, string memory _drug) public view returns(AllData[] memory) {
        uint256[] memory idList;
        AllData[] memory tempResults = new AllData[](ID);
        AllData[] memory results;
        uint pos = 0;
        uint index = 0;
        if(ID == 0) {
            return results;
        } else {
            if(keccak256(abi.encodePacked(_gene)) == keccak256("*") && keccak256(abi.encodePacked(_variant)) == keccak256("*") && keccak256(abi.encodePacked(_drug)) == keccak256("*")) {
                idList = new uint256[](ID);
                for(uint i = 0; i < ID; i++) {
                    idList[i] = i;
                }

                for(uint i = 0; i < uniqueEntriesID.length; i++) {
                    for(uint j = 0; j < idList.length; j++) {
                        if(uniqueEntriesID[i] == idList[j]) {
                            tempResults[index] = AllData({gene: database[idList[j]].gene, variant: database[idList[j]].variant, drug: database[idList[j]].drug, outcome: database[idList[j]].outcome, relation: database[idList[j]].relation, sideEffect: database[idList[j]].sideEffect});
                            index = index + 1;
                        }
                    }
                }
            } else {
                uint256 min = geneMapping[_gene].length;
                if(variantMapping[_variant].length < min) {
                    min = variantMapping[_variant].length;
                }
                if(drugMapping[_drug].length < min) {
                    min = drugMapping[_drug].length;
                }
                idList = new uint256[](min);
                // if(min == geneMapping[_gene].length) {
                //     for(uint i = 0; i < geneMapping[_gene].length; i++) {
                //         idList[i] = geneMapping[_gene][i];
                //     }
                // }

                // if(min == variantMapping[_variant].length) {
                //     for(uint i = 0; i < variantMapping[_variant].length; i++) {
                //         idList[i] = variantMapping[_variant][i];
                //     }  
                // }
                // if(min == drugMapping[_drug].length) {
                //     for(uint i = 0; i < drugMapping[_drug].length; i++) {
                //         idList[i] = drugMapping[_drug][i];
                //     }  
                // }
                for(uint i = 0 ; i < geneMapping[_gene].length; i++) {
                    for(uint j = 0; j < variantMapping[_variant].length; j++) {
                        if(variantMapping[_variant][j] != geneMapping[_gene][i]) continue;
                        for(uint k = 0; k < drugMapping[_drug].length; k++) {
                            if(drugMapping[_drug][k] != variantMapping[_variant][j]) continue;
                            idList[pos] = drugMapping[_drug][k];
                            pos = pos + 1;
                        }
                    }
                }

                for(uint i = 0; i < uniqueEntriesID.length; i++) {
                    for(uint j = 0; j < pos; j++) {
                        if(uniqueEntriesID[i] == idList[j]) {
                            tempResults[index] = AllData({gene: database[idList[j]].gene, variant: database[idList[j]].variant, drug: database[idList[j]].drug, outcome: database[idList[j]].outcome, relation: database[idList[j]].relation, sideEffect: database[idList[j]].sideEffect});
                            index = index + 1;
                        }
                    }
                }
            }
            
            results = new AllData[](index);
            for(uint i = 0; i < index; i++) {
                results[i] = AllData({gene: tempResults[i].gene, variant: tempResults[i].variant, drug: tempResults[i].drug, outcome: tempResults[i].outcome, relation: tempResults[i].relation, sideEffect: tempResults[i].sideEffect});
            }
            return results;
        }
    }
}