/*-------------------------------------------------------------------------------------------------
Author:             Shoukat Hussain
Date: 				02/19/2021
Version:            1.0
/*-------------------------------------------------------------------------------------------------
Description:        Medallia Staging  Trigger Handler 
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on             Added By               Description
**********************************************************************************/
// 03/17/2021		Shoukat Hussain 		Add case status transformation functionality 
// 05/11/2021       Shoukat Hussain         Add Survey get update by Medallia through more fields
// 06/15/2021       Shoukat Hussain 		Add a logic =  if survey status (new/old survey) Overdue or Escalated or Escalated Level Two 
// 											then Case_handled_in_SFDC_flag__c = True and Queue should be Active queue   

public class MedalliaStagingTrgHandler {    
    Public Id caseRTid =  Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('GX360_Survey').getRecordTypeId();
    
    public void OnAfterInsert(List<Medallia_Staging__c> newObjects, Map<Id, Medallia_Staging__c> newMap){
        ProcessSurveyResponseIns(newObjects); // Use to create/update contact and cases when new survey create 
        
    }
    
    public void onAfterUpdate(List<Medallia_Staging__c> oldObjects, List<Medallia_Staging__c> newObjects, Map<Id, Medallia_Staging__c> oldMap, Map<Id, Medallia_Staging__c> newMap){          		
        ProcessSurveyResponseUpd(newObjects,oldMap); // Use to update Contact/Case when existing survey get updating
    }    
    
