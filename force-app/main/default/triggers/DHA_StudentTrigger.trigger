/**
 * @description: Trigger for DHA_Student__c object
 * @created: 2025/07/14 Hien Phan
 */
trigger DHA_StudentTrigger on DHA_Student__c(
  before insert,
  before update,
  after insert,
  after update
) {
  DHA_Trigger_Setting__c triggerSetting = DHA_Trigger_Setting__c.getOrgDefaults();
  if (triggerSetting == null || !triggerSetting.Is_Student_Trigger_Active__c) {
    return;
  }

  switch on Trigger.operationType {
    when BEFORE_INSERT {
      DHA_StudentTriggerHandler.onBeforeInsert(Trigger.new);
    }
    when BEFORE_UPDATE {
      try {
        SecurityUtil.validateUpdateAccess(Trigger.new);
        DHA_StudentTriggerHandler.onBeforeUpdate(Trigger.new);
      } catch (SecurityException e) {
        CustomExceptionData myException = new CustomExceptionData(
        'DHA_StudentTrigger',
        'BEFORE_UPDATE',
        e.getMessage(),
        e.getLineNumber().toString()
      );
      throw new AuraHandledException(JSON.serialize(myException));
      }
    }
  }
}
