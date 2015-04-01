/*
    Type:       Utility for record update insert or delete
    Purpose:    Utility for record update insert or delete
    User Story: 
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Bing Bai Created on 2013-08-05
*/
public with sharing class DBUtil {

    public static void insertSobjects(List<Sobject> sos) {
        if(sos.size()>0){
            try {
                insert sos;
            }
            catch (DMLException e) {
                if(trigger.new != null){
                    trigger.new[0].addError(e.getDMLMessage(0));
                }
            }
        }
    }

    public static void updateSobjects(List<Sobject> sos) {
        if(sos.size()>0){
            try {
                update sos;
            }
            catch (DMLException e) {
                if(trigger.new != null){
                    trigger.new[0].addError(e.getDMLMessage(0));
                }
            }
        }
    }
    
    public static void deleteSobjects(List<Sobject> sos) {
        if(sos.size()>0){
            try {
                delete sos;
            }
            catch (DMLException e) {
                if(trigger.new != null){
                    trigger.new[0].addError(e.getDMLMessage(0));
                }
            }
        }
    }
}