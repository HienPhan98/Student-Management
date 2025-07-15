public without sharing class DHA_StudyResultTriggerHandler {
  public static void onBeforeUpdate(
    List<DHA_Study_Result__c> newRecords,
    Integer passScore
  ) {
    for (DHA_Study_Result__c result : newRecords) {
      if ((Integer) result.Final_Score__c < passScore) {
        result.Final_Score__c.addError('Cannot update this result because Final Score is less than ' + passScore);
      }
    }
  }
}
