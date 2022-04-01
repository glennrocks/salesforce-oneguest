/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               06-April-2021
Version:            1.0
Description:        AgentWork Trigger Handler
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on             Added By               Description
**********************************************************************************

*/
public class AgentWorkHandler {

     public void onBeforeInsert(List<AgentWork> newObjects, Map<Id, AgentWork> newMap){
     set<String> setOfWorkItemIds = new set<String>();
     list<Case> lstOfCasesToUpdate = new list<Case>();    
         // storing case prefix Id
        string caseObjIdPrefix = Case.sobjecttype.getDescribe().getKeyPrefix();
         
         for(AgentWork row:newObjects){
            if(string.valueOf(row.WorkItemId).startsWith(caseObjIdPrefix))
            {    
                row.Case__c=row.WorkItemId;
                setOfWorkItemIds.add(row.WorkItemId);
            
            } 
         }
         
         if(setOfWorkItemIds.size()>0)
         {
             for(Case caseRow:[Select Id , Status From Case Where Id IN:setOfWorkItemIds]){
                 caseRow.Status ='In Progress';
                 lstOfCasesToUpdate.add(caseRow);
             }
             
           //  update lstOfCasesToUpdate;
             List<Database.SaveResult> SR = Database.update(lstOfCasesToUpdate,false);
             
         }
         
        
     }    
}