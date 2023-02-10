import { LightningElement, api } from 'lwc';

export default class Lwc_NotifyMessage extends LightningElement {
    @api message;
    @api type;
    get alertClass() {
        return 'slds-scoped-notification slds-media slds-media_center slds-theme_'+this.type;
    }
}