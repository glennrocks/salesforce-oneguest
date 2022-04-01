/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               03-march-2021
Version:            1.0
Description:        Test Class for ContactTrgHandler and ContactTrg
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
03-march-2021            Danish QaimKhani                   Initial                     
**********************************************************************************/
@isTest
private class ContactTrgHandlerTest {

    
    @isTest static void test_insert() {
		
		list<Contact> ListContact = DataFactoryTest.testgetContactList('Customer_Guest');
		
	}
    
    @isTest static void test_update() {
		list<Contact> ListContact = DataFactoryTest.testgetContactList('Customer_Guest');
		list<Account> ListAccount = DataFactoryTest.testgetAccountList('Customer_Guest_Account');
		ListContact[0].AccountId=ListAccount[0].Id;
        ListContact[0].LastName='test test';
		update ListContact;
		
	}
    
}