// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract VotingSystem {
    address private owner;

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Election {
        string name;
        uint256 electionId; // Unique identifier for each election
        mapping(address => bool) hasVoted;
        mapping(uint256 => Candidate) candidates;
        uint256 candidateCount;
    }

    mapping(uint256 => Election) private elections;
    uint256 private electionCount;
    mapping(address => bool) private registeredVoters;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this operation.");
        _;
    }

    modifier onlyRegisteredVoter() {
        require(registeredVoters[msg.sender], "Only registered voters can interact.");
        _;
    }

    constructor() {
        owner = msg.sender;
        electionCount = 0;
    }

    function registerVoter(address _voterAddress) public onlyOwner {
        registeredVoters[_voterAddress] = true;
    }

    function createElection(string memory _name, string[] memory _candidateNames) public onlyOwner {
        uint256 electionId = electionCount++;
        Election storage newElection = elections[electionId];
        newElection.name = _name;
        newElection.electionId = electionId;

        for (uint256 i = 0; i < _candidateNames.length; i++) {
            newElection.candidates[i] = Candidate({
                name: _candidateNames[i],
                voteCount: 0
            });
            newElection.candidateCount++;
        }
    }

    function vote(uint256 _electionId, uint256 _candidateIndex) public onlyRegisteredVoter {
        Election storage election = elections[_electionId];
        require(!election.hasVoted[msg.sender], "You have already voted in this election.");
        require(_candidateIndex < election.candidateCount, "Invalid candidate index.");

        election.candidates[_candidateIndex].voteCount++;
        election.hasVoted[msg.sender] = true;
    }

    function getElectionCount() public view returns (uint256) {
        return electionCount;
    }

    function getElection(uint256 _electionId) public view returns (string memory name, uint256 candidateCount) {
        Election storage election = elections[_electionId];
        return (election.name, election.candidateCount);
    }

    function getCandidate(uint256 _electionId, uint256 _candidateIndex) public view returns (string memory name, uint256 voteCount) {
        Election storage election = elections[_electionId];
        require(_candidateIndex < election.candidateCount, "Invalid candidate index.");
        Candidate storage candidate = election.candidates[_candidateIndex];
        return (candidate.name, candidate.voteCount);
    }
}
