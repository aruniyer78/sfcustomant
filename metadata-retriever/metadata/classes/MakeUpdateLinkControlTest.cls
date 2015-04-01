/*
    Type:       MakeUpdateLinkControl Test
    Purpose:    Test the class
    User Story: 
    ---------------------------------------------------------------
    History:

    1. Shuang Li created on 2014-03-10

*/
@isTest
public class MakeUpdateLinkControlTest {
    @isTest(seeALLData = true)
    public static void testMakeUpdateLinkControl(){
        MakeUpdateLinkControl controller = new MakeUpdateLinkControl();
        String address = controller.getEmailserviceAddress();
        String leadId = controller.getLeadId();
        System.assertEquals(null, leadId);
    }
}