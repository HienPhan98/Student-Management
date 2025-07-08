public with sharing class StudentClassController {
  @AuraEnabled(cacheable=true)
  public static List<DHA_Class__c> getAllClasses() {
    try {
      return [
        SELECT Id, Name
        FROM DHA_Class__c
        WITH SECURITY_ENFORCED
        LIMIT 50
      ];
    } catch (Exception e) {
      CustomExceptionData myException = new CustomExceptionData(
        'StudentClassController',
        'getAllClasses',
        e.getMessage(),
        e.getLineNumber().toString()
      );
      throw new AuraHandledException(JSON.serialize(myException));
    }
  }

  @AuraEnabled
  public static List<DHA_Student__c> searchStudents(String name, String birthDate, String classId) {
    System.debug(name + ' - ' + birthDate + ' - ' + classId);
    List<String> filterConditions = new List<String>();
    List<String> fieldsToSelect = new List<String>{
      'Id',
      'Student_Code__c',
      'Name',
      'Birthdate__c',
      'Address__c',
      'Email__c'
    };
    String objectToQueryFrom = 'DHA_Student__c';
    String originalQuery ='SELECT ' + String.join(fieldsToSelect, ', ') + ' FROM ' + objectToQueryFrom;
    try {
      if (String.isNotBlank(name)) {
        filterConditions.add(
          'Name LIKE \'%' + String.escapeSingleQuotes(name) + '%\''
        );
      }
      if (String.isNotBlank(birthDate)) {
        filterConditions.add('Birthdate__c = ' + birthDate);
      }
      if (String.isNotBlank(classId)) {
        Set<Id> setStudentIds = new Set<Id>();
        for (DHA_Class_Assignment__c ca : [
          SELECT DHA_Student__r.Id
          FROM DHA_Class_Assignment__c
          WHERE DHA_Class__r.Id = :classId
          WITH SECURITY_ENFORCED
        ]) {
          setStudentIds.add(ca.DHA_Student__r.Id);
        }
        if (!setStudentIds.isEmpty()) {
          List<String> idList = new List<String>();
          for (Id sid : setStudentIds) {
            idList.add('\'' + sid + '\'');
          }
          filterConditions.add('Id IN (' + String.join(idList, ',') + ')');
        }
      }

      if (!filterConditions.isEmpty()) {
        originalQuery += ' WHERE ' + String.join(filterConditions, ' AND ');
        originalQuery += ' LIMIT 50';
        system.debug('totalQuery:  ' + originalQuery);
        return Database.query(originalQuery);
      }
      return new List<DHA_Student__c>();
    } catch (Exception e) {
      CustomExceptionData myException = new CustomExceptionData(
        'StudentClassController',
        'searchStudents',
        e.getMessage(),
        e.getLineNumber().toString()
      );
      throw new AuraHandledException(JSON.serialize(myException));
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<DHA_Student__c> getRecentlyViewedStudents() {
    try {
      // Get 50 records recently viewed by current user
      return [
        SELECT Id, Student_Code__c, Name, Birthdate__c, Address__c, Email__c
        FROM DHA_Student__c
        WHERE LastViewedDate != NULL
        WITH SECURITY_ENFORCED
        ORDER BY LastViewedDate DESC, Student_Code__c ASC
        LIMIT 50
      ];
    } catch (Exception e) {
      CustomExceptionData myException = new CustomExceptionData(
        'StudentClassController',
        'getRecentlyViewedStudents',
        e.getMessage(),
        e.getLineNumber().toString()
      );
      throw new AuraHandledException(JSON.serialize(myException));
    }
  }

  @AuraEnabled(cacheable=true)
  public static Integer countAssignedClassesOfStudent(String studentId) {
    try {
      return [
        SELECT COUNT()
        FROM DHA_Class_Assignment__c
        WHERE DHA_Student__r.Id = :studentId
        WITH SECURITY_ENFORCED
      ];
    } catch (Exception e) {
      CustomExceptionData myException = new CustomExceptionData(
        'StudentClassController',
        'countAssignedClassesOfStudent',
        e.getMessage(),
        e.getLineNumber().toString()
      );
      throw new AuraHandledException(JSON.serialize(myException));
    }
  }

  @AuraEnabled(cacheable=true)
  public static Integer countClassHaveFinalScore(String studentId) {
    try {
      Integer countClassHaveFinalScore = 0;
      List<DHA_Class_Assignment__c> listAssignment = [
        SELECT Id,
          (
            SELECT Final_Score__c
            FROM DHA_Study_Results__r
            WHERE Final_Score__c != NULL
          )
        FROM DHA_Class_Assignment__c
        WHERE DHA_Student__r.Id = :studentId
        WITH SECURITY_ENFORCED
      ];
      for (DHA_Class_Assignment__c ca : listAssignment) {
        List<DHA_Study_Result__c> listStudyResult = ca.DHA_Study_Results__r;
        if (listStudyResult.size() > 0) {
          countClassHaveFinalScore = listStudyResult.size();
        }
      }
      return countClassHaveFinalScore;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<String> getAverageScores(String studentId) {
    try {
      List<String> averageScores = new List<String>();
      List<DHA_Class_Assignment__c> listAssignment = [
        SELECT Id,
          (
            SELECT Final_Score__c
            FROM DHA_Study_Results__r
            WHERE Final_Score__c != NULL
          )
        FROM DHA_Class_Assignment__c
        WHERE DHA_Student__r.Id = :studentId
        WITH SECURITY_ENFORCED
      ];
      for (DHA_Class_Assignment__c ca : listAssignment) {
        List<DHA_Study_Result__c> listStudyResult = ca.DHA_Study_Results__r;
        if (listStudyResult.size() > 0) {
          for(DHA_Study_Result__c studyResult : listStudyResult) 
          {
            averageScores.add(studyResult.Final_Score__c.toString());
          }
        }
      }
      return averageScores;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
