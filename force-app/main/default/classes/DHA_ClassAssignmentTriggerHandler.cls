/**
 * @description: DHA_Class_Assignment__c object Trigger Handler
 * @created: 2025/07/14 Hien Phan
 */
public without sharing class DHA_ClassAssignmentTriggerHandler {
  private static void validateClassAssignmentRule(
    List<DHA_Class_Assignment__c> newRecords,
    Integer maxAssignedClass
  ) {
    Set<Id> newStudentIds = new Set<Id>();
   
    for(DHA_Class_Assignment__c ca : newRecords){
      newStudentIds.add(ca.DHA_Student__c);
    }

    List<AggregateResult> results = [
      SELECT DHA_Student__c, COUNT(Id) total
      FROM DHA_Class_Assignment__c
      WHERE DHA_Student__c IN :newStudentIds
      WITH SECURITY_ENFORCED
      GROUP BY DHA_Student__c
      HAVING COUNT(Id) >= :maxAssignedClass
    ];

    Set<Id> studentExceedAssignedClass = new Set<Id>();
    for(AggregateResult result : results) {
      system.debug('tong cong so lop voi student nay` la` ' + (Integer) result.get('total'));
      studentExceedAssignedClass.add((Id) result.get('DHA_Student__c'));
    }
   
    for (DHA_Class_Assignment__c ca : newRecords) { 
        if(studentExceedAssignedClass.contains(ca.DHA_Student__c)){
            ca.DHA_Student__c.addError('This student is attending to too much class.');
        }
    }
  }

  public static void onBeforeInsert(
    List<DHA_Class_Assignment__c> newRecords,
    Integer maxAssignedClass
  ) {
    validateClassAssignmentRule(newRecords, maxAssignedClass);
  }

  public static void onAfterInsert(List<DHA_Class_Assignment__c> newRecords) {
   List<DHA_Study_Result__c> newStudyResults = new List<DHA_Study_Result__c>();
    for(DHA_Class_Assignment__c ca : newRecords) {
    newStudyResults.add(new DHA_Study_Result__c( 
      DHA_Class_Assignment__c = ca.Id,
      Is_Latest__c = true));
   }

   insert newStudyResults;
  }
}
