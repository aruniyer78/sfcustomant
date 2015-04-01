public with sharing class CustomSettingUtil {
	public static Boolean isEnabled(String triggerName) {
		Boolean result = true;
		TriggerStatus__c status = TriggerStatus__c.getAll().get(triggerName);
		if(status != null && !status.Enabled__c){
			result = false;
		}
		return result;
    }
}