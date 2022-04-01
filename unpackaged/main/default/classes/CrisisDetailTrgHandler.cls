/*-------------------------------------------------------------------------------------------------
Author:             Danish QaimKhani
Date:               02-March-2021
Version:            1.0
Description:        Case Trigger Handler
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on             Added By               Description
**********************************************************************************
02-March-2021         Danish QaimKhani          Added method that
adding crisis number with name
**********************************************************************************/

public class CrisisDetailTrgHandler {

    public void onBeforeInsert(List<Crisis_Details__c> newObjects, Map<Id, Crisis_Details__c> newMap){
      
        for(Crisis_Details__c row:newObjects){
            if(row.Crisis_Number__c !=null)
                row.Name=row.Crisis_Number__c +' ' +row.Name;
            
             row.Name=row.Name.left(80);
        }

    }
    
     public void onBeforeUpdate(List<Crisis_Details__c> oldObjects, List<Crisis_Details__c> newObjects, Map<Id, Crisis_Details__c> oldMap, Map<Id, Crisis_Details__c> newMap){
      	Crisis_Details__c OldRow;
        String tempCrisisNumber='';
		for(Crisis_Details__c row:newObjects){
            OldRow = oldMap.get( row.Id );
            tempCrisisNumber='';
            
            if(row.Crisis_Number__c != null)
            	tempCrisisNumber = String.valueOf(row.Crisis_Number__c)+' ';
          
            
            
            if( OldRow.Name !=row.Name ||  OldRow.Crisis_Number__c !=row.Crisis_Number__c)
            {     // checking if old data is not null so remove characters from name and add again
                if(OldRow.Crisis_Number__c !=null)
            		row.Name=row.Name.replace(String.valueOf(OldRow.Crisis_Number__c), '' );
                
                row.Name=tempCrisisNumber+row.Name;
                row.Name=row.Name.left(80);
            }
            
        }
         
     }
    
    
}