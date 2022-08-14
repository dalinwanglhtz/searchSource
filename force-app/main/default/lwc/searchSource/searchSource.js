import { LightningElement } from 'lwc';
import getApexClass from '@salesforce/apex/SearchSourceController.getApexClass';

const columns = [
    { label: 'Class Name', fieldName: 'Name' },
    { label: 'Source', fieldName: 'Body' }
];
export default class SearchSource extends LightningElement {
    data = [];
    columns = columns;

    handleChange(event) {
        console.log('Text: ', event.target.value);
        getApexClass({searchKey: event.target.value})
            .then(result => {
                console.log('Result: ', result[0]);
                this.data = result;
            })
            .catch(error => {
                console.log('Error: ', error.body.message);
            });
    }
}