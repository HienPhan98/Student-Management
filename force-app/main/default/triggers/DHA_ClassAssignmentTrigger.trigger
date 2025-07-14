/**
 * @description: Trigger for DHA_Class_Assignment__c object
 * @created: 2025/07/14 Hien Phan
 */
trigger DHA_ClassAssignmentTrigger on DHA_Class_Assignment__c(
  before insert,
  before update,
  after insert,
  after update
) {
DHA_Trigger_Setting__c triggerSetting = DHA_Trigger_Setting__c.getOrgDefaults();
if (triggerSetting == null || !triggerSetting.Is_Class_Assignment_Trigger_Active__c){return;} 

DHA_Management_Setting__c classAssignmentSetting = DHA_Management_Setting__c.getOrgDefaults();
if(classAssignmentSetting == null || classAssignmentSetting.Max_Assigned_Class__c == null || classAssignmentSetting.Max_Students_In_Class__c == null){return;}

Integer maxAssignedClass = (Integer) classAssignmentSetting.Max_Assigned_Class__c;

switch on Trigger.operationType {
    when BEFORE_INSERT {
      DHA_ClassAssignmentTriggerHandler.onBeforeInsert(Trigger.new, maxAssignedClass );
    }
    when BEFORE_UPDATE {
      //DHA_ClassAssignmentTriggerHandler.onBeforeUpdate(Trigger.new);
    }
    when AFTER_INSERT {
      DHA_ClassAssignmentTriggerHandler.onAfterInsert(Trigger.new);
    }
  }

}
