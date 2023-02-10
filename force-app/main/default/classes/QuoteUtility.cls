public class QuoteUtility {
    public static Quote createQuote(String oppRecId){
        Quote quoteRec = new Quote(); 
        
        Opportunity oppRec = [SELECT Id, Bill_to_Account__c,AccountId,Account.Name,License_Count__c,License_Type__c,Term__c,Start_Date__c,End_Date__c,Account.Billing_Email__c,Bill_to_Account__r.Name,
                             Bill_to_Account__r.BillingStreet,Bill_to_Account__r.BillingCity,Bill_to_Account__r.BillingState,Bill_to_Account__r.BillingPostalCode,Bill_to_Account__r.BillingCountry,
                            Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
                            Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry
                            FROM Opportunity WHERE Id =:  oppRecId];
           
        if(oppRec != null){

            if(oppRec.Bill_to_Account__c != null){
                quoteRec.BillingStreet                  = oppRec.Bill_to_Account__r.BillingStreet;
                quoteRec.BillingCity 					= oppRec.Bill_to_Account__r.BillingCity;
                quoteRec.BillingState                   = oppRec.Bill_to_Account__r.BillingState;
                quoteRec.BillingPostalCode              = oppRec.Bill_to_Account__r.BillingPostalCode;
                quoteRec.BillingCountry                 = oppRec.Bill_to_Account__r.BillingCountry;

                quoteRec.Billing_Email__c               = oppRec.Bill_to_Account__r.Billing_Email__c;
                quoteRec.BillingName                    = oppRec.Bill_to_Account__r.Name;
                //quoteRec.bill_to_account_id__c          = oppRec.Bill_to_Account__c;
            }
            else{
                quoteRec.BillingStreet                  = oppRec.Account.BillingStreet;
                quoteRec.BillingCity                    = oppRec.Account.BillingCity;
                quoteRec.BillingState                   = oppRec.Account.BillingState;
                quoteRec.BillingPostalCode              = oppRec.Account.BillingPostalCode;
                quoteRec.BillingCountry                 = oppRec.Account.BillingCountry;

                quoteRec.Billing_Email__c               = oppRec.Account.Billing_Email__c;
                quoteRec.billingName                    = oppRec.Account.Name;
                //quoteRec.bill_to_account_id__c          = oppRec.AccountId;

            }
            
            quoteRec.ShippingStreet                     = oppRec.Account.ShippingStreet;
            quoteRec.ShippingCity                       = oppRec.Account.ShippingCity;
            quoteRec.ShippingState                      = oppRec.Account.ShippingState;
            quoteRec.ShippingPostalCode                 = oppRec.Account.ShippingPostalCode;
            quoteRec.Shippingcountry                    = oppRec.Account.ShippingCountry;
            
            quoteRec.License_Count__c                   = oppRec.License_Count__c;
            quoteRec.License_Type__c                    = oppRec.License_Type__c;
            quoteRec.Billing_Terms__c                   = oppRec.Term__c;
            quoteRec.Start_Date__c                      = oppRec.Start_Date__c;
			quoteRec.End_Date__c                        = oppRec.End_Date__c;
            quoteRec.OpportunityId 						= oppRec.Id;
            //quoteRec.AccountId                        = oppRec.Account.Id;// field not writeble
            
            List<Contact> contactList = [select Id,Email,Phone from Contact 
                                         where Primary_Contact__c =: true
                                         and AccountId =: oppRec.AccountId];
            
            if (contactList.size() > 0){
                quoteRec.ContactId 						= contactList[0].Id;
                quoteRec.Email 							= contactList[0].Email;
            }
        }
        return quoteRec;
    }
    
    public Static Quote CloneQuote(String quoteId){
        Quote originalQuote = [Select id,BillingStreet , BillingCity , BillingState,
                         BillingPostalCode,BillingCountry,Billing_Email__c,
                         BillingName,ShippingStreet,
                         ShippingCity ,ShippingState,ShippingPostalCode ,
                         Shippingcountry ,License_Count__c,License_Type__c ,
                         Billing_Terms__c,Start_Date__c,End_Date__c,
                         OpportunityId,ContactId ,Email FROM Quote where id =:quoteId ];
        Quote clonedQuote = originalQuote.clone(false, true, false, false);
        return clonedQuote;
    }
    
    public static Date getEndDate(Date stDate, String licenseType){
        Date endDate;
        if(licenseType == 'Monthly'){
            endDate = stDate.addMonths(1);
        }
        if(licenseType == 'Yearly'){
            endDate = stDate.addYears(1);
        }
        return endDate;
        
    }
}