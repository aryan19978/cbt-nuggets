import { LightningElement, wire, track,api } from 'lwc';
import fetchWrapperData from '@salesforce/apex/GlobalDeleteController.fetchWrapperData';
import deleteSelectedRows from '@salesforce/apex/GlobalDeleteController.deleteSelectedRows';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';

const columns = [
    {
        label: 'Name',
        fieldName: 'name',
        type: 'text',
        sortable: true
    },
    {
        label: 'Type',
        fieldName: 'objType',
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
    @api selectedIdList=[];

    @wire(fetchWrapperData)
    wiredAccounts({error, data}) {
        if (data) {
            console.log(data);
            this.data = data;
        } else if (error) {
            this.error = error;
        }
    }

    getSelectedIdAction(event){
        const selectedRows = event.detail.selectedRows;
        //window.console.log('selectedRows# ' + JSON.stringify(selectedRows));
        this.selectedIdList=[];
        for (let i = 0; i<selectedRows.length; i++){
            this.selectedIdList.push(selectedRows[i].id);
        }
        window.console.log('selectedRows# ' + this.selectedIdList);
    }
  
   
    deleteRowAction(){
        console.log(this.selectedIdList);
        deleteSelectedRows({recIdList:this.selectedIdList})
        .then(()=>{
            this.template.querySelector('lightning-datatable').selectedRows=[];
 
            const toastEvent = new ShowToastEvent({
                title:'Success!',
                message:'Record deleted successfully',
                variant:'success'
              });
              this.dispatchEvent(toastEvent);
 
            return refreshApex(this.wireContact);
        })
        .catch(error =>{
            this.errorMsg =error;
            window.console.log('unable to delete the record due to ' + JSON.stringify(this.errorMsg));
        });
    }
}