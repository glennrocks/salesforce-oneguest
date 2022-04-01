/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               25-Jan-2021
Version:            1.0
Description:        Contact Trigger Handler
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on             Added By               Description
**********************************************************************************
25/Jan/2021          Danish QaimKhani          Added method that
If contact is created with guest/customer record type then create its account with default values HRSC3AP-86

**********************************************************************************
*/
public class ContactTrgHandler {
    
    public void OnBeforeInsert(List<Contact> newObjects, Map<Id, Contact> newMap){ 
        for(Contact ContactObj : newObjects){            
            //objCon.System_EmailFNLN_Text__c = objCon.Email != null?objCon.Email.toLowerCase():''+'-'+objCon.FirstName.toLowerCase() != null ? objCon.FirstName.toLowerCase():''+'-'+objCon.LastName.toLowerCase() !=null ? objCon.LastName.toLowerCase() :''; //objCon.System_EmailFNLN__c;
            //objCon.System_EmailFNLN_Text__c = objCon.Email.toLowerCase()+'-'+objCon.FirstName.toLowerCase()+'-'+objCon.LastName.toLowerCase(); //objCon.System_EmailFNLN__c;
               ContactObj.System_EmailFNLN_Text__c= GetString(ContactObj.Email).toLowerCase()+'-'+
                									GetString(ContactObj.FirstName).toLowerCase()+'-'+
                									GetString(ContactObj.LastName).toLowerCase();
            

            system.debug('check if contact has digits');
            
            	if(Label.System_DataLoading_Contact_Mask_Email=='TRUE')
                {
                	// only for data loading if User wants to append .invalid in contacts
                    if(ContactObj.Email != null   && (!ContactObj.Email.endsWith('.test')) )
                    	ContactObj.Email=ContactObj.Email+'.test';
                    
                    //  row.MSD_Created_Date__c=row.CreatedDate.date();
                         if(ContactObj.CreatedDate != null)
                    	 ContactObj.MSD_CreatedDate__c= ContactObj.CreatedDate.date();

                   //sh if(ContactObj.MSD_CreatedDate__c != null)
                   //sh {  //Date dToday = MSD_CreatedDate__c;
                   //sh    Datetime dt = datetime.newInstance(ContactObj.MSD_CreatedDate__c.year(), ContactObj.MSD_CreatedDate__c.month(),ContactObj.MSD_CreatedDate__c.day());	 
                   //sh    ContactObj.CreatedDate= dt;
                   //sh }
                   // 
                   // row.CreatedDate= row.MSD_Created_Date__c;
                }   
           
       
        }
    }
    public void OnAfterInsert(List<Contact> newObjects, Map<Id, Contact> newMap){ 
    	List<Contact> listOfConUpdate = new List<Contact>();
        List<Account> listOfAccountToInsert = new List<Account>();
        Map<String,String> mapOfErrorMsg = new Map<String,String>();
        
        String tempFirstName='';
		for(Contact objCon : newObjects){
		  if(objCon.AccountId == null && objCon.System_Record_Type_Name__c=='Customer_Guest')
          {  // adding condition to skip first name if it is null
              tempFirstName='';
              if(objCon.FirstName !=null)
              	tempFirstName=objCon.FirstName+' ';
              
              Account acct = new Account();
              acct.Name = tempFirstName+objCon.LastName+' Account';
              acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Guest_Account').getRecordTypeId();
              acct.SystemContactId__c=objCon.Id;
               acct.OwnerId=Label.Medallia_Integration_User_Id;
              listOfAccountToInsert.add(acct);
          }
		
		}
       
        if(listOfAccountToInsert.size()>0)
        {
           List<Database.SaveResult> SR = Database.insert(listOfAccountToInsert,false);
            
           for(Integer i=0;i<SR.size();i++)
           {	//only look at failures, or NOT Successes
              
               if(!SR[i].isSuccess())
               {	
                    mapOfErrorMsg.put(listOfAccountToInsert[i].SystemContactId__c, String.valueOf(SR[i].getErrors()));
                  	system.debug('kk_'+SR[i]. getErrors());
                  	system.debug('kk_'+listOfAccountToInsert[i]); //instead of debug, you could have an email processor something else that looks at that record and the error message
               }else{
                   Contact con = new Contact();
                   con.AccountId=listOfAccountToInsert[i].Id;
                   system.debug('Account ID: ' + con.AccountId);
                   con.Id=listOfAccountToInsert[i].SystemContactId__c;
                   listOfConUpdate.add(con);
               }
			}	
        }
            
        if(listOfConUpdate.size()>0){
            update listOfConUpdate;
        }
        // checking size for error
        if(mapOfErrorMsg.size()>0)
        {    
            for(Contact objCon : newObjects){
                if(mapOfErrorMsg.containsKey(objCon.Id)){
                    objCon.addError(''+mapOfErrorMsg.get(objCon.Id));
                }
            }
        }  
        
        
    }
    
    public void onAfterUpdate(List<Contact> oldObjects, List<Contact> newObjects, Map<Id, Contact> oldMap, Map<Id, Contact> newMap){
        Contact OldContactObj; 
        List<Account> listOfAccountToUpdate = new List<Account>();
        String tempFirstName='';
        for(Contact ContactObj : newObjects){
            OldContactObj = oldMap.get( ContactObj.Id );
             // checking if user changing the first name or last name
             if( (ContactObj.FirstName != OldContactObj.FirstName || ContactObj.LastName != OldContactObj.LastName) &&  ContactObj.AccountId !=null && ContactObj.System_Record_Type_Name__c=='Customer_Guest'  )
             {
                // adding condition to skip first name if it is null
              tempFirstName='';
              if(ContactObj.FirstName !=null)
              	tempFirstName=ContactObj.FirstName+' ';
                 
              // if user is changing the name then update account 
              Account acct = new Account();
              acct.Id=ContactObj.AccountId;
              acct.Name = tempFirstName+ContactObj.LastName+' Account';
              listOfAccountToUpdate.add(acct);               
             }
             
         }
        
        if(listOfAccountToUpdate.size()>0)
        {
            try{
            	update listOfAccountToUpdate;    
                
            }
            Catch(exception e){
                system.debug('Error: '+e.getMessage());
            }
            
        }
    }
    
  
    public void OnBeforeUpdate(List<Contact> oldObjects, List<Contact> newObjects, Map<Id, Contact> oldMap, Map<Id, Contact> newMap){
	 	Contact OldContactObj; 
        for(Contact ContactObj : newObjects){
            
             OldContactObj = oldMap.get( ContactObj.Id );
             
           
           
            if(GetString(ContactObj.Email)		!= GetString(OldContactObj.Email) ||
               GetString(ContactObj.FirstName) 	!= GetString(OldContactObj.FirstName) ||
               GetString(ContactObj.LastName) 	!= GetString(OldContactObj.LastName)
              )
            {
               ContactObj.System_EmailFNLN_Text__c= GetString(ContactObj.Email).toLowerCase()+'-'+
                									GetString(ContactObj.FirstName).toLowerCase()+'-'+
                									GetString(ContactObj.LastName).toLowerCase();
            }
        }        
    }   
          
 	private string GetString(String myval){
        Return myval==null?'':myval.toLowerCase();
        
    }
        
}