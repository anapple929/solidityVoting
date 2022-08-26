// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Voting{
    mapping (bytes32 => uint8) public votesReceived;//候选人姓名编码，票数
    bytes32[] public candidateList;

    //构造函数
    constructor(bytes32[] memory candidateNames)public{
        candidateList = candidateNames;
    }
    //统计总票数
    function totalVotesFor(bytes32 candidate) view public returns (uint8){
        require(validCandidate(candidate));//判断这个候选人在不在列表中
        return votesReceived[candidate];
    }

    //投票，选票+1
    function voteForCandidate(bytes32 candidate)public {
        require(validCandidate(candidate));
        votesReceived[candidate] +=1;
    }

    //判断是否在选民中
    function validCandidate(bytes32 candidate) view public returns(bool){
        for(uint i=0;i<candidateList.length;i++){
            if(candidateList[i] == candidate){
                return true;
            }
        }
        return false;
    }

    function getCandidateLength()view public returns(uint){
        return candidateList.length;
    }
}