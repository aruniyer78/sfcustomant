/*
    Type:       Trigger on Task   
    Purpose:    send the email notification to the assigned to user
                
    User Story: US_AU-CD-044
    Used By:    
    ---------------------------------------------------------------
    History:
    1. Shuang Li Created on 2014-02-19
*/
trigger TaskBeforeTrigger on Task (before insert, before update) {
    if(!CustomSettingUtil.isEnabled('TaskBeforeTrigger')){
        return;
    }
    if(Trigger.isInsert || Trigger.isUpdate){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Task task : Trigger.new) {
        	if(task.ActivityDate != null){
	        	task.Notification_Email_Time__c = datetime.newInstance(task.ActivityDate, Time.newInstance(9, 0, 0, 0));
            }
            if(task.Notification_Email_Flag__c){
                User us = [Select Id, FirstName, LastName, Email From User Where Id = :task.OwnerId];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setSubject(task.Subject);
                message.setPlainTextBody('Due Task' +
                '\nTo:'+ us.FirstName + us.LastName + '\nPlease action this task!' + '\nSubject: ' + task.Subject + '\nPriority: ' + task.Priority + '\nFor more details, click the following link: \n' + 'https://c.ap1.visual.force.com/' + task.id);
                message.setToAddresses(new String[] {us.Email});
                message.setSaveAsActivity(false);
                task.Notification_Email_Flag__c = false;
                mails.add(message);
            }
        }
        if (mails.size() > 0) {
            try {
                Messaging.sendEmail(mails);
            }
            catch(Exception ex) {
                system.debug('Send Due Task Email Exception :' + ex.getMessage());
            }
        }
    }
}