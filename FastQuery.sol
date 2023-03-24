// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract FastQuery{

    struct EntryIdentity {
        string gene;
        string variant;
        string drug;
    }

    struct EntryData {
        string outcome;
        bool relation;
        bool sideEffect;
    }

    uint256 public counter = 1;
    mapping(uint256 => EntryData) public entryData;
    mapping(uint256 => EntryIdentity) public database;
    mapping(string => uint256[]) private geneMapping;
    mapping(string => uint256[]) private variantMapping;
    mapping(string => uint256[]) private drugMapping;
    mapping(string => mapping(string => mapping(string => uint256))) public idKeeper;

    function insert(string memory _gene, string memory _variant, string memory _drug, string memory _outcome, bool _relation, bool _sideEffect) public {
        EntryIdentity memory entryIdentity = EntryIdentity({gene: _gene, variant: _variant, drug: _drug});
        

        uint256 ID = idKeeper[_gene][_variant][_drug];
        if(ID == 0) {
            idKeeper[_gene][_variant][_drug] = counter;
            ID = counter;
            database[ID] = entryIdentity;
            geneMapping[_gene].push(counter);
            geneMapping["*"].push(counter);
            variantMapping[_variant].push(counter);
            variantMapping["*"].push(counter);
            drugMapping[_drug].push(counter);
            drugMapping["*"].push(counter);
            entryData[ID] = EntryData({outcome: _outcome, relation: _relation, sideEffect: _sideEffect});
            counter = counter + 1;
        }
    }

    function query(string memory _gene, string memory _variant, string memory _drug) public view returns(EntryIdentity[] memory) {
        uint256[] memory idList;
        EntryIdentity[] memory results;
        if(counter == 1) {
            return results;
        } else {
            if(keccak256(abi.encodePacked(_gene)) == keccak256("*") && keccak256(abi.encodePacked(_variant)) == keccak256("*") && keccak256(abi.encodePacked(_drug)) == keccak256("*")) {
                idList = new uint256[](counter);
                results = new EntryIdentity[](counter);
                for(uint i = 1; i < counter; i++) {
                    idList[i - 1] = i;
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
                results = new EntryIdentity[](min);

                uint256 pos = 0;
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
            }

            uint256 index = 0;

            for(uint i = 0; i < idList.length; i++) {
                results[index] = EntryIdentity({gene: database[idList[i]].gene, variant: database[idList[i]].variant, drug: database[idList[i]].drug});
                index = index + 1;
            }
            return results;
        }
    }
}