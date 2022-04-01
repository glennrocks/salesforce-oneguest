/*-------------------------------------------------------------------------------------------------
Author:             Shoukat Hussain
Date:               10-Mar-2021
Version:            1.0
Description:        Test Class for MedalliaStagingTrgHandler and MedalliaStagingTrg
----------------------------------------------------------------------------------------------------*/
@isTest
public class MedalliaStagingTrgHandlerTest {
    @isTest static void SR_Insert() {  
        list<Administration_Data__c> lstadmin = new list<Administration_Data__c>();
        integer myratingscore = 0;
        Id AdmindataRTid =  Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Medallia_Case').getRecordTypeId();        
        for (Integer i = 0, j = 0; i < 10; i++) {
    		lstadmin.add(new Administration_Data__c(name='Progress',rating_score__C=myratingscore,
                                                 progress_bar_color__C='red',Use_For__c='Medallia Survey Progress',
                                                RecordTypeId = Schema.SObjectType.Administration_Data__c.getRecordTypeInfosByDeveloperName().get('Medallia_Case').getRecordTypeId() ));            
			myratingscore = myratingscore+1;
       }
        system.debug('check '+lstadmin);
        If(lstadmin.size()>0) insert lstadmin;
        
        
        Medallia_Staging__C ms = new Medallia_Staging__C();
        ms =  DataFactoryTest.SurveyResponseIns(ms,'001','New');
		insert ms;
		ms.Rank__c = '13';
        ms.Tier__c = 'Elite';
        ms.Current_status_of_alert__c = 'In Progress';
        update ms;
        //for existing contactg
        ms.clear();
        ms =  DataFactoryTest.SurveyResponseIns(ms,'002','New');
        Insert ms;
		// Auto Clsoed case
		ms.clear();
        ms =  DataFactoryTest.SurveyResponseIns(ms,'003','Closed');
        Insert ms;
        
    }
    
}