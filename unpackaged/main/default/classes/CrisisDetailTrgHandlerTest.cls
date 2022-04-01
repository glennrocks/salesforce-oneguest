/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               03-march-2021
Version:            1.0
Description:        Test Class for CrisisDetailTrgHandler 
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
03-march-2021            Danish QaimKhani                   Initial                     
**********************************************************************************/
@isTest
private class CrisisDetailTrgHandlerTest {
    
    @isTest static void test_method1() {
        
         Crisis_Details__c CDobj = new Crisis_Details__c();
		CDobj.Name='test'; 
        CDobj.Crisis_Number__c='123';
        CDobj.Crisis_Type__c='Drowning';
        
        insert CDobj;
        
        CDobj.Crisis_Number__c='456';
        
        update CDobj;

        
    }

}