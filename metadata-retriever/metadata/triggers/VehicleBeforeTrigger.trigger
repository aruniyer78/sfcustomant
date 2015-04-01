/*
    Type:       Trigger
    Purpose:    The vehicle object needs to be enhanced by a field called Vehicle Group.    
                
    User Story: US_AU-CD-001.2
*/
trigger VehicleBeforeTrigger on Vehicle__c (before insert, before update) {
    
    if(!CustomSettingUtil.isEnabled('VehicleBeforeTrigger')){
        return;
    }
    
    Set<String> carClasses = new Set<String>();
    
    for(Vehicle__c newCar : trigger.new){
        if(!carClasses.contains(newCar.Class__c)){
            carClasses.add(newCar.Class__c);
        }
    }

    Map<String,String> vehicleGroupMappings = new Map<String,String>();
    for(Vehicle_Group_Mapping__c vgm : [select Name, Vehicle_Group__c from Vehicle_Group_Mapping__c where Name in :carClasses]){
        String stringName = vgm.Name;
        stringName = stringName.toUpperCase();
        if(!vehicleGroupMappings.containsKey(stringName)){
            vehicleGroupMappings.put(stringName,vgm.Vehicle_Group__c);
        }
    }
    for(Vehicle__c newCar : trigger.new){
        String stringClass = newCar.Class__c;
        stringClass = stringClass.toUpperCase();
        newCar.Vehicle_Group__c = vehicleGroupMappings.get(stringClass);
    }
}