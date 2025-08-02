@isTest
public class TestDataFactory {
  public static void setTriggerFlags(
    Boolean isStudentTriggerActive,
    Boolean isClassAssignmentTriggerActive,
    Boolean isStudyReulstTriggerActive
  ) {
    // Upsert DHA_Trigger_Setting__c custom setting
    DHA_Trigger_Setting__c setting = new DHA_Trigger_Setting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      Is_Student_Trigger_Active__c = isStudentTriggerActive,
      Is_Class_Assignment_Trigger_Active__c = isClassAssignmentTriggerActive,
      Is_Study_Result_Trigger_Active__c =  isStudyReulstTriggerActive
    );
    upsert setting;
  }

  public static void setManagementSetting(
    Integer maxAssignedClass,
    Integer maxStudentsInClass,
    Integer passScore
  ) {
    // Upsert DHA_Management_Setting__c custom setting
    DHA_Management_Setting__c setting = new DHA_Management_Setting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      Max_Assigned_Class__c = maxAssignedClass,
      Max_Students_In_Class__c = maxStudentsInClass,
      Pass_Score__c = passScore
    );
    upsert setting;
  }

  public static List<DHA_Student__c> createStudents(Integer numStudents,String name,Date birthdate) {
    List<DHA_Student__c> studentList = new List<DHA_Student__c>();

    for (Integer i = 0; i < numStudents; i++) {
      studentList.add(
        new DHA_Student__c(
          Address__c = 'Test Adrress ' + i,
          Email__c = 'Test' + i + '@gmail.com',
          Name = name + i,
          Birthdate__c = birthdate,
          Gender__c = 'Male'
        )
      );
    }
    return studentList;
  }

  public static Map<String, List<SObject>> createStudentsWithClassAssignments(Integer numStudents,Integer numClasses) {
    Map<String, List<SObject>> mapResult = new Map<String, List<SObject>>();
    List<DHA_Student__c> studentList = new List<DHA_Student__c>();
    List<DHA_Class__c> classList = new List<DHA_Class__c>();
    List<DHA_Class_Assignment__c> classAssignmentList = new List<DHA_Class_Assignment__c>();
    List<DHA_Study_Result__c> studyResultList = new List<DHA_Study_Result__c>();

    for (Integer i = 0; i < numClasses; i++) {
      classList.add(new DHA_Class__c(Is_Opened__c = true)); //Name is auto number with C-{0000} format
    }
    insert classList;

    for (Integer i = 0; i < numStudents; i++) {
      DHA_Student__c stu = new DHA_Student__c(
        Name = 'Test Student ' + i,
        Birthdate__c = Date.newInstance(2000, i + 1, i + 1),
        Email__c = 'TestEmail' + i + '@gmail.com',
        Address__c = 'Test Address ' + i,
        Gender__c = 'Male'
      );
      studentList.add(stu);
    }
    insert studentList;

    for (Integer i = 0; i < studentList.size(); i++) {
      for (Integer j = 0; j < numClasses - 1; j++) {
        classAssignmentList.add(
          new DHA_Class_Assignment__c(
            DHA_Class__c = classList[j].Id,
            DHA_Student__c = studentList[i].Id
          )
        );
      }
    }
    insert classAssignmentList;

    for(Integer i=0; i<classAssignmentList.size()/10;i++){
      studyResultList.add(
        new DHA_Study_Result__c(
          DHA_Class_Assignment__c = classAssignmentList[i].Id,
          Score_1__c = 50,
          Score_2__c = 60,
          Score_3__c = 70,
          Result__c = 'Passed'
          )
      );
    }
    insert studyResultList;
    
    mapResult.put('StudyResult', studyResultList);
    mapResult.put('Student', studentList);
    mapResult.put('Class', classList);

    return mapResult;
  }

  public static Map<String, List<SObject>> createStudentsAndClasses(Integer numStudents,Integer numClasses) {
    Map<String, List<SObject>> mapResult = new Map<String, List<SObject>>();
    List<DHA_Student__c> studentList = new List<DHA_Student__c>();
    List<DHA_Class__c> classList = new List<DHA_Class__c>();

    for (Integer i = 0; i < numClasses; i++) {
      classList.add(new DHA_Class__c(Is_Opened__c = true)); //Name is auto number with C-{0000} format
    }
    insert classList;

    for (Integer i = 0; i < numStudents; i++) {
      DHA_Student__c stu = new DHA_Student__c(
        Name = 'Test Student ' + i,
        Birthdate__c = Date.newInstance(2000, i + 1, i + 1),
        Email__c = 'TestEmail' + i + '@gmail.com',
        Address__c = 'Test Address ' + i,
        Gender__c = 'Male'
      );
      studentList.add(stu);
    }
    insert studentList;

    mapResult.put('Student', studentList);
    mapResult.put('Class', classList);

    return mapResult;
  }
}
