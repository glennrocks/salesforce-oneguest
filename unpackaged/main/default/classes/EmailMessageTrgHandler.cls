/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date: 				27-Jan-2021
Version:            1.0
Description:        Email Trigger Handler  // HRSC3AP-97
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on             Added By               Description
06/Jan/2022			Mustafa Quresh			Case Status on email to case

**********************************************************************************/

public class EmailMessageTrgHandler
{
    
  
    public void OnAfterInsert(List<EmailMessage> newObjects, Map<Id, EmailMessage> newMap)
    {
        set<Id> setOfCaseId = new set<Id>();
        set<Id> setOfEECaseId = new set<Id>(); //set of executive escalation case.
        list<case> listofCasesToUpdate = new list<case>();
        map<String,String> mapofCasesWithEmail = new  map<String,String>();
        map<String,String> mapofCasesWithContactIds = new  map<String,String>();
        map<String,String> mapofCasesFromEmailAddress = new  map<String,String>();
        map<String,String> mapofCasesWithIds = new  map<String,String>();
        map<String,String> mapofEmailTemplateids = new  map<String,String>();
        map<String,String> mapofEmailWithOrgids = new  map<String,String>();
        set<String> setofTemplateDevNames = new set<String>();
        map<String,Case> mapofCaseInfo = new  map<String,Case>();
        List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        map<String,EmailTemplate> mapofEmailTemplateData = new  map<String,EmailTemplate>();
        // storing case prefix Id
        String caseObjIdPrefix = Case.sobjecttype.getDescribe().getKeyPrefix();
        
        set<Id> setOfEmailMessageId = new set<Id>();
        set<Id> setOfContactId = new set<Id>();
        map<Id,String> mapofContactInfo= new map<Id,String>();
        map<Id,Id> mapofEmailMessageWithContactId= new map<Id,Id>();
		Id contactIdTemp;
        
        //Variable declaration for Inactive Contact Emails
        map<String,EmailMessage> mapofEmailAddresses= new map<String,EmailMessage>();
        List<String> lstEmailAddresses = new List<String>();
        //String caseObjIdPrefix = Case.sobjecttype.getDescribe().getKeyPrefix();
        
        //Variable declaration for Executive Escalation
        map<String, Administration_Data__c> mapOfFromEmails = new map<String, Administration_Data__c>();
        map<Id, EmailMessage> mapofEmailMessageWithCaseID = new map<Id, EmailMessage>();
       	List<Case> caseEscalationList = new List<Case>();
                                                            
        try
        {
            
        
         	while(newObjects[newObjects.size()-1].ToAddress == null){
                //loop added to wait for getting the values in the field of ToAddress, CCAddress and BCCAddress.
        	}
            
            for(EmailMessage emailObj : newObjects)
            {
            	system.debug('ToAddress in after insert: ' + emailObj.ToAddress);
                //Finding out if email has been sent via case reply
                if(emailObj.RelatedToId != null && string.valueOf(emailObj.RelatedToId).startsWith(caseObjIdPrefix) && emailObj.Incoming == true)
                {   // storing case ids to update their status
                    setOfCaseId.add(emailObj.RelatedToId);	
                    setOfEECaseId.add(emailObj.RelatedToId);
                    mapofEmailMessageWithCaseID.put(emailObj.RelatedToId, emailObj);
                    
                    
                //Code done for escalation cases - HRSC3AP-520
            	if(setOfEECaseId.size() > 0){
                    for(Administration_Data__c adminDataItem:[Select Id, Name, To_Address__c, From_Address__c, SF_Case_Status__c, Case_Record_Type__c, Case_Priority__c
                                                             from Administration_Data__c Where use_for__c='Executive Escalation' ]){
                         
                         mapOfFromEmails.put(adminDataItem.From_Address__c, adminDataItem);                                      
                        
                    }
                
                    for(Case caseItem : [Select Id, Status, Priority, Is_Executive_Escalation__c From Case where Id in : setOfEECaseId]){
                        
                        if(mapofEmailMessageWithCaseID.containsKey(caseItem.Id)){
                            if(mapOfFromEmails.containsKey(mapofEmailMessageWithCaseID.get(caseItem.Id).FromAddress)){
                              //  system.debug('From Address: ' + mapofEmailMessageWithCaseID.get(caseItem.Id).FromAddress);
                             //   if(mapOfFromEmails.get(emailObj.FromAddress).To_Address__c == mapofEmailMessageWithCaseID.get(caseItem.Id).ToAddress){
                                    caseItem.Status = mapOfFromEmails.get(emailObj.FromAddress).SF_Case_Status__c ;
                                    caseItem.Priority = mapOfFromEmails.get(emailObj.FromAddress).Case_Priority__c;
                                    Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(mapOfFromEmails.get(emailObj.FromAddress).Case_Record_Type__c).getRecordTypeId();
                                    caseItem.RecordTypeId = recordTypeId;
                                    caseItem.Is_Executive_Escalation__c = true;
                                    caseEscalationList.add(caseItem);
                              //  }    
                            }
                        }
                	}
                    
                    Update caseEscalationList;
                
            	}
            	//End code for escalation cases - HRSC3AP-520
                    
                }
                
                //Finding out if email has been sent via case reply using contact email.
                
           		if(emailObj.ParentId != null && string.valueOf(emailObj.ParentId).startsWith(caseObjIdPrefix) && emailObj.Incoming == false){
                    system.debug('For Email to Case Check false');
                    if(emailObj.ToAddress != null){
                        lstEmailAddresses.addAll(emailObj.ToAddress.split(','));
                    }           
                    
                    if(emailObj.BccAddress != null){
                        lstEmailAddresses.addAll(emailObj.BccAddress.split(','));
                    }
                    
                    if(emailObj.CcAddress != null){
                        lstEmailAddresses.addAll(emailObj.CcAddress.split(','));
                    }
                    
                    for(String str : lstEmailAddresses)
                    {
                        mapofEmailAddresses.put(str, emailObj);
                    }
                
        		}
        
        //addition for checking email addresses of inactive contact  
        if(mapofEmailAddresses.Size() > 0){
            system.debug('mapofEmailAddresses ' + mapofEmailAddresses);
            for(Contact contactItem : [Select Id, Name, Status__c, Email from Contact where Email IN : mapofEmailAddresses.keySet()]){
                system.debug('contactItem ' + contactItem);
                if(contactItem.Status__c == 'Inactive'){
                   
                    system.debug('contactItem'+contactItem.Email);
                    mapofEmailAddresses.get(contactItem.Email).addError('Cannot Send An Email To The Inactive Contact \''+contactItem.Name+'\'');
                  
                }				
            }
        }  
                
        //End of code for inactive contact emails.
                
                //Finding out if email has been sent via case reply using contact lookup
                // using it stop sending email to inactive contact
                if(emailObj.RelatedToId != null && string.valueOf(emailObj.RelatedToId).startsWith(caseObjIdPrefix) && emailObj.Incoming== false)
                {   // storing case ids to update their status
                    setOfEmailMessageId.add(emailObj.Id);
                    
                   
                }
                               
            }
                       
        
            // ended stop sending email to inactive contact
            // getting template id from  admin table
            for(Administration_Data__c AdminDataRow:[Select id, name,Email_Template_Name__c, Receiver_Email__c from Administration_Data__c Where use_for__c='Email To Case Template Selection' ])
            {
                mapofEmailTemplateids.put(AdminDataRow.Receiver_Email__c,AdminDataRow.Email_Template_Name__c);
                setofTemplateDevNames.add(AdminDataRow.Email_Template_Name__c);
            }
            
            // storing template data in Map
            for(EmailTemplate rowTemplate:[SELECT Id, Name, DeveloperName, Subject, Body,HtmlValue FROM EmailTemplate  WHERE DeveloperName IN :setofTemplateDevNames ])
            {   
                mapofEmailTemplateData.put(rowTemplate.DeveloperName,rowTemplate);
                
            }
            
            // storing OrgWideEmailAddress
            for(OrgWideEmailAddress rowTemplate:[SELECT Id, Address FROM OrgWideEmailAddress  WHERE Address IN :mapofEmailTemplateids.keySet() ])
            {   
                mapofEmailWithOrgids.put(rowTemplate.Address,rowTemplate.Id);
              
            } 
            
        
            if(setOfCaseId.size() > 0 )
            {  	// quering on case object to update 
                for(Case row:[Select Id,Status,Origin,ContactId,SuppliedEmail,CaseNumber,CreatedDate,
                              (SELECT id, ParentId ,ToAddress FROM EmailMessages ORDER BY CreatedDate DESC   ) 
                              From Case Where Id IN :setOfCaseId]){
                                  Case caseData = new Case();
                                  
                                  caseData.Id=row.Id;
                                  caseData.System_Reason_For_Contact_Association__c=row.Status;
                                  //changes done by Julius as part of uat user story, commented the code for status == closed.
                                  //Added the new status condition - Mustafa Quresh
                                     if(row.Status=='Closed'|| (row.Status!='Property Hold' && row.Status!='New' && row.status != 'General Hold')){ 
                                      //   system.debug('check new status condition ' + row.Status);
                                          caseData.Status='Reopened';
                                          caseData.OwnerId = System.Label.Case_Active_Queue_Id;
                                     }
                                  //    else
                                  if(row.Status !='New' && row.Status !='Closed' && row.status != 'General Hold'&&row.Status!='Property Hold'){
                                      caseData.Status='Responded';
                                      caseData.OwnerId = System.Label.Case_Active_Queue_Id;
                                  }
                                  
                                  
                                  // storing ids for sending email from apex
                                  if(row.Origin =='Email' && row.EmailMessages.size()==1 ){
                                      mapofCasesWithIds.put(row.CaseNumber,row.Id);
                                      mapofCaseInfo.put(row.CaseNumber,row);
                                      
                                      if(row.ContactId==null && row.SuppliedEmail !=null)
                                          mapofCasesWithEmail.put(row.CaseNumber,row.SuppliedEmail);
                                      else if(row.ContactId!=null)
                                          mapofCasesWithContactIds.put(row.CaseNumber,row.ContactId);
                                      // stroing to address 
                                      for(EmailMessage emailMessagerow : row.EmailMessages)
                                      {
                                          mapofCasesFromEmailAddress.put(row.CaseNumber,emailMessagerow.ToAddress);
                                      }   
                                      
                                  }               
                                  
                                  /*  else
    								caseData.Status='Responded';*/
                                  
                                  listofCasesToUpdate.add(caseData);
                              }
            }
        
        
       
        
            // sending emails
            String getFromaddress='';
            String EmailBody='';
            String EmailSubject=''; 
            List<String> lstofcontactIds= new List<String>();
            List<String> lstofEmailAddress= new List<String>();
            EmailTemplate currentTemplateData = new  EmailTemplate();
            Case CaseData = new  Case();
            if(mapofCasesFromEmailAddress.size()>0)
            {
                for(String currentCaseId: mapofCasesFromEmailAddress.keyset())
                {	
                    lstofcontactIds.clear();
                    EmailBody='';
                    getFromaddress= mapofCasesFromEmailAddress.get(currentCaseId);
                    //  Respond from customer_care@hardrock.com when a case is created from hardrock_crm@hardrock.com
                    if(Label.System_Auto_Response_Sender_Change == 'TRUE')
                    {
                        if(getFromaddress == 'hardrock_crm@hardrock.com')
                           getFromaddress = 'customer_care@hardrock.com';
                    }    
                    
                    CaseData=mapofCaseInfo.get(currentCaseId);
                    
                    // if email template not found then skip this block                
                    if(!(mapofEmailTemplateids.containsKey(getFromaddress))) 
                        continue;
                    
                    currentTemplateData=mapofEmailTemplateData.get(mapofEmailTemplateids.get(getFromaddress));
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    // storing ids or email address to send
                    if(mapofCasesWithContactIds.containsKey(currentCaseId))
                    {    
                        lstofcontactIds.add(mapofCasesWithContactIds.get(currentCaseId));
                    	//mail.setTargetObjectId(mapofCasesWithContactIds.get(currentCaseId)); 
                        //mail.setSaveAsActivity(false);
                        mail.setToAddresses(lstofcontactIds);
                    }
                   else if(mapofCasesWithEmail.containsKey(currentCaseId))
                    {    
                        lstofcontactIds.add(mapofCasesWithEmail.get(currentCaseId));
                     	 mail.setToAddresses(lstofcontactIds);
                    }
                     
                   
                    // dynamic merge field work 
                    Map<String, String> mapSubjectParams = new Map<String, String> {
                        '{!Case.Status}' => caseData.Status,
                        '{!Case.CaseNumber}' => caseData.CaseNumber
                         
                            };
                                
                                
                    Map<String, String> mapBodyParams = new Map<String, String> {
                        '{!Case.CaseNumber}' => caseData.CaseNumber,
                        '{!Case.Status}' => caseData.Status,
                        '{!Case.CreatedDate}' => caseData.CreatedDate.date().format(),
                        '{!Case.Contact}'=>null,
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
                        '{!$Label.System_Link_For_Unity}' => Label.System_Link_For_Unity
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
                    if(mapofEmailWithOrgids.containsKey(getFromaddress)) 
                     	mail.setOrgWideEmailAddressId(mapofEmailWithOrgids.get(getFromaddress));
                   
                    mail.setSubject(EmailSubject);
                   
                    if(currentTemplateData.HtmlValue != null)  
                    	mail.setHtmlBody(EmailBody);
                   else
                       mail.setPlainTextBody(EmailBody); 
                    mail.setReplyTo(getFromaddress);
                   // mail.setSenderDisplayName('SHRSS Customer Support');
                    mail.setWhatId(mapofCasesWithIds.get(currentCaseId));
                    mail.setTemplateId(currentTemplateData.Id);
                    
                    // mail.setTemplateId('00XS0000002i8VaMAI');
                    //mail.setTargetObjectId(mapofCasesWithIds.get(currentCaseId));
                    
                    
                    
                    
                    lstSingleEmailMessage.add(mail); 
                    
                    
                    
                } 
                // sening emails in bulk
                if(lstSingleEmailMessage.size() > 0 && Label.Send_Auto_Response_Emails=='TRUE')
                    Messaging.SendEmailResult[] r = Messaging.sendEmail(lstSingleEmailMessage);
            }
        
        
        if(listofCasesToUpdate.size()>0)
            update listofCasesToUpdate;
    
       }catch( Exception Ex )
        { System.debug('KK_Error 1:: ' + Ex.getMessage() ); 
         string contactidLabel= Label.Error_Email_Receiver;
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //mail.setToAddresses(contactidLabel.split(','));
        mail.setSubject('Apex Failure : ' );
        mail.setPlainTextBody(' Error Msg ' +Ex.getMessage());
		mail.setTargetObjectId(contactidLabel.split(',')[0]);
		mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
        }      
            
            
    }
    
  
    
}