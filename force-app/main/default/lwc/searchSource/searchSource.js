import { LightningElement } from 'lwc';
import getApexClass from '@salesforce/apex/SearchSourceController.getApexClass';

export default class SearchSource extends LightningElement {

    handleChange(event) {
        console.log('Text: ', event.target.value);
        getApexClass({searchKey: event.target.value})
            .then(result => {
                console.log('Result: ', result[0]);
            })
            .catch(error => {
                console.log('Error: ', error.body.message);
            });
    }
}