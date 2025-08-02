@isTest
private class TestStudyResultOperations {
  @isTest
  static void checkUpdateStudyResultWithInvalidPassScore() {
    // Make sure trigger is active
  TestDataFactory.setTriggerFlags(false, false, true);

   // Set up test data
    TestDataFactory.setManagementSetting(null, null, 100);
    Map<String, List<SObject>> mapResult = TestDataFactory.createStudentsWithClassAssignments(200,10);
    List<DHA_Study_Result__c> listStudyResult = mapResult.get('StudyResult');

    for(DHA_Study_Result__c sr : listStudyResult){
        sr.Score_1__c = 30;
        sr.Score_2__c = 30;
        sr.Score_3__c = 30;
    }

    // Run test
    Test.startTest();
    Database.SaveResult[] saveResults = Database.update(listStudyResult,false);
    Test.stopTest();

    // Assertions
    for(Database.SaveResult result : saveResults){
        if(!result.isSuccess()){
            Assert.areEqual(1, result.getErrors().size(), 'Expected one error should be inserted');
        }
    }
  }
}
