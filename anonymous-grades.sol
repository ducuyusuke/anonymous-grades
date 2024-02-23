pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract GradeContract is Ownable {
  using SafeMath for uint256;

  // Important! These "events" are what we are actually adding to the blockchain
  event NewStudent(address indexed student, string name);
  event NewGrade(address indexed student, string subject, uint8 grade, uint256 date);

  struct Grade {
    string subject;
    uint8 grade;
    uint256 date;
  }

  Grade[] internal grades;
  uint256 public gradeCount;

  mapping(uint256 => address) internal gradeIdToStudent;
  mapping(string => address) internal studentNameToAddress;
  mapping(address => string) internal addressToStudentName;
  mapping(address => uint256) internal studentToGradeCount;


  modifier addressIsStudent(address memory _studentAddress) {
    require(addressToStudentName[_studentAddress] != "", "This address is not a student");
  }

  modifier addressIsNotStudent(address memory _studentAddress) {
    require(addressToStudentName[_studentAddress] == "", "This address already a student");
  }

  modifier nameIsStudent(string memory _studentName) {
    require(studentNameToAddress[_studentName] != address(0), "This name is not a student");
  }

  modifier nameIsNotStudent(address memory _studentName) {
    require(studentNameToAddress[_studentName] == address(0), "This name already a student");
  }

  modifier gradeIsValid (uint8 memory _grade) {
    require(_grade >= 0 && _grade <= 10, "Grade must be between 0 and 10");
  }

  function _becomeStudent(
    string memory _name
  ) internal {
    studentNameToAddress[_name] = msg.sender;
    addressToStudentName[msg.sender] = _name;
  }

  function becomeStudent(
    string memory _name
  )
    external
    addressIsNotStudent(msg.sender)
    nameIsNotStudent(_name)
  {
    _becomeStudent(_name);
    emit NewStudent(msg.sender, _name);
  }

  function _createGrade(
    string memory _subject,
    uint8 memory _grade,
    uint256 memory _date
  ) internal {
    grades.push(Grade(_subject, _grade, _date));
  }

  function createGrade(
    string memory _subject,
    string memory _studentName,
    uint8 memory _grade,
    uint256 memory _date
  )
    external
    onlyOwner
    nameIsStudent(_studentName)
    gradeIsValid(_grade)
  {
    _createGrade(_subject, _grade, _date);
    gradeCount = gradeCount.add(1);
    studentToGradeCount = studentToGradeCount.add(1);
    uint256 id = grades.length.sub(1);
    address studentAddress = studentNameToAddress[_studentName];
    gradeIdToStudent[id] = studentAddress;
    emit NewGrade(studentAddress, _subject, _grade, _date);
  }

  function _getAllGrades()
    internal
    view
    returns (
      string[] memory subjectArray,
      uint8[] memory gradeArray,
      uint256[] memory dateArray
    )
  {
    subjectArray = new string[](gradeCount);
    gradeArray = new uint8[](gradeCount);
    dateArray = new uint256[](gradeCount);
    uint256 index;

    for (uint256 i = 0; i < grades.length; i = i.add(1)) {
        Grade memory iGrade = grades[i];
        subjectArray[index] = iGrade.subject;
        gradeArray[index] = iGrade.grade;
        dateArray[index] = iGrade.date;
        index = index.add(1);
    }
  }

  function getGrades()
    external
    view
    onlyOwner
    returns (
        string[] memory,
        uint8[] memory,
        uint256[] memory
    )
  {
    return _getAllGrades();
  }

  function _getStudentGrades()
    internal
    view
    returns (
      string[] memory subjectArray,
      uint8[] memory gradeArray,
      uint256[] memory dateArray
    )
  {
    subjectArray = new string[](studentToGradeCount(msg.sender));
    gradeArray = new uint8[](studentToGradeCount(msg.sender));
    dateArray = new uint256[](studentToGradeCount(msg.sender));
    uint256 index;

    for (uint256 i = 0; i < grades.length; i = i.add(1)) {
        if (gradeIdToStudent[i] == msg.sender) {
          Grade memory iGrade = grades[i];
          subjectArray[index] = iGrade.subject;
          gradeArray[index] = iGrade.grade;
          dateArray[index] = iGrade.date;
          index = index.add(1);
        }
    }
  }

  function getStudentGrades()
    external
    view
    addressIsStudent(msg.sender)
    returns (
        string[] memory,
        uint8[] memory,
        uint256[] memory
    )
  {
    return _getStudentGrades();
  }
}
