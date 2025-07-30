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
  DHA_Trigger_Setting__c triggerSetting = [
  SELECT Is_Student_Trigger_Active__c FROM DHA_Trigger_Setting__c
  WHERE SetupOwnerId = :UserInfo.getOrganizationId()
  WITH SECURITY_ENFORCED
  LIMIT 1
  ];
  if (triggerSetting == null || !triggerSetting.Is_Student_Trigger_Active__c) {return;}

  switch on Trigger.operationType {
    when BEFORE_INSERT {
      DHA_StudentTriggerHandler.onBeforeInsert(Trigger.new);
    }
    when BEFORE_UPDATE {
      try {
        if (!Test.isRunningTest()) {
          SecurityUtil.validateUpdateAccess(Trigger.new);
        }
        DHA_StudentTriggerHandler.onBeforeUpdate(Trigger.new);
      } catch (Exception e) {
        CustomExceptionData myException = new CustomExceptionData(
          'DHA_StudentTrigger',
          'BEFORE_UPDATE',
          e.getTypeName(),
          e.getMessage(),
          e.getLineNumber().toString()
        );
        throw new AuraHandledException(JSON.serialize(myException));
      }
    }
  }
}
