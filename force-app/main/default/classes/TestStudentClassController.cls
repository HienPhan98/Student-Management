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
}
