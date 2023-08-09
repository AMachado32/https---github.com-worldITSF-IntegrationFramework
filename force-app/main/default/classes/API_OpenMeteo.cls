public class API_OpenMeteo {
    public static void getWeather(API__c api, ID  objectId){
        List<String> errorList = new List<String>();
        Map<String, Object> response = new Map<String, Object>();
        
        List<Account> accList = [SELECT ID, Name, Description
                                 FROM Account WHERE ID = :objectId LIMIT 1];
        if (accList.size() < 1){
            errorList.add('No Account.');
            API_Framework.logAPIRequest(api.id, '- no data -', '-0', 'No Account.', 'Open', 'API_OpenMEteo', (String)objectId, '-no data-');
        }
        else{
            Account acc = accList.get(0);
            
        	response = API_Framework.outboundRestCall(api.Id, api.Credential__c, api.HTTP_Method__c, api.HTTP_Content_Type__c, null);
            system.debug(response);
            
            Decimal input = (Decimal)response.get('elevation');
            String temperature = (String)response.get('temperature_2m');
            acc.Description = 'Elevation: ' + String.valueOf(input) + '\nTemperature: ' + temperature;
            
            upsert acc;
            
        }
    }
}