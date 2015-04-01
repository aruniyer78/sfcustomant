/*
    Type:       Campaign Calendar Controller
    Purpose:    Query User and Campaign Information shown on Calendar
    User Story: US_AU-Cpn-011
    Used By:    Campaign Calendar(VF)
    ---------------------------------------------------------------
    History:

    1. Justin Yu created on 2013-08-08

*/
public class CampaignCalendarController {
        
    public String getUserLan(){
         return UserInfo.getLanguage();
    }
    
    @RemoteAction
    public static List<Campaign> queAllCamps(String startYear, String endYear) {
        
        Date startDate = system.today();
        Date endDate = system.today();
        List<Campaign> result = new List<Campaign>();
        
        String baseSoql = 'select Id, Name, Type, Status, StartDate, EndDate, IsActive, Frequency_Category__c from Campaign';
        String otherSoql = ' ';
        
        if(!String.isBlank(startYear)){
                startDate = date.valueOf(startYear + '-1' + '-1');
                otherSoql = ' where StartDate != Null AND StartDate >= :startDate ';
        }
        if(!String.isBlank(endYear))
        {
                endDate = date.valueOf(endYear + '-12' + '-31');
                otherSoql += ' AND EndDate != Null AND EndDate <= :endDate ';
        }
        
        result = Database.query(baseSoql + otherSoql);
        return result;
    }
}