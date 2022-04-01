/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               03-march-2021
Version:            1.0
Description:        Test Class for CaseEscalation_Batch
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
03-march-2021            Danish QaimKhani                   Initial                     
**********************************************************************************/
@isTest (SeeAllData=false)
private class CaseEscalation_BatchTest {
    
    @isTest static void test_method1(){
         list<Escalation_Admin_Table__c> ListOfCaseTableData = DataFactoryTest.testgetEscalationAdminTableData(); 
        list<Administration_Data__c> ListOfAdminData = DataFactoryTest.testgetAdministrationData(); 
        
        List<Account> ListOfAccount = new List<Account>();
        
        ListOfAccount.add(new Account(Name= 'test Account 5',Location_Number__c='1237',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Franchise_Managed_Account').getRecordTypeId()));
        ListOfAccount.add(new Account(Name= 'test Account 6',Location_Number__c='1238',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Franchise_Managed_Account').getRecordTypeId()));
        ListOfAccount.add(new Account(Name= 'test Account 7',Location_Number__c='1239',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Franchise_Managed_Account').getRecordTypeId()));
        ListOfAccount.add(new Account(Name= 'test Account 8',Location_Number__c='1210',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Franchise_Managed_Account').getRecordTypeId()));
       
        insert ListOfAccount;
        
        Crisis_Details__c CDobj = new Crisis_Details__c();
		CDobj.Name='test'; 
        CDobj.Crisis_Number__c='123';
        CDobj.Crisis_Type__c='Drowning';
        
        insert CDobj;
        
        CDobj.Crisis_Number__c='1231234';
        update CDobj;
        if(ListOfAdminData[0].Property_Id__c != null)
        	DataFactoryTest.testgetContactWithAccountRelationShipList('Franchise_Managed_Property_Employee',ListOfAccount[0].Id,ListOfAdminData[0].Property_Id__c);
         
        list<Case> ListCase = DataFactoryTest.testgetCaseList('Loyalty');
        Integer i=0;
        for(Case row:ListCase){
            row.Status='In Progress';
            row.Status_Updated_Time__c=system.now().addMinutes(-120);
            if(i==0 || i==1)
            {
                row.Is_related_to_Crisis__c=true;
                row.Crisis_Details__c=CDobj.Id;
            }    
			i++;
        }
        	update ListCase;
        
        Test.startTest();
         Database.executeBatch(new CaseEscalation_Batch(), 200);

    }
    
    @isTest static void test_method2(){
         list<Escalation_Admin_Table__c> ListOfCaseTableData = DataFactoryTest.testgetEscalationAdminTableData(); 
        list<Administration_Data__c> ListOfAdminData = DataFactoryTest.testgetAdministrationData(); 
        
        List<Account> ListOfAccount = new List<Account>();
        
        ListOfAccount.add(new Account(Name= 'test Account 5',Location_Number__c='1211',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Franchise_Managed_Account').getRecordTypeId()));
        ListOfAccount.add(new Account(Name= 'test Account 6',Location_Number__c='1221',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Franchise_Managed_Account').getRecordTypeId()));
        ListOfAccount.add(new Account(Name= 'test Account 7',Location_Number__c='1231',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Franchise_Managed_Account').getRecordTypeId()));
        ListOfAccount.add(new Account(Name= 'test Account 8',Location_Number__c='1241',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Franchise_Managed_Account').getRecordTypeId()));
       
        insert ListOfAccount;
        
        Crisis_Details__c CDobj = new Crisis_Details__c();
		CDobj.Name='test'; 
        CDobj.Crisis_Number__c='123';
        CDobj.Crisis_Type__c='Drowning';
        
        insert CDobj;
        
       
       DataFactoryTest.testgetContactWithAccountRelationShipList('Franchise_Managed_Property_Employee',ListOfAccount[0].Id,ListOfAccount[1].Id);
         
        list<Case> ListCase = DataFactoryTest.testgetCaseList('Loyalty');
        Integer i=0;
        for(Case row:ListCase){
            row.Status='In Progress';
            row.Status_Updated_Time__c=system.now().addMinutes(-120);
            row.Location__c=ListOfAccount[1].Id;
            if(i==0 || i==1)
            {
                row.Is_related_to_Crisis__c=true;
                row.Crisis_Details__c=CDobj.Id;
            }    
			i++;
        }
        	update ListCase;
        
        Test.startTest();
         Database.executeBatch(new CaseEscalation_Batch(), 200);

    }
    
    
    
}