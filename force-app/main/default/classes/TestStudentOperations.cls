/**
 * @description: Test methods on DHA_Student__c operations
 * @created: 2025/07/29 Hien Phan
 */
@isTest
private class TestStudentOperations {
  @isTest
  static void checkInsertStudentWithShortNameAndBirthdate() {
     // Make sure trigger is active
    TestDataFactory.setTriggerFlags(true,false);
    // Set up test data
    List<DHA_Student__c> students = TestDataFactory.createStudents(
      200,
      'H',
      Date.newInstance(1990, 1, 1)
    );

    Test.startTest();
    Database.SaveResult[] results = Database.insert(students, false);
    Test.stopTest();
    for (Integer i = 0; i < results.size(); i++) {
      if (!results[i].isSuccess()) {
        for (Database.Error err : results[i].getErrors()) {
          System.debug(err.getMessage());
          Assert.areEqual(
            false,
            err.getFields().isEmpty(),
            'Expected at least one field in the error.'
          );
        }
      }
    }
  }

  @isTest
  static void checkInsertStudentWithInvalidAge() {
     // Make sure trigger is active
    TestDataFactory.setTriggerFlags(true,false);
    // Set up test data
    List<DHA_Student__c> students = TestDataFactory.createStudents(
      200,
      'ValidName',
      Date.today()
    );

    Test.startTest();
    Database.SaveResult[] results = Database.insert(students, false);
    Test.stopTest();
    for (Database.SaveResult sr : results) {
      for (Database.Error err : sr.getErrors()) {
        Assert.areEqual(
          false,
          err.getFields().isEmpty(),
          'Expected at least one field in the error.'
        );
      }
    }
  }

  @isTest
  static void checkUpdateStudentWithInvalidAgeAndShortName() {
     // Make sure trigger is active
    TestDataFactory.setTriggerFlags(true,false);
    
    List<DHA_Student__c> students = TestDataFactory.createStudents(
      200,
      'ValidName',
      Date.newInstance(2000, 1, 1)
    );
    insert students;

    for (DHA_Student__c st : students) {
      st.Name = 'V';
      st.Birthdate__c = Date.today();
    }

    Test.startTest();
    Database.SaveResult[] results = Database.update(students, false);
    Test.stopTest();
     for (Database.SaveResult sr : results) {
      for (Database.Error err : sr.getErrors()) {
        Assert.areEqual(
          false,
          err.getFields().isEmpty(),
          'Expected at least one field in the error.'
        );
      }
    }
  }
}
