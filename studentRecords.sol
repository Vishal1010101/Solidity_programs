pragma solidity ^0.5.1;

contract studentRecord{
    
    address internal owner;
    
    constructor() internal onlyOwner{
        owner = msg.sender;
    }
    
    struct Student{
        string name;
        uint age;                   
        string courses;          
        uint year;            
        address rollno;       
    }
    
    Student[] internal allStudents;

    function createStudentRecords(string memory _stuName, uint _stuAge,string memory _stuCourses, uint _stuYear)  public onlyOwner{
        Student memory newStudent = Student({
            name: _stuName,
            age: _stuAge,
            courses : _stuCourses, 
            year : _stuYear,
            rollno : msg.sender
        });
        allStudents.push(newStudent);
    }
    
    function displayRecords(uint index) public view returns(string memory, string memory, uint, address){
        return(allStudents[index].name, allStudents[index].courses, allStudents[index].age, allStudents[index].rollno);
    }
    
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

}