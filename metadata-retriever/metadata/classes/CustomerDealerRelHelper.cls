/*
    Type:       Utility for Customer Dealer Relationship
    Purpose:    for user story process unit 
    User Story: US_AU-CD-016
    Used By:    AccountTriggerBeforeInsertOrUpdate
    ---------------------------------------------------------------
    History:
        1. Justin Yu Created on  2013-08-05
        2. Justin Yu Modified on 2013-08-29
*/
public with sharing class CustomerDealerRelHelper {
    
    private static final String CUSTOMER_TYPE = 'Customer', SERVICE_TYPE = 'Service', PROSPECT_TYPE = 'Prospect';
    private static final String NO_TYPE = 'The imported relationship has no type';
    
    public static void preventRelationshipSaving(List<Customer_Dealer_Relationship__c> relationships){
        
        Map<String, Customer_Dealer_Relationship__c> existentRelationships = getAllExistentRelationships(relationships);
        List<Customer_Dealer_Relationship__c> removedRelationships = new List<Customer_Dealer_Relationship__c>();
        
        for(Customer_Dealer_Relationship__c rel : relationships){
            if(String.isBlank(rel.Type__c)){
                rel.addError(NO_TYPE);
                continue;
            }
            
            String index = getIndex(rel);
            if(existentRelationships.containsKey(index)){
                Customer_Dealer_Relationship__c existentRel = existentRelationships.get(index);
                if(isHigherPriority(existentRel.Type__c, rel.Type__c)){
                    rel.Type__c = existentRel.Type__c;
                }
            }
        }
        
        if(existentRelationships.size() > 0){
            delete existentRelationships.values();
        }
    }
    
    /**
     *  Finds all existent customer dealer relationships according to the new relationships, Maps with customer ID and Dealer ID.
     */
    private static Map<String, Customer_Dealer_Relationship__c> getAllExistentRelationships(List<Customer_Dealer_Relationship__c> relationships){
        Set<String> customerIds = new Set<String>();
        Set<String> dealerIds = new Set<String>();
        
        for(Customer_Dealer_Relationship__c item : relationships){
            customerIds.add(item.Customer__c);
            dealerIds.add(item.Dealer__c);
        }
        
        Map<String, Customer_Dealer_Relationship__c> resultMap = new Map<String, Customer_Dealer_Relationship__c>();
        for(Customer_Dealer_Relationship__c item : [select Id, Customer__c, Dealer__c, Type__c
                                                    from Customer_Dealer_Relationship__c
                                                    where Customer__c in :customerIds and Dealer__c in :dealerIds]){
            String index = getIndex(item);
            if(resultMap.containskey(index)){
            }
            else{
                resultMap.put(index, item);
            }
        }
        return resultMap;
    }
    
    private static String getIndex(Customer_Dealer_Relationship__c relationship){
        String cid = relationship.Customer__c, did = relationship.Dealer__c;
        return cid.substring(0, 15) + ';' + did.substring(0, 15);
    }
    
    private static Boolean isHigherPriority(String one, String two){
        if(two == CUSTOMER_TYPE){
            return false;
        }
        if(one == CUSTOMER_TYPE){
            return true;
        }
        if(one > two){
            return true;
        }
        return false;
    }
}