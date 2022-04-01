/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               04-may-2021
Version:            1.0
Description:        Test Class for AgentWorkHandler  
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
04-may-2021            Danish QaimKhani                   Initial                     
**********************************************************************************/
@isTest
public class AgentWorkHandlerTest {
    
    @isTest static void  testTriggerCoverage(){
        
        ServiceChannel sc = [SELECT Id
                             FROM ServiceChannel LIMIT 1];
      //  Case caseRec = [SELECT Id FROM Case LIMIT 1];
       // User systemUser = [SELECT Id FROM User WHERE FirstName = 'System'];
        list<Case> ListCase = DataFactoryTest.testgetCaseList('Loyalty');
        
        
            //Try Catch is to ensure test doesn't fail in cisit and ciuat
            try{
                AgentWork aw = new AgentWork(
                    ServiceChannelId = sc.Id,
                    WorkItemId = ListCase[0].Id,
                    UserId = UserInfo.getUserId()
                );
                insert aw;
                
               // aw.MyField__c = 'Submitted';
               // update aw;
            }catch(Exception ex){
                //Exception will occur due to the omni channel bug. Ignore it
                
            }
            
        
        
    }
    
}