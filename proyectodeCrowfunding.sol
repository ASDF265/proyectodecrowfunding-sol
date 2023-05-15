// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdfundingProject {
    enum FundraisingState {Opened, Closed}
    
    struct Contribution {
        address contributor;
        uint value;
    }
    struct Project {
        string id;
        string projectName;
        string description;
        FundraisingState state;
        uint funds;
        uint fundraisingGoal;
        address payable author;
    }
    
    Project[] public projects;
    
    mapping(string => Contribution[]) public contributions;
    
    event ProjectFunded(string _projectId , uint _value, uint _funds);
    
    event ChangeProjectState(string _projectId, FundraisingState _newState);
    
    event ProjectCreated(string _projectId, string _projectName, string _description, uint fundraisingGoal);
    
    modifier onlyOwnerChangeState(uint index) {
        Project memory project = projects[index];
        require(project.author == msg.sender, "Only owner can change the state");
        _;
    }
    modifier sendFunds(uint index) {
        Project memory project = projects[index];
        require(project.author != msg.sender, "The owner can't send funds to his project");
        _;
    }
    
    function createProject(string memory _id, string memory _projectName, string memory _description, uint _fundraisingGoal) public {
        require(_fundraisingGoal > 0, "fundraising goal must be greater than 0");
        Project memory project = Project(_id, _projectName, _description, FundraisingState.Opened , 0 , _fundraisingGoal, payable(msg.sender));
        projects.push(project);
        emit ProjectCreated(_id, _projectName, _description, _fundraisingGoal);
    }
    
    function fundProject(uint index) public payable sendFunds(index) {
        Project memory project = projects[index];
        require(project.state == FundraisingState.Opened, "This project is already closed, you can't send funds");
        require(msg.value > 0, "You need to give a value greater than zero");
        project.author.transfer(msg.value);
        project.funds += msg.value;
        projects[index] = project;
        contributions[project.id].push(Contribution(msg.sender, msg.value));
        emit ProjectFunded(project.id, msg.value, project.funds);
    }
    function changeProjectState(uint index, FundraisingState _newState) public onlyOwnerChangeState(index) {
        Project memory project = projects[index];
        require(project.state != _newState, "You should change the new state, this is the same as the last one");
        project.state = _newState;
        projects[index] = project;
        emit ChangeProjectState(project.id, _newState);
    }
}