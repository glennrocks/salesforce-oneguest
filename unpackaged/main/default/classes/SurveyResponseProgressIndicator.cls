public class SurveyResponseProgressIndicator {
   @AuraEnabled
    public static list<String> getRatingScoreColor(){
        list<String> lstColor = new list<String>(); 
        For(Administration_Data__c row : [select Progress_Bar_Color__c from Administration_Data__c 
                                          where Use_For__c ='Medallia Survey Progress' order by Rating_Score__c]){           
			lstColor.add(row.Progress_Bar_Color__c);                                              
        }
        
          return lstColor;
      }
}