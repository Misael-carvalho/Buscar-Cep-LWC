public with sharing class LeadProcessingBatch implements Database.Batchable<String>, Database.AllowsCallouts {
    private String contactlists;
    private List<String> leadsData;
    
    public LeadProcessingBatch(String contactlists, String contacts) {
        this.contactlists = contactlists;
        this.leadsData = contacts.split(',');
    }
    
    public Iterable<String> start(Database.BatchableContext bc) {
        return leadsData; 
    }
    
    public void execute(Database.BatchableContext bc, List<String> scope) {
        for (String leadData : scope) {
            System.debug('leadData >> '+ leadData.replaceAll('\'', ''));
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.mypurecloud.com/api/v2/outbound/contactlists/' + contactlists + '/contacts/' + leadData.replaceAll('\'', ''));
            req.setMethod('DELETE');
            req.setHeader('Content-Type', 'application/json');
            System.debug('req.getEndpoint() ' + req.getEndpoint());
            // Http http = new Http();
            // HttpResponse res = http.send(req);
            
            // if (res.getStatusCode() != 200) {
            //     System.debug('Error: ' + res.getBody());
            // }
        }
    }
    

    public void finish(Database.BatchableContext bc) {
        // Final steps if any
    }
}
