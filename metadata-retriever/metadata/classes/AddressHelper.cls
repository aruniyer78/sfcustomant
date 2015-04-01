/*
    Type:       Utility for Account
    Purpose:    for user story process unit 
    User Story: US_AU-CD-001,US_AU-CD-003,US_AU-DD-034
    Used By:    Address Trigger
    ---------------------------------------------------------------
    History:
    
    1. Bing Bai Created on 2013-08-06
    2. Justin Yu modified on 2013-08-07
    3. Stanley Yang modified on 2013-08-13
    4. Justin Yu modified on 2013-08-15
    5. Shuang Li modified on 2014-02-12
*/
public with sharing class AddressHelper {

    //flag prefferAddress
    public static void flagPreferredAddressAndPopulateToCustomer(Set<String> customerIds){
        Map<String,List<AddressWrapper>> addresses = getAllAddressWrapperes(customerIds);
        List<Address__c> preferredAddresses = new List<Address__c>();
        List<Address__c> originalPreferredAddresses = new List<Address__c>();
        List<Address__c> updatedAddresses = new List<Address__c>();
        
        Map<String, Account> idAccount = new Map<String, Account>();
        for(Account acc : [select id, Status__c, Address_State__c,Address_Line_1__c, Address_Line_2__c, Address_Type__c,
                           Company_Name__c, Country__c, Suburb__c, Post_Code__c from Account where id in :customerIds]) {
            idAccount.put(acc.id, acc);
        }
        
        List<Account> updateAccounts = new List<Account>();
        
        for(ID customerId : customerIds){
            List<AddressWrapper> addressList = new List<AddressWrapper>();
            if(addresses != null && addresses.keyset().contains(customerId)) {
                addressList = addresses.get(customerId);
            }
            
            if(addressList.size() == 0 && idAccount.size() > 0 && idAccount.keyset().contains(customerId)) {
                Account acc = idAccount.get(customerId);
                
                acc.Status__c = '';
                acc.Address_State__c = '';
                acc.Address_Line_1__c = '';
                acc.Address_Line_2__c = '';
                acc.Address_Type__c = '';
                acc.Company_Name__c = '';
                acc.Country__c = '';
                acc.Suburb__c = '';
                acc.Post_Code__c = '';
                
                updateAccounts.add(acc);
            }
            
            // Sort address as the hierarchy of Type.
            if(addressList != null && addressList.size() > 0){
                addressList.sort();
                
                // Flag the preferred address.
                if(!addressList[0].address.Preferred__c){
                    addressList[0].address.Preferred__c = true;
                    updatedAddresses.add(addressList[0].address);
                }
                preferredAddresses.add(addressList[0].address);
                
                // Cancel the original flag.
                addressList.remove(0);
                for(Integer i = 0; i < addressList.size(); i++){
                    if(addressList[i].address.Preferred__c){
                        addressList[i].address.Preferred__c = false;
                        updatedAddresses.add(addressList[i].address);
                    }
                }
            }
        }
        
        if(updateAccounts.size()>0){
            update updateAccounts;
        }
        
        if(preferredAddresses.size() > 0){
            populatePreferredAddressToCustomer(preferredAddresses);
        }
        
        // Update addresses.
        if(updatedAddresses.size() > 0){
            update updatedAddresses;
        }
    }
    
    //get All addresses of customer
    public static Map<String,List<Address__c>> getAllAddresses(Set<String> customerIds){
        Map<String,List<Address__c>> result = new Map<String, List<Address__c>>();
        for(Address__c address : [select Preferred__c, Status__c, Customer__c,Address_Line_1__c, Address_Line_2__c, Address_Type__c,
                                         Country__c, Suburb__c, Post_Code__c, State__c, Customer__r.Id
                                  from Address__c where Customer__c in :customerIds]){
            if(result.containsKey(address.Customer__c)){
                result.get(address.Customer__c).add(address);
            }
            else{
                result.put(address.Customer__c, new List<Address__c>{address});
            }
        }
        return result;
    }
    
    //US-CD-003, Auto-fill the post code by the suburb    
    public static Map<String,String> getMappingBetweenSuburbAndZip(Set<String> suburbs){
        Map<String, String> SuburbZips = new Map<String, String>();
        if(suburbs.size() > 0){
            for(Suburb_Zip_Mapping__c sz : [select Name, Zip__c from Suburb_Zip_Mapping__c where Name in :suburbs]) {
                SuburbZips.put(sz.Name, sz.Zip__c);
            }
        }
        return SuburbZips;
    } 
    
    private static Map<String,List<AddressWrapper>> getAllAddressWrapperes(Set<String> customerIds){
        Map<String,List<AddressWrapper>> result = new Map<String, List<AddressWrapper>>();
        //for CR-000202 start
        for(Address__c address : [select Preferred__c, Status__c, Customer__c,Address_Line_1__c, Address_Line_2__c, Address_Type__c,
                                         Company_Name__c, Country__c, Suburb__c, Post_Code__c, State__c, Customer__r.Id
                                  from Address__c where Customer__c in :customerIds]){
            if(result.containsKey(address.Customer__c)){
                result.get(address.Customer__c).add(new AddressWrapper(address));
            }
            else{
                result.put(address.Customer__c, new List<AddressWrapper>{new AddressWrapper(address)});
            }
        }
        //for CR-000202 end
        return result;
    }
    
    private static void populatePreferredAddressToCustomer(List<Address__c> preferredAddresses){
        List<Account> updateAccounts = new List<Account>();
        
        for(Address__c address: preferredAddresses){
                address.Customer__r.Status__c = address.Status__c;
                address.Customer__r.Address_State__c = address.State__c;
                address.Customer__r.Address_Line_1__c = address.Address_Line_1__c;
                address.Customer__r.Address_Line_2__c = address.Address_Line_2__c;
                address.Customer__r.Address_Type__c = address.Address_Type__c;
                //for CR-000202 start
                address.Customer__r.Company_Name__c = address.Company_Name__c;
                //for CR-000202 end
                address.Customer__r.Country__c = address.Country__c;
                address.Customer__r.Suburb__c = address.Suburb__c;
                address.Customer__r.Post_Code__c = String.valueOf(address.Post_Code__c);
                updateAccounts.add(address.Customer__r);
        }
        
        if(updateAccounts.size()>0){
            update updateAccounts;
        }
    }
    
    /**
     *  Sort class for address object. 
     *  For individual account, Mailing=>Home=>Business=>Prev Mailing.
     *  For company account, Mailing=>Company=>Prev Mailing
    **/
    public class AddressWrapper implements Comparable {

        private Address__c address;
        private Map<String, Integer> addressHierarchy = new Map<String, Integer>{'Mailing'=>1, 'Home'=>2, 'Business'=>3, 'Company'=>3, 'Prev Mailing'=>4};
        
        public AddressWrapper(Address__c ar) {
            address = ar;
        }
        
        public Integer compareTo(Object compareTo) {
            AddressWrapper compareToAddress = (AddressWrapper)compareTo;
            Integer returnValue = 0;
            if(String.isBlank(address.Status__c) && !String.isBlank(compareToAddress.address.Status__c)){
                returnValue = -1;
            }
            else if(String.isBlank(compareToAddress.address.Status__c) && !String.isBlank(address.Status__c)){
                returnValue = 1;
            }
            else{
                Integer a = addressHierarchy.get(address.Address_Type__c);
                Integer b = addressHierarchy.get(compareToAddress.address.Address_Type__c);
                if (a > b){
                    returnValue = 1;
                }
                else if (a < b) {
                    returnValue = -1;
                }
            }
            return returnValue;       
        }
    }  
}