/*-------------------------------------------------------------------------------------------------
Author:             Danish Qaimkhani
Date:               17-02-2021  
Version:            1.0
Description:        Batch Process Case Escalation
----------------------------------------------------------------------------------------------------*/


/************************MODIFICATION HISTORY*************************************
Added on            Added By            Description
17-02-2021         Danish Qaimkhani              Initial Draft 
**********************************************************************************/

public class CaseEscalation_Batch implements Database.Batchable<sobject>,Schedulable,Database.Stateful {
    public string defaultAccountId='';
    public String Query='';
    public set<Id> setOfCaseIds = new set<Id>();
    public map<String,Set<Id>> mapOfAccountWithContactIds= new  map<String,Set<Id>>();
    public map<String,Set<Id>> mapOfDefaultAccountWithContactIds= new  map<String,Set<Id>>();
    
    
    
    public map<String,Set<Case>> mapOfAccountWithCases= new  map<String,Set<Case>>();
    public map<String,Set<Case>> mapOfDefaultAccountWithCases= new  map<String,Set<Case>>();
    	
    // seprating map to store only crises cases
    public map<String,Set<Id>> mapOfAccountWithContactIdsOnlyCrises= new  map<String,Set<Id>>();
    public map<String,Set<Id>> mapOfDefaultAccountWithContactIdsOnlyCrises= new  map<String,Set<Id>>();
    
    public map<String,Set<Case>> mapOfAccountWithCasesOnlyCrises= new  map<String,Set<Case>>();
    public map<String,Set<Case>> mapOfDefaultAccountWithCasesOnlyCrises= new  map<String,Set<Case>>();
    
    public map<String,String> mapOfAccountWithName= new  map<String,String>();
    
    public set<Id> setOfDefaultContactTeamLead = new set<Id>();
    public set<Id> setOfDefaultContactSuperVisor = new set<Id>();
    public set<Id> setOfDefaultContactManager = new set<Id>();
    public set<Id> setOfDefaultContactDirector = new set<Id>();
    public set<Id> setOfDefaultContactVP = new set<Id>();
    
    public set<Id> setOfDefaultContactTeamLeadCrises = new set<Id>();
    public set<Id> setOfDefaultContactSuperVisorCrises = new set<Id>();
    public set<Id> setOfDefaultContactManagerCrises = new set<Id>();
    public set<Id> setOfDefaultContactDirectorCrises = new set<Id>();
    public set<Id> setOfDefaultContactVPCrises = new set<Id>();
    
    public List<AccountContactRelation> DefaultAccountContactData = new List<AccountContactRelation>();
    
   
    
    public CaseEscalation_Batch() {

        initializeVariables();

    }

    public CaseEscalation_Batch(set<Id> setOfCaseIdsParam) {
        
        setOfCaseIds.addAll(setOfCaseIdsParam);
        initializeVariables();

         Query = 'Select Id, Location__c,Location__r.Name, System_Contact_Tier__c, Status, Status_Updated_Time__c,Escalation_Level__c,IsEscalated,RecordType.DeveloperName,RecordType.Name,Is_related_to_Crisis__c,Owner.name,CaseNumber,Subject,Type '; 
         Query += ' from Case';
         Query += ' Where Status_Updated_Time__c != null' ;
         Query += ' AND Id IN '+inClausify(setOfCaseIds) ;
         Query += ' AND Case_handled_in_SFDC_flag__c = true AND Is_Junk_Case__c = false';


    }

    public CaseEscalation_Batch(String QueryPrm) {
        Query = QueryPrm;
        initializeVariables();
    }

    
    
 public Database.QueryLocator start(Database.BatchableContext BC) {
      
        if (Query == ''){
            Query = 'Select Id, Location__c,Location__r.Name, System_Contact_Tier__c, Status, Status_Updated_Time__c,Escalation_Level__c,IsEscalated,RecordType.DeveloperName,RecordType.Name,Is_related_to_Crisis__c,Owner.name,CaseNumber,Subject,Type'; 
            Query += ' from Case';
            Query += ' Where Status_Updated_Time__c != null ';
            Query += ' AND Case_handled_in_SFDC_flag__c = true AND Is_Junk_Case__c = false'; 
           
        }
     return Database.getQueryLocator(Query);
 }
    
