/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               18-Jan-2021
Version:            1.0
Description:        Test Class for ContactTrgHandler and ContactTrg
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
18-Jan-2021           Danish QaimKhani                   Initial                     
**********************************************************************************/
@isTest
private class ContactUnMask_BatchTest {
    
    
       @isTest static void test_insert() {
		
		list<Contact> ListContact = DataFactoryTest.testgetContactList('Customer_Guest');
           ListContact[0].email=ListContact[0].email+'.test';
           update ListContact;
           
           ContactUnMask_Batch c=new ContactUnMask_Batch();
			database.executeBatch(c,200);
          
		
	}

}