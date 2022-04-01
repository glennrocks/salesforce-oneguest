/*-------------------------------------------------------------------------------------------------
Author:             Shoukat Hussain
Date:               10-Mar-2021
Version:            1.0
Description:        Test Class for SurveyResponseProgressIndicator 
----------------------------------------------------------------------------------------------------*/
@isTest
public class SurveyResponseProgressIndicatorTest {
    @isTest 
    static void SR_Insert() {   
       list<Administration_Data__c> lstadmin = new list<Administration_Data__c>();
       integer myratingscore = 0;
         Id AdmindataRTid =  Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Medallia_Case').getRecordTypeId();                
       for (Integer i = 0, j = 0; i < 10; i++) {
    		lstadmin.add(new Administration_Data__c(name='Progress',rating_score__C=myratingscore,
                                                 progress_bar_color__C='red',Use_For__c='Medallia Survey Progress',
                                                RecordTypeId = Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Medallia_Case').getRecordTypeId() ));            
			myratingscore = myratingscore+1;
       }
        insert lstadmin;
        list<String> lstColor = new list<String>(); 
        lstColor =SurveyResponseProgressIndicator.getRatingScoreColor(); 
    }
    
}