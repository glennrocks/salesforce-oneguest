trigger AgentWorkTrg on AgentWork (before insert) {
// Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'AgentWorkTrg'];
    if(!objTrgActive.Flag__c ) return ;
     
    
    AgentWorkHandler handler = new AgentWorkHandler();
    
     // Before Insert 
    if(Trigger.isInsert && Trigger.isBefore)
    {
        handler.onBeforeInsert(Trigger.new, Trigger.newMap);
    }

    
}