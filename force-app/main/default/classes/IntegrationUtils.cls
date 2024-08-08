public with sharing class IntegrationUtils {

    public static RequestResponseObject executeCallout(IntegrationData__c integrationData, String payload, Map<String, String> requestHeaders) {
        return executeCallout(integrationData, payload, requestHeaders, 'POST');
    }

    public static RequestResponseObject executeCallout(IntegrationData__c integrationData, String payload, Map<String, String> requestHeaders, String method) {
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setTimeout(110000);
        request.setEndpoint(integrationData.Endpoint__c);
        if (payload != null) {
            request.setBody(payload);
        }
        if (String.isNotBlank(integrationData.Username__c) && String.isNotBlank(integrationData.Password__c)){ 
            IntegrationUtils.addBasicAuthData(integrationData.Username__c, integrationData.Password__c, request);
        }
        
        if (requestHeaders != null && requestHeaders.size() > 0){
            for (String headerKey : requestHeaders.keySet()){
                request.setHeader(headerKey, requestHeaders.get(headerKey));
            }
        }
        HttpResponse response;
        try{
            response = (new Http()).send(request);
            return new RequestResponseObject(response);
        }catch (Exception ex){
            System.debug('CALLOUT EXCEPTION: ' + ex.getMessage() + ex.getStackTraceString());
            return new RequestResponseObject(ex);
        }
    }

    public static void WSLog(String integrationName, String messageError, String payloadIN, String payloadOUT, Boolean hasAnyErrors){

        Boolean shouldUseAttachmentIN  = (payloadIN.length() > 32768);
        Boolean shouldUseAttachmentOUT = (payloadOUT.length() > 32768);
        Datetime tNow = System.now();

        IntegrationLog__c log = new IntegrationLog__c(
            Name   = integrationName,
            MessageError__c   = messageError,
            PayloadIN__c     = (shouldUseAttachmentIN  ? payloadIN.substring(0, 32768) : payloadIN),
            PayloadOUT__c    = (shouldUseAttachmentOUT ? payloadOUT.substring(0, 32768) : payloadOUT),
            Status__c         = (hasAnyErrors ? 'ERROR' : 'OK'),
            ExecuteDate__c    = tNow
        );

        try{
            insert log;
        }catch(Exception e){
            System.debug('EXCEPTION ON LOG - Please review parameters - '+ e.getMessage()+' - '+e.getStackTraceString());
        }
    }

    public static void addBasicAuthData(String username, String password, HttpRequest req){
        req.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(username+':'+password)));
    }

    public class RequestResponseObject {
        public HttpResponse response;
        public Boolean success;
        public Exception exceptionObject;
		public Integer statusCode;
		public String body;

        public RequestResponseObject(HttpResponse response){
            this.success = true;
            this.response = response;
            this.exceptionObject = null;
			this.statusCode = response.getStatusCode();
			this.body = response.getBody();
        }

        public RequestResponseObject(Exception ex){
            this.success = false;
            this.response = null;
            this.exceptionObject = ex;
        }
    }
}