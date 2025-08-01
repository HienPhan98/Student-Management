/**
 * @description: DHA_Class_Assignment__c object Trigger Handler
 * @created: 2025/07/14 Hien Phan
 */
public without sharing class DHA_ClassAssignmentTriggerHandler {
  private static void validateClassAssignmentRule(
    List<DHA_Class_Assignment__c> newRecords,
    Integer maxAssignedClass,
    Integer maxStudentInClass
  ) {
    Set<Id> newStudentIds = new Set<Id>();
    Set<Id> newClassIds = new Set<Id>();

    for (DHA_Class_Assignment__c ca : newRecords) {
      newStudentIds.add(ca.DHA_Student__c);
      newClassIds.add(ca.DHA_Class__c);
    }

    //first-check if bulk insert include any student exceeds maxAssignedClass & any class exceeds maxStudentInClass
    Map<Id, Integer> assingedClassMap = new Map<Id, Integer>();
    Map<Id, Integer> studentInClassMap = new Map<Id, Integer>();

    for (DHA_Class_Assignment__c ca : newRecords) {
      if (!assingedClassMap.containsKey(ca.DHA_Student__c)) {
        assingedClassMap.put(ca.DHA_Student__c, 1);
      } else {
        Integer assignedClass = assingedClassMap.get(ca.DHA_Student__c);
        assignedClass++;
        assingedClassMap.put(ca.DHA_Student__c, assignedClass);
      }

      if (assingedClassMap.get(ca.DHA_Student__c) > maxAssignedClass) {
        ca.DHA_Student__c.addError('This student is attending to too much class.');
      }
    }

    for (DHA_Class_Assignment__c ca : newRecords) {
      if (!studentInClassMap.containsKey(ca.DHA_Class__c)) {
        studentInClassMap.put(ca.DHA_Class__c, 1);
      } else {
        Integer studentInClass = studentInClassMap.get(ca.DHA_Class__c);
        studentInClass++;
        studentInClassMap.put(ca.DHA_Class__c, studentInClass);
      }

      if (studentInClassMap.get(ca.DHA_Class__c) > maxStudentInClass) {
        ca.DHA_Class__c.addError('There is no seat to join this class.');
      }
    }

    //second-check with existing database
    List<AggregateResult> assignedClassResults = [
      SELECT DHA_Student__c, COUNT(Id) total
      FROM DHA_Class_Assignment__c
      WHERE DHA_Student__c IN :newStudentIds
      WITH SECURITY_ENFORCED
      GROUP BY DHA_Student__c
      HAVING COUNT(Id) >= :maxAssignedClass
    ];

    List<AggregateResult> studentInClassResults = [
      SELECT DHA_Class__c, COUNT(Id) total
      FROM DHA_Class_Assignment__c
      WHERE DHA_Class__c IN :newClassIds
      WITH SECURITY_ENFORCED
      GROUP BY DHA_Class__c
      HAVING COUNT(Id) >= :maxStudentInClass
    ];

    //check if Student exceeds assigned class Rule
    Set<Id> studentExceedAssignedClass = new Set<Id>();
    for (AggregateResult result : assignedClassResults) {
      studentExceedAssignedClass.add((Id) result.get('DHA_Student__c'));
    }

    for (DHA_Class_Assignment__c ca : newRecords) {
      if (studentExceedAssignedClass.contains(ca.DHA_Student__c)) {
        ca.DHA_Student__c.addError(
          'This student is attending to too much class.'
        );
      }
    }

    //check if Class exceeds number of student Rule
    Set<Id> classExceedStudentNumber = new Set<Id>();
    for (AggregateResult result : studentInClassResults) {
      classExceedStudentNumber.add((Id) result.get('DHA_Class__c'));
    }

    for (DHA_Class_Assignment__c ca : newRecords) {
      if (classExceedStudentNumber.contains(ca.DHA_Class__c)) {
        ca.DHA_Class__c.addError('There is no seat to join this class.');
      }
    }
  }

  public static void onBeforeInsert(
    List<DHA_Class_Assignment__c> newRecords,
    Integer maxAssignedClass,
    Integer maxStudentInClass
  ) {
    validateClassAssignmentRule(
      newRecords,
      maxAssignedClass,
      maxStudentInClass
    );
  }

  public static void onAfterInsert(List<DHA_Class_Assignment__c> newRecords) {
    List<DHA_Study_Result__c> newStudyResults = new List<DHA_Study_Result__c>();
    for (DHA_Class_Assignment__c ca : newRecords) {
      newStudyResults.add(
        new DHA_Study_Result__c(
          DHA_Class_Assignment__c = ca.Id,
          Is_Latest__c = true
        )
      );
    }

    insert newStudyResults;
  }
}
