public class CaseUpdateOwnerToQueue_Batch implements Database.Batchable<sobject> {
    public String Query=''; 
 public Database.QueryLocator start(Database.BatchableContext BC) {
        
            Query = 'Select Id, Status,OwnerId'; 
            Query += ' from Case';
            Query += ' Where Status = \'Open in MS Dynamics\'  AND OwnerId!=\''+ Label.Case_Pending_Queue_Id+ '\'  ';
           
        
        return Database.getQueryLocator(Query);
    }
     public void execute(Database.BatchableContext BC, List<Case> lstOfCases) {
         
          for(Case row:lstOfCases){
               if(row.OwnerId != null  && row.OwnerId!= Label.Case_Pending_Queue_Id ){
                   row.OwnerId=Label.Case_Pending_Queue_Id;
               }    
            }
         
         update lstOfCases;
     }
    
     
    public void finish(Database.BatchableContext BC) {
        
    }
}