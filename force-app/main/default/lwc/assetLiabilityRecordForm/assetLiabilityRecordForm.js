import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import NAME_FIELD from '@salesforce/schema/Asset_Liability__c.Name';
import TYPE_FIELD from '@salesforce/schema/Asset_Liability__c.Type__c';
import BALANCE_FIELD from '@salesforce/schema/Asset_Liability__c.Balance__c';

export default class AssetLiabilityRecordForm extends LightningElement {
    @api recordId;

    fields = [NAME_FIELD, BALANCE_FIELD, TYPE_FIELD];

    //Duplicate Asset/Liability creation is handled by  config Asset/Liability Duplicate Rule 
    
    handleSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: "Your record has been created! Refresh the page.",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }
}