public without sharing class API_Framework {
    
    // Call API
    //
    // Hub to select which API class to work with
    // Values:
    // 
    // List<List<String>> idList - list with API id and Object id. List<List<>> for workflow compability.
    // 
    // Returns:
    // 
    // List<List<String>> with errors that occurred during the call of this class. List<List<>> for workflow compability.
    //
    @InvocableMethod
    public static List<List<String>> callApi(List<List<String>> idList){
        List<List<String>> returnList = new List<List<String>>();
        List<String> errorList = new List<String>();
        String queryString = '';
        
        List<String> queryId = idList.get(0);
        String apiId = queryId.get(0);
        String objectId = queryId.get(1);
        
        List<API__c> apiList = [SELECT Id, Name, Object_Name__c, Credential__c, HTTP_Method__c, HTTP_Content_Type__c
                                FROM API__c WHERE Id = :apiId LIMIT 1];
        
        if (apiList.size() < 1){
            errorList.add('No API.');
            logAPIRequest(queryId.get(0), '- no data -', '-0', 'No API.', 'Open', 'API_Framework', '-no data-', '-no data-');
        }
        else{
            API__c api = apiList[0];
            
            switch on api.Name {
                when 'Open-Meteo' {
                    API_OpenMeteo.getWeather(api, objectId);
                }	
                when 'Jokes' {
                    //call method
                }
                when 'CoinDesk' {
                    //call method
                }
                when else {
                    errorList.add('No API method implemented.');
                    logAPIRequest(api.Id, '- no data -', '-0', 'No API method implemented.', 'Open', 'API_Framework', '-no data-', api.HTTP_Method__c);
                }
            }
            
            if(errorList.isEmpty() != TRUE){
                returnList.add(errorList);
            }
            else{
                returnList = null;
            }
        }
        
        return returnList;
        
    }
    
    // Outbound Rest Call to API
    //
    // Make a call to send/get data from the API 
    // Values:
    // 
    // Id apiId - ID of the API called
    // String credential - Named credential used by the API
    // String method - HTTP method used
    // String contentType - content type defiened by the API 
    // String body - body used to send data to the API.
    // 
    // Returns:
    // 
    // Map<String, Object> with information from the response from the API
    //
    public static Map<String, Object> outboundRestCall(Id apiId, String credential, String method, String contentType, String body){
        Map<String, Object> responseList = new Map<String, Object>();
        
        try{
            Http httpInstance = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response;
            
            String endpoint = 'callout:' + credential;
            
            request.setEndpoint(endpoint);
            
            request.setMethod(method);
            request.setHeader('Content-Type', contentType);
            if(method == 'POST' || method == 'PUT'){
                request.setBody(body);
            }
            
            response = httpInstance.send(request);
            
            if (response.getStatusCode() == 201 || response.getStatusCode() == 200) {
                responseList = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
				
                //temp
                logAPIRequest(apiId, String.valueOf(request), String.valueOf(response.getStatusCode()), response.getBody(), 'Closed', 'API_Framework', 'id : ', method);
            }
            else {
                responseList = null;
                
                // Handle the error
                logAPIRequest(apiId, String.valueOf(request), String.valueOf(response.getStatusCode()), response.getBody(), 'Open', 'API_Framework', 'id : ', method);
            }
        } catch (DmlException e) {
            responseList = null;
            
            logAPIRequest(apiId, '', '-5', e.getMessage(), 'Open', 'API_Framework', 'id : ', method);
        }
        
        return responseList;
    }
    
    // Log API Request
    // 
    // Create a Log_API object, that shows the values of a error or a call to the API.
    // Values:
    // 
    // ID apiId - ID of the API called
    // String inputMsg - Message/Body sent to the API 
    // String retCode - code received (ex. 201, 430, 500, ...)
    // String outputMsg - Message/Body received from the API 
    // String status - values: Closed - no error in the call | Open - error during the call
    // String apexClass - Apex class where this method was called
    // String objectID - ID of the object that was being handled in the call
    // String httpMethod - HTTP method used
    //
    public static void logAPIRequest(Id apiId, String inputMsg, String retCode, String outputMsg, String status, String apexClass, String objectId, String httpMethod){
        Log_API__c log = new Log_API__c();
        
        List<API__c> apiList = [SELECT Id, Name, Credential__c, HTTP_Method__c, HTTP_Content_Type__c, RecordType.Name
                                FROM API__c WHERE Id = :apiId LIMIT 1];
        
        if (apiList.size() == 1){
            API__c api = apiList[0];
            log.API_Record_Type__c = api.RecordType.Name;
        }
        
        log.API__C = apiId;
        log.Input_Body__c = inputMsg;
        log.Return_Code__c = retCode;
        log.Output_Body__c = outputMsg;
        log.Status__c = status;
        log.Apex_Class__c = apexClass;
        log.Object_ID__c = objectId;
        log.HTTP_Method__c = httpMethod;
        
        insert log;
    }
    
}