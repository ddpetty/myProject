import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { refreshApex } from '@salesforce/apex';
import getAssetLiabilityList from '@salesforce/apex/GetAssetLiabilityRecords.getAssetLiabilityList';
import calculateAssetsLiabilities from '@salesforce/apex/GetAssetLiabilityRecords.calculateAssetsLiabilities';
import deleteAssetLiabilityRecords from '@salesforce/apex/GetAssetLiabilityRecords.deleteAssetLiabilityRecords';

// Row actions
const actions = [
  { label: 'Delete', name: 'delete' }
];

const columns = [
  { label: 'Name', fieldName: 'Name', sortable: "true" },
  { label: 'Type', fieldName: 'Type__c', type: 'text', sortable: "true" },
  { label: 'Balance', fieldName: 'Balance__c', type: 'currency', sortable: "true", cellAttributes: { alignment: 'left' }},
  {
    type: 'action',
    typeAttributes: { rowActions: actions },
  },
];


export default class AssetLiabilityDataTable extends LightningElement {
  columns = columns;
  refreshTable;
  records = [];
  error;

  @wire(calculateAssetsLiabilities) summary;

  @wire(getAssetLiabilityList)
  wiredRecords({ error, data }) {
    this.refreshTable = data;

    if (data) {
      this.records = data;
      this.error = undefined;
    } else if (error) {
      this.refreshTable = [];
      console.log('Error: '+ JSON.stringify(error));
      this.error = error;
      this.records = undefined;
    }
  }

  // @wire(calculateAssetsLiabilities)
  // wiredCalculations({ error, results }) {
  //   if (results) {
  //     this.summary = results;
  //     this.netWorth = this.summary.netWorth;
  //     this.assetsTotal = this.summary.assetsTotal;
  //     this.liabilitiesTotal = this.summary.liabilitiesTotal;
  //     this.error = undefined;
  //   } else if (error) {
  //     console.log('Error: '+ JSON.stringify(error));
  //     this.error = error;
  //     this.records = undefined;
  //   }
  // }
  
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    switch (actionName) {
      case 'delete':
        this.deleteAssetLiabilityRecs(row);
        break;
      default:
    }
  }

  // Delete record from database
  deleteAssetLiabilityRecs(row) {
    deleteAssetLiabilityRecords({ recordIds: row.Id })
      .then(data => {
        this.showToast('Success!', 'Record was deleted.', 'success');
        //Clear selected rows
        this.template.querySelector('lightning-datatable').selectedRows = [];
        // Refresh table
        return refreshApex(this.refreshTable);

      }).catch(error => {
        console.log('Error: '+ error);
        this.showToast('Unable to delete record. Please contact your System Administrator.', error.message, 'error');
      });
  }

}