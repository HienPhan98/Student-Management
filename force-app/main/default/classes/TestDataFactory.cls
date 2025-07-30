@isTest
public class TestDataFactory {
  public static void setTriggerFlags(
    Boolean isStudentTriggerActive,
    Boolean isClassAssignmentTriggerActive
  ) {
    // Upsert DHA_Trigger_Setting__c custom setting
    DHA_Trigger_Setting__c setting = new DHA_Trigger_Setting__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      Is_Student_Trigger_Active__c = isStudentTriggerActive,
      Is_Class_Assignment_Trigger_Active__c = isClassAssignmentTriggerActive
    );
    upsert setting;

    // Force query to "commit" to test context cache
    //setting = [SELECT Id FROM DHA_Trigger_Setting__c WHERE SetupOwnerId = :UserInfo.getOrganizationId()];
  }

  public static List<DHA_Student__c> createStudents(
    Integer numStudents,
    String name,
    Date birthdate
  ) {
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
    mapResult.put('Student', studentList);
    mapResult.put('Class', classList);

    return mapResult;
  }
}