    private void ProcessSurveyResponseUpd(List<Medallia_Staging__c> LstSRTriggerData,Map<Id, Medallia_Staging__c> oldMap){
        list<Case> 	LstCases2bUpdate = new list<Case>();    // list for case update
        Map<string,contact> Mapcon2bUpdate = new Map<string,contact>();  // Map for contact update
        Map<String,String> MapCaseStatus = new Map<String,String>();  // Map to keep Transformation for case.Status
        MapCaseStatus = GetCaseStatus(MapCaseStatus);	// Get Values from Admin Setup for Case.Status transformation        
        
        //Iteration on Trigger data  
        system.debug('update trigger LstSRTriggerData '+LstSRTriggerData);  
       // system.debug('update trigger Time '+system.Datetime.now());
        
        For(Medallia_Staging__c SR :LstSRTriggerData){
            system.debug('Check update trigger Status:'+SR.Current_status_of_alert__c+'-'+oldMap.get(SR.Id).Current_status_of_alert__c+
                        ' Contact: '+SR.Contact__c+'-'+oldMap.get(SR.Id).Contact__c+
                        ' Case: '+SR.Case__c+'-'+oldMap.get(SR.Id).Case__c+ 
                        ' Errordesc: '+SR.Error_Description__C+'-'+oldMap.get(SR.Id).Error_Description__C  
                         );
			system.debug('Check update trigger only Status:'+SR.Current_status_of_alert__c+'-'+oldMap.get(SR.Id).Current_status_of_alert__c);
			system.debug('Check update trigger only Error:'+SR.Error_Description__C+'-'+oldMap.get(SR.Id).Error_Description__C);
            Boolean IsSurveyGetUpdate = false;
            if(SR.Current_status_of_alert__c <> oldMap.get(SR.Id).Current_status_of_alert__c ||
               SR.Problem_Area__c <> oldMap.get(SR.Id).Problem_Area__c ||
               SR.Action_Taken__c <> oldMap.get(SR.Id).Action_Taken__c ||
               SR.Appeasement_Comp_Dollars__c <> oldMap.get(SR.Id).Appeasement_Comp_Dollars__c ||
               SR.What_are_the_teams_that_feedback_can_be__c <> oldMap.get(SR.Id).What_are_the_teams_that_feedback_can_be__c ||
               SR.Alert_owner__c <> oldMap.get(SR.Id).Alert_owner__c ||
               SR.Alert_closed_by__c <> oldMap.get(SR.Id).Alert_closed_by__c ||
               SR.Alert_close_time__c <> oldMap.get(SR.Id).Alert_close_time__c ||
               SR.All_log_notes_combined_if_any__c <> oldMap.get(SR.Id).All_log_notes_combined_if_any__c ||
               SR.Overall_Satisfaction_Service_Facility_2__c <> oldMap.get(SR.Id).Overall_Satisfaction_Service_Facility_2__c 
              ){
                  IsSurveyGetUpdate = True;
              }
            
            if(SR.Current_status_of_alert__c <> oldMap.get(SR.Id).Current_status_of_alert__c ||
               SR.Contact__c <> oldMap.get(SR.Id).Contact__c ||
               SR.Case__c <> oldMap.get(SR.Id).Case__c ||
               SR.Error_Description__C <> oldMap.get(SR.Id).Error_Description__C ||
               IsSurveyGetUpdate)
            {
              // Start- Case Update
              case SRcase = new case();  // initialize new case object           			
             system.debug('Check update1 : '+IsSurveyGetUpdate);   
             system.debug('Check update2 : '+SR.Current_status_of_alert__c);   
             if(IsSurveyGetUpdate){ 
                 if(SR.Current_status_of_alert__c == 'Overdue' || 
                    SR.Current_status_of_alert__c == 'Escalated' ||
                    SR.Current_status_of_alert__c == 'Escalated Level Two')
                 {
	                 SRcase.Case_handled_in_SFDC_flag__c = True;   
    	             SRcase.OwnerId= System.Label.Case_Active_Queue_Id ; 
                 }Else{                     
                 	SRcase.Case_handled_in_SFDC_flag__c = False;   // false = case handle in Medallia     
                 	SRcase.OwnerId= System.Label.Case_Medallia_Queue_Id ; // Case assign to Medallia Queue                       
                 }                 
                 SRcase.status = MapCaseStatus.get(SR.Current_status_of_alert__c);                     
                 system.debug('Check update status: '+SRcase.status);
                 system.debug('Check update handle: '+SRcase.Case_handled_in_SFDC_flag__c);
                 system.debug('Check update OwnerId: '+SRcase.OwnerId);
                 
                }
                
                SRcase.Medallia_Alert_Status__C 			    = SR.Current_status_of_alert__c;                        
                SRcase.medallia_xm__Medallia_internal_id__c     = SR.Survey_ID__c;                        
                SRcase.id     					= SR.Case__C;            
                SRcase.Problem_Area__c			=SR.Problem_Area__c;
                SRcase.Action_Taken__c			=SR.Action_Taken__c;        
                SRcase.Value__c					=SR.Appeasement_Comp_Dollars__c;
                SRcase.Concerned_Dept__c		=SR.What_are_the_teams_that_feedback_can_be__c;
                SRcase.Notes__c					=SR.All_log_notes_combined_if_any__c;  
                SRcase.Alert_closed_by__c		= SR.Alert_closed_by__c;
                SRcase.Alert_close_time__c		= SR.Alert_close_time__c;
                SRcase.Alert_owner__c			=SR.Alert_owner__c;
                LstCases2bUpdate.add(SRcase);                                                
            }
           // system.debug('Check contact Mapcon2bUpdate: '+Mapcon2bUpdate);
            system.debug('Check case LstCases2bUpdate: '+LstCases2bUpdate);        
            Map<String,Map<String,String>> MapSuccessErrorCon = new Map<String,Map<String,String>>(); 
            Map<String,Map<String,String>> MapSuccessErrorCase = new Map<String,Map<String,String>>();  
            if(LstCases2bUpdate.size()>0){
                try {
                    System.debug('Case update LstCases2bUpdate:'+LstCases2bUpdate);
                     //Update LstCases2bUpdate;
                    MapSuccessErrorCase = UpdateCase( LstCases2bUpdate, LstSRTriggerData,MapSuccessErrorCase);
                    
                } catch(DmlException e) {
                    System.debug('Error during case update at Survey update time : ' + e.getMessage());
                }                        
            } 
            // Update Contact,Case update errors to the Survey Response object (Medallia_Staging__C) 
                Try{
                Update_Survey_Response(MapSuccessErrorCon,MapSuccessErrorCase,LstSRTriggerData);    
            }
            Catch(DmlException e){
                System.debug('Error during insert case : ' + e.getMessage());
            }        
                  
            }
    }
    
