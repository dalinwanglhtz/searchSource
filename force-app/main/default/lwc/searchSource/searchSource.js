import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getApexClass from '@salesforce/apex/SearchSourceController.getApexClass';

const actions = [
    { label: 'Show Details', name: 'showDetails'}
]

const columns = [
    { label: 'Class Name', fieldName: 'Name' },
    { type: 'action', 
        typeAttributes: {
            rowActions: actions
        }
    }
];
export default class SearchSource extends NavigationMixin(LightningElement) {
    data = [];
    columns = columns;
    err;

    handleChange(event) {
        const word = event.target.value;
        if(!word) {
            this.data = [];
            return;
        }

        getApexClass({searchKey: word})
            .then(result => {
                this.data = result;
            })
            .catch(error => {
                this.err = error;
            });
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch(action.name) {
            case 'showDetails':
                this.navigateToWebPage(row.Id);
                break;
        }
    }

    navigateToWebPage(rowId) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rowId,
                objectApiName: 'ApexClass',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
    }
}