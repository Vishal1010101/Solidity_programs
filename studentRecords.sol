pragma solidity ^0.5.1;

contract StudentRecord{
    
    address internal owner;
    uint internal count = 0;
    
    constructor() public{
        owner = msg.sender;
    }
    
    struct Student{
        string name;
        uint age;                   
        string courses;          
        uint year;            
        uint rollno;       
    }
    
    Student[] internal allStudents;

    function createStudentRecords(string memory _stuName, uint _stuAge,string memory _stuCourses, uint _stuYear, uint _stuRollNo)  public onlyOwner{
        Student memory newStudent = Student({
            name: _stuName,
            age: _stuAge,
            courses : _stuCourses, 
            year : _stuYear,
            rollno : _stuRollNo
        });
        allStudents.push(newStudent);
        allStudents[count] = newStudent;
        count++;
    }
    
    function displayRecords(uint index) public view returns(string memory, string memory, uint, uint){
        require(index >=0 && index<= count);
        return(allStudents[index].name, allStudents[index].courses, allStudents[index].age, allStudents[index].rollno);
    }
    
    function displayTotalStudentsCount() public view returns(uint){
        return count;
    }
    
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }
}
