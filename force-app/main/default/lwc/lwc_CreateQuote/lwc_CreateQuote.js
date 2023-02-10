import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import getQuoteDetail from '@salesforce/apex/CreateQuoteController.getQuoteDetail';
import getEndDate from '@salesforce/apex/CreateQuoteController.getEndDate';
import getContact from '@salesforce/apex/CreateQuoteController.getContact';
import { NavigationMixin } from 'lightning/navigation';


export default class Lwc_CreateQuote extends NavigationMixin(LightningElement) {
    @api recordId;
    @api isLoading = false;
    @track oppRecordId;
    @track autoRenew;
    @track licenseCount;
    @track licenseType;
    @track billingTerms;
    @track startDate;
    @track endDate;
    @track createTrial;
    @track oppId;
    @track accId;
    @track email;
    @track conId;
    @track billingEmail;
    @track billingName;
    @track billToAccountId;

    @track billingAddress = {
        street: '',
        city: '',
        state: '',
        postalCode: '',
        country: '',
    };
    @track shippingAddress = {
        street: '',
        city: '',
        state: '',
        postalCode: '',
        country: '',
    };

    // not used wire as wire face issue with updated data , server side data do not reflect until page is refreshed

    connectedCallback() {
        setTimeout(() => {
            this.oppRecordId = this.recordId;
            this.fetchQuoteDetail();
        }, 4);
    }

    // used to get the Quote auto fill information on page load
    fetchQuoteDetail() {
        getQuoteDetail({ oppRecId: this.oppRecordId })
            .then(result => {
                console.log(result);
                this.autoRenew = result.autoRenew;
                this.licenseCount = result.licenseCount;
                this.licenseType = result.licenseType;
                this.billingTerms = result.billingTerms;
                this.startDate = result.startDate;
                this.endDate = result.endDate;
                this.oppId = result.oppId;
                this.accId = result.accId;
                this.conId = result.conId;
                this.email = result.email;
                this.phone = result.phone;
                this.billingName = result.billingName;
                this.billingEmail = result.billingEmail;
                this.billToAccountId = result.billToAccountId;
                this.billingAddress.street = result.billing.street;
                this.billingAddress.city = result.billing.city;
                this.billingAddress.state = result.billing.state;
                this.billingAddress.postalCode = result.billing.postalCode;
                this.billingAddress.country = result.billing.country;
                this.shippingAddress.street = result.shipping.street;
                this.shippingAddress.city = result.shipping.city;
                this.shippingAddress.state = result.shipping.state;
                this.shippingAddress.postalCode = result.shipping.postalCode;
                this.shippingAddress.country = result.shipping.country;
            })
            .catch(error => {
                console.log(error);
            });
    }

    /*renderedCallback() {
        console.log('here in rendercallback')
    }*/

    // handle change in billing field
    billingAddressInputChange(event) {
        this.billingAddress.street = event.target.street;
        this.billingAddress.city = event.target.city;
        this.billingAddress.state = event.target.province;
        this.billingAddress.postalCode = event.target.postalCode;
        this.billingAddress.country = event.target.country;
    }

    // handle change in shipping field
    shippingAddressInputChange(event) {
        this.shippingAddress.street = event.target.street;
        this.shippingAddress.city = event.target.city;
        this.shippingAddress.state = event.target.province;
        this.shippingAddress.postalCode = event.target.postalCode;
        this.shippingAddress.country = event.target.country;
    }

    // handle change in License Type field
    handleLicenseTypeChange(event) {
        this.licenseType = event.target.value;
        this.setEndDate(this.startDate, this.licenseType);
    }

    // handle change in Start Date field
    handleStartDateChange(event) {
        this.startDate = event.target.value
        this.setEndDate(this.startDate, this.licenseType);
    }

    // handle change in Contact field
    handleContactChange(event) {
        console.log(event.target.value);
        this.setContactInfo(event.target.value);
    }

    // set email field based on contact selection
    setContactInfo(conId) {
        getContact({ contactId: conId })
            .then(result => {
                //console.log(JSON.parse(JSON.stringify(result)));
                this.email = result.email;
            })
            .catch(error => {
                console.log(error);
            });
    }

    // set end Date field
    setEndDate(stDateIs, licenseTypeIs) {
        getEndDate({ stDate: stDateIs, licenseType: licenseTypeIs })
            .then(result => {
                this.endDate = result;
                console.log(result);
            })
            .catch(error => {
                console.log(error);
            });
    }

    // handle submit 
    handleSubmit(event) {
        this.isLoading = true;
        event.preventDefault();       // stop the form from submitting
        console.log('here in submit');
        const fields = event.detail.fields;
        fields.BillingStreet = this.billingAddress.street;
        fields.BillingCity = this.billingAddress.city;
        fields.BillingState = this.billingAddress.state;
        fields.BillingPostalCode = this.billingAddress.postalCode;
        fields.BillingCountry = this.billingAddress.country;
        fields.ShippingStreet = this.shippingAddress.street;
        fields.ShippingCity = this.shippingAddress.city;
        fields.ShippingState = this.shippingAddress.state;
        fields.ShippingPostalCode = this.shippingAddress.postalCode;
        fields.ShippingCountry = this.shippingAddress.country;
        fields.bill_to_account_id__c = this.billToAccountId;

        console.log(fields);
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        console.log('here in submit save');

    }

    // handle sucsess
    handleSuccess(event) {
        this.isLoading = false;
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Quote Created.',
                variant: 'success'
            })
        );
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                objectApiName: 'Quote',
                actionName: 'view'
            }
        });

    }

    handleError(event) {
        this.isLoading = false;
        const evt = new ShowToastEvent({
            title: 'Error!',
            message: event.detail.detail,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    // handle cancel button
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}