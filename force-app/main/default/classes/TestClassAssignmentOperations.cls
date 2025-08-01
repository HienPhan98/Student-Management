@isTest
private class TestClassAssignmentOperations {
  @isTest
  static void checkInsertClassAssignment() {
    // Make sure trigger is active
    TestDataFactory.setTriggerFlags(false, true);
    // Set up test data
    TestDataFactory.setManagementSetting(2, 2);
    Map<String, List<SObject>> mapResult = TestDataFactory.createStudentsAndClasses(200,10);
    List<DHA_Student__c> listStudent = mapResult.get('Student');
    List<DHA_Class__c> listClass = mapResult.get('Class');
    List<DHA_Class_Assignment__c> listClassAssignment = new List<DHA_Class_Assignment__c>();

    for (Integer i = 0; i < 3; i++) {
      for (Integer j = 0; j < 3; j++) {
        listClassAssignment.add(
          new DHA_Class_Assignment__c(
            DHA_Student__c = listStudent[i].Id,
            DHA_Class__c = listClass[j].Id
          )
        );
      }
    }

    // Run test
    Test.startTest();
    Database.SaveResult[] saveResults = Database.insert(listClassAssignment,false);
    Test.stopTest();

    // Assertions
    List<String> errors = new List<String>{'This student is attending to too much class.', 'There is no seat to join this class.'};
    for (Database.SaveResult result : saveResults) {
      if (!result.isSuccess()) {
        for (Database.Error error : result.getErrors()) {       
          Assert.areEqual(
            true,
            errors.contains(error.getMessage()),
            'Expect this student and class get error'
          );
        }
      }
    }
  }
}
