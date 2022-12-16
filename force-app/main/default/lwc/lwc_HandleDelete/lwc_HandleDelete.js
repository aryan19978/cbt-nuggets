import { LightningElement, wire, track } from 'lwc';
import fetchWrapperData from '@salesforce/apex/GlobalDeleteController.fetchWrapperData';

const columns = [
    {
        label: 'Name',
        fieldName: 'name',
        type: 'text',
        sortable: true
    }
];
export default class Lwc_HandleDelete extends LightningElement {
    handleEmailInput() {
        var flag = true;
        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        let email = this.template.querySelector('[data-id="txtEmailAddress"]');
        let emailVal = email.value;
        if (emailVal.match(emailRegex)) {
            email.setCustomValidity("");

        } else {
            flag = false;
            email.setCustomValidity("Please enter valid email");
        }
        email.reportValidity();
        return flag;
    }

    @track columns = columns
    @track error;
    @track data ;
 
    @wire(fetchWrapperData)
    wiredAccounts({error, data}) {
        if (data) {
            console.log(data);
            this.data = data;
        } else if (error) {
            this.error = error;
        }
    }
}