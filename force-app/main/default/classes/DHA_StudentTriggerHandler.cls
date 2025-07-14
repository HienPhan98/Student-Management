/**
 * @description: DHA_Student__c object Trigger Handler
 * @created: 2025/07/14 Hien Phan
 */
public without sharing class DHA_StudentTriggerHandler {
  private static void validateStudentFields(List<DHA_Student__c> newRecords) {
    for (DHA_Student__c student : newRecords) {
      if (student.Name.length() < 3) {
        student.Name.addError('This student name is too short.');
      }

      if (student.Birthdate__c.daysBetween(Date.newInstance(1990, 1, 1)) >= 0) {
        student.Birthdate__c.addError('This student birthdate is invalid. Birthdate should be after 1990/01/01');
      }

      Integer currentyear = Date.today().year();
      Integer currentDay = Date.today().day();
      Integer currentMonth = Date.today().month();

      if (student.Birthdate__c.daysBetween(Date.newInstance(currentyear - 6, currentMonth, currentDay)) < 0) {
        student.Birthdate__c.addError('This student age is not enough to attend our classes.');
      }
    }
  }

  public static void onBeforeInsert(List<DHA_Student__c> newRecords) {
    validateStudentFields(newRecords);
  }

  public static void onBeforeUpdate(List<DHA_Student__c> newRecords) {
    validateStudentFields(newRecords);
  }
}
