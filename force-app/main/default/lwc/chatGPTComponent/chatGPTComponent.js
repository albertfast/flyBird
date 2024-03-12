import { LightningElement, track } from 'lwc';
import generateResponseFromGPT from '@salesforce/apex/ChatGPTClass.generateResponseFromGPT';

export default class ChatGPTComponent extends LightningElement {
    @track queryText = '';
    @track response = '';

    handleInputChange(event) {
        this.queryText = event.target.value;
    }

    search() {
        generateResponseFromGPT({ queryText: this.queryText })
            .then(result => {
                this.response = result;
            })
            .catch(error => {
                console.error('Error fetching response:', error);
            });
    }
}
