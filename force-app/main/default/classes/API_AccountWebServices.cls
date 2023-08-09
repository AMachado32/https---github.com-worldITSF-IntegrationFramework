@RestResource(urlMapping='/Account/*')
global without sharing class API_AccountWebServices {
    public static RestResponse response = RestContext.response;
    public static RestRequest req = RestContext.request;
    public static String requestBody = req.requestBody.toString();
    public static Type t = Type.forName('API_AccountWebServices');
    public static String name = t.getName();
		        
    public static API__c api = [SELECT Id, Apex_Class__c
                  				FROM API__c
                                WHERE Apex_Class__c =: name
                               ];
         
    @HttpGet
    global static void doGet() {  
        String accId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        
        List<Account> accountList = [SELECT id, Name, Phone, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode
                                     FROM Account
                                     WHERE id = :accId
                                    ];
		response.addHeader('Content-Type', 'application/json');                      
        
        String body = '';
        if(accountList.size() > 0) {
            AccountWrapper wrapper = new AccountWrapper();
            wrapper.accName = accountList[0].Name;
            wrapper.accPhone = accountList[0].Phone;
            wrapper.accBillingStreet = accountList[0].BillingStreet;
            wrapper.accBillingCity = accountList[0].BillingCity;
            wrapper.accBillingState = accountList[0].BillingState;
            wrapper.accBillingCountry = accountList[0].BillingCountry;
            wrapper.accBillingPostalCode = accountList[0].BillingPostalCode;
            body = JSON.serializePretty(wrapper);
            response.responseBody = Blob.valueOf('Account Information: \n' + body);
            response.statusCode = 200;
            API_Framework.logAPIRequest(api.Id,response.responseBody.toString(),String.valueOf(response.statusCode),'','Open','API_AccountWebServices','','GET');
        
        }else {
            body = 'No account found with id: ' + accId;
            response.responseBody = Blob.valueOf('Account Information: \n' + body);
            response.statusCode = 404;
            API_Framework.logAPIRequest(api.Id,response.responseBody.toString(),String.valueOf(response.statusCode),'','Open','API_AccountWebServices','','GET');
                   
        }
                              
     }
     @HttpPost    
     global static void doPost() {
        NewAccountRequest newAccount = (NewAccountRequest)JSON.deserialize(requestBody, NewAccountRequest.class);
    	
        Account newAccountRecord = new Account(Name = newAccount.accName, 
                                               Phone = newAccount.accPhone,
                                               BillingStreet = newAccount.accBillingStreet,
                                               BillingCity =  newAccount.accBillingCity,
                                               BillingState =  newAccount.accBillingState,
                                               BillingCountry =  newAccount.accBillingCountry,
                                               BillingPostalCode =  newAccount.accBillingPostalCode);
         
        response.addHeader('Content-Type', 'application/json');
                
        try {
             insert newAccountRecord;
            
             response.responseBody = Blob.valueOf('A new account has been created: \n' + 
                                                  '- Account Id: ' + newAccountRecord.Id + 
                                                  '\n- Account Name: ' + newAccountRecord.Name);
             response.statusCode = 201;
             API_Framework.logAPIRequest(api.Id,response.responseBody.toString(),String.valueOf(response.statusCode),'','Open','API_AccountWebServices','','POST');
            
        }catch(Exception ex) {
            response.responseBody = Blob.valueOf('{ "error" :' + ex.getMessage() + '}');
            response.statusCode = 500;
            API_Framework.logAPIRequest(api.Id,ex.getMessage(),'', '', 'Open', 'API_AccountWebServices', '','POST');
        }
     }
    
     @HttpDelete
     global static void doDelete() {
   		String accId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        Account accountToDelete = [SELECT Id FROM Account WHERE id = :accId ];
        
        response.addHeader('Content-Type', 'application/json');
        try {
        	 delete accountToDelete;
            
             response.responseBody = Blob.valueOf('The Account with id ' + accId + ' has been successfully deleted.');
             response.statusCode = 200;
             API_Framework.logAPIRequest(api.Id,response.responseBody.toString(),String.valueOf(response.statusCode),'','Open','API_AccountWebServices','','DELETE');
            
        }catch(Exception ex) {
            response.responseBody = Blob.valueOf('{ "Error" :' + ex.getMessage() + '}');
            response.statusCode = 500;
            API_Framework.logAPIRequest(api.Id,ex.getMessage(),'', '', 'Open', 'API_AccountWebServices', '','DELETE');
        }
       
     }
    
     @HttpPatch
     global static void doPatch() {
        String accId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        NewAccountRequest wrapper = (NewAccountRequest)JSON.deserialize(requestBody, NewAccountRequest.class);
        
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(req.requestbody.tostring());
            
        List<Account> accountToUpdate = [SELECT id, Name, Phone, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode
                                         FROM Account
                                         WHERE id = :accId
                              		    ];
        
        response.addHeader('Content-Type', 'application/json');
         
        try {
            
            if(accountToUpdate.size() > 0) {
            	accountToUpdate[0].Name = wrapper.accName;
                accountToUpdate[0].Phone = wrapper.accPhone;
                accountToUpdate[0].BillingStreet = wrapper.accBillingStreet;
                accountToUpdate[0].BillingCity = wrapper.accBillingCity;
                accountToUpdate[0].BillingState = wrapper.accBillingState;
                accountToUpdate[0].BillingCountry = wrapper.accBillingCountry;
                accountToUpdate[0].BillingPostalCode = wrapper.accBillingPostalCode;
                
                update accountToUpdate;
                response.responseBody = Blob.valueOf('The Account with id ' + accId + ' has been successfully updated.');
                response.statusCode = 200;
                API_Framework.logAPIRequest(api.Id,response.responseBody.toString(),String.valueOf(response.statusCode),'','Open','API_AccountWebServices','','PATCH');
            }else {
                response.statusCode = 404;
                response.responseBody = Blob.valueOf('No account found with id: ' + accId);
                API_Framework.logAPIRequest(api.Id,response.responseBody.toString(),String.valueOf(response.statusCode),'','Open','API_AccountWebServices','','PATCH');
            }                         
        }catch(Exception ex) {
            response.responseBody = Blob.valueOf('{ "Error" :' + ex.getMessage() + '}');
            response.statusCode = 500;
            API_Framework.logAPIRequest(api.Id,ex.getMessage(),'', '', 'Open', 'API_AccountWebServices', '','PATCH');
        }
                 
     }
    
     @HttpPut    
     global static void doPut() {
        NewAccountRequest newAccount = (NewAccountRequest)JSON.deserialize(requestBody, NewAccountRequest.class);
    	
        Account newAccountRecord = new Account(Id = newAccount.accId,
            								   Name = newAccount.accName, 
                                               Phone = newAccount.accPhone,
                                               BillingStreet = newAccount.accBillingStreet,
                                               BillingCity =  newAccount.accBillingCity,
                                               BillingState =  newAccount.accBillingState,
                                               BillingCountry =  newAccount.accBillingCountry,
                                               BillingPostalCode =  newAccount.accBillingPostalCode);
         
        
        response.addHeader('Content-Type', 'application/json');
                 
        try {
            upsert newAccountRecord;
            
            if(newAccountRecord.Id == newAccount.accId) {
            	response.responseBody = Blob.valueOf('The Account record with the id ' + newAccountRecord.Id + ' has been updated.');
                response.statusCode = 200;
                API_Framework.logAPIRequest(api.Id,response.responseBody.toString(),String.valueOf(response.statusCode),'','Open','API_AccountWebServices','','PUT');
            }else {
                response.responseBody = Blob.valueOf('A new account has been created: \n' + 
                                                     '- Account Id: ' + newAccountRecord.Id + 
                                                     '\n- Account Name: ' + newAccountRecord.Name);
                response.statusCode = 201;
                API_Framework.logAPIRequest(api.Id,response.responseBody.toString(),String.valueOf(response.statusCode),'','Open','API_AccountWebServices','','PUT');
            }
                                  
        }catch(Exception ex) {
            response.responseBody = Blob.valueOf('{ "error" :' + ex.getMessage() + '}');
            response.statusCode = 500;
            API_Framework.logAPIRequest(api.Id,ex.getMessage(),'', '', 'Open', 'API_AccountWebServices', '','PUT');
        }
     }
    
     global class AccountWrapper {
        public String accName {get; set;}
        public String accPhone {get; set;}
        public String accBillingStreet {get; set;}
        public String accBillingCity {get; set;}
        public String accBillingState {get; set;}
        public String accBillingCountry {get; set;}
        public String accBillingPostalCode {get; set;}
        
    }
    
    global class NewAccountRequest{
        public String accId{get; set;}
        public String accName{get; set;}
        public String accPhone{get; set;}
        public String accBillingStreet {get; set;}
        public String accBillingCity {get; set;}
        public String accBillingState {get; set;}
        public String accBillingCountry {get; set;}
        public String accBillingPostalCode {get; set;}
	}
    
}