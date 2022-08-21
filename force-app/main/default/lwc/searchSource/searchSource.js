import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getApexClass from '@salesforce/apex/SearchSourceController.getApexClass';
import getPermission from '@salesforce/apex/SearchSourceController.getPermission';
import getAutoSuggest from '@salesforce/apex/SearchSourceController.getAutoSuggest';

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

const profileColumns = [
    { label: 'Profile Name', fieldName: 'Name'}
]

export default class SearchSource extends NavigationMixin(LightningElement) {
    data = [];
    columns = columns;
    profileData = [];
    profileColumns = profileColumns;
    autoSuggestList;
    err;

    handleChange(event) {
        const word = event.target.value;
        if(!word) {
            this.data = [];
            return;
        }

        getAutoSuggest({searchKey: word})
            .then(result => {
                this.autoSuggestList = result;
            })
            .catch(error => {
                this.err = error;
            });

        getApexClass({searchKey: word})
            .then(result => {
                this.data = result;
            })
            .catch(error => {
                this.err = error;
            });
    }

    setSelected(event) {
        console.log('Selected: ', event.currentTarget.dataset.name);
        const searchInput = this.template.querySelector('lightning-input');
        searchInput.value = event.currentTarget.dataset.name;
        this.autoSuggestList = null;

        getPermission({keyWord: searchInput.value})
            .then(result => {
                console.log('Profiles: ', result);
                this.profileData = result;
            })
            .catch(error => {
                console.log('Error: ', error);
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