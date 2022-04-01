/*

Description : This class will help to create test data and return it to its calling class.

*/ 
@isTest
public class DataFactoryTest
{
     public static list<Account> testgetAccountList(String RecordtypeParam)
    {
        List<Account> ListOfAccount = new List<Account>();
        
        ListOfAccount.add(new Account(Name= 'test Account 1',Location_Number__c='1_'+ Math.round((Math.random() * (900000) + 100000)),RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId()));
        ListOfAccount.add(new Account(Name= 'test Account 2',Location_Number__c='2_'+ Math.round((Math.random() * (900000) + 100000)),RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId()));
        ListOfAccount.add(new Account(Name= 'test Account 3',Location_Number__c='3_'+ Math.round((Math.random() * (900000) + 100000)),RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId()));
        ListOfAccount.add(new Account(Name= 'test Account 4',Location_Number__c='4_'+ Math.round((Math.random() * (900000) + 100000)),RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId()));
       
        insert ListOfAccount;
        return ListOfAccount;
    }
    
    public static list<Contact> testgetContactList(String RecordtypeParam)
    {
        List<Contact> ListOfContact = new List<Contact>();
        
        ListOfContact.add(new Contact(LastName= 'test Account 1',FirstName='test',Email = 'test1@gmail.com', MailingPostalCode = '10001',RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId()));
        ListOfContact.add(new Contact(LastName= 'test Account 2',FirstName='test',Email = 'test2@gmail.com',RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId()));
        
        
        insert ListOfContact;
        return ListOfContact;
    }
    
