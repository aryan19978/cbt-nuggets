global class TrialExternalCallout 
{
    public class TrialInputVariables{
        @InvocableVariable public Id OppId;
        @InvocableVariable public String calloutType;
        @InvocableVariable public String startDate;
        @InvocableVariable public String licenseCount;
        @InvocableVariable public String adminFirstName;
        @InvocableVariable public String adminLastName;
        @InvocableVariable public String adminEmail;
        @InvocableVariable public String durationOverride;
        @InvocableVariable public String licenseType;
    }
    
    public class TrialOutputVariables{
        @InvocableVariable public String result;
        @InvocableVariable public String responseType;
    }
    
    @InvocableMethod(callout=true label='TrialExternalCallout')    
    public static TrialOutputVariables[] makeTrialCallout(List<TrialInputVariables> params) {
        Id oppId = params[0].oppId;
        String calloutType = params[0].calloutType;
        String durationOverride = params[0].durationOverride;
        String adminEmail = params[0].adminEmail;
        String adminFirstName = params[0].adminFirstName;
        String adminLastName = params[0].adminLastName;
        String licenseCount = params[0].licenseCount;
        String licenseType = params[0].licenseType;
        String startDate = params[0].startDate;
        
        if(calloutType == 'CreateTrial'){
            Opportunity oppRec = [select id, AccountId, Account.Name,StageName from opportunity where id =: oppId];
            Account accRec = [Select id, name, Subscription_Id__c, Adept_Customer_Id__c,(Select id,FirstName,LastName,Email from Contacts where Primary_Contact__c  = true order by LastModifiedDate Desc) from Account where id =: oppRec.AccountId];  
            
            Map<String, String> inputData = new Map<String, String>();

            inputData.put('durationOverride', durationOverride);
            inputData.put('licenseCount', licenseCount);
            inputData.put('licenseType', licenseType);
            inputData.put('startDate', startDate);
            inputData.put('newEndDate', startDate);

            if(accRec.Contacts.size()>0){
                inputData.put('firstName', accRec.Contacts[0] != null ? accRec.Contacts[0].FirstName : '' );
                inputData.put('lastName', accRec.Contacts[0] != null ? accRec.Contacts[0].LastName : '');
                inputData.put('email', accRec.Contacts[0] != null ? accRec.Contacts[0].Email : '');
                inputData.put('conId', accRec.Contacts[0].id);
            }
            else{
                inputData.put('firstName', '' );
                inputData.put('lastName', '');
                inputData.put('email', adminEmail);
                inputData.put('conId', '');
            }

            inputData.put('accountId', oppRec.AccountId);
            inputData.put('accountName', oppRec.Account.Name);
            inputData.put('calloutType', calloutType);
            inputData.put('oppId', oppId);

            inputData.put('adminEmail', adminEmail);
            inputData.put('adminFirstName', adminFirstName);
            inputData.put('adminLastName', adminLastName);

            system.debug('input data Map ' + inputData);
            
            //make callout
            String response = TrialCalloutHandler.makeHttpCallout(inputData);
            system.debug('response' + response);
            
            List<TrialOutputVariables> results = new List<TrialOutputVariables>();
            TrialOutputVariables output = new TrialOutputVariables();
            
            //handle response and parse
            try{
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
                try{
                    
                    accRec.Subscription_Id__c = String.valueof(responseMap.get('subscriptionId'));
                    accRec.Adept_Customer_Id__c = String.valueof(responseMap.get('adeptCustomerId'));
                    update accRec;
                    // set stage of opp on trial
                    oppRec.StageName = 'Trial';
                    update oppRec;
                    
                    // create admin contact if admin email is populated
                    if(! String.isBlank(inputData.get('adminEmail'))){
                        Contact con = new Contact();
                        con.AccountId = inputData.get('accountId');
                        con.Admin__c = true;
                        con.Email = inputData.get('adminEmail');
                        if(String.isBlank(inputData.get('adminEmail'))){
                            con.Lastname = inputData.get('adminEmail'); 
                        }else{
                            con.Lastname = adminLastName;
                        }
                        insert con;
                    }
                    
                    output.result = 'Trial is created successfully.';
                    output.responseType = 'success';
                    results.add(output);
                    return results;
                }
                Catch(Exception ex){
                    output.result = ex.getMessage() + ex.getLineNumber() +ex.getCause();
                    output.responseType = 'warning';
                    results.add(output);
                    return results;
                }
            }
            Catch(Exception ex){
                HandleExceptionError.LogException('TrialExternalCallout','makeTrialCallout',oppId,ex,TrialCalloutHandler.createInputRequest(inputData),response);
                output.result = response;
                output.responseType = 'warning';
                results.add(output);
                return results;
            }
        }
        else{
            return null;
        }
    }
}