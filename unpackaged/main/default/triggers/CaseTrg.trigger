trigger CaseTrg on Case (after insert, after update, before insert, before update, before delete) {
 // Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'CaseTrg'];
    if(!objTrgActive.Flag__c ) return ;
    
    
    CaseTrgHandler handler = new CaseTrgHandler();
    
     // Before Insert 
    if(Trigger.isInsert && Trigger.isBefore)
    {
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
    }
    
     // After Insert
    else if(Trigger.isInsert && Trigger.isAfter)
    {
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }
    
    // Before Update
    else if(Trigger.isUpdate && Trigger.isBefore)
    { 
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
}