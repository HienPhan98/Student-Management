@isTest
private class TestStudentClassController {
  @isTest
  static void checkSearchStudentsWithNameAndBirthdate() {
    //Make sure trigger is inactive for the search function testing purpose only
    TestDataFactory.setTriggerFlags(false, false);

    //setup test data
    Map<String, List<SObject>> mapObjects = TestDataFactory.createStudentsWithClassAssignments(200,10);

    //run test function
    List<DHA_Student__C> searchStudents = StudentClassController.searchStudents('Test Student','2000-01-01',null);

    //validate result
    Assert.areEqual(1,searchStudents.size(),'Expected at least one student with Test Student | 2000-01-01');
  }

  @isTest
  static void checkSearchStudentsWithNameAndValidClass() {
    //Make sure trigger is inactive for the search function testing purpose only
    TestDataFactory.setTriggerFlags(false, false);

    //setup test data
    Map<String, List<SObject>> mapObjects = TestDataFactory.createStudentsWithClassAssignments(200,10);
    List<DHA_Class__c> listClasses = mapObjects.get('Class');

    Id classId = listClasses[0].Id;
    //run test function
    List<DHA_Student__C> searchStudents = StudentClassController.searchStudents('Test Student','2000-01-01',classId);

    //validate result
    Assert.areEqual(1,searchStudents.size(),'Expected at least one student with Test Student | 2000-01-01 | ' + classId);
  }

  @isTest
  static void checkSearchStudentsWithNameAndInvalidClass() {
    //Make sure trigger is inactive for the search function testing purpose only
    TestDataFactory.setTriggerFlags(false, false);

    //setup test data
    Map<String, List<SObject>> mapObjects = TestDataFactory.createStudentsWithClassAssignments(200,10);
    List<DHA_Class__c> listClasses = mapObjects.get('Class');
    Id classId = listClasses[listClasses.size()-1].Id; //last Class is not assigned to any student
    //run test function
    List<DHA_Student__C> searchStudents = StudentClassController.searchStudents('Test Student','2000-01-01',classId);

    //validate result
    Assert.areEqual(0,searchStudents.size(),'Expected none of student with Test Student | 2000-01-01 | ' + classId); 
  }

  @isTest
  static void checkGetSummaryStudyResultInfo() {
  //Make sure trigger is inactive for the getSummaryStudyResultInfo testing purpose only
  TestDataFactory.setTriggerFlags(false, false);

  //setup test data
  Map<String, List<SObject>> mapObjects = TestDataFactory.createStudentsWithClassAssignments(200,10);
  List<DHA_Student__c> listStudents = mapObjects.get('Student');
  Id studentId = listStudents[0].Id;
  //run test function
  StudentResultInformation sri = StudentClassController.getSummaryStudyResultInfo(studentId);

  //validate result
  Assert.areEqual(9,sri.numberOfAssignedClass,'Expected 9 assigned class for this student Id: ' + studentId);  
  Assert.areEqual('60.00',sri.averageFinalScores[0],'Expected 60 average final score for these assigned class of this student Id: ' + studentId);
  Assert.areEqual(9,sri.numberOfClassHasFinalScore,'Expected 9 assigned class has final score for this student Id: ' + studentId); 
  }

  @isTest
  static void checkGetDetailStudyResultInfoV2() {
  //Make sure trigger is inactive for the getSummaryStudyResultInfo testing purpose only
  TestDataFactory.setTriggerFlags(false, false);

  //setup test data
  Map<String, List<SObject>> mapObjects = TestDataFactory.createStudentsWithClassAssignments(200,10);
  List<DHA_Student__c> listStudents = mapObjects.get('Student');
  Id studentId = listStudents[0].Id;
  //run test function
  List<DHA_Study_Result__c> studyResults = StudentClassController.getDetailStudyResultInfoV2(studentId);
  
  //validate result
  Assert.areEqual('60.00',studyResults[0].Final_Score__c.ToString(),'Expected 60.00 final score for this student Id: ' + studentId);
  Assert.areEqual('Passed',studyResults[0].Result__c,'Expected Pass for this student Id: ' + studentId);
  }

  @isTest
  static void checkGetAllClasses() {
   //Make sure trigger is inactive for the getSummaryStudyResultInfo testing purpose only
  TestDataFactory.setTriggerFlags(false, false);
  //setup test data
  Map<String, List<SObject>> mapObjects = TestDataFactory.createStudentsWithClassAssignments(200,10);
  List<DHA_Class__c> listClasses = StudentClassController.getAllClasses();
   //validate result
  Assert.areEqual(10,listClasses.size(),'Expected 10 classes returned');
  }
}
