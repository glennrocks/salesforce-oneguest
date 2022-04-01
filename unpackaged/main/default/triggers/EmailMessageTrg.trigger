/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               27-Jan-2021
Version:            1.0
Description:        EmailMessage Trigger
----------------------------------------------------------------------------------------------------*/

trigger EmailMessageTrg on EmailMessage (after insert, after update, before insert, before update)
{
    // Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'EmailMessageTrg'];
    if(!objTrgActive.Flag__c ) return ;
    
    EmailMessageTrgHandler handler = new EmailMessageTrgHandler();
     // Before Insert 
   /* if(Trigger.isInsert && Trigger.isBefore)
    {
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
    }*/
    // After Insert
    if(Trigger.isInsert && Trigger.isAfter)
    {
       handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }

}