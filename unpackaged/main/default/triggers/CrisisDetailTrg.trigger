trigger CrisisDetailTrg on Crisis_Details__c (before insert, before update) {

     // Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'CrisisDetailsTrg'];
    if(!objTrgActive.Flag__c ) return ;
    
    CrisisDetailTrgHandler handler = new CrisisDetailTrgHandler();
    
      // Before Insert 
    if(Trigger.isInsert && Trigger.isBefore)
    {
      handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
    }
    
     // Before Update
    else if(Trigger.isUpdate && Trigger.isBefore)
    {
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    
}