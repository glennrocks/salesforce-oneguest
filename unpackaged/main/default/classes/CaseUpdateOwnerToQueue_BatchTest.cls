/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               21-June-2021
Version:            1.0
Description:        Test Class for ContactTrgHandler and ContactTrg
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
21-June-2021          Danish QaimKhani                   Initial                     
**********************************************************************************/
@isTest
private class CaseUpdateOwnerToQueue_BatchTest {
    
      @isTest static void test_insert() {
		
		
          
           List<Case> ListOfCases = new List<Case>();
        
        ListOfCases.add(new Case(Subject='Test Controller Acct Case',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loyalty').getRecordTypeId(),Status='Open in MS Dynamics'));
        ListOfCases.add(new Case(Subject='Test Controller Acct Case',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loyalty').getRecordTypeId(),Status='Open in MS Dynamics'));
      
        insert ListOfCases;
           
           
           CaseUpdateOwnerToQueue_Batch c=new CaseUpdateOwnerToQueue_Batch();
			database.executeBatch(c,200);
          
		
	}

}