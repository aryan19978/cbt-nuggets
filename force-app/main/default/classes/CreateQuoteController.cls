public with sharing class CreateQuoteController {
    
    @AuraEnabled(cacheable=false)
    public static Date getEndDate(Date stDate, String licenseType){
        Date endDate;
        if(licenseType == 'Monthly'){
            endDate = stDate.addMonths(1);
        }
        if(licenseType == 'Annual'){
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
        system.debug('oppRecId'+ oppRecId);
        Opportunity oppRec = [SELECT Id, Bill_to_Account__c, Bill_to_Account__r.Name,AccountId,
                              Account.BillingStreet, Account.BillingCity, 
                              Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
                              Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, 
                              Account.ShippingPostalCode, Account.ShippingCountry,
                              License_Count__c,License_Type__c,Term__c,Start_Date__c,
                              End_Date__c,Account.Billing_Email__c
                              
                              FROM Opportunity WHERE Id =:  oppRecId];
        system.debug(oppRec);
        
        
        if(oppRec != null){
            if(oppRec.Bill_to_Account__c != null){
                Account accRec = [SELECT Id, BillingStreet, BillingCity, 
                                  BillingState, BillingPostalCode, BillingCountry
                                  FROM Account WHERE Id =:  oppRec.Bill_to_Account__c];
                
                billingInfo.street = accRec.BillingStreet;
                billingInfo.city = accRec.BillingCity;
                billingInfo.state = accRec.BillingState;
                billingInfo.postalCode = accRec.BillingPostalCode;
                billingInfo.country = accRec.BillingCountry;
            }
            else{
                billingInfo.street = oppRec.Account.BillingStreet;
                billingInfo.city = oppRec.Account.BillingCity;
                billingInfo.state = oppRec.Account.BillingState;
                billingInfo.postalCode = oppRec.Account.BillingPostalCode;
                billingInfo.country = oppRec.Account.BillingCountry;
            }
            
            shippingInfo.street = oppRec.Account.ShippingStreet;
            shippingInfo.city = oppRec.Account.ShippingCity;
            shippingInfo.state = oppRec.Account.ShippingState;
            shippingInfo.postalCode = oppRec.Account.ShippingPostalCode;
            shippingInfo.country = oppRec.Account.ShippingCountry;
            
            quoteInfo.billing = billingInfo;
            quoteInfo.shipping = shippingInfo;
            quoteInfo.billingEmail = oppRec.Account.Billing_Email__c;
            quoteInfo.licenseCount = oppRec.License_Count__c;
            quoteInfo.licenseType = oppRec.License_Type__c;
            quoteInfo.billingTerms = oppRec.Term__c;
            quoteInfo.startDate = oppRec.Start_Date__c;
            if(oppRec.License_Type__c == 'Monthly'){
                quoteInfo.endDate = oppRec.Start_Date__c.addMonths(1);
            }
            if(oppRec.License_Type__c == 'Annual'){
                quoteInfo.endDate = oppRec.Start_Date__c.addYears(1);
            }
            quoteInfo.oppId = oppRec.Id;
            quoteInfo.accId = oppRec.Account.Id;
            quoteInfo.billingName = oppRec.Bill_to_Account__r.Name;
            
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