     public static list<Case> testgetCaseList(String RecordtypeParam)
    {
        List<Case> ListOfCases = new List<Case>();
        
        ListOfCases.add(new Case(Subject='Test Controller Acct Case',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId(),Status='new'));
        ListOfCases.add(new Case(Subject='Test Controller Acct Case',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId(),Status='new'));
        ListOfCases.add(new Case(Subject='Test Controller Acct Case',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId(),Status='new'));
        ListOfCases.add(new Case(Subject='Test Controller Acct Case',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId(),Status='Pending',Origin='Email',SuppliedEmail='danish.qaimkhani@getteconic.com',ContactId=null));
        ListOfCases.add(new Case(Subject='Test Controller Acct Case',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId(),Status='Pending',Origin='Email',SuppliedEmail='danish.qaimkhani@getteconic.com',ContactId=null));
		ListOfCases.add(new Case(Subject='Test Controller Acct Case urgent',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId(),Status='Pending',Origin='Email',SuppliedEmail='danish.qaimkhani@getteconic.com',ContactId=null));
        ListOfCases.add(new Case(Subject='Test Controller Acct Case',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId(),Status='Pending',Origin='Email',SuppliedEmail='danish.qaimkhani@getteconic.com',ContactId=null,Is_Junk_Case__c=true));
        ListOfCases.add(new Case(Subject='Test Controller Acct Case',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId(),Status='Pending',Origin='Web',SuppliedEmail='danish.qaimkhani@getteconic.com',ContactId=null,System_W2C_Website__c='abc',Reason='Customer Service',SuppliedPhone='123'));
		ListOfCases.add(new Case(Subject='Test Controller Acct Case',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId(),Status='Pending',Origin='Web',SuppliedEmail='test3@gmail.com',ContactId=null,System_W2C_Website__c='InternalWebForm',Reason='Loyalty',SuppliedPhone='123',System_Contact_Last_Name__c='test Account 2',System_Contact_First_Name__c='test'));
        insert ListOfCases;
        return ListOfCases;
    }
    public static list<Administration_Data__c> testgetAdministrationData(){
        List<Account> ListOfAccount = testgetAccountList('Franchise_Managed_Account');
        List<Administration_Data__c> ListOfAdminData = new List<Administration_Data__c>();
        EmailTemplate templateId = [Select id,DeveloperName from EmailTemplate limit 1];
        
        // do not change 0 index using it batch escalation test class
        ListOfAdminData.add(new Administration_Data__c(Name='CaseEscalationSetup',use_for__c='Case Escalation',Property_Id__c=ListOfAccount[0].Id,Trackable_Statuses__c='In Progress,Pending,Pending Guest,Pending Internal,Pending Warehouse,Pending Shipper,Pending Shipper Secondary,Pending Warehouse Secondary,Pending Internal Secondary,Pending,Guest Secondary,Pending Onsite Property Team Member,Paused Crisis,Paused Other,Responded,Reopened',Un_Trackable_Statuses__c='Resolved,New,Closed',RecordTypeId = Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Case_Escalation').getRecordTypeId()) );
        ListOfAdminData.add(new Administration_Data__c(Name='Medallia alert type transform to case High',use_for__c='Medallia Alert Type',Medallia_Alert_Types__c='Detractor | Elite or R2,Passive | Elite or R2,Promoter | Elite or R2,Detractor | X or Rank 1,Passive | X or Rank 1,Promoter | X or Rank 1',Case_Priority__c ='High',RecordTypeId = Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Medallia_Case').getRecordTypeId() ) );
		ListOfAdminData.add(new Administration_Data__c(Name='Medallia alert type transform to case High',use_for__c='Medallia Alert Type',Medallia_Alert_Types__c='Detractor | Elite or R2,Passive | Elite or R2,Promoter | Elite or R2,Detractor | X or Rank 1,Passive | X or Rank 1,Promoter | X or Rank 1',Case_Priority__c ='High',RecordTypeId = Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Medallia_Case').getRecordTypeId() ) );
        ListOfAdminData.add(new Administration_Data__c(Name='test',use_for__c='Case Priority With Case Type',Webform_Link__c='abc',Case_Priority__c ='High', Reason_for_Contacting__c='Customer Service', Case_Record_Type__c='Loyalty',RecordTypeId = Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Case_Priority_With_Case_Type').getRecordTypeId() ) );
		ListOfAdminData.add(new Administration_Data__c(Name='test2',use_for__c='WebForms Property',Webform_Link__c='abc',Property_Id__c=ListOfAccount[0].Id,RecordTypeId = Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Web_Forms_Property').getRecordTypeId() ) );
		ListOfAdminData.add(new Administration_Data__c(Name='test4',use_for__c='WebForms Property',Webform_Link__c='abc',Property_Id__c=ListOfAccount[0].Id,RecordTypeId = Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Web_Forms_Property').getRecordTypeId() ) );
		ListOfAdminData.add(new Administration_Data__c(Name='test3',use_for__c='WebForms Property',Webform_Link__c='abc',Receiver_Email__c=Label.System_Org_Wide_Email_Address,Email_Template_Name__c=templateId.DeveloperName,Property_Id__c=ListOfAccount[0].Id,RecordTypeId = Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Web_Forms_Property').getRecordTypeId() ) );
	    ListOfAdminData.add(new Administration_Data__c(Name='test5',use_for__c='Email To Case Template Selection',Receiver_Email__c=Label.System_Org_Wide_Email_Address,Email_Template_Name__c=templateId.DeveloperName,Property_Id__c=ListOfAccount[0].Id,RecordTypeId = Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Email_To_Case_Template_Selection').getRecordTypeId() ) );
        insert ListOfAdminData;
        return ListOfAdminData;
    }
    
    public static list<Contact> testgetContactWithAccountRelationShipList(String RecordtypeParam,String Accid ,String AccountIdparam)
    {
        List<Contact> ListOfContact = new List<Contact>();
        AccountContactRelation acr =new AccountContactRelation();
        // AccountId=AccountIdparam ,
        ListOfContact.add(new Contact(LastName= 'test  1', AccountId=Accid , FirstName='test1',Email = 'test1@gmail.com', MailingPostalCode = '10001',RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId()));
        ListOfContact.add(new Contact(LastName= 'test  2', AccountId=Accid ,  FirstName='test2',Email = 'test2@gmail.com',RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId()));
		ListOfContact.add(new Contact(LastName= 'test  3', AccountId=Accid ,  FirstName='test3',Email = 'test3@gmail.com',RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RecordtypeParam).getRecordTypeId()));
        
        
        insert ListOfContact;
        
        List<AccountContactRelation> ListOfContactRelationShip = new List<AccountContactRelation>();
       integer i=0;
       /* for(Contact row:ListOfContact){
             acr =  new AccountContactRelation();
            
            acr.Contactid=row.Id;
            acr.Accountid=row.AccountId;
            if(i==0)
            	acr.Email_Notifications__c='All Cases (Crisis & Non-Crisis)';
            if(i==1)
            	acr.Email_Notifications__c='Non-Crisis Cases';
            if(i>1)
            	acr.Email_Notifications__c='Only Crisis Cases';
            acr.Escalation_Level__c='Lead Team Member; Supervisor; Manager; Director; VP';
            
            ListOfContactRelationShip.add(acr);
            
            i++;
        }*/
        
        acr =  new AccountContactRelation();
            
            acr.Contactid=ListOfContact[0].Id;
            acr.Accountid=AccountIdparam;
			acr.Email_Notifications__c='All Cases (Crisis & Non-Crisis)';
			acr.Escalation_Level__c='Lead Team Member; Supervisor; Manager; Director; VP';
        
         ListOfContactRelationShip.add(acr);
        
            acr =  new AccountContactRelation();
            
            acr.Contactid=ListOfContact[1].Id;
            acr.Accountid=AccountIdparam;
			acr.Email_Notifications__c='Non-Crisis Cases';
            acr.Escalation_Level__c='Lead Team Member; Supervisor; Manager; Director; VP';
         ListOfContactRelationShip.add(acr);
        
        	acr =  new AccountContactRelation();
            
            acr.Contactid=ListOfContact[2].Id;
            acr.Accountid=AccountIdparam;
			acr.Email_Notifications__c='Only Crisis Cases';
            acr.Escalation_Level__c='Lead Team Member; Supervisor; Manager; Director; VP';
        
        
         ListOfContactRelationShip.add(acr);
        
        
        insert ListOfContactRelationShip;
        return ListOfContact;
    }
    
    
    
    public static list<Escalation_Admin_Table__c> testgetEscalationAdminTableData(){
       
        List<Escalation_Admin_Table__c> ListOfAdminData = new List<Escalation_Admin_Table__c>();
        ListOfAdminData.add(new Escalation_Admin_Table__c(Case_Record_Type__c='Loyalty',Case_Status__c='In Progress',Escalation_Level__c='Lead Team Member',Tier__c='Premier',Time_Minutes__c=2) );
        ListOfAdminData.add(new Escalation_Admin_Table__c(Case_Record_Type__c='Loyalty',Case_Status__c='In Progress',Escalation_Level__c='Supervisor',Tier__c='Premier',Time_Minutes__c=2) );
        ListOfAdminData.add(new Escalation_Admin_Table__c(Case_Record_Type__c='Loyalty',Case_Status__c='In Progress',Escalation_Level__c='Manager',Tier__c='Premier',Time_Minutes__c=2) );
        ListOfAdminData.add(new Escalation_Admin_Table__c(Case_Record_Type__c='Loyalty',Case_Status__c='In Progress',Escalation_Level__c='Director',Tier__c='Premier',Time_Minutes__c=2) );
        ListOfAdminData.add(new Escalation_Admin_Table__c(Case_Record_Type__c='Loyalty',Case_Status__c='In Progress',Escalation_Level__c='VP',Tier__c='Premier',Time_Minutes__c=2) );
        insert ListOfAdminData;
        return ListOfAdminData;
    }
    
    public static Medallia_Staging__C SurveyResponseIns(Medallia_Staging__C ms,string SurveyId,string SRstatus){       
        //Medallia_Staging__C ms = new Medallia_Staging__C();
        ms.CASINO_ACCOUNT_NUMBER__C = '03082021-1307-10';
        ms.EMAIL__C = 'e.gomez10@testing.gmail.com';
        ms.FIRST_NAME__C = 'Easton';
        ms.LAST_NAME__C = 'Gomez';
        ms.Rank_Value__c = 20;
        ms.Survey_ID__c = SurveyId;
        ms.Responsedate__c = system.Date.today();
        ms.Record_Type_Seminole__c = 'RT Seminole';
        ms.Overall_Satisfaction_with_Property__c = 'Somewhat satisfied2';
        ms.Alert_type__c = 'Detractor | Elite or R2';
        ms.Current_status_of_alert__c = SRstatus;
        ms.Property__c = 'Hard Rock Hotel & Casino Atlantic City';
        ms.Rank__c = '09';
        ms.Tier__c='XCARD';
        return ms;
    }
    
    public static list<Administration_Data__c> testGetAdminDataForExecutiveEscalation(){
    
        List<Administration_Data__c> adminDataEEList = new List<Administration_Data__c>();
        
     	Administration_Data__c adminItem = new Administration_Data__c();
        adminItem.Name = 'Case Escalation For Test';
        adminItem.Use_For__c = 'Executive Escalation';
        adminItem.RecordTypeId = Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Executive_Escalation').getRecordTypeId();
        adminItem.From_Address__c = 'mok309@outlook.com';
        adminItem.To_Address__c = Label.System_Org_Wide_Email_Address;
        adminItem.Case_Record_Type__c = 'Other';
        adminItem.SF_Case_Status__c = 'General Hold';
        adminItem.Case_Priority__c = 'High';
        
        adminDataEEList.add(adminItem);
        
        return adminDataEEList;
        
    }    
    
    
}