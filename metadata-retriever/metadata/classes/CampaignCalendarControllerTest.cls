/*
    Type:       Campaign Calendar Controller Test
    Purpose:    Test the class
    User Story: 
    ---------------------------------------------------------------
    History:

    1. Justin Yu created on 2013-08-08

*/
@isTest
public class CampaignCalendarControllerTest {

    @isTest
    public static void testCampaignCalendarController(){
        CampaignCalendarController controller = new CampaignCalendarController();
        String language = controller.getUserLan();
        System.assert(language != null);
        List<Campaign> campaigns = CampaignCalendarController.queAllCamps('2012', '2012');
        System.assert(campaigns != null);
    }
}