/*
    Type:       Utility for Customer_Vehicle_Relationship__c
    Purpose:    1.when get a CustomerVehicle data , update tenure
    User Story: US_AU-CD-001
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Bing Bai Created on 2013-08-05
*/
public with sharing class CustomerVehicleRelHelper {

    //US-CD-001
    //Get vehiches Vehicle_Group__c by vehicle id
    public static Map<id,Vehicle__c> getVehichles(set<Id> ids){
        return new Map<id,Vehicle__c>(
        [select id,
               Vehicle_Group__c
        from Vehicle__c 
        where Id in :ids]);
       
    }
    
    //get the lastest record
    public static Map<String,Date> getExsitedInfos(Set<Id> customerIds , String vehicleGroup){
        Map<String,Date>  recordsInfo = new Map <String,Date>();
        for (sObject obj:[select Customer__c, min(Purchase_Date__c) Purchase_Date__c from Customer_Vehicle_Relationship__c where Vehicle_ID__r.Vehicle_Group__c = :vehicleGroup and Customer__c in :customerIds group by Customer__c]){
            recordsInfo.put(String.valueOf(obj.get('Customer__c')),Date.valueOf(obj.get('Purchase_Date__c')));
        }
        
        return  recordsInfo;
    }
    
    private static Map<String, List<String>> colsMap = new Map<String,List<String>>
        {'PC'=> new List<String>{'PC_Status__c','PC_No_Brand_Purchases__c','PC_Tenure__c'},
         'CV'=> new List<String>{'CV_Status__c','CV_No_Brand_Purchases__c','CV_Tenure__c'},
         'VAN'=> new List<String>{'VAN_Status__c','VAN_No_Brand_Purchases__c','VAN_Tenure__c'}
        };
        
    //update PC CV VAN tenure
    private static Account updatePCCVField(Account userInfo ,String vehicleGroup, Map<String ,Map<String,Date>> preRecords){
        if(!String.isblank(vehicleGroup)){
            Map<String,Date> preRecord = preRecords.get(vehicleGroup);
            List<String> cols = colsMap.get(vehicleGroup);
            
            userInfo.put(cols[0], 'customer');
            integer numberofP = 1;
            if(userInfo.get(cols[1])!=null){
                numberofP = integer.valueOf(userInfo.get(cols[1]))+1;
            }
            userInfo.put(cols[1], Decimal.valueOf(numberofP));
            integer tenure = 0;
            if(preRecord.get(userInfo.id) != null){
                tenure = preRecord.get(userInfo.id).monthsBetween(Date.today())/12;
            }
            
            userInfo.put(cols[2] , Decimal.valueOf(tenure));
        }
        return userInfo;        
    }
        
    //US-CD-001 No.11
    //When PA gets a Customer-Vehicle-Relationship
    public static void updataWhenCreateCVR(Set<Id> vehicleIds, Set<Id> customerIds, List<Customer_Vehicle_Relationship__c> cvrs) {
        Map<id,Account> accounts = new Map<id,Account>();
        Map<String, Map<String,Date>> exsisedRecord = new Map<String, Map<String,Date>>();
        //get pc first date records
        Map<String,Date>  preRecordsPc = getExsitedInfos(customerIds,'PC');
        //get cv first date records 
        Map<String,Date>  preRecordsCv = getExsitedInfos(customerIds,'CV');
        //get cv first date records 
        Map<String,Date>  preRecordsVAN = getExsitedInfos(customerIds,'VAN');
        system.debug(customerIds);
        system.debug(preRecordsPc);    
        exsisedRecord.put('PC', preRecordsPc);
        exsisedRecord.put('CV', preRecordsCv);
        exsisedRecord.put('VAN', preRecordsVAN);
        
        Map<id,Account> accs = AccountHelper.getCustomerInfos(customerIds);
        Map<id,Vehicle__c> vehichles = getVehichles(vehicleIds);
        for(Customer_Vehicle_Relationship__c curCvr : cvrs){
            Account acc = new Account();
            if(accounts.containsKey(curCvr.Customer__c)){
                acc = accounts.get(curCvr.Customer__c);
            }else{
                acc = accs.get(curCvr.Customer__c);
            }
            acc = updatePCCVField(acc, vehichles.get(curCvr.Vehicle_ID__c).Vehicle_Group__c, exsisedRecord);
            
            accounts.put(acc.id,acc);
        }
        DBUtil.updateSobjects(accounts.values());
    }    
}