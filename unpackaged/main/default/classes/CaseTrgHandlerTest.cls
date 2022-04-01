/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               03-march-2021
Version:            1.0
Description:        Test Class for CaseTrgHandler and CaseTrg 
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
03-march-2021            Danish QaimKhani                   Initial                     
**********************************************************************************/
@isTest
private class CaseTrgHandlerTest {

    @isTest static void test_insert() {
        list<Administration_Data__c> ListOfAdminData = DataFactoryTest.testgetAdministrationData(); 
        list<Account> ListAccount = DataFactoryTest.testgetAccountList('Franchise_Managed_Account');
        DataFactoryTest.testgetContactList('Customer_Guest');
       // DataFactoryTest.testgetContactList('Customer_Guest');
        list<Case> ListCase = DataFactoryTest.testgetCaseList('Loyalty');
         
        ListCase[0].Status='Closed';
        ListCase[0].Resolution__c='Added Credits'; 
        ListCase[0].Reason_Text__c ='test';  
		ListCase[0].Value__c ='test';
        ListCase[0].Location__c =ListAccount[0].Id;
        ListCase[0].Action_Taken__c ='Question Answered';
        ListCase[0].Problem_Area__c='FH: Attitude';
        ListCase[1].Status='Pending';
        ListCase[1].Origin='Email';
        ListCase[1].SuppliedEmail=Label.System_Org_Wide_Email_Address;
        ListCase[1].ContactId=null;
        Update  ListCase;
        
        
    }
    
}