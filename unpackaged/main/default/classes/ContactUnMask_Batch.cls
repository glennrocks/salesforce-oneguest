/*Author:           Danish Qaimkhani
Date:               17-06-2021  
Version:            1.0
Description:        Batch Process To un mask Emails on contact
----------------------------------------------------------------------------------------------------*/

/************************MODIFICATION HISTORY*************************************
Added on            Added By            Description
17-06-2021        Danish Qaimkhani              Initial Draft 
**********************************************************************************/
public class ContactUnMask_Batch implements Database.Batchable<sobject> {
     public String Query=''; 
   
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
            Query = 'Select Id, Email'; 
            Query += ' from Contact';
          //  Query += ' Where id = \'0037h00000TQMyE\'  OR id=\'0037h00000TQKgp\' ';
           
        
        return Database.getQueryLocator(Query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> lstOfContact) {
        list<contact> lstOfContactToUpdate = new list<contact>();
        Contact objContact = new  Contact();
        for(Contact row:lstOfContact){
            if(row.Email != null  && row.Email.endsWith('.test')){
                objContact = new  Contact();
                objContact.Id=row.Id;
                objContact.Email=row.Email.removeEnd('.test');
                lstOfContactToUpdate.add(objContact);
            }
        }
        
        if(lstOfContactToUpdate.size()>0)
            update lstOfContactToUpdate;
           
        

    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}