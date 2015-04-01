/*
    Type:       Aftersales util
    Purpose:    1.update pc cv van status when status is porspect or null
                
    User Story: US-CD-001
    Used By:    
    ---------------------------------------------------------------
    History:
    
*/
public with sharing class AfterSalesHelper {
    
    private static Map<String,String> updateFields = new Map<String,String>{
        'PC'=>'PC_Status__c',
        'CV'=>'CV_Status__c',
        'VAN'=>'VAN_Status__c'
    };
    
    //US_AU-CD-001 update pc cv van status when status is porspect or null
    public static void updateAccountStatus(Set<Id> ids){
    
        //get vechile info 
        Map<Id,Vehicle__c> vehicles = new Map<Id,Vehicle__c>
        ([select id, Vehicle_Group__c from Vehicle__c where id in: ids]);
        
        Map<String,Map<String,Integer>> cvrInfos = new Map<String,Map<String,Integer>>();
        Map<String,Map<String,Integer>> contractInfos = new Map<String,Map<String,Integer>>();
        Map<id,id> customers = new Map<id,id>(); 

        for(Customer_Vehicle_Relationship__c cvr: [select Vehicle_ID__c, Customer__c from Customer_Vehicle_Relationship__c 
         where Vehicle_ID__c in :ids]){
            if(!customers.containsKey(cvr.Customer__c)){
                customers.put(cvr.Customer__c,cvr.Vehicle_ID__c);
            }
         }

        for(Sobject rel : 
        [select count(Id) ammount, Vehicle_ID__r.Vehicle_Group__c, Customer__c from Customer_Vehicle_Relationship__c 
         where Customer__c in :customers.keyset()
         group by Customer__c,Vehicle_ID__r.Vehicle_Group__c]){
              integer ammount = Integer.valueOf(rel.get('ammount'));
              String vehicleGroup = String.valueOf(rel.get('Vehicle_Group__c'));
              String customerId = String.valueOf(rel.get('Customer__c'));
             if(cvrInfos.containsKey(customerId)){
                 cvrInfos.get(customerId).put(vehicleGroup,ammount);
             }else{
                cvrInfos.put(customerId, new Map<String,Integer>{vehicleGroup=>ammount});
             }
         }
        
        for(Sobject acontract: [select count(id) ammount, 
                                       Vehicle__r.Vehicle_Group__c,
                                       AccountId 
                                from contract 
                                where AccountId in : customers.keyset() 
                                group by AccountId,Vehicle__r.Vehicle_Group__c ]){
             integer ammount = Integer.valueOf(acontract.get('ammount'));
             String vehicleGroup = String.valueOf(acontract.get('Vehicle_Group__c'));
             String customerId = String.valueOf(acontract.get('AccountId'));
             if(contractInfos.containsKey(customerId)){
                contractInfos.get(customerId).put(vehicleGroup,ammount);
             }else{
                contractInfos.put(customerId, new Map<String,Integer>{vehicleGroup=>ammount});
             }
        }
       
        List<Account> forUpdate = new List<Account>();
        for(Account customer: [select id, PC_Status__c, CV_Status__c, VAN_Status__c from Account where id in:customers.keyset()]){
            Vehicle__c vehicleInfo = vehicles.get(customers.get(customer.id));
            boolean hasCvrRec = false;
            boolean hasContractRec = false;
            if(cvrInfos.containsKey(customer.id) ){
                if(cvrInfos.get(customer.id).containskey(vehicleInfo.Vehicle_Group__c)){
                    hasCvrRec = true;
                }
            }
            if(contractInfos.containsKey(customer.id) ){
                if(contractInfos.get(customer.id).containskey(vehicleInfo.Vehicle_Group__c)){
                    hasContractRec = true;
                }
            }

            if(!hasCvrRec && !hasContractRec){
               if (!String.isblank(vehicleInfo.Vehicle_Group__c) && updateFields.containsKey(vehicleInfo.Vehicle_Group__c)){
                   String fieldName = updateFields.get(vehicleInfo.Vehicle_Group__c);
                   customer.put(fieldName,'Service Only');
                   forUpdate.add(customer);
               }
            }
        }
        
        DButil.updateSobjects(forUpdate);
    }
}