trigger DHA_StudyResultTrigger on DHA_Study_Result__c ( before insert,
  before update,
  after insert,
  after update) {

DHA_Trigger_Setting__c triggerSetting = DHA_Trigger_Setting__c.getOrgDefaults();
if (triggerSetting == null || !triggerSetting.Is_Study_Result_Trigger_Active__c){return;} 

DHA_Management_Setting__c classAssignmentSetting = DHA_Management_Setting__c.getOrgDefaults();
if(classAssignmentSetting == null || classAssignmentSetting.Pass_Score__c == null){return;}

Integer passScore = (Integer) classAssignmentSetting.Pass_Score__c;

switch on Trigger.operationType {
    when BEFORE_UPDATE {
      DHA_StudyResultTriggerHandler.onBeforeUpdate(Trigger.new, passScore);
    }
  }

}