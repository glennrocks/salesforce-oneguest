trigger ContactTrg on Contact (after insert, after update, before insert, before update, before delete, after delete)
{
    // Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'ContactTrg'];
    if(!objTrgActive.Flag__c ) return ;
    
    ContactTrgHandler handler = new ContactTrgHandler();
    
    // before Insert
    if(Trigger.isInsert && Trigger.isBefore)
    {
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
    }
    
    // After Insert
     if(Trigger.isInsert && Trigger.isAfter)
    {
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }
    
     // After Update
     if(Trigger.isUpdate && Trigger.isAfter)
    {
        handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
     // Before Update
    if(Trigger.isUpdate && Trigger.isBefore)
    {
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    
     // After Delete
    /*if(Trigger.isDelete && Trigger.isAfter)
    {
        handler.OnAfterDelete(Trigger.old);
    }*/
    
  
    
  
    
   
    
 
}