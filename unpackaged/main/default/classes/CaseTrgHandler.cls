/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               29-Jan-2021
Version:            1.0
Description:        Case Trigger Handler
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on             Added By               Description
**********************************************************************************
29/Jan/2021          Danish QaimKhani          Added method that
Associate Contact with Case in case in case of Email to Case HSC3AP-106
**********************************************************************************
16/Feb/2021          Danish QaimKhani          Added method that
store and empty status change time acording to the requirments // onBeforeUpdate
**********************************************************************************
**********************************************************************************
10/Mar/2021          Shoukat Hussain          Added feature that
store current login in case close by once the case get closed // onBeforeUpdate
**********************************************************************************
15/Arpil/2021        Danish QaimKhani          Added feature that
automatically check/uncheck crisis checkbox // onBeforeInsert , onBeforeUpdate // HRSC3AP-289
**********************************************************************************
05/Jan/2022 		Mustafa Quresh			Modifications in dynamic merge field work
Added unity account number and location number fields in the auto response email sending part //HRSC3AP-557
**********************************************************************************
*/

public class CaseTrgHandler {
    
    public void onBeforeInsert(List<Case> newObjects, Map<Id, Case> newMap){

        try{    
            set<String> setofEmailAddresses = new set<String>();
            set<String> setofEmailAddressesCreateContact = new set<String>();
            map<String,String> mapofEmailWithId = new  map<String,String>();
            map<String,String> mapofEmailCreatedContacts = new  map<String,String>();
            Datacloud.FindDuplicatesResult[] results;     
            list<Contact> lstOfContactstoCheckDuplicate =new list<Contact>();
            set<String> setofduplicateContactCaseNumber =new set<String> ();
            Contact objContact = new Contact();
            
            map<String,list<Administration_Data__c>> mapofRecordTypeAndPriority  = new  map<String,list<Administration_Data__c>>();       
            map<String,list<Administration_Data__c>> mapofPropertyWithlink  = new  map<String,list<Administration_Data__c>>();  
            list<Administration_Data__c> tempPriorityData= new list<Administration_Data__c>();
            List<String> listOfSubjectBreakWithSpace = new List<String>();  
            
            String trackableStatuses='';
            String nonTrackableStatuses='';
            Boolean EmailFlag = False;
           
            //Get Custom Metadata values of Default Account
            //
            
        /*    Set<id> setLocations=new Set<id>();
            
            
            for(case cObj:newObjects){
                setLocations.add(cObj.Location__c);
            }
            Map<string,Account> mpLocationName=new Map<string,Account>();
            
            Map<id,Account> mpLocations=new Map<Id,Account>([select id,Name from Account where id in: setLocations]);
         
            
            map<string,string> mpCaseEmail=new map<string,string> ();
            for(CaseEmail_Trigger__c m:[select Decision__c,Id,EmailTemplate_API__c, Entity__c,To_Email_Address__c ,CC_Email_Address__c, Location__c, Property__c, Case_Reason__c  from CaseEmail_Trigger__c]){
               mpCaseEmail.put(m.Case_Reason__c+'##'+m.Location__c,m.id);
            }
     
            for(case cObj:newObjects){
                for(string str:mpCaseEmail.keyset()){
                  Account ac=  mpLocations.get(cObj.Location__c);
                    system.debug('ac'+ac.Name+'cObjReason'+cObj.Reason+'str'+str);
                    List<string> lstlocationName=str.split('##');
                    if(str.contains(cObj.Reason) && ac.Name.contains(lstlocationName[1])){
                       cObj.Email_Close__c =mpCaseEmail.get(str);
                        break;
                    }
                }
            }
            */
            
            // Ticket 452 to send notification for the 1000 case created for that day
            Integer noOfCases;
            //List<Case> numberofcases = [select id from Case where CreatedDate = TODAY AND Owner.Name != 'Medallia Queue'];
            List<Case> numberofcases = [select id from Case where CreatedDate = TODAY];
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            noOfCases = numberofcases.size();
            System.debug('Number of Cases: '+noOfCases);
            //Send Email Alert
            if(noOfCases == 500 && !EmailFlag ){
                // String[] sendTo = new String[]{'SGAHelpDesk@stofgaming.com','emile.zack@shrss.com','dessire.ruiz@shrss.com','Judy.prisk@shrss.com','kushangi.patel@shrss.com'};
 				String[] sendTo = new String[]{'dessire.ruiz@shrss.com','v-pavan.nichenametla@shrss.com','kushangi.patel@shrss.com'};
                String body = 'Salesforce has detected that over 500 cases have been created today. Salesforce support will be reviewing shortly and will provide an update if an issue is identified.';
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(sendTo);
                mail.setSubject('Salesforce Service Cloud - High Case Volume Notification 1,000+');
                mail.setHtmlBody(body);
                mailList.add(mail);
                Messaging.sendEmail(mailList);
                EmailFlag = True;
            }
            
            if(noOfCases == 0){
                EmailFlag = False;
            }
            // Ticket 452 End
            
            for(Administration_Data__c AdminDataRow:[Select id, name,Trackable_Statuses__c,Un_Trackable_Statuses__c,use_for__c,Webform_Link__c,Reason_for_Contacting__c,Case_Priority__c,Case_Record_Type__c,Property_Id__c from Administration_Data__c Where use_for__c='Case Escalation' OR Name='CaseEscalationSetup' OR use_for__c='Case Priority With Case Type' OR use_for__c='WebForms Property'  ])
            {
                if(AdminDataRow.Name=='CaseEscalationSetup' && AdminDataRow.use_for__c=='Case Escalation')
                {	
                    trackableStatuses= AdminDataRow.Trackable_Statuses__c;
                    nonTrackableStatuses=AdminDataRow.Un_Trackable_Statuses__c;
                }
                else if(AdminDataRow.use_for__c=='Case Priority With Case Type' && AdminDataRow.Webform_Link__c!=null && AdminDataRow.Reason_for_Contacting__c!= null)
                {
                    
                    // storing data in map to reuse in loop
                    if(mapofRecordTypeAndPriority.containsKey(AdminDataRow.Webform_Link__c+'_'+AdminDataRow.Reason_for_Contacting__c)){
                        mapofRecordTypeAndPriority.get(AdminDataRow.Webform_Link__c+'_'+AdminDataRow.Reason_for_Contacting__c).add(AdminDataRow);
                    }
                    else
                        mapofRecordTypeAndPriority.put(AdminDataRow.Webform_Link__c+'_'+AdminDataRow.Reason_for_Contacting__c,new  List <Administration_Data__c>{ AdminDataRow});
                    
                }
                
                else if(AdminDataRow.use_for__c=='WebForms Property' && AdminDataRow.Webform_Link__c!=null && AdminDataRow.Property_Id__c!= null)
                {
                    //mapofPropertyWithlink
                    // storing data in map to reuse in loopEmail
                    if(mapofPropertyWithlink.containsKey(AdminDataRow.Webform_Link__c)){
                        //  mapofRecordTypeAndPriority.get(AdminDataRow.Webform_Link__c+'_'+AdminDataRow.Reason_for_Contacting__c).add(AdminDataRow);
                    }
                    else
                        mapofPropertyWithlink.put(AdminDataRow.Webform_Link__c,new  List <Administration_Data__c>{ AdminDataRow});
                    
                }    
                
                
            }	  
            
            List<String> listofactiveCaseStatusValues =  trackableStatuses.split(',');
            List<String> listofInactiveCaseStatusValues = nonTrackableStatuses.split(','); 
            Integer counter=0;
            for(Case row:newObjects)
            {
                
                // only for data loading if User wants to insert created data time 
                if(Label.System_DataLoading_Case_Audit_Fields=='TRUE')
                {
                    //  row.MSD_Created_Date__c=row.CreatedDate.date();
                    if(row.CreatedDate != null)
                        row.MSD_Created_Date__c=row.CreatedDate.date();
                    else
                        row.MSD_Created_Date__c=System.today();
                    // 
                    // row.CreatedDate= row.MSD_Created_Date__c;
                }   
                
                
                counter++;
                // automatically change crisis checkbox HRSC3AP-289
                if(row.Crisis_Details__c != null)
                    row.Is_related_to_Crisis__c	=true;
                
                // checking origin is email and 
                // code for email to case
                if(row.Origin=='Email' && row.ContactId == null && row.SuppliedEmail != null){
                    setofEmailAddresses.add(row.SuppliedEmail); 
                    setofEmailAddressesCreateContact.add(row.SuppliedEmail);
                    
                }
                //checking for email to case if subject has urgent word   //HRSC3AP-469
                if(row.Origin=='Email' && row.Subject !=null)
                {
                    listOfSubjectBreakWithSpace= row.Subject.toLowercase().split(' ');
                    if(listOfSubjectBreakWithSpace.contains('urgent')  || listOfSubjectBreakWithSpace.contains('[urgent]'))
                        row.Priority='High';
                }
                // assign high priority to internal web form cases  HRSC3AP-483row
                if(row.System_W2C_Website__c == 'InternalWebForm')
                    row.Priority='High';
                // change origin to phone only for internal web form HRSC3AP-483
                if(row.Origin=='Web' && row.System_W2C_Website__c != null && row.System_W2C_Website__c == 'InternalWebForm' &&  row.Reason !=null){
                    row.Origin='Phone';
                    // coloning the value into record type as per reason HRSC3AP-483
                    row.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( row.Reason).getRecordTypeId();  
                }    
                
                // checking for web // HRSC3AP-169
                // code for web to case forms
                if( (row.Origin=='Web' || row.System_W2C_Website__c == 'InternalWebForm' ) && row.System_W2C_Website__c != null && row.Reason != null){
                    row.OwnerId=Label.Case_Active_Queue_Id;
                    
                    if(row.SuppliedPhone !=null)
                        row.Supplied_Web_Phone__c=row.SuppliedPhone;
                    
                    // storing data in map to reuse in loop
                    // assigning case record type and priority
                    // DONOT add values for internal web forms otherwise it will over right the value of record type HRSC3AP-483
                    if(mapofRecordTypeAndPriority.containsKey(row.System_W2C_Website__c+'_'+row.Reason)){
                        tempPriorityData=   mapofRecordTypeAndPriority.get(row.System_W2C_Website__c+'_'+row.Reason);
                        row.Priority=tempPriorityData[0].Case_Priority__c;
                        // checking if record type has value
                        if(tempPriorityData[0].Case_Record_Type__c!=null)
                            row.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(tempPriorityData[0].Case_Record_Type__c).getRecordTypeId();
                    }
                    
                    //assigning property id 
                    if(mapofPropertyWithlink.containsKey(row.System_W2C_Website__c) && mapofPropertyWithlink.get(row.System_W2C_Website__c)[0].Property_Id__c != null ){
                        row.Location__c=mapofPropertyWithlink.get(row.System_W2C_Website__c)[0].Property_Id__c;
                    }
                    
                    // if no contact is associated  checking for duplicate
                    // if(row.ContactId == null){
                    
                    row.ContactId=null;
                    objContact = new Contact();
                    
                    objContact.FirstName=row.System_Contact_First_Name__c;
                    objContact.LastName=row.System_Contact_Last_Name__c;
                    objContact.Email=row.SuppliedEmail;
                    objContact.Phone=row.SuppliedPhone;
                    objContact.System_Run_Duplicate_Rule_Via_Code__c=true;
                    //  objContact.System_Reason_For_Contact_Association__c='>> name '+row.SuppliedName;
                    lstOfContactstoCheckDuplicate.add(objContact);
                    
                    results = Datacloud.FindDuplicates.findDuplicates(lstOfContactstoCheckDuplicate);
                    for (Datacloud.FindDuplicatesResult findDupeResult : results) {
                        for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                            for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                                for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) 
                                {
                                    if(matchResult.getMatchRecords().size()>1)
                                    {
                                        
                                        row.System_Reason_For_Contact_Association__c='Duplicate Contact Found';
                                        setofduplicateContactCaseNumber.add(row.CaseNumber);
                                    }
                                    else if(matchResult.getMatchRecords().size()==1){
                                       
                                        row.ContactId=matchRecord.getRecord().Id;
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    
                    
                    
                    
                }
                
                // Assigning a case to junk Queue if case is marked in junked HRSC3AP-440
                if(row.Is_Junk_Case__c==true)
                    row.OwnerId=Label.Case_Junk_Queue_Id;
                
                // inserting time if status is trackable 
                // this is done for escalation process
                if(listofactiveCaseStatusValues.contains(row.Status))
                {
                   // row.Status_Change_Time__c=row.Status_Updated_Time__c;
                 	row.Status_Updated_Time__c=system.now();

                }
                else if(listofInactiveCaseStatusValues.contains(row.Status))
                {
                    // row.Status_Change_Time__c=row.Status_Updated_Time__c;
                     row.Status_Updated_Time__c=null;

                }
                
                //making sure these fields are blank when the record is getting inserted
                row.IsEscalated=false;
                row.Escalation_Level__c = null;
                
                
            }
            
            // checking size
            if(setofEmailAddressesCreateContact.size()>0)
            {    // query on contact to fetch data 
                for(Contact con:[Select Id,Name,Email From Contact Where Email In:setofEmailAddressesCreateContact])
                {    // contact found must be duplicate 
                    if(!mapofEmailWithId.containsKey(con.Email))
                        mapofEmailWithId.put(con.Email,con.Id);
                    // removing from set so we donot need to create Contact for this  Email 
                    setofEmailAddressesCreateContact.remove(con.Email);
                }
            } 
            
            // checking size after remvoing found contact's email
            if(setofEmailAddressesCreateContact.size()>0)
            {  
                mapofEmailCreatedContacts= CreateContactWithAccounts(setofEmailAddressesCreateContact) ;
            }
            // checking Orginal Size
            if(setofEmailAddresses.size()>0)
            {
                for(Case row:newObjects)
                {
                    // checing origin is email and 
                    if(mapofEmailCreatedContacts.containsKey(row.SuppliedEmail) && row.Origin=='Email'){
                        row.System_Reason_For_Contact_Association__c='New Contact Created';
                        row.ContactId=mapofEmailCreatedContacts.get(row.SuppliedEmail);
                    }
                    else if(mapofEmailWithId.containsKey(row.SuppliedEmail) && row.Origin=='Email'){
                        row.System_Reason_For_Contact_Association__c='Duplicate Contacts Found';
                    }
                    
                }
            }
            
            // if no contact is associated then create contact and account
            // assuming web to case will one by one
            list<contact> lstOfContactsToInsert = new list<contact>();
            map<Integer,Contact> mapofContactWithCounter = new  map<Integer,Contact>(); 
            counter=0;
            for(Case row:newObjects){
                system.debug('Print contactID: ' + row.ContactId);
                if( (row.Origin=='Web' || row.System_W2C_Website__c == 'InternalWebForm' ) && row.ContactId == null && row.System_Reason_For_Contact_Association__c != 'Duplicate Contact Found' ){
                    counter++;
                    objContact = new Contact();
                    
                    objContact.FirstName=row.System_Contact_First_Name__c;
                    // Throwing exception if the last name is null for Web to case 
                    if(row.System_Contact_Last_Name__c != null){
                                            objContact.LastName=row.System_Contact_Last_Name__c;

                    }
                    else 
                    {
                                 		  objContact.LastName=row.SuppliedName;
 
                    }
                    objContact.Email=row.SuppliedEmail;
                    objContact.Phone=row.SuppliedPhone;
                    objContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Guest').getRecordTypeId();
                    objContact.OwnerId=Label.Medallia_Integration_User_Id;	
                    // only for UAT
                   // if(row.Unity_Account_Number__c != null)
                     //   objContact.Unity_Loyalty_ID__c= row.Unity_Account_Number__c;
                    
                    lstOfContactsToInsert.add(objContact);                    
                    mapofContactWithCounter.put(counter,objContact) ;	
                    
                }
            }
            if(lstOfContactsToInsert.size()>0)
            {    
                system.debug('Contact Creation Checked:');
                insert  lstOfContactsToInsert;
                counter=0;
                for(Case row:newObjects)
                {
                    if( (row.Origin=='Web' || row.System_W2C_Website__c == 'InternalWebForm' ) && row.ContactId == null && row.System_Reason_For_Contact_Association__c != 'Duplicate Contact Found' ){
                        counter++;
                        row.System_Reason_For_Contact_Association__c='New Contact Created';
                        if(mapofContactWithCounter.containsKey(counter))
                            row.ContactId=mapofContactWithCounter.get(counter).Id;
                        
                    }    
                }
            }
            
            
        } catch(Exception Ex)
        {  
            System.debug('KK_Error :: ' + Ex.getMessage() +' >' + EX.getCause() +'>'+ EX.getLineNumber()  ); 
            string contactidLabel= Label.Error_Email_Receiver;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            //  mail.setToAddresses(contactidLabel.split(','));
            mail.setSubject('Apex Failure : ' );
            mail.setPlainTextBody(' Error Msg ' +Ex.getMessage()+ 'Line Number'+Ex.getLineNumber());
            mail.setTargetObjectId(contactidLabel.split(',')[0]);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
                    });
            
        }           
        
        
    }	
    
    
    public void OnAfterInsert(List<Case> newObjects,Map<Id, Case> newMap){
        map<String,Administration_Data__c> mapofAdminData = new  map<String,Administration_Data__c>();
        map<String,EmailTemplate> mapofEmailTemplateData = new  map<String,EmailTemplate>();
        map<String,String> mapofEmailWithOrgids = new  map<String,String>();
        map<String,String> mapofCasesWithEmail = new  map<String,String>();
        map<String,String> mapofCasesWithContactIds = new  map<String,String>();
        map<String,String> mapofAccIdContactEmail = new  map<String,String>();

        map<String,Case> mapofCaseInfo = new  map<String,Case>();
        set<String> setofOrgWideEmails = new set<String>();
        set<String> setofWebLinks = new set<String>();
        set<String> setofTemplateDevNames = new set<String>();
        set<String> setofAccountIds = new set<String>();
        set<String> setofContactIds= new set<String>();
        Boolean EmailForEachIdFlag = false;
        Boolean propertyFlag = false;
        List<String> PropertyEmailAdd = new List<String>();
        List<AccountContactRelation> aConRelRecord = new List<AccountContactRelation>();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        
        Administration_Data__c currentAdminData= new Administration_Data__c();
        EmailTemplate currentTemplateData = new  EmailTemplate();
        List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        try{
            
            //CaseEmailTrigger.triggerEmail(newObjects);
            
            for(Case rowCase:newObjects)
            {
                if(rowCase.Origin=='Web'  && rowCase.System_W2C_Website__c !=null)
                {   
                    mapofCaseInfo.put(rowCase.Id,rowCase);
                    setofWebLinks.add(rowCase.System_W2C_Website__c);
                    
                    if(rowCase.Location__c != null)
                        setofAccountIds.add(rowCase.Location__c);
                    
                    if(rowCase.ContactId==null && rowCase.SuppliedEmail !=null)
                        mapofCasesWithEmail.put(rowCase.Id,rowCase.SuppliedEmail);
                    else if(rowCase.ContactId!=null)
                    {
                        mapofCasesWithContactIds.put(rowCase.Id,rowCase.ContactId);
                        setofContactIds.add(rowCase.ContactId);
                    }
                    
                }
            }  
            // if web to cases records found
            if(setofWebLinks.size()>0)
            {    
                // getting template id from  admin table
                for(Administration_Data__c AdminDataRow:[Select id, name,Email_Template_Name__c, Receiver_Email__c,Webform_Link__c from Administration_Data__c Where use_for__c='WebForms Property' ])
                {
                    if(AdminDataRow.Webform_Link__c!= null && AdminDataRow.Receiver_Email__c != null && AdminDataRow.Email_Template_Name__c !=null ) 
                    {
                        mapofAdminData.put(AdminDataRow.Webform_Link__c,AdminDataRow);
                        setofTemplateDevNames.add(AdminDataRow.Email_Template_Name__c);
                        setofOrgWideEmails.add(AdminDataRow.Receiver_Email__c);
                    } 
                }
                
                
                // storing template data in Map
                for(EmailTemplate rowTemplate:[SELECT Id, Name, DeveloperName, Subject, Body,HtmlValue FROM EmailTemplate  WHERE DeveloperName IN :setofTemplateDevNames ])
                {   
                    mapofEmailTemplateData.put(rowTemplate.DeveloperName,rowTemplate);
                    
                }
                
                // storing OrgWideEmailAddress
                for(OrgWideEmailAddress rowTemplate:[SELECT Id, Address FROM OrgWideEmailAddress  WHERE Address IN :setofOrgWideEmails ])
                {   
                    mapofEmailWithOrgids.put(rowTemplate.Address,rowTemplate.Id);
                    
                }
                
                // storing account information
                Map<Id, Account> mapofAccountData = new Map<Id, Account>([SELECT Id, Name FROM Account Where Id IN:setofAccountIds]);
                // checking if inserted contact has a valid email or not
                Map<Id, Contact> mapofcontactValidEmails = new Map<Id, Contact>([SELECT Id, Name FROM Contact Where Id IN:setofContactIds AND Email != null]);
                
                String getFromaddress='';
                String EmailBody='';
                String EmailSubject=''; 
                List<String> lstofcontactIds= new List<String>();
                List<String> lstofcontactIds2= new List<String>();

                List<String> lstofEmailAddress= new List<String>();
                
                Case CaseData = new  Case();
                Account accountData = new  Account();
                
                
                for(Case currentCaseRow:mapofCaseInfo.values())
                {   
                    
                    
                    
                    if(!mapofAdminData.containsKey(currentCaseRow.System_W2C_Website__c))
                        continue;
                    
                    //accountData = new  Account();
                    
                    
                    currentAdminData=  mapofAdminData.get(currentCaseRow.System_W2C_Website__c);
                    currentTemplateData 	= mapofEmailTemplateData.get(currentAdminData.Email_Template_Name__c);
                    
                    accountData=    mapofAccountData.get(currentCaseRow.Location__c);
                    
                    
                //    system.debug('Account Data: '+accountData);
                    
                    
                    
                    // comment code and sending email to supplied email  HRSC3AP-501
                    /*
// storing ids or email address to send
// also cheking contact id must have valid emails
if(mapofCasesWithContactIds.containsKey(currentCaseRow.Id) && mapofcontactValidEmails.containsKey(mapofCasesWithContactIds.get(currentCaseRow.Id)))
{ 
lstofcontactIds.add(mapofCasesWithContactIds.get(currentCaseRow.Id));
//mail.setTargetObjectId(mapofCasesWithContactIds.get(currentCaseRow.Id));
// mail.setSaveAsActivity(false);
mail.setToAddresses(lstofcontactIds); 
}
else if(mapofCasesWithEmail.containsKey(currentCaseRow.Id) )
{    
lstofcontactIds.add(mapofCasesWithEmail.get(currentCaseRow.Id));
mail.setToAddresses(lstofcontactIds);
} 
else
continue;
*/
                  
                    
                    // sending email to supplied email HRSC3AP-501
                    if(currentCaseRow.suppliedemail != null)
                    {	lstofcontactIds.add(currentCaseRow.suppliedemail);
                     	//mail.setToAddresses(lstofcontactIds);
                    }
                             
                    System.debug('Account ID: '+currentCaseRow.Location__c);
                    System.debug('Reason: '+currentCaseRow.Reason);
                    aConRelRecord = [SELECT Property_Email__c,Web_Reason__c  from AccountContactRelation WHERE AccountId =:currentCaseRow.Location__c];
                    System.debug('Account Contact Relation Records - Name: '+aConRelRecord);
                    for(AccountContactRelation abc :aConRelRecord ){
                        if(abc.Web_Reason__c != null && abc.Web_Reason__c.indexOf(currentCaseRow.Reason)!= -1){
                            system.debug('Emails from the relation: '+abc.Property_Email__c);
                    		lstofcontactIds.add(abc.Property_Email__c);
                            propertyFlag = TRUE;
                        }
                    }

                              
                    /* 

                    aConRelRecord = [SELECT Account.Name, Contact.Email from AccountContactRelation WHERE Account.Name =:currentCaseRow.Location__r.Name];
                    
                    aConRelRecord = [SELECT Property_Email__c from AccountContactRelation WHERE AccountId =:currentCaseRow.Location];

                    System.debug('Account Contact Relation Records:Name: '+aConRelRecord);
                    

                    if(aConRelRecord.size() > 0){
                        mapofAccIdContactEmail.put(acrRec.Account.Name,acrRec.Contact.Email);
                        if(mapofAccIdContactEmail.containsKey(currentCaseRow.Location__r.Name)){
                                lstofcontactIds.add(mapofAccIdContactEmail.get(currentCaseRow.Location__r.Name));
                        }
                    }
                    
                    if(currentCaseRow.Location__c != null){
                        {
                            //lstofcontactIds.add('pknichen@gmail.com');
                            
                            for(AccountContactRelation acrRec:aConRelRecord){
                                mapofAccIdContactEmail.put(acrRec.Account.Name,acrRec.Contact.Email);
                            }
                            if(mapofAccIdContactEmail.containsKey(currentCaseRow.Location__r.Name)){
                                lstofcontactIds.add(mapofAccIdContactEmail.get(currentCaseRow.Location__r.Name));
                            }
                        }
                    }
                    */


                     
                    system.debug('List of Emails:'+lstofcontactIds);
                    system.debug('Status: '+currentCaseRow.Status);
                    mail.setToAddresses(lstofcontactIds);
					List<Case> lstCases = [SELECT Id, Status, CaseNumber from Case where Id IN :trigger.new];
                    for(Case c:lstCases){
                        if(propertyFlag){
                        	c.Status = 'Property Hold';
                        }
                    update c;
                    }
                    
                    system.debug('Status: '+currentCaseRow.Status);

                    
                    // dynamic merge field work 
                    Map<String, String> mapSubjectParams = new Map<String, String> {
                        '{!Case.Status}' => currentCaseRow.Status,
                            '{!Case.CaseNumber}' => currentCaseRow.CaseNumber,
                            '{!Case.Location__c}' => accountData.Name,
                            '{!Case.Location__r}' => accountData.Name,
                            '{!Case.Reason_Text__c}'=> currentCaseRow.Reason, 
                            '{!Case.System_Contact_First_Name__c}'=> currentCaseRow.System_Contact_First_Name__c,
                            '{!Case.System_Contact_Last_Name__c}'=> currentCaseRow.System_Contact_Last_Name__c,
                            '{!Case.Unity_Account_Number__c}'=> currentCaseRow.Unity_Account_Number__c, //Mustafa Quresh
                            '{!Case.Location_Number__c}'=> currentCaseRow.Location_Number__c, //Mustafa Quresh
                            '{!Case.Name_of_property_visited__c}'=> currentCaseRow.Name_of_property_visited__c, //Mustafa Quresh
                            '{!Case.SuppliedEmail}'=> currentCaseRow.SuppliedEmail, 
                            '{!Case.SuppliedName}'=> currentCaseRow.SuppliedName, //Pavan
                            '{!Case.Rewards_Member_ID__c}'=> currentCaseRow.Rewards_Member_ID__c, 
                            '{!Case.Description}'=> currentCaseRow.Description,
                            '{!Seminole_Wild_Card_Number__c}'=>  currentCaseRow.Seminole_Wild_Card_Number__c, 
                            '[YYYY]'=> string.valueOf(System.Today().year())    
                            
                            };
                                
                                
                                Map<String, String> mapBodyParams = new Map<String, String> {
                                    '{!Case.CaseNumber}' => currentCaseRow.CaseNumber,
                                        '{!Case.Reason_Text__c}'=> currentCaseRow.Reason , 
                                        '{!Case.Reason}'=> currentCaseRow.Reason , //Pavan
                                        '{!Case.System_Contact_First_Name__c}'=> currentCaseRow.System_Contact_First_Name__c,
                                        '{!Case.System_Contact_Last_Name__c}'=> currentCaseRow.System_Contact_Last_Name__c, 
                                        '{!Case.Unity_Account_Number__c}'=> currentCaseRow.Unity_Account_Number__c, //Mustafa Quresh
                                        '{!Case.Location_Number__c}'=> currentCaseRow.Location_Number__c, //Mustafa Quresh
                                        '{!Case.Name_of_property_visited__c}'=> currentCaseRow.Name_of_property_visited__c, //Mustafa Quresh
                                        '{!Case.SuppliedEmail}'=> currentCaseRow.SuppliedEmail,
                                        '{!Case.SuppliedName}'=> currentCaseRow.SuppliedName, //Pavan
                                        '{!Case.SuppliedPhone}'=> currentCaseRow.SuppliedPhone, //Pavan
                                        '{!Case.Rewards_Member_ID__c}'=> currentCaseRow.Rewards_Member_ID__c, 
                                        '{!Case.Description}'=> currentCaseRow.Description,
                                        '{!Seminole_Wild_Card_Number__c}'=>  currentCaseRow.Seminole_Wild_Card_Number__c, 
                                        '[YYYY]'=> string.valueOf(System.Today().year()),     
                                        '{!Case.Status}' => currentCaseRow.Status,
                                        '{!Case.CreatedDate}' => currentCaseRow.CreatedDate.date().format(),
                                        '{!Case.Contact}'=>null,
                                        '{!Case.Location__c}' => accountData.Name,
                                        '{!Case.Location__r}' => accountData.Name, //   
                                        '{!Case.System_Location_Phone__c}' => currentCaseRow.System_Location_Phone__c,
                                        '{!$Label.System_Link_For_Brand}' => Label.System_Link_For_Brand,
                                        '{!$Label.System_Link_For_Brighton}' => Label.System_Link_For_Brighton,
                                        '{!$Label.System_Link_For_Classic}' => Label.System_Link_For_Classic,
                                        '{!$Label.System_Link_For_CoCo}' => Label.System_Link_For_CoCo,
                                        '{!$Label.System_Link_For_Ecom}' => Label.System_Link_For_Ecom,
                                        '{!$Label.System_Link_For_HWHR}' => Label.System_Link_For_HWHR,
                                        '{!$Label.System_Link_For_Loyalty}' => Label.System_Link_For_Loyalty,
                                        '{!$Label.System_Link_For_SGIM}' => Label.System_Link_For_SGIM,
                                        '{!$Label.System_Link_For_TAHR}' => Label.System_Link_For_TAHR,
                                        '{!$Label.System_Link_For_Banner}' => Label.System_Link_For_Banner,  
                                        '{!$Label.System_Link_For_Banner2}' => Label.System_Link_For_Banner2,
                                        '{!$Label.System_Link_For_Unity}' => Label.System_Link_For_Unity //Mustafa Quresh
                                        };             
                                            
                                            if(currentTemplateData.HtmlValue != null)   
                                            EmailBody=  currentTemplateData.HtmlValue;
                    else
                        EmailBody=  currentTemplateData.Body;
                    
                    EmailSubject= currentTemplateData.Subject;
                    
                    for(String key: mapSubjectParams.keySet())
                        EmailSubject = EmailSubject.replace(key, (mapSubjectParams.get(key) == null ? '' : mapSubjectParams.get(key)));
                    
                    for(String key: mapBodyParams.keySet())
                        EmailBody = EmailBody.replace(key, (mapBodyParams.get(key) == null ? '' : mapBodyParams.get(key)));
                    
                    
                    
                    
                    
                    //  dynamic field work ended here
                    //  mail sending work 
                    //  
                    if(mapofEmailWithOrgids.containsKey(currentAdminData.Receiver_Email__c))
                    	mail.setOrgWideEmailAddressId(mapofEmailWithOrgids.get(currentAdminData.Receiver_Email__c));
                    
                    mail.setSubject(EmailSubject);
                    if(currentTemplateData.HtmlValue != null)  
                        mail.setHtmlBody(EmailBody);
                    else
                        mail.setPlainTextBody(EmailBody); 
                    
                    mail.setReplyTo(currentAdminData.Receiver_Email__c);
                    // mail.setSenderDisplayName('SHRSS Customer Support');
                    mail.setWhatId(currentCaseRow.Id);
                    // mail.setTargetObjectId(currentCaseRow.Id);
                    mail.setTemplateId(currentTemplateData.Id);
                    
                    // mail.setTemplateId('00XS0000002i8VaMAI');
                    //mail.setTargetObjectId(mapofCasesWithIds.get(currentCaseId));

                    lstSingleEmailMessage.add(mail); 
                    
                }    
                // sening emails in bulk
                if(lstSingleEmailMessage.size()>0 && Label.Send_Auto_Response_Emails=='TRUE')
                    Messaging.SendEmailResult[] r = Messaging.sendEmail(lstSingleEmailMessage);
               
            }
            
        }catch(Exception ex){
            System.debug('KK_Error :: ' + Ex.getMessage() ); 
            string contactidLabel= Label.Error_Email_Receiver;
            Messaging.SingleEmailMessage mailError = new Messaging.SingleEmailMessage();
            
            // mail.setToAddresses(contactidLabel.split(','));
            mailError.setSubject('Apex Failure : Web to Case ' );
            mailError.setPlainTextBody(' Error Msg ' +Ex.getMessage());
            mailError.setTargetObjectId(contactidLabel.split(',')[0]);
            mailError.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mailError
                    });
        }
        
        /* string contactidLabel2= Label.Error_Email_Receiver;
Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();

mail2.setToAddresses(contactidLabel2.split(','));
mail2.setSubject('001  : ' );
list<EmailMessage> lst=new list<EmailMessage>();

map<String,String> mapofCasesWithEmail = new  map<String,String>();
map<String,String> mapofCasesWithContactIds = new  map<String,String>();
map<String,String> mapofCasesFromEmailAddress = new  map<String,String>();
List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
try{
for(Case rowCase:newObjects)
{  
// if contact is assosicated with this case
if(rowCase.Origin =='Email' ){
if(rowCase.ContactId==null && rowCase.SuppliedEmail !=null)
mapofCasesWithEmail.put(rowCase.Id,rowCase.SuppliedEmail);
else if(rowCase.ContactId!=null)
mapofCasesWithContactIds.put(rowCase.Id,rowCase.ContactId);
}

lst=[SELECT id, ParentId ,ToAddress FROM EmailMessage  where ParentId='500S000000EkDzEIAV'  ];
mail2.setPlainTextBody('lst >> '+lst+' rowCase.Id  '+rowCase.Id +' >> mapofCasesWithEmail'+mapofCasesWithEmail.size() );

Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
mail2
});

}




if(mapofCasesWithContactIds.size()>0 || mapofCasesWithEmail.size()>0 )
{
// query on email message object to find the TO email address
for(Case row:[select Id, OwnerId, 
(SELECT id, ParentId ,ToAddress FROM EmailMessages ORDER BY CreatedDate DESC   ) 
from Case 
Where Id IN:mapofCasesWithEmail.keyset()
OR Id IN:mapofCasesWithContactIds.keyset()])
{

if(row.EmailMessages.size() > 0)
{
for(EmailMessage emailMessagerow : row.EmailMessages)
{
mapofCasesFromEmailAddress.put(row.id,emailMessagerow.ToAddress);
}   

}
}
}



// sending emails
String getFromaddress='';
String EmailBody='';
String EmailSubject=''; 
List<String> lstofcontactIds= new List<String>();
List<String> lstofEmailAddress= new List<String>();
if(mapofCasesFromEmailAddress.size()>0)
{
for(String currentCaseId: mapofCasesFromEmailAddress.keyset())
{	
lstofcontactIds.clear();
EmailBody='';
getFromaddress= mapofCasesFromEmailAddress.get(currentCaseId);

Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
// storing ids or email address to send
if(mapofCasesWithEmail.containsKey(currentCaseId))
lstofcontactIds.add(mapofCasesWithEmail.get(currentCaseId));
if(mapofCasesWithContactIds.containsKey(currentCaseId))
lstofcontactIds.add(mapofCasesWithContactIds.get(currentCaseId));

EmailBody='<html <body>'
+'Dear   <br/> <br/>'
+'To confirm, your request is being processed under case number '+currentCaseId+'. Please be assured that your inquiry is very important to us and we will endeavor to contact you via email or via telephone at our earliest convenience. If in the meantime if you would like to speak with us or if your inquiry is urgent please call us at. <br/> <br/>'
+'Sincerely <br/>'
+'SHRSS <br/>'
+'</body> </html>';

mail.setToAddresses(lstofcontactIds);
mail.setSubject('Auto Response From Apex Code ');
mail.setHtmlBody(EmailBody);
mail.setReplyTo(getFromaddress);
lstSingleEmailMessage.add(mail); 

lstofcontactIds.clear();

} 
// sening emails in bulk
if(lstSingleEmailMessage.size()>0)
Messaging.SendEmailResult[] r = Messaging.sendEmail(lstSingleEmailMessage);
}

}catch( Exception Ex )
{ System.debug('KK_Error :: ' + Ex.getMessage() ); 
string contactidLabel= Label.Error_Email_Receiver;
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

mail.setToAddresses(contactidLabel.split(','));
mail.setSubject('Apex Failure : ' );
mail.setPlainTextBody(' Error Msg ' +Ex.getMessage());

Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
mail
});
}                 
*/
    }
    
    
    public void onBeforeUpdate(List<Case> oldObjects, List<Case> newObjects, Map<Id, Case> oldMap, Map<Id, Case> newMap){
        Case OldCase; 
        String trackableStatuses='';
        String omniTrackableStatuses='';
        String nonTrackableStatuses='';
        //Get Custom Metadata values of Default Account
        for(Administration_Data__c AdminDataRow:[Select id, name,Trackable_Statuses__c,Un_Trackable_Statuses__c, use_for__c from Administration_Data__c Where (use_for__c='Case Escalation' OR use_for__c='Omni Channel') AND (Name='CaseEscalationSetup' OR Name='OmniChannelStatus') LIMIT 10])
        {
            if(AdminDataRow.use_for__c == 'Omni Channel')
                omniTrackableStatuses = AdminDataRow.Trackable_Statuses__c;
            else{
                trackableStatuses= AdminDataRow.Trackable_Statuses__c;
                nonTrackableStatuses=AdminDataRow.Un_Trackable_Statuses__c;
            }
        }	  
        
        List<String> listofactiveCaseStatusValues =  trackableStatuses.split(',');
        List<String> listofPendingOmniCaseStatusValues =  omniTrackableStatuses.split(',');
        List<String> listofInactiveCaseStatusValues = nonTrackableStatuses.split(',');
        // storing User prefix Id
        string userObjIdPrefix = User.sobjecttype.getDescribe().getKeyPrefix();
        for(Case rowCase:newObjects)
        {
            OldCase = oldMap.get( rowCase.Id );
            
            
            
            // automatically change crisis checkbox HRSC3AP-289
            if(rowCase.Crisis_Details__c != null && ( rowCase.Crisis_Details__c != OldCase.Crisis_Details__c  || rowCase.Is_related_to_Crisis__c != OldCase.Is_related_to_Crisis__c   ))
                rowCase.Is_related_to_Crisis__c	=true;
            
            // Assigning a case to junk Queue if case is marked in junked HRSC3AP-440
            if(rowCase.Is_Junk_Case__c != OldCase.Is_Junk_Case__c && rowCase.Is_Junk_Case__c==true)
                rowCase.OwnerId=Label.Case_Junk_Queue_Id;
            
            // is status is changed and in track able status
            if(rowCase.Status != OldCase.Status  )
            {
                if(listofactiveCaseStatusValues.contains(rowCase.Status))
                    rowCase.Status_Updated_Time__c=system.now();
                else if(listofInactiveCaseStatusValues.contains(rowCase.Status))
                    rowCase.Status_Updated_Time__c=null;
                
                rowCase.IsEscalated=false;
                rowCase.Escalation_Level__c = null;
                //Added by Shoukat 10-mar-21
                if(rowCase.Status=='Closed') rowCase.Case_Closed_By__c =   UserInfo.getUserId(); // if case closed then keep current user id
            }
            if(rowCase.Status != OldCase.Status && 
               (rowCase.System_Profile_Name__c == 'Agent' || rowCase.System_Profile_Name__c == 'Supervisor' 
                || rowCase.System_Profile_Name__c== 'System Administrator' || rowCase.System_Profile_Name__c== 'Business Admin'  ) &&
               listofPendingOmniCaseStatusValues.contains(rowCase.Status)){
                   rowCase.OwnerId = System.Label.Case_Pending_Queue_Id;
                   rowCase.Pending_Status_TimeStamp__c = system.now();
               }

			
            if(rowCase.OwnerId != OldCase.OwnerId && rowCase.OwnerId == System.Label.Case_Active_Queue_Id){
                rowCase.Pending_Status_TimeStamp__c = null;
            }
        }
    }  
    
    
    
    @testvisible
    private map<String,String> CreateContactWithAccounts(set<String> emailListParam){
        
        map<String,String> mapofEmailWithId = new  map<String,String>();
        List<Account> listOfAccountToInsert = new List<Account>();
        List<Contact> conList = new List<Contact>();
        String tempAccountName ='';
        try{
            for(String strrow:emailListParam){
                
                
                Contact con = new Contact();
                if(strrow.indexOf('@')>0)
                    con.LastName = strrow.substring(0,strrow.indexOf('@'));
                else
                    con.LastName = strrow; 
                con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Guest').getRecordTypeId();
                
                con.Email=strrow;
                con.OwnerId=Label.Medallia_Integration_User_Id;
                conList.add(con);
                
            }
            
            if(conList.size()>0)	
                insert conList;
            
            for(Contact con:conList){
                if(!mapofEmailWithId.containsKey(con.Email))
                    mapofEmailWithId.put(con.Email,con.Id);
            }
            
            return mapofEmailWithId;
            
        } catch( Exception Ex )
        { System.debug('KK_Error :: ' + Ex.getMessage() ); 
         string contactidLabel= Label.Error_Email_Receiver;
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         
         //mail.setToAddresses(contactidLabel.split(','));
         mail.setSubject('Apex Failure : ' );
         mail.setPlainTextBody(' Error Msg ' +Ex.getMessage()+  Ex.getLineNumber());
         mail.setTargetObjectId(contactidLabel.split(',')[0]);
         mail.setSaveAsActivity(false);
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
             mail
                 });
         
         return mapofEmailWithId;
        }               
        
        
    }
    
}