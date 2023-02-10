public with sharing class CreateQuoteController {
    
    @AuraEnabled(cacheable=false)
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
    
    @AuraEnabled(cacheable=false)
    public static ContactWrapper getContact(String contactId ){
        List<Contact> contactList = [select id,Email,Phone from Contact where Id =: contactId];
        ContactWrapper conWrapper =  new ContactWrapper();
        conWrapper.email = '';
        conWrapper.phone = '';
        if (contactList.size() > 0){
            conWrapper.email = contactList[0].Email;
            conWrapper.phone = contactList[0].Phone;
        }
        return conWrapper;
    }
    
    
    @AuraEnabled(cacheable=false)
    public static QuoteWrapper getQuoteDetail(String oppRecId){

        QuoteWrapper quoteInfo = new QuoteWrapper();
        BillingWrapper billingInfo = new BillingWrapper();
        ShippingWrapper shippingInfo = new ShippingWrapper();

        Opportunity oppRec = [SELECT Id, Bill_to_Account__c,AccountId,Account.Name,Auto_Renew__c,License_Count__c,License_Type__c,Term__c,Start_Date__c,End_Date__c,Account.Billing_Email__c,Bill_to_Account__r.Name,
                             Bill_to_Account__r.BillingStreet,Bill_to_Account__r.BillingCity,Bill_to_Account__r.BillingState,Bill_to_Account__r.BillingPostalCode,Bill_to_Account__r.BillingCountry,
                            Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
                            Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry
                            FROM Opportunity WHERE Id =:  oppRecId];
        
        
        if(oppRec != null){

            if(oppRec.Bill_to_Account__c != null){

                billingInfo.street = oppRec.Bill_to_Account__r.BillingStreet;
                billingInfo.city = oppRec.Bill_to_Account__r.BillingCity;
                billingInfo.state = oppRec.Bill_to_Account__r.BillingState;
                billingInfo.postalCode = oppRec.Bill_to_Account__r.BillingPostalCode;
                billingInfo.country = oppRec.Bill_to_Account__r.BillingCountry;

                quoteInfo.billingEmail = oppRec.Bill_to_Account__r.Billing_Email__c;
                quoteInfo.billingName = oppRec.Bill_to_Account__r.Name;
                quoteInfo.billToAccountId = oppRec.Bill_to_Account__c;
            }
            else{
                billingInfo.street = oppRec.Account.BillingStreet;
                billingInfo.city = oppRec.Account.BillingCity;
                billingInfo.state = oppRec.Account.BillingState;
                billingInfo.postalCode = oppRec.Account.BillingPostalCode;
                billingInfo.country = oppRec.Account.BillingCountry;

                quoteInfo.billingEmail = oppRec.Account.Billing_Email__c;
                quoteInfo.billingName = oppRec.Account.Name;
                quoteInfo.billToAccountId = oppRec.AccountId;

            }
            
            shippingInfo.street = oppRec.Account.ShippingStreet;
            shippingInfo.city = oppRec.Account.ShippingCity;
            shippingInfo.state = oppRec.Account.ShippingState;
            shippingInfo.postalCode = oppRec.Account.ShippingPostalCode;
            shippingInfo.country = oppRec.Account.ShippingCountry;
            
            quoteInfo.billing = billingInfo;
            quoteInfo.shipping = shippingInfo;
            quoteInfo.autoRenew = oppRec.Auto_Renew__c;
            quoteInfo.licenseCount = oppRec.License_Count__c;
            quoteInfo.licenseType = oppRec.License_Type__c;
            quoteInfo.billingTerms = oppRec.Term__c;
            quoteInfo.startDate = oppRec.Start_Date__c;

            if(oppRec.Start_Date__c != null){
                if(oppRec.License_Type__c == 'Monthly'){
                    quoteInfo.endDate = oppRec.Start_Date__c.addMonths(1);
                }
                if(oppRec.License_Type__c == 'Yearly'){
                    quoteInfo.endDate = oppRec.Start_Date__c.addYears(1);
                }
            }
            quoteInfo.oppId = oppRec.Id;
            quoteInfo.accId = oppRec.Account.Id;

            
            List<Contact> contactList = [select Id,Email,Phone from Contact 
                                         where Primary_Contact__c =: true
                                         and AccountId =: oppRec.AccountId];
            
            if (contactList.size() > 0){
                quoteInfo.conId = contactList[0].Id;
                quoteInfo.email = contactList[0].Email;
            }            
        }
        system.debug(quoteInfo);
        return quoteInfo;
    }
    
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class ContactWrapper{
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String phone{get;set;}
    }
    
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class QuoteWrapper{
        @AuraEnabled
        public BillingWrapper billing{get;set;}
        @AuraEnabled
        public ShippingWrapper shipping{get;set;}
        @AuraEnabled
        public String oppId{get;set;}
        @AuraEnabled
        public String accId{get;set;}
        @AuraEnabled
        public Boolean autoRenew{get;set;}
        @AuraEnabled
        public Decimal licenseCount{get;set;}
        @AuraEnabled
        public String licenseType{get;set;}
        @AuraEnabled
        public String billingTerms{get;set;}
        @AuraEnabled
        public Date startDate{get;set;}
        @AuraEnabled
        public Date endDate{get;set;}
        @AuraEnabled
        public String billingName{get;set;}
        @AuraEnabled
        public String billingEmail{get;set;}
        @AuraEnabled
        public String conId{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String billToAccountId{get;set;}
        
    }
    
    public class BillingWrapper{
        @AuraEnabled
        public String street{get;set;}
        @AuraEnabled
        public String city{get;set;}
        @AuraEnabled
        public String state{get;set;}
        @AuraEnabled
        public String postalCode{get;set;}
        @AuraEnabled
        public String country{get;set;}
    }
    
    public class ShippingWrapper{
        @AuraEnabled
        public String street{get;set;}
        @AuraEnabled
        public String city{get;set;}
        @AuraEnabled
        public String state{get;set;}
        @AuraEnabled
        public String postalCode{get;set;}
        @AuraEnabled
        public String country{get;set;}
    }
}