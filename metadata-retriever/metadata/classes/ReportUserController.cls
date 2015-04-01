/*    
    Type:       ReportUser Controller    
    Purpose:    Query User Information shown on Activity Report User Based
    User Story: US_AU-RD-006   
    Used By:    Activity Report User Based (VF)    
    ---------------------------------------------------------------    
    History:    
    1. Shuang Li created on 2013-09-11
*/
public class ReportUserController{
    private static Id accPerson_RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();    
    private static Id accCompany_RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();

    public List<CountData> theResults = new List<CountData>();

    public List<CountData> getTheResults() {
        List<user> users = [select Id, name, state from User where isActive = true];
        Map<String, String> userMap = new Map<String, String>();  

        for (user user : users) 
        {
           userMap.put(user.id, user.name); 
           CountData countData = new CountData(String.valueOf(user.id), String.valueOf(user.name), String.valueOf(user.state));
           theResults.add(countData);
        }
        
       List <AggregateResult> aggrsAccountAdd = [select createdById, count(Id) total from account where createdById in :userMap.KeySet() and (RecordTypeId =:accPerson_RecordTypeId or RecordTypeId =:accCompany_RecordTypeId) group by createdById];
       List <AggregateResult> aggrsAccountMod = [select LastModifiedById , count(Id) total from account where LastModifiedById in :userMap.KeySet() and (RecordTypeId =:accPerson_RecordTypeId or RecordTypeId =:accCompany_RecordTypeId ) group by LastModifiedById];
       List <AggregateResult> aggrsTasksAdd = [select createdById , count(Id) total from task where createdById in :userMap.KeySet() group by createdById];
       List <AggregateResult> aggrsTasksMod = [select LastModifiedById , count(Id) total from task where LastModifiedById in :userMap.KeySet() group by LastModifiedById];
       List <AggregateResult> aggrsVehicleAdd = [select createdById , count(Id) total from Customer_Vehicle_Relationship__c where createdById in :userMap.KeySet() group by createdById];
       List <AggregateResult> aggrsVehicleMod = [select LastModifiedById , count(Id) total from Customer_Vehicle_Relationship__c where LastModifiedById in :userMap.KeySet() group by LastModifiedById];
       for(AggregateResult ja : aggrsAccountAdd) 
       {
           for (CountData rs : theResults){   
               if(String.valueOf(ja.get('createdById')) == rs.UserId){
                   rs.totalAccountAdd = Integer.valueOf(ja.get('total'));
               }          
           }
       }

       for (AggregateResult ja : aggrsAccountMod) 
       {
           for (CountData rs : theResults){   
               if(String.valueOf(ja.get('LastModifiedById')) == rs.UserId){
                   rs.totalAccountMod = Integer.valueOf(ja.get('total'));
               }          
           }
       }
       
       for (AggregateResult ja : aggrsTasksAdd) 
       {
           for (CountData rs : theResults){   
               if(String.valueOf(ja.get('createdById')) == rs.UserId){
                   rs.totalTasksAdd = Integer.valueOf(ja.get('total'));
               }          
           }
       }
        
       for (AggregateResult ja : aggrsTasksMod) 
       {
           for (CountData rs : theResults){   
               if(String.valueOf(ja.get('LastModifiedById')) == rs.UserId){
                   rs.totalTasksMod = Integer.valueOf(ja.get('total'));
               }          
           }
       }
       for(AggregateResult ja : aggrsVehicleAdd) 
       {
           for(CountData rs : theResults){   
               if(String.valueOf(ja.get('createdById')) == rs.UserId){
                   rs.totalVehicleAdd = Integer.valueOf(ja.get('total'));
               }          
           }
       }
        
       for (AggregateResult ja : aggrsVehicleMod) 
       {
           for (CountData rs : theResults){   
               if(String.valueOf(ja.get('LastModifiedById')) == rs.UserId){
                   rs.totalVehicleMod = Integer.valueOf(ja.get('total'));
               }          
           }
       }
       return theResults;
        
    }
     
    private class CountData {               
         public String UserId { get; set; }   
         public String Username { get; set; } 
         public String State { get; set; }             
         public Integer totalAccountAdd { get; set; }         
         public Integer totalAccountMod { get; set; } 
         public Integer totalTasksAdd { get; set; }         
         public Integer totalTasksMod { get; set; }    
         public Integer totalVehicleAdd { get; set; }  
         public Integer totalVehicleMod { get; set; }       
         public CountData (String UserId ,String UserName ,String State) {                       
             this.UserId = UserId; 
             this.UserName = UserName;
             this.State = State;              
             this.totalAccountAdd = 0;           
             this.totalAccountMod = 0; 
             this.totalTasksAdd = 0;
             this.totalTasksMod = 0;  
             this.totalVehicleAdd = 0; 
             this.totalVehicleMod = 0;                                 
         }       
    }
}