    private void ProcessSurveyResponseIns(List<Medallia_Staging__c> LstSRTriggerData){
        system.debug('Check 0 LstSRTriggerData '+LstSRTriggerData);
        Map<String,Integer> MapSRConDupTable = new Map<String,Integer>();  // Map to keep count contact duplication       
        Map<String,Medallia_Staging__c> MapSRContact = new Map<String,Medallia_Staging__c>();  		// <Casinoaccount#/EmailFNLN,orgContact>
        List<Case> LstCases2bInsert =  new List<Case>();
        // Get Values from Admin Setup 
        Map<String,String> MapAlertType = new Map<String,String>();  // Map to keep Transformation for case.priority
        MapAlertType = GetCasePriority(MapAlertType);    			 // Get Transformation from admin setup: alert type into case.priority
        Map<String,String> MapCaseLocationId = new Map<String,String>();  // Map to keep Transformation for case.Location
        MapCaseLocationId = GetCaseLocationId(MapCaseLocationId);	// Get Values from Admin Setup to Set Case.Location
        Map<String,String> MapCaseStatus = new Map<String,String>();  // Map to keep Transformation for case.Status
        MapCaseStatus = GetCaseStatus(MapCaseStatus);	// Get Values from Admin Setup to Set Case.Status
        System.debug('Check Location '+MapCaseLocationId);        
        system.debug('System MapAlertType '+MapAlertType);
        system.debug('System Case Status '+MapCaseStatus);
        String CaseQueue;
        //Iteration on Trigger data
        For(Medallia_Staging__c sr :LstSRTriggerData){                   
            string conKey = GetConkey(sr.Email__c,sr.First_name__c,sr.Last_name__c);
            conKey = conkey.toLowerCase(); // 04162021
            MapSRConDupTable.put(conKey,0);
            MapSRContact.put(conKey,sr);
            if(sr.Alert_type__c!=null ){ // Condition to consider a case              
                case SRcase = new case();               
                Fillcase(SRcase,SR,caseRTid,MapAlertType,MapCaseLocationId,MapCaseStatus)	;
                system.debug('check case SRcase '+SRcase);
                LstCases2bInsert.add(SRcase);                                                
            }                            
        }
        
        // Get Existing Contact
        system.debug('Check contact MapSRConDupTable '+MapSRConDupTable);
        //MapExistingCon = GetExistingCon(MapSRConDupTable);         // Get Existing Contact List        
        Map<String,contact> MapExistingCon = new Map<String,contact>();
        If(!MapSRConDupTable.isEmpty()){
            for(contact co : ([select id,Casino_Account_Number__c,System_EmailFNLN_Text__c from contact 
                               where  System_EmailFNLN_Text__c in :MapSRConDupTable.keySet() ])){
                                   MapExistingCon.put(co.System_EmailFNLN_Text__c, co); 
                                   integer tno = MapSRConDupTable.get(co.System_EmailFNLN_Text__c); //04302021
                                   MapSRConDupTable.put(co.System_EmailFNLN_Text__c,tno+1); //04302021
                               }
        }        
        system.debug('Check 2 MapSRConDupTable '+MapSRConDupTable); 
        system.debug('Check 2 MapExistingCon '+MapExistingCon);
        system.debug('Contact Check MapSRConDupTable: '+MapSRConDupTable);

        //Start Create or update contact
        Map<String,Map<String,String>> MapSuccessErrorCon = new Map<String,Map<String,String>>();
        // Create/Update contact and Get contact success error
        system.debug('Contact Check MapSRContact:'+MapSRContact);       	
        MapSuccessErrorCon = CreUpdcontact(MapSRConDupTable,MapExistingCon,MapSRContact); 
        system.debug('Check Contact MapSRContact:'+MapSRContact);
        
        // Start Insert cases
        Map<String,Map<String,String>> MapSuccessErrorCaseIns = new Map<String,Map<String,String>>();        
        if(LstCases2bInsert.size()>0){
            try{
                system.debug('Case Insert Start LstCases2bInsert '+LstCases2bInsert);
                MapSuccessErrorCaseIns = InsertCases(LstCases2bInsert,MapSuccessErrorCaseIns);
            } catch (DmlException e) {
                System.debug('Error during insert case : ' + e.getMessage());
            }            
        }
        
        // Update Contact,Case Lookup to the Survey Response object (Medallia_Staging__C) and contact id to case obj
        Try{
            system.debug('Success Error Contact:'+MapSuccessErrorCon);
            system.debug('Success Error Case:'+MapSuccessErrorCaseIns);
            Update_Survey_Response(MapSuccessErrorCon,MapSuccessErrorCaseIns,LstSRTriggerData);    
        }
        Catch(DmlException e){
            System.debug('Error during insert case : ' + e.getMessage());
        }
        
    } 
    private string GetConkey(String conemail,string conFname,string conLname){
        String conkey = conemail+'-'+conFname+'-'+conLname;
        return conkey;
    }
private void Update_Survey_Response(Map<String,Map<String,String>> MapSuccessErrorCon,Map<String,Map<String,String>> MapSuccessErrorCase,List<Medallia_Staging__c> LstSRTriggerData){
        system.debug('Check case update MapSuccessErrorCon '+MapSuccessErrorCon);
        system.debug('Check case update MapSuccessErrorCaseIns '+MapSuccessErrorCase);
        Map<String,String> MapConId = new Map<String,String>();   // sr.SurveyId,Contactid
        Map<String,String> MapCaseId = new Map<String,String>();  // sr.SurveyId,Caseid 
        List<Case> LstCases = new List<Case>();  // sr.Caseid,Contactid to udpate cases by contactid  
        for(Medallia_Staging__C sr: LstSRTriggerData){
            system.debug('check SR: '+sr);
            system.debug('check case update sr.Survey_ID__c '+sr.Survey_ID__c);
            system.debug('Check MapCaseId '+MapCaseId);
            // Update Contact Lookup
            String conkey = GetConkey(sr.Email__c,sr.First_name__c,sr.Last_name__c);
            system.debug('Check con  conkey '+conkey);
            string conid ;
            string conresult;
            system.debug('check con3 '+MapSuccessErrorCon.containsKey(conkey));
            if(MapSuccessErrorCon.containsKey(conkey)){
                map<string,string> mymap = new map<string,string>();
                mymap = MapSuccessErrorCon.get(conkey);
                system.debug('Check contact '+mymap.values());                
                for(string mm : mymap.keyset()){
                    if(mm.left(3)=='003' && mm.length()==18){
                        conid     = mm;      
                    }   
                    Else{                      
                        conresult = conresult+' '+mm;                                                     
                    }                                           
                }
                MapConId.put(sr.Survey_ID__c,conresult!=null?conresult:conid);  // maintain survey id,errordescrition or conid
                system.debug('Check Contact Insert result for Survey '+sr.Survey_ID__c+' '+MapConId+' '+conresult);                 
            }
            system.debug('Check Contact Insert result MapConId:'+MapConId); 
            
            //Update Case Lookup
            string caseid;
            string caseresult;
            if(MapSuccessErrorCase.containsKey(sr.Survey_ID__c)){
                map<string,string> mymap = new map<string,string>();
                mymap = MapSuccessErrorCase.get(sr.Survey_ID__c);                  
                for(string mm : mymap.keyset()){
                    system.debug('Check Case mm:'+mm+'End');
                    if(mm.left(3)=='500'  && mm.length()==18){
                        caseid     = mm;      
                    }   
                    Else{                      
                        caseresult = caseresult+' '+mm;                                                     
                    }                       
                }  
                system.debug('Check case Insert result for Survey '+sr.Survey_ID__c+' '+caseid+' '+caseresult);  
                MapCaseId.put(sr.Survey_ID__c,caseresult!=null?caseresult:caseid);  // maintain survey id,errordescrition or caseid
                system.debug('Check case Insert result for Survey End:'+MapCaseId);
            }             
        }
        ///// Going to update
        system.debug('Check continue');
        system.debug('Check Contact Case update in SR Contact '+MapConId); 
        system.debug('Check Contact Case update in SR Case '+MapCaseId);        
        
        if(!MapCaseId.isEmpty() ||!MapConId.isEmpty()){
            //list<Medallia_Staging__C> lstSR = ([select id,Survey_id__C,Contact__c,Case__C from Medallia_Staging__C where Contact__c=null and Case__C=null and (Survey_id__c in :MapConId.keyset() or Survey_id__c in :MapCaseId.keyset())]);
            list<Medallia_Staging__C> lstSR = ([select id,Survey_id__C,Contact__c,Case__C,Error_Description__c,ALERT_TYPE__C from Medallia_Staging__C where Survey_id__c in :MapConId.keyset() or Survey_id__c in :MapCaseId.keyset()]);
            system.debug('check case id lstSR '+lstSR);
          
			// Error description update
            if(lstSR.size()>0){
                for(Medallia_Staging__c ms: lstSR){
                    String ConResult =  MapConId.get(ms.Survey_ID__c);                  
                    //String Errordesc = ms.Error_Description__c+', Result for '+string.valueOf(system.Datetime.now())+':';
                   //system.debug('Check Errordesc 2'+Errordesc);
                    string ConError;
                    if(ConResult!=null){
                        if(ConResult.left(3)=='003'  && ConResult.length()==18){
                            if(ms.Contact__c==null){
                                ms.Contact__c =  ConResult;  
                            }                         
                        }
                        Else{
                            //ms.Error_Description__c = 'Contact Error: '+ConResult; //04302021
							ConError = 'Contact Error: '+ConResult; 	                            
                            system.debug('Contact update errordesc '+ConError);
                        }                    
                        
                    } 
                    //Errordesc = Errordesc+' Contact Error: '+ConResult;
                    system.debug('Check contact ms '+ms);
                    String CaseResult =  MapCaseId.get(ms.Survey_ID__c);
                    String CaseError;
                    if(CaseResult!=null){
                        if(CaseResult.left(3)=='500'  && CaseResult.length()==18){
                            if(ms.Case__c==null){
                                ms.Case__c =  CaseResult;  
                            }                         
                        }
                        Else{
                            system.debug('Case update errordesc '+ms.Error_Description__c);
                            //ms.Error_Description__c = ' Case Error: '+CaseResult; //04302021
                            CaseError = ' Case Error: '+CaseResult;
                            system.debug('Case update errordesc after '+ms.Error_Description__c);
                        }     
                        
                    }
                    Else{  // if CaseResult ==null
                        if(ms.Alert_type__c==null) {
                            CaseError = ' Case Error: case could not get created becuase Alert_type__c is empty.';
                        }
                    }
                    string myErroDesc;
                    if(ms.Error_Description__c!=null){
                    	myErroDesc = ms.Error_Description__c.replace('null','') ;    
                    }
                    
                    //if(ms.Error_Description__c==null ){
                    if(myErroDesc==null || myErroDesc==' '){
                        if(ConError!=null) ConError = ConError.replace('null','');
                        if(CaseError!=null) CaseError = CaseError.replace('null','');
                        ms.Error_Description__c = ConError+' '+CaseError;
                    }
                    //Errordesc = Errordesc+' Case Error: '+CaseResult;
                    //ms.Error_Description__c = Errordesc;
                    //system.debug('Check Errordesc '+Errordesc);
                    system.debug('Check case ms '+ms);
                    if(ms.Case__c!=null) 	LstCases.add( new case(id=ms.Case__c,contactid=ms.Contact__c));
                }                
            }
            system.debug('Check SR lstSR:'+lstSR);
            if(lstSR.size()>0) {
                try{
                	update lstSR;		// Update Survey Response by contactid,caseid    
                }
                catch(Exception e){
                    system.debug('Error lstSR: '+e.getMessage());
                }
                
            }
            system.debug('check case update '+LstCases);
            if(LstCases.size()>0){
                try{            	
	                update LstCases;	//update con lookup in case
                }
                catch(Exception e){
                    system.debug('Error LstCases: '+e.getMessage());
                }                
            } 
        }
        
    }    
    private Map<String,Map<String,String>>  CreUpdcontact(Map<String,Integer> MapSRConDupTable,Map<string,contact> MapExistingCon,Map<String,Medallia_Staging__c> MapSRContact){
        system.debug('Check creupd con MapSRConDupTable '+MapSRConDupTable);
        system.debug('Check creupd con MapExistingCon '+MapExistingCon);
        system.debug('Check creupd con MapSRContact '+MapSRContact);
        
        //Create or update contact processing if MapTotalCon count is:
        Id conRTid 	=  Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('Customer_Guest').getRecordTypeId();        
        List<contact> Lstcon2bCreate = new List<contact>();
        List<contact> Lstcon2bUpdate = new List<contact>();        
        For(string conkey : MapSRConDupTable.keyset() ){
            integer tno = MapSRConDupTable.get(conkey);
            system.debug('Check contact tno '+tno);
            Medallia_Staging__c SR =  MapSRContact.get(conkey); // get related survey contact fields
            contact con = new contact();            
            if(tno==0){  // 0 means, contact not found and need to create new contact         
                FillContact(con,SR,0);       // 0 mean fill all fields becuase need to create new contact        
                con.RecordTypeId = conRTid;     
                Lstcon2bCreate.add(con);
            }
            Else if(tno==1){  // 1 mean, contact is already exists and just need to update contact                
                FillContact(con,SR,1);      // 1 = fill out limited fields because contact need to get update                     
                con.Id = MapExistingCon.get(conkey).id;                 
                Lstcon2bUpdate.add(con);
                
            }
            Else{ //skip if contact exists more then 1 time and here no need to create/update contact 
                
            }            
        } 
        Map<String,Map<String,String>> MapSuccessErrorCon = new Map<String,Map<String,String>>();
        Map<Id,String> MapConId_EmailFNLN = new Map<Id,String>(); // use only in contact update case 
        // Start - Insert Contact 
        if(Lstcon2bCreate.size()>0){
            try{
                system.debug('Check Insert 1 Lstcon2bCreate'+Lstcon2bCreate);  
                database.DMLOptions dml = new database.DMLOptions();
                dml.OptAllOrNone  = False;                
                Database.SaveResult[] srLstcon2bCreate = Database.insert(Lstcon2bCreate,dml);  
                system.debug('Check Insert 2 srLstcon2bCreate '+srLstcon2bCreate);
                // Get contact create result (success/error status)
                MapSuccessErrorCon = GetConSuccessError(srLstcon2bCreate,Lstcon2bCreate,MapSuccessErrorCon,MapConId_EmailFNLN,'Insert');
                system.debug('Check Insert 3 MapSuccessErrorCon '+MapSuccessErrorCon);
            } catch (DmlException e) {
                System.debug('Error contact: ' + e.getMessage());
            }            
        }
        // Update Contact
        if(Lstcon2bUpdate.size()>0){
            try{
                system.debug('Check Update 1 Lstcon2bUpdate'+Lstcon2bUpdate);
                database.DMLOptions dml = new database.DMLOptions();
                dml.OptAllOrNone  = False;    // update partially and not rollback all records             
                Database.SaveResult[] srLstcon2bUpdate = Database.Update(Lstcon2bUpdate,dml);  
                system.debug('Check update 2 srLstcon2bUpdate '+srLstcon2bUpdate);
                system.debug('Check update 2 MapSuccessErrorCon '+MapSuccessErrorCon);
                //Convert Map into Map<Id,EmailFNLN
                For(Contact co : MapExistingCon.values()){
                    MapConId_EmailFNLN.put(co.Id,co.System_EmailFNLN_Text__c); //System_EmailFNLN__c a formual field (Email+Fname+Lname)
                }  
                
                MapSuccessErrorCon = GetConSuccessError(srLstcon2bUpdate,Lstcon2bUpdate,MapSuccessErrorCon,MapConId_EmailFNLN,'Update');
                system.debug('Check Update 3 MapSuccessErrorCon '+MapSuccessErrorCon);
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
            }            
        }
        // Update Survey Response (Medallia_Stagging)
        system.debug('Check MapSuccessErrorCon '+MapSuccessErrorCon);
        
        return MapSuccessErrorCon;
    }
    private void FillContact(contact co,Medallia_Staging__c sr,integer myevent){  // myevent: 0= create, 1=update
        co.Rank_Value__c				= sr.Rank_Value__c;
        co.Global_Rank__c				= sr.Global_Rank__c;
        co.Global_Tier__c				= sr.Global_Tier__c;
        co.Rank__c						= sr.Rank__c;
        co.Tier_Name__c					= sr.Tier__c;
        co.Property_Tier__c				= sr.Property_Tier__c;        
        co.Casino_Account_Number__c 	= sr.Casino_Account_number__c;
        co.Email 						= sr.Email__c;			// don't comment out
        co.FirstName 					= sr.First_name__c;		// don't comment out
        co.LastName						= sr.Last_name__c;		// don't comment out

        if(myevent==0){
            co.Member_Source__c				='Medallia'; // Jira#HRSC3AP-314
           // co.Email 						= sr.Email__c;			// don't remove comment
           // co.FirstName 					= sr.First_name__c;		// don't remove comment
           // co.LastName						= sr.Last_name__c;	// don't remove comment
            co.Player_ID__c					= sr.Player_ID__c;
            co.Phone						= sr.Phone__c;
            co.Player_type_distance__c		= sr.Player_type_distance__c;        
            co.HRI_account__c				= sr.HRI_account__c;
            co.HOST__c						= sr.HOST__c;
            co.AgeSegment__c				= sr.AgeSegment__c;
            co.Distance_to_property__c		= sr.Distance_to_property__c;
            co.Language__c					= sr.Language__c;
            if(sr.Tier__c=='XCARD'){
                //co.Tier_Name__c = 'X-Card_Rock Loyalty';
                 co.Tier_Name__c  = 'X-Card_Rock Royalty';
            }                
            
        }
    } 
    private case Fillcase(case newcase,Medallia_Staging__c SR,Id CaseRTid,Map<String,String> MapAlertType,Map<String,String> MapCaseLocationId,Map<String,String> MapCaseStatus){
        // Event: 0 = create, 1=update
        newcase.status = MapCaseStatus.get(SR.Current_status_of_alert__c);
        if(SR.Current_status_of_alert__c=='Closed'){   // if case already closed then the case handle by Medallia
            newcase.Case_handled_in_SFDC_flag__c = False;            
			newcase.OwnerId	=System.Label.Case_Medallia_Queue_Id;            
        } 
        Else{
            newcase.Case_handled_in_SFDC_flag__c = True;        
            newcase.OwnerId	=System.Label.Case_Active_Queue_Id;                        
        }
        
        
        newcase.Medallia_Alert_Status__C=SR.Current_status_of_alert__c;       
        newcase.Problem_Area__c			=SR.Problem_Area__c;
        newcase.Action_Taken__c			=SR.Action_Taken__c;        
        newcase.Value__c				=SR.Appeasement_Comp_Dollars__c;
        newcase.Concerned_Dept__c		=SR.What_are_the_teams_that_feedback_can_be__c;
        newcase.Notes__c				=SR.All_log_notes_combined_if_any__c;
        newcase.Casino_Account_number__c=SR.Casino_Account_number__c;
        newcase.RecordTypeId  = caseRTid;        	         
        newcase.Origin = 'Survey';  
        newcase.medallia_xm__Medallia_internal_id__c=SR.Survey_ID__c; 
        newcase.Subject			= 'Survey ID: '+SR.Survey_ID__c;
        newcase.Medallia_Alert_Type__c	=SR.Alert_type__c;
        newcase.Rank_Value__c			=SR.Rank_Value__c;
        newcase.Global_Rank__c			=SR.Global_Rank__c;
        newcase.Global_Tier__c			=SR.Global_Tier__c;
        newcase.Rank__c					=SR.Rank__c;        
        newcase.Tier__c					=SR.Tier__c;
        newcase.Property_Tier__c		=SR.Property_Tier__c;
        newcase.Record_Type_Seminole__c =SR.Record_Type_Seminole__c;
        newcase.Priority				= MapAlertType.get(SR.Alert_type__c);      
        newcase.Location__c				= MapCaseLocationId.get(SR.Property__c);
        newcase.Responsedate__c			= SR.Responsedate__c;
        newcase.Alert_closed_by__c		= SR.Alert_closed_by__c;
        newcase.Alert_close_time__c		= SR.Alert_close_time__c;
        newcase.Alert_owner__c			=SR.Alert_owner__c;
        newcase.HOST__c					= SR.HOST__c;
        return newcase;
    }
    private map<string,map<string,string>> GetConSuccessError(Database.SaveResult[] srLstcon2bCreUpd,List<contact> Lstcon2bCreUpd,Map<String,Map<String,String>> MapSuccessErrorCon,Map<Id,String> MapConId_EmailFNLN,string dml){
        system.debug('Check in MapConId_EmailFNLN '+dml+' '+MapConId_EmailFNLN);
        system.debug('Check in Lstcon2bCreUpd '+dml+' '+Lstcon2bCreUpd);
        system.debug('Check in MapSuccessErrorCon '+dml+' '+MapSuccessErrorCon);
        
        
        // Iterate through each returned result
        integer sno = -1;
        
        for (Database.SaveResult sr : srLstcon2bCreUpd) {
            system.debug('Check SuccessError sr '+sr);
            sno = sno+1;
            map<string,string> mymap =  new map<string,string>(); // temporary use to keep value
            string conkey ;
            //if(dml=='Insert'){
                conkey = GetConkey(Lstcon2bCreUpd.get(sno).Email,Lstcon2bCreUpd.get(sno).FirstName,Lstcon2bCreUpd.get(sno).LastName);                     
           // }
           // Else{  // incase update contact 
              //  conkey = MapConId_EmailFNLN.get(sr.getid());                      
           // }
            system.debug('Check SuccessError conkey '+conkey);
            // }                 
            if (sr.isSuccess()) {                     
                mymap.put(sr.getId(),dml+' Success');
                system.debug('Check SuccessError mymap '+mymap);
                MapSuccessErrorCon.put(conkey,mymap); 
            }
            else {
                // Operation failed, so get all errors
                string ConError;                
                for(Database.Error err : sr.getErrors()) {
                    ConError = ConError+' '+err.getMessage()+' '+err.getFields();
                }
                mymap.put(ConError,dml+' False');
                 system.debug('Check FalseError mymap '+mymap);
                MapSuccessErrorCon.put(conkey,mymap);   
               
            }
        }
        system.debug('Check SuccessError MapSuccessErrorCon '+MapSuccessErrorCon);
        return MapSuccessErrorCon;
    }
    private Map<String,map<string,string>> InsertCases(List<Case> LstCases2bInsert,Map<String,map<string,string>> MapSuccessErrorCase){
        system.debug('Check Case LstCases2bInsert '+LstCases2bInsert);
        database.DMLOptions dml = new database.DMLOptions();
        dml.OptAllOrNone  = False;       
        Database.SaveResult[] results  = Database.insert(LstCases2bInsert,dml);  
        
        // Iterate through each returned result
        integer sno = -1;
        string casekey;
        for (Database.SaveResult sr : results) {
            system.debug('Check SuccessError '+sr);
            sno = sno+1;
            casekey = LstCases2bInsert.get(sno).medallia_xm__Medallia_internal_id__c;
            system.debug('check case update casekey: '+casekey);
            map<string,string> mymap =  new map<string,string>(); // temporary use to keep value
            if (sr.isSuccess()) {                     
                mymap.put(sr.getId(),' Insert Success');
                MapSuccessErrorCase.put(casekey,mymap); 
            }
            else {
                // Operation failed, so get all errors
                string caseError;                
                for(Database.Error err : sr.getErrors()) {
                    caseError = caseError+' '+err.getMessage()+' '+err.getFields();
                }
                mymap.put(caseError,' Insert Fail');
                MapSuccessErrorCase.put(casekey,mymap);                      
            }
        }
        
        return MapSuccessErrorCase;
        
    }
    private Map<String,String> GetCasePriority(Map<String,String> MapAlertType){
        for(Administration_Data__c ad : ([Select id,Medallia_Alert_Types__c,Case_Priority__c from Administration_Data__c Where Use_For__c='Medallia Alert Type'])){            
            for(string ss : ad.Medallia_Alert_Types__c.split(',')){
                MapAlertType.put(ss,ad.Case_Priority__c);
            }
        }        
        return MapAlertType;
    }
    private Map<String,String> GetCaseLocationId(Map<String,String> MapCaseLocationId){
        for(Administration_Data__c ad : ([Select Name,Property_Id__c from Administration_Data__c Where Use_For__c='Medallia Property'])){            
            MapCaseLocationId.put(ad.Name,ad.Property_Id__c);
        }        
        return MapCaseLocationId;
    }
    private Map<String,String> GetCaseStatus(Map<String,String> MapCaseStatus){
        for(Administration_Data__c ad : ([Select Medallia_Alert_Status__c,SF_Case_Status__c from Administration_Data__c Where Use_For__c='Medallia Case Status'])){            
            MapCaseStatus.put(ad.Medallia_Alert_Status__c,ad.SF_Case_Status__c);
        }        
        return MapCaseStatus;
    }
	Private Map<String,Map<String,String>> UpdateCase(List<case> Lstcase,List<Medallia_Staging__c> LstSRTriggerData,Map<String,map<string,string>> MapSuccessErrorCase){
        system.debug('Check Case Lstcase '+Lstcase);
        database.DMLOptions dml = new database.DMLOptions();
        dml.OptAllOrNone  = False;
        Database.SaveResult[] results  = Database.Update(Lstcase,dml);  
        
        // Iterate through each returned result
        integer sno = -1;
        string casekey;
        for (Database.SaveResult sr : results) {
            system.debug('Check SuccessError '+sr);
            sno = sno+1;
            casekey = Lstcase.get(sno).medallia_xm__Medallia_internal_id__c;
            system.debug('check case update casekey: '+casekey);
            map<string,string> mymap =  new map<string,string>(); // temporary use to keep value
            if (sr.isSuccess()) {                     
                mymap.put(sr.getId(),' Update Success');
                MapSuccessErrorCase.put(casekey,mymap); 
            }
            else {
                // Operation failed, so get all errors
                string caseError;                
                for(Database.Error err : sr.getErrors()) {
                    caseError = caseError+' '+err.getMessage()+' '+err.getFields();
                }
                mymap.put(caseError,' Update Fail');
                MapSuccessErrorCase.put(casekey,mymap);                      
            }
        }
        
        return MapSuccessErrorCase;

    }    

}