    public void execute(Database.BatchableContext BC, List<Case> listOfCasesStart) {
         set<Id> setOfAccountIds = new set<Id>();
         set<String> setOfCaseStatus = new set<String>();
         set<String> setOfCaseTier = new set<String>();
         set<String> setOfCaseRecordTypes = new set<String>(); 
         set<Id> setOfCaseIds = new set<Id>();
         list<Case> lstCasesToUpdate=new list<Case>();
         Map<String,List<Escalation_Admin_Table__c>> mapofAdminData= new Map<String,List<Escalation_Admin_Table__c>>();
         
        
        set<Id> setOfAssociatedContactIds = new set<Id>();
         Map<Id,List<AccountContactRelation>> mapofContactData= new Map<Id,List<AccountContactRelation>>();
        
        List<Escalation_Admin_Table__c> currentAccountAdminData = new List<Escalation_Admin_Table__c>();
        
        // storing data is sets to query on admin table
        for(Case CaseRow:listOfCasesStart){
            if(CaseRow.Location__c!= null)
            {	
                setOfAccountIds.add(CaseRow.Location__c);
                if(!mapOfAccountWithName.containsKey(CaseRow.Location__c))
                    mapOfAccountWithName.put(CaseRow.Location__c,CaseRow.Location__r.Name);
            }
            setOfCaseTier.add(CaseRow.System_Contact_Tier__c);
            setOfCaseStatus.add(CaseRow.Status);
            setOfCaseRecordTypes.add(CaseRow.RecordType.DeveloperName);
           
        }
        
       // getting data from admin table
       for(Escalation_Admin_Table__c AdminTableRow :[Select Id,Case_Record_Type__c,Case_Status__c,Escalation_Level__c,
                                                     Tier__c,Time_Minutes__c,System_Priority__c from Escalation_Admin_Table__c 
                                                     WHERE Case_Record_Type__c IN:setOfCaseRecordTypes
                                                     AND Case_Status__c IN:setOfCaseStatus
                                                     AND Tier__c IN:setOfCaseTier
                                                     AND Time_Minutes__c>0
                                                     ORDER BY System_Priority__c ASC
                                                     ])
       {
           String mapKey=AdminTableRow.Case_Record_Type__c+'_'+AdminTableRow.Case_Status__c+'_'+AdminTableRow.Tier__c;
          
           // storing data in map to reuse in loop
           if(mapofAdminData.containsKey(mapKey)){
               mapofAdminData.get(mapKey).add(AdminTableRow);
           }
           else
               mapofAdminData.put(mapKey,new  List <Escalation_Admin_Table__c>{ AdminTableRow});
           
       }
       
        // storing all contact with reference to Map 
        for(Account AccRow :[SELECT Id, (SELECT Id,Contact.Id,Contact.Email,Escalation_Level__c,Only_Crises_Emails__c,Email_Notifications__c 
                                         FROM AccountContactRelations) FROM Account WHERE Id IN:setOfAccountIds])
        {
            if(AccRow.AccountContactRelations.size() > 0){
                for(AccountContactRelation contRow : AccRow.AccountContactRelations)
                {
                    if(contRow.Contact.Email == null || contRow.Escalation_Level__c == null || contRow.Email_Notifications__c == null)
                        continue;
      			 // storing data in map to reuse in loop
               if(mapofContactData.containsKey(AccRow.Id)){
                   mapofContactData.get(AccRow.Id).add(contRow);
               }
               else
               		mapofContactData.put(AccRow.Id,new  List <AccountContactRelation>{ contRow});
            //	System.debug('The test name is:::::' + test.name);
      
                }
            }
        }
        
       	for(Case CaseRow:listOfCasesStart){
            
             String mapKey=CaseRow.RecordType.DeveloperName+'_'+CaseRow.Status+'_'+CaseRow.System_Contact_Tier__c;
            // if no admin data found then do not do any thing
			if(!mapofAdminData.containsKey(mapKey)) 
        		continue;
            
          currentAccountAdminData=  mapofAdminData.get(mapKey);
            for(Escalation_Admin_Table__c AdminDataRow:currentAccountAdminData){
                // matching data
                if(AdminDataRow.Escalation_Level__c == getNextEscalationlevel(CaseRow.Escalation_Level__c,currentAccountAdminData)   )
                {
					system.debug('KK_ 0  first condition matched'+ CaseRow.Escalation_Level__c+'>>>'+AdminDataRow.Escalation_Level__c+'>>'+CaseRow.Id);	
                    if( system.now() > CaseRow.Status_Updated_Time__c.addMinutes(Integer.valueOf(AdminDataRow.Time_Minutes__c)) || Test.isRunningTest())
                    {		
                        CaseRow.IsEscalated=true;
                        CaseRow.Escalation_Level__c=getNextEscalationlevel(CaseRow.Escalation_Level__c,currentAccountAdminData);
                    	setOfCaseIds.add(CaseRow.Id);
                     	  
                            // clearing old data if exisits
							//lstOfAccountContantRelation.clear();
							setOfAssociatedContactIds.clear();
                            
                            // storing contact ids to send email for accounts
                            if(CaseRow.Location__c!= null)
                            {
                                // storing data for all cases
                                setOfAssociatedContactIds.clear();
                                setOfAssociatedContactIds= getContactsIdstoSendEmailAll(CaseRow.Location__c,CaseRow.Escalation_Level__c,mapofContactData,CaseRow.Is_related_to_Crisis__c,DefaultAccountContactData,'All Cases (Crisis & Non-Crisis)');
                                // checking set must have values
                                if(setOfAssociatedContactIds.size()>0)
                                {	
                                       if(mapOfAccountWithContactIds.containsKey(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_All'))
                                       {
                                         // mapOfAccountWithContactIds.get(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_All').addall(setOfAssociatedContactIds);
                                       }
                                        else   
                                           mapOfAccountWithContactIds.put(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_All', new set<Id>(setOfAssociatedContactIds) );
                                        
                                        // storing case to re use in 
                                        if(mapOfAccountWithCases.containsKey(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_All')){
                                           mapOfAccountWithCases.get(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_All').add(CaseRow);
                                        }
                                        else
                                            mapOfAccountWithCases.put(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_All',new  Set <Case>{ CaseRow});
								}
                                // storing only for non crises
                                setOfAssociatedContactIds.clear();
                                setOfAssociatedContactIds= getContactsIdstoSendEmailNonCrisis(CaseRow.Location__c,CaseRow.Escalation_Level__c,mapofContactData,CaseRow.Is_related_to_Crisis__c,DefaultAccountContactData,'Non-Crisis Cases');
                                // checking set must have values
                                if(setOfAssociatedContactIds.size()>0)
                                {	
                                       if(mapOfAccountWithContactIds.containsKey(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Non'))
                                       {
                                         // mapOfAccountWithContactIds.get(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Non').addall(setOfAssociatedContactIds);
                                       }
                                        else   
                                           mapOfAccountWithContactIds.put(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Non', new set<Id>(setOfAssociatedContactIds) );
                                        
                                        // storing case to re use in 
                                        if(mapOfAccountWithCases.containsKey(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Non')){
                                           mapOfAccountWithCases.get(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Non').add(CaseRow);
                                        }
                                        else
                                            mapOfAccountWithCases.put(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Non',new  Set <Case>{ CaseRow});
								}
                                
                                // storing only for  crises cases
                                setOfAssociatedContactIds.clear();
                                setOfAssociatedContactIds= getContactsIdstoSendEmailOnlyCrisis(CaseRow.Location__c,CaseRow.Escalation_Level__c,mapofContactData,CaseRow.Is_related_to_Crisis__c,DefaultAccountContactData,'Only Crisis Cases');
                                // checking set must have values
                                if(setOfAssociatedContactIds.size()>0)
                                {	
                                       if(mapOfAccountWithContactIds.containsKey(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Crisis'))
                                       {
                                         // mapOfAccountWithContactIds.get(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Crisis').addall(setOfAssociatedContactIds);
                                       }
                                        else   
                                           mapOfAccountWithContactIds.put(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Crisis', new set<Id>(setOfAssociatedContactIds) );
                                        
                                        // storing case to re use in 
                                        if(mapOfAccountWithCases.containsKey(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Crisis')){
                                           mapOfAccountWithCases.get(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Crisis').add(CaseRow);
                                        }
                                        else
                                            mapOfAccountWithCases.put(CaseRow.Location__c+'_'+CaseRow.Escalation_Level__c+'_Crisis',new  Set <Case>{ CaseRow});
								}
                                
                            		 setOfAssociatedContactIds.clear();
                            }
                            else
                            {	 // if no location is on the case
                               
                                 setOfAssociatedContactIds.clear();	
                                 setOfAssociatedContactIds= getContactsIdstoSendEmailAll(null,CaseRow.Escalation_Level__c,mapofContactData,CaseRow.Is_related_to_Crisis__c,DefaultAccountContactData,'All Cases (Crisis & Non-Crisis)');
                            
                                // checking set must have values
                                if(setOfAssociatedContactIds.size()>0)
                                {	
                                       if(mapOfDefaultAccountWithContactIds.containsKey(CaseRow.Escalation_Level__c+'_All'))
                                       {
                                        //  mapOfDefaultAccountWithContactIds.get(CaseRow.Escalation_Level__c+'_All').addall(setOfAssociatedContactIds);
                                       }
                                        else   
                                           mapOfDefaultAccountWithContactIds.put(CaseRow.Escalation_Level__c+'_All',  new set<Id>(setOfAssociatedContactIds));
                                    
                                        // storing case to re use in 
                                        if(mapOfDefaultAccountWithCases.containsKey(CaseRow.Escalation_Level__c+'_All')){
                                            mapOfDefaultAccountWithCases.get(CaseRow.Escalation_Level__c+'_All').add(CaseRow);
                                        }
                                        else
                                            mapOfDefaultAccountWithCases.put(CaseRow.Escalation_Level__c+'_All',new  Set <Case>{ CaseRow});
								}
                                
                                // storing only non crisis cases
                                setOfAssociatedContactIds.clear();	
                                 setOfAssociatedContactIds= getContactsIdstoSendEmailNonCrisis(null,CaseRow.Escalation_Level__c,mapofContactData,CaseRow.Is_related_to_Crisis__c,DefaultAccountContactData,'Non-Crisis Cases');
                            
                                // checking set must have values
                                if(setOfAssociatedContactIds.size()>0)
                                {
                                       if(mapOfDefaultAccountWithContactIds.containsKey(CaseRow.Escalation_Level__c+'_Non'))
                                       {
                                        //  mapOfDefaultAccountWithContactIds.get(CaseRow.Escalation_Level__c+'_Non').addall(setOfAssociatedContactIds);
                                       }
                                        else   
                                           mapOfDefaultAccountWithContactIds.put(CaseRow.Escalation_Level__c+'_Non',  new set<Id>(setOfAssociatedContactIds));
                                    
                                        // storing case to re use in 
                                        if(mapOfDefaultAccountWithCases.containsKey(CaseRow.Escalation_Level__c+'_Non')){
                                            mapOfDefaultAccountWithCases.get(CaseRow.Escalation_Level__c+'_Non').add(CaseRow);
                                        }
                                        else
                                            mapOfDefaultAccountWithCases.put(CaseRow.Escalation_Level__c+'_Non',new  Set <Case>{ CaseRow});
								}
                                
                                // storing only  crisis cases
                                setOfAssociatedContactIds.clear();	
                                 setOfAssociatedContactIds= getContactsIdstoSendEmailOnlyCrisis(null,CaseRow.Escalation_Level__c,mapofContactData,CaseRow.Is_related_to_Crisis__c,DefaultAccountContactData,'Only Crisis Cases');
                            
                                // checking set must have values
                                if(setOfAssociatedContactIds.size()>0)
                                {
                                       if(mapOfDefaultAccountWithContactIds.containsKey(CaseRow.Escalation_Level__c+'_Crisis'))
                                       {
                                        //  mapOfDefaultAccountWithContactIds.get(CaseRow.Escalation_Level__c+'_Crisis').addall(setOfAssociatedContactIds);
                                       }
                                        else   
                                           mapOfDefaultAccountWithContactIds.put(CaseRow.Escalation_Level__c+'_Crisis',  new set<Id>(setOfAssociatedContactIds));
                                    
                                        // storing case to re use in 
                                        if(mapOfDefaultAccountWithCases.containsKey(CaseRow.Escalation_Level__c+'_Crisis')){
                                            mapOfDefaultAccountWithCases.get(CaseRow.Escalation_Level__c+'_Crisis').add(CaseRow);
                                        }
                                        else
                                            mapOfDefaultAccountWithCases.put(CaseRow.Escalation_Level__c+'_Crisis',new  Set <Case>{ CaseRow});
								}
                                 setOfAssociatedContactIds.clear();
                                
                            } // else ended here
                        
                             
                     
                     	break;
                     }
                    
                }          
           	}
            
        }    
        //looping again to update only changed records
        lstCasesToUpdate.clear();
        for (Case row:listOfCasesStart){
            
           if(setOfCaseIds.contains(row.Id))
              lstCasesToUpdate.add(row); 
               
        }
        if(lstCasesToUpdate.size()>0)
        	Database.update(lstCasesToUpdate, false);
        
        system.debug('KK_'+setOfCaseRecordTypes);
        
    }
    
     public void finish(Database.BatchableContext BC) {
         
         String orgWideAddressId=null;
         for(OrgWideEmailAddress rowOrgWide:[SELECT Id, Address FROM OrgWideEmailAddress  WHERE Address = :Label.System_Org_Wide_Email_Address LIMIT 1])
                {   
                    orgWideAddressId =rowOrgWide.Id; 
                   
                }
         
		List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        String EmailBody='';
        String EmailSubject=''; 
        String IsCrises=''; 
        Set<Id> setofcontactIds= new Set<Id>();
        List<Id> lstofcontactIds= new List<Id>();
         system.debug('KK_5' +mapOfAccountWithCases.keySet());
         
         // sending email to all stored contacts with accounts
          for(String key : mapOfAccountWithCases.keySet()) 
          {	  
              lstofcontactIds.clear();
              EmailSubject='';
              EmailBody='';
              String[] splitedkey = key.split('_');
              lstofcontactIds.addall(mapOfAccountWithContactIds.get(key))  ;
              EmailBody= '<html <body><STYLE type="text/css">          TH {font-size: 11px; font-face: arial;background: #CCCCCC;border-width: 1;  text-align: center }' 
         				 +'TD  {font-size: 11px; font-face: verdana; text-align: center;  } '
         				 +'TABLE {border: solid #CCCCCC; border-width: 1}'
         				 +'TR {border: solid #CCCCCC; border-width: 1}'
        				 +'</STYLE>'
        				 +'<font face="arial" size="2"><p>The following Cases that belong to <b> '+mapOfAccountWithName.get(splitedkey[0])+' </b> are escalated at the <b> '+splitedkey[1] +'</b> level, you are requested to take the necessary actions to resolve these cases as soon as possible. </p>';
             EmailBody+='<table border="1" style="border-collapse: collapse;width:100%"><tr><th>Case Number</th><th>Is Crisis</th> <th>Subject</th><th>Type</th> <th>Tier</th> <th>Status</th> <th>Owner</th> </tr>';
              for(case CaseRow:mapOfAccountWithCases.get(key)){
                  if(CaseRow.Type==null)
                      CaseRow.Type='';
                  if(CaseRow.Is_related_to_Crisis__c== true)
                      IsCrises='Yes';
                  else
                      IsCrises='No';
                 EmailBody+='<tr> <td> <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+CaseRow.Id+'">  '+CaseRow.CaseNumber+' </a> </td> <td>'+IsCrises+' </td> <td>   '+CaseRow.Subject+' </td> <td> '+CaseRow.RecordType.Name+' </td> <td> '+CaseRow.System_Contact_Tier__c+' </td> <td> '+CaseRow.Status+' </td> <td> '+CaseRow.Owner.Name+' </td>  </tr>'; 
              }
             
             // EmailBody+=string.join(lstofcontactIds,',')+ '---'; 
              EmailBody+='</table>  </font> </body </html>';
        		//  setofcontactIds=    ;
            
         
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(lstofcontactIds);
            if(orgWideAddressId!=null)  
           	 mail.setOrgWideEmailAddressId(orgWideAddressId);
            mail.setSubject('Case Escalation ');
            mail.setHtmlBody(EmailBody);
            lstSingleEmailMessage.add(mail);
      		// Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
         
         // sending email to all Default Account's Concact
          for(String key : mapOfDefaultAccountWithCases.keySet()) 
          {		
              lstofcontactIds.clear();
              String[] splitedkey = key.split('_');
              EmailSubject='';
              EmailBody='';
             lstofcontactIds.addall(mapOfDefaultAccountWithContactIds.get(key))  ;
              EmailBody= '<html <body><STYLE type="text/css">          TH {font-size: 11px; font-face: arial;background: #CCCCCC;border-width: 1;  text-align: center }' 
          				 +'TD  {font-size: 11px; font-face: verdana; text-align: center;  } '
          				+'TABLE {border: solid #CCCCCC; border-width: 1}'
          				+'TR {border: solid #CCCCCC; border-width: 1}'
       					 +'</STYLE>'
        				+'<font face="arial" size="2"><p>The following Cases that belong to <b> '+mapOfAccountWithName.get(this.defaultAccountId)+' </b>  are escalated at the <b> '+splitedkey[0] +'</b> level, you are requested to take the necessary actions to resolve these cases as soon as possible. </p>';
             EmailBody+='<table border="1" style="border-collapse: collapse;width:100%"><tr><th>Case Number</th> <th>Is Crisis</th> <th>Subject</th><th>Type</th> <th>Tier</th> <th>Status</th> <th>Owner</th> </tr>';
             for(case CaseRow:mapOfDefaultAccountWithCases.get(key)){
                 if(CaseRow.Type==null)
                      CaseRow.Type='';
                 if(CaseRow.Is_related_to_Crisis__c== true)
                      IsCrises='Yes';
                  else
                      IsCrises='No';
                 
                 EmailBody+='<tr> <td> <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+CaseRow.Id+'">  '+CaseRow.CaseNumber+' </a> </td> <td>'+IsCrises+' </td> <td>  '+CaseRow.Subject+' </td> <td> '+CaseRow.RecordType.Name+' </td> <td> '+CaseRow.System_Contact_Tier__c+' </td> <td> '+CaseRow.Status+' </td> <td> '+CaseRow.Owner.Name+' </td>  </tr>'; 
              }
              EmailBody+='</table>  </font> </body </html>';
        		//  setofcontactIds=    ;
            
           //   EmailBody+=string.join(lstofcontactIds,',')+ '---'; 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(lstofcontactIds);
            mail.setSubject('Case Escalation ');
            if(orgWideAddressId!=null)  
           	 mail.setOrgWideEmailAddressId(orgWideAddressId);
            mail.setHtmlBody(EmailBody);
            lstSingleEmailMessage.add(mail);
     		// Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
         
    		     
	      
         
         // sening emails in bulk
         if(lstSingleEmailMessage.size()>0)
			Messaging.SendEmailResult[] r = Messaging.sendEmail(lstSingleEmailMessage);
         
         
         
         //get receiver's email from Label
        string contactidLabel= Label.Error_Email_Receiver;
        
        if(string.isBlank(contactidLabel)) return;
        // Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email, ExtendedStatus
            from AsyncApexJob where Id =: BC.getJobId()
        ];
         

        if(a.NumberOfErrors == 0) return;

        // Email the Batch Job's submitter that the Job is finished.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(contactidLabel.split(','));
        mail.setSubject('Case Escalation Batch Status : ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures. ExtendedStatus: ' + a.ExtendedStatus);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
    } 
    
     private String getNextEscalationlevel(String strparam,List<Escalation_Admin_Table__c> currentAccountAdminDataParam){
         Integer valueToSearch=0;
         String foundLevel='';
       /*  switch on strparam {
            when ''  	{strToSearch= 'Lead Team Member';}
            when null 	{strToSearch= 'Lead Team Member';}
            when 'Lead Team Member' {strToSearch= 'Supervisor';}
            when 'Supervisor' {strToSearch= 'Manager';}
            when 'Manager' {strToSearch= 'Director';}
            when 'Director' {strToSearch= 'VP';}
			when 'VP' {strToSearch= 'VP';}
            when else {strToSearch= null;}
		}*/
        switch on strparam {
            when ''  	{valueToSearch= 1;}
            when null 	{valueToSearch= 1;}
            when 'Lead Team Member' {valueToSearch= 2;}
            when 'Supervisor' {valueToSearch= 3;}
            when 'Manager' {valueToSearch= 4;}
            when 'Director' {valueToSearch= 5;}
			when 'VP' {valueToSearch= 5;}
            when else {valueToSearch= 0;}
		}
         foundLevel='Not Found';
		if(currentAccountAdminDataParam.size()>0)
        {
            for(Escalation_Admin_Table__c row:currentAccountAdminDataParam)
            {
                if(integer.valueOf(row.System_Priority__c) == valueToSearch ||  integer.valueOf(row.System_Priority__c) > valueToSearch  )
                {
                    foundLevel=row.Escalation_Level__c;
                    Break;
                }    
            }               
        }    
         
     return foundLevel;   
    }
    
    private String inClausify(set<Id> ids){
        String inClause = String.format( '(\'\'{0}\'\')', new List<string> { String.join( new List<Id>(ids) , '\',\'') });
        return inClause;
    }
    
     private set<Id> getContactsIdstoSendEmailAll(Id AccountIdParam,String EscalaionLevelParam, Map<Id,List<AccountContactRelation>> mapofContactDataParam,Boolean CrisesCase, list<AccountContactRelation> DefaultAccountContactDataParam,String SelectOnlyParam){
        set<Id> IdstoReturn =new set<Id>();
         list<AccountContactRelation> lstOfAccountContantRelation = new list<AccountContactRelation>();
        // system.debug('KK_ getContactsIdstoSendEmail'+ContactRelaionListParam);
         if(AccountIdParam != null)
         { 
             if(mapofContactDataParam.containsKey(AccountIdParam))   
           		lstOfAccountContantRelation=  mapofContactDataParam.get(AccountIdParam);
             
             if(lstOfAccountContantRelation.size()>0)
             {
                  for(AccountContactRelation contRow : lstOfAccountContantRelation)
                  {		system.debug('kk_12 contRow.Escalation_Level__c '+ contRow.Escalation_Level__c  +'=='+EscalaionLevelParam +' &&  contRow.Only_Crises_Emails__c '+ contRow.Only_Crises_Emails__c+'=='+CrisesCase);
                      if(contRow.Escalation_Level__c.contains(EscalaionLevelParam)    && contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)'  )
                      {
                          IdstoReturn.add(contRow.Contact.Id);
                          system.debug('kk_10 in side >>>'+ AccountIdParam  +'>>>'   +contRow.Contact.Id);
                      }
                   	  
                  }
             
            }
         }
         
         // adding default contact ids if found
		 if(DefaultAccountContactDataParam.size()>0)
         {
			 for(AccountContactRelation contRow : DefaultAccountContactDataParam)
             {		 system.debug('kk_12 contRow.Escalation_Level__c '+ contRow.Escalation_Level__c  +'=='+EscalaionLevelParam +' &&  contRow.Only_Crises_Emails__c '+ contRow.Only_Crises_Emails__c+'=='+CrisesCase);
                      if(contRow.Escalation_Level__c.contains(EscalaionLevelParam)    && contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)'  )
                      {
                          IdstoReturn.add(contRow.Contact.Id);
                          system.debug('kk_10 in side >>>'+ AccountIdParam  +'>>>'   +contRow.Contact.Id);
                      }
                   	 
              }
 
         }    
        
        return IdstoReturn;
    }
    
    private set<Id> getContactsIdstoSendEmailNonCrisis(Id AccountIdParam,String EscalaionLevelParam, Map<Id,List<AccountContactRelation>> mapofContactDataParam,Boolean CrisesCase, list<AccountContactRelation> DefaultAccountContactDataParam,String SelectOnlyParam){
        set<Id> IdstoReturn =new set<Id>();
         list<AccountContactRelation> lstOfAccountContantRelation = new list<AccountContactRelation>();
        // system.debug('KK_ getContactsIdstoSendEmail'+ContactRelaionListParam);
         if(AccountIdParam != null)
         { 
             if(mapofContactDataParam.containsKey(AccountIdParam))   
           		lstOfAccountContantRelation=  mapofContactDataParam.get(AccountIdParam);
             
             if(lstOfAccountContantRelation.size()>0)
             {
                  for(AccountContactRelation contRow : lstOfAccountContantRelation)
                  {		system.debug('kk_12 contRow.Escalation_Level__c '+ contRow.Escalation_Level__c  +'=='+EscalaionLevelParam +' &&  contRow.Only_Crises_Emails__c '+ contRow.Only_Crises_Emails__c+'=='+CrisesCase);
                       if(contRow.Escalation_Level__c.contains(EscalaionLevelParam)   && CrisesCase == false &&  contRow.Email_Notifications__c=='Non-Crisis Cases'  )
                      {
                          IdstoReturn.add(contRow.Contact.Id);
                          system.debug('kk_10 in side >>>'+ AccountIdParam  +'>>>'   +contRow.Contact.Id);
                      }
                  }
             
            }
         }
         
         // adding default contact ids if found
		 if(DefaultAccountContactDataParam.size()>0)
         {
			 for(AccountContactRelation contRow : DefaultAccountContactDataParam)
             {		 system.debug('kk_12 contRow.Escalation_Level__c '+ contRow.Escalation_Level__c  +'=='+EscalaionLevelParam +' &&  contRow.Only_Crises_Emails__c '+ contRow.Only_Crises_Emails__c+'=='+CrisesCase);
                       if(contRow.Escalation_Level__c.contains(EscalaionLevelParam)   && CrisesCase == false &&  contRow.Email_Notifications__c=='Non-Crisis Cases' )
                      {
                          IdstoReturn.add(contRow.Contact.Id);
                          system.debug('kk_10 in side >>>'+ AccountIdParam  +'>>>'   +contRow.Contact.Id);
                      }
              }
 
         }    
        
        return IdstoReturn;
    }
    
    
    private set<Id> getContactsIdstoSendEmailOnlyCrisis(Id AccountIdParam,String EscalaionLevelParam, Map<Id,List<AccountContactRelation>> mapofContactDataParam,Boolean CrisesCase, list<AccountContactRelation> DefaultAccountContactDataParam,String SelectOnlyParam){
        set<Id> IdstoReturn =new set<Id>();
         list<AccountContactRelation> lstOfAccountContantRelation = new list<AccountContactRelation>();
        // system.debug('KK_ getContactsIdstoSendEmail'+ContactRelaionListParam);
         if(AccountIdParam != null)
         { 
             if(mapofContactDataParam.containsKey(AccountIdParam))   
           		lstOfAccountContantRelation=  mapofContactDataParam.get(AccountIdParam);
             
             if(lstOfAccountContantRelation.size()>0)
             {
                  for(AccountContactRelation contRow : lstOfAccountContantRelation)
                  {		system.debug('kk_12 contRow.Escalation_Level__c '+ contRow.Escalation_Level__c  +'=='+EscalaionLevelParam +' &&  contRow.Only_Crises_Emails__c '+ contRow.Only_Crises_Emails__c+'=='+CrisesCase);
                      if(contRow.Escalation_Level__c.contains(EscalaionLevelParam)   && CrisesCase == true &&  contRow.Email_Notifications__c=='Only Crisis Cases')
                      {
                          IdstoReturn.add(contRow.Contact.Id);
                          system.debug('kk_10 in side >>>'+ AccountIdParam  +'>>>'   +contRow.Contact.Id);
                      }
                   	 
                  }
             
            }
         }
         
         // adding default contact ids if found
		 if(DefaultAccountContactDataParam.size()>0)
         {
			 for(AccountContactRelation contRow : DefaultAccountContactDataParam)
             {		 system.debug('kk_12 contRow.Escalation_Level__c '+ contRow.Escalation_Level__c  +'=='+EscalaionLevelParam +' &&  contRow.Only_Crises_Emails__c '+ contRow.Only_Crises_Emails__c+'=='+CrisesCase);
                      if(contRow.Escalation_Level__c.contains(EscalaionLevelParam)   && CrisesCase == true && contRow.Email_Notifications__c=='Only Crisis Cases'  )
                      {
                          IdstoReturn.add(contRow.Contact.Id);
                          system.debug('kk_10 in side >>>'+ AccountIdParam  +'>>>'   +contRow.Contact.Id);
                      }
                   	  
              }
 
         }    
        
        return IdstoReturn;
    }
    
    
    
    
    
     private void initializeVariables(){
         String tempname;

system.debug('name'+tempname);
          //Get Custom Metadata values of Default Account
         for(Administration_Data__c AdminDataRow:[Select id, name,Property_Id__c from Administration_Data__c Where use_for__c='Case Escalation' AND Name='CaseEscalationSetup' LIMIT 1])
   		{
         	this.defaultAccountId=AdminDataRow.Property_Id__c;
            
           tempname=[select id,name from account where id =:this.defaultAccountId].Name;
            // storing account name with key 
            mapOfAccountWithName.put(AdminDataRow.Property_Id__c,tempname);
    	}	  
   
        if(this.defaultAccountId !=null)
        {    
         // storing all contact with Fetched  from Default Account 
        for(Account AccRow :[SELECT Id, (SELECT Id,Contact.Id,Contact.Email,Escalation_Level__c,Only_Crises_Emails__c,Email_Notifications__c 
                                         FROM AccountContactRelations) FROM Account WHERE Id =:this.defaultAccountId])
        {
            if(AccRow.AccountContactRelations.size() > 0){
                for(AccountContactRelation contRow : AccRow.AccountContactRelations)
                {
      				if(contRow.Contact.Email == null || contRow.Escalation_Level__c == null || contRow.Email_Notifications__c==null)
                        continue;
                    // adding items in list and will use
                    DefaultAccountContactData.add(contRow);
                   /* 
                    if(contRow.Escalation_Level__c.contains('Lead Team Member')  && (contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)' || contRow.Email_Notifications__c=='Non-Crisis Cases' ))
      					setOfDefaultContactTeamLead.add(contRow.Contact.Id);
                    
                    if(contRow.Escalation_Level__c.contains('Supervisor')  && (contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)' || contRow.Email_Notifications__c=='Non-Crisis Cases' ))
      					setOfDefaultContactSuperVisor.add(contRow.Contact.Id);
                    
                    if(contRow.Escalation_Level__c.contains('Manager')  && (contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)' || contRow.Email_Notifications__c=='Non-Crisis Cases' ))
      					setOfDefaultContactManager.add(contRow.Contact.Id);
                    
                    if(contRow.Escalation_Level__c.contains('Director') && (contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)' || contRow.Email_Notifications__c=='Non-Crisis Cases' ))
      					setOfDefaultContactDirector.add(contRow.Contact.Id);
                    
                    if(contRow.Escalation_Level__c.contains('VP')  && (contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)' || contRow.Email_Notifications__c=='Non-Crisis Cases' ))
      					setOfDefaultContactVP.add(contRow.Contact.Id);
                    
                    // storing for crisis
                    
                    if(contRow.Escalation_Level__c.contains('Lead Team Member')  && (contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)' || contRow.Email_Notifications__c=='Only Crisis Cases' ) )
      					setOfDefaultContactTeamLeadCrises.add(contRow.Contact.Id);
                    
                    if(contRow.Escalation_Level__c.contains('Supervisor')  &&  (contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)' || contRow.Email_Notifications__c=='Only Crisis Cases' ))
      					setOfDefaultContactSuperVisorCrises.add(contRow.Contact.Id);
                    
                    if(contRow.Escalation_Level__c.contains('Manager')  &&  (contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)' || contRow.Email_Notifications__c=='Only Crisis Cases' ))
      					setOfDefaultContactManagerCrises.add(contRow.Contact.Id);
                    
                    if(contRow.Escalation_Level__c.contains('Director')  &&  (contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)' || contRow.Email_Notifications__c=='Only Crisis Cases' ))
      					setOfDefaultContactDirectorCrises.add(contRow.Contact.Id);
                    
                    if(contRow.Escalation_Level__c.contains('VP')  &&  (contRow.Email_Notifications__c=='All Cases (Crisis & Non-Crisis)' || contRow.Email_Notifications__c=='Only Crisis Cases' ))
      					setOfDefaultContactVPCrises.add(contRow.Contact.Id);

					*/
                }
            }
        }
        }
         System.debug('KK setOfDefaultContactTeamLead >'+setOfDefaultContactTeamLead);
         
         
     }
    
     public void execute(SchedulableContext SC) {
        Database.executeBatch(new CaseEscalation_Batch(), 200);
    }

    
    
}