/*-------------------------------------------------------------------------------------------------
Author:             Shoukat Hussain
Date: 				 
Version: 			1.0
Description:        Medallia Staging Trigger
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on             Added By               Description
**********************************************************************************/

trigger MedalliaStagingTrg on Medallia_Staging__c (After insert, After update) {
    // Get the  current trigger information to execute or not execute  
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'MedalliaStagingTrg'];
    if(!objTrgActive.Flag__c) return ;  // Return if trigger is inactive from custom meta data type
    // Initialize handler object
    MedalliaStagingTrgHandler handler = new MedalliaStagingTrgHandler(); 
    // MedalliaStagingTrgHandler_SH handler = new MedalliaStagingTrgHandler_SH();    
    
    
    if(Trigger.isInsert && Trigger.isAfter) // for after insert
    {             
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }    
    else if(Trigger.isUpdate && Trigger.isAfter) // for after update
    {
        system.debug('OnAfterUpdate 1');
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }   
    
}