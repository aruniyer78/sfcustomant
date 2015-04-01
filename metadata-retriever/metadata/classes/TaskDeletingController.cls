/*
    Type:       Page Controller
    Purpose:    Prevent someone from removing tasks.
    User Story: 
    Used By:    Task Deleting page.
    ---------------------------------------------------------------
    History:
    
    1. Shuang Li Created on 2014-04-08
*/
public class TaskDeletingController {

    private Set<String> profiles = new Set<String>();
    private Task task;
    
    public TaskDeletingController(ApexPages.StandardController controller) {
        task = (Task)controller.getRecord();
        isAllowedDelete = false;
        profiles.add('BMBS CRM Manager - Acq & Loyalty');
        profiles.add('BMBS AS Marketing Manager');
        profiles.add('BMBS AS Marketing Staff');
        profiles.add('CAC IT Manager');
    }
    
    public Boolean isAllowedDelete { get; set; }
    
    public PageReference removeTask(){
        User user = [select Profile.Name from User where Id = :Userinfo.getUserId()];
        if(profiles.contains(user.Profile.Name)){
            try{
                delete task;
                isAllowedDelete = true;
                return new PageReference('/007?isdtp=it');
            }
            catch(DMLException ex){
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }
}