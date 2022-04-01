/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               03-march-2021
Version:            1.0
Description:        Test Class for EmailMessageTrgHandler 
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
03-march-2021            Danish QaimKhani                   Initial                     
**********************************************************************************/
@isTest
public class EmailMessageTrgHandlerTest {
    
     @isTest static void test_insert() {
        list<Administration_Data__c> ListOfAdminData = DataFactoryTest.testgetAdministrationData();
         
        list<Contact> ListOfContact = DataFactoryTest.testgetContactList('Customer_Guest'); 
        list<Account> ListAccount = DataFactoryTest.testgetAccountList('Franchise_Managed_Account');
        
        list<Case> ListCase = DataFactoryTest.testgetCaseList('Loyalty');
        ListCase[0].Origin='Email'; 
        ListCase[0].SuppliedEmail='test@test.com';
        ListCase[0].Status='Closed';
        ListCase[0].Resolution__c='Added Credits'; 
        ListCase[0].Reason_Text__c ='test';  
		ListCase[0].Value__c ='test';
        ListCase[0].Location__c =ListAccount[0].Id;
        ListCase[0].Action_Taken__c ='Question Answered';
        ListCase[0].Problem_Area__c='FH: Attitude';
        ListCase[1].Status='Pending'; 
        ListCase[1].Origin='Email'; 
        ListCase[1].SuppliedEmail='test2@test.com';
        Update  ListCase;
         
         
         //Insert test case record
        Case c = new Case();
        c.Subject = 'Ok Test';
        c.Status ='New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        insert c;

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= Label.System_Org_Wide_Email_Address;
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;       
         
     	List<EmailMessage > listofEmailMessage = new List<EmailMessage >();
        
        listofEmailMessage.add(new EmailMessage(fromaddress='test12ss12@gmail.com', toAddress = ListOfContact[0].Email, subject = 'Opt Out Test Message', TextBody= 'This is the message body BR-Interno.', RelatedToId = ListCase[0].Id,Incoming=true));
        listofEmailMessage.add(new EmailMessage(fromaddress='test@test.com', toAddress = ListOfContact[0].Email, subject = 'Opt Out Test Message', TextBody= 'This is the message body BR-Interno.',Incoming=true));
        listofEmailMessage.add(new EmailMessage(fromaddress='test@test.com', toAddress = ListOfContact[0].Email, subject = 'Opt Out Test Message', TextBody= 'This is the message body BR-Interno.', RelatedToId = ListCase[1].Id,Incoming=true));
        listofEmailMessage.add(new EmailMessage(fromaddress='test@test.com', toAddress = 'test12ssam@gmail.com', subject = 'Opt Out Test Message', TextBody= 'This is the message body BR-Interno.'));
        listofEmailMessage.add(new EmailMessage(fromaddress='test@test.com', toAddress = Label.System_Org_Wide_Email_Address, RelatedToId = ListCase[1].Id, subject = 'Opt Out Test Message', TextBody= 'This is the message body BR-Interno.',Incoming=true));    
		
         insert listofEmailMessage;
         
        
		
	}
    
    //Code done for escalation cases - HRSC3AP-520 by Mustafa Quresh dated: 15/11/2021
     @isTest static void test_insert_executive_escalation() {  
       
        Test.StartTest(); 
         List<Administration_Data__c> adminDataEEList = DataFactoryTest.testGetAdminDataForExecutiveEscalation(); 
         Insert adminDataEEList;
         system.debug('admin data list: ' + adminDataEEList); 
         
         //Insert test case record
        Case c = new Case();
        c.Subject = 'Ok Test';
        c.Status ='New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        insert c;
         
         //Insert emailmessage for executive escalation case
        EmailMessage emailItem = new EmailMessage();
        emailItem.FromAddress = 'mok309@outlook.com';
        emailItem.Incoming = True;
        emailItem.ToAddress= Label.System_Org_Wide_Email_Address;
        emailItem.Subject = 'Test email';
        emailItem.HtmlBody = 'Test email body';
        emailItem.RelatedToId = c.Id; 
      
        insert emailItem;   
        
        
         
		Test.stopTest();         
     }
    
}