public class SecurityUtil {
  public static void validateUpdateAccess(List<SObject> records) {
    if (records.size() == 0) {
      return;
    }

    for (SObject record : records) {
      Schema.DescribeSObjectResult dsr = record.getSObjectType().getDescribe();
      //check if object is updateable
      if (!dsr.isUpdateable()) {
        throw new SecurityException(
          'You do not have access to update: ' + dsr.getLabel() + ' records'
        );
      }

      //check if any fields are updateable
      Map<String, Schema.SObjectField> fieldsMap = dsr.fields.getMap();
      for (String key : fieldsMap.keySet()) {
        Schema.DescribeFieldResult dfr = fieldsMap.get(key).getDescribe();
        if (!dfr.isUpdateable()) {
          throw new SecurityException(
            'You do not have access to update the field: ' + dfr.getLabel()
          );
        }
      }
    }
  }
}
