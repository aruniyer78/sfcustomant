/*
    Type:       Trigger
    Purpose:    1. Update display name when a account be changed.
                2. Set field PC & CV Status with a defalut value.
                3. Track the updating history for FS fields
                
    User Story: US_AU-CD-001 , US_AU-CD-002, US-CD-003, US-CD-004, US_AU-CD-001.6, US_AU-DD-002
*/

trigger AccountBeforeTrigger on Account (before insert, before update) {
    
    if(!CustomSettingUtil.isEnabled('AccountBeforeTrigger')){
        return;
    }
    
    // The following variables are for US-CD-004
    // Flag the primary person account: the lastest inserted contact or updated contact is primary.
    // For the new company with inserting or updating.
    Set<String> newCompanyIds = new Set<String>();
    Set<String> personIds = new Set<String>();
    
    for(Account acc : Trigger.new) {
    
        //US_AU-CD-001 No.7, US_AU-002
        if (AccountHelper.RECORD_TYPE_SET.contains(acc.RecordTypeId)){
            acc = AccountHelper.updateDisplayName(acc);
        
            //set field PC & CV Status with defalut value 
            if (trigger.isInsert) {
                acc = AccountHelper.setDefaultValue(acc);
            }
        }
        
        // US-CD-004 Flag the primary person account.
        if(acc.isPersonAccount && acc.Company__c != null){
            if(!trigger.isUpdate || acc.Company__c != trigger.oldMap.get(acc.Id).Company__c){
                // Sets the contact to primary and cancels the original contact in this company.
                acc.Primary__pc = true;
                newCompanyIds.add(acc.Company__c);
                if(trigger.isUpdate){
                    personIds.add(acc.Id);
                }
            }
        }
        
        // US_AU-CD-001.6 Track the updating history for FS fields.
        if(trigger.isUpdate){
            AccountHelper.trackUpdatHistoryForFsInfo(acc, trigger.oldMap.get(acc.Id));
        }
        
        // US_AU-DD-002  Copy Postal Address 2 Street Address 
        if(acc.Copy_Postal_Address_2_Street_Address__c) {
            acc.Dealer_Street_Address_Address_Line_1__c = acc.Dealer_Postal_Address_Address_Line_1__c;
            acc.Dealer_Street_Address_Address_Line_2__c = acc.Dealer_Postal_Address_Address_Line_2__c;
            acc.Dealer_Street_Address_Post_Code__c = acc.Dealer_Postal_Address_Post_Code__c;
            acc.Dealer_Street_Address_Suburb__c = acc.Dealer_Postal_Address_Suburb__c;
            acc.Dealer_Street_Address_State__c = acc.Dealer_Postal_Address_State__c;
            acc.Dealer_Street_Address_Country__c = acc.Dealer_Postal_Address_Country__c;        
        }
    }
    
    // US-CD-004 Flag the primary person account: the lastest inserted contact or updated contact is primary.
    newCompanyIds.remove(null);
    if(!newCompanyIds.isEmpty()){
        AccountHelper.cancelPrimaryContact(newCompanyIds, personIds);
    }
}