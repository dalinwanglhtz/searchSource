import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getApexClass from '@salesforce/apex/SearchSourceController.getApexClass';
import getProfiles from '@salesforce/apex/SearchSourceController.getProfiles';
import getAutoSuggest from '@salesforce/apex/SearchSourceController.getAutoSuggest';
import getPermissionSets from '@salesforce/apex/SearchSourceController.getPermissionSets';

const actions = [
    { label: 'Show Details', name: 'showDetails'}
];

const columns = [
    { label: 'Class Name', fieldName: 'Name' },
    { 
        type: 'action', 
        typeAttributes: {
            rowActions: actions
        }
    }
];

const profileColumns = [
    { label: 'Profile Name', fieldName: 'Name'},
    { 
        type: 'action',
        typeAttributes: {
            rowActions: actions
        }
    }
];

const permissionSetColumns = [
    { label: 'Permission Set Name', fieldName: 'Label'},
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions
        }
    }
];

export default class SearchSource extends NavigationMixin(LightningElement) {
    data;
    columns = columns;
    profileData;
    profileColumns = profileColumns;
    permissionSetData;
    permissionSetColumns = permissionSetColumns;
    autoSuggestList;
    err;

    handleChange(event) {
        const word = event.target.value;
        if(!word) {
            console.log('Word cleared');
            this.data = null;
            this.profileData = null;
            this.permissionSetData = null;
            this.autoSuggestList = null;
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
        const searchInput = this.template.querySelector('lightning-input');
        searchInput.value = event.currentTarget.dataset.name;
        this.autoSuggestList = null;

        getProfiles({keyWord: searchInput.value})
            .then(result => {
                this.profileData = result;
            })
            .catch(error => {
                this.err = error;
            });
        getPermissionSets({keyWord: searchInput.value})
            .then(result => {
                this.permissionSetData = result;
            })
            .catch(error => {
                this.err = error;
            });
    }

    clearAutoSuggest() {
        this.autoSuggestList = null;
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

    handleClear() {
        this.data = null;
        this.profileData = null;
        this.permissionSetData = null;
        this.autoSuggestList = null;
    }

    navigateToWebPage(rowId) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rowId,
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
    }
}