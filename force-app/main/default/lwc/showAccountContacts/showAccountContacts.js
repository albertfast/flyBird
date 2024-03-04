import { MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import { LightningElement, wire } from 'lwc';
import Comrevo from '@salesforce/messageChannel/Comrevo__c';
import getAccountContacts from '@salesforce/apex/AccountClass.getAccountContacts';

export default class ShowAccountContacts extends LightningElement {
    subscription = null;
    title = 'Contacts';
    contacts;
    hasContacts;

    @wire(MessageContext) messageContext;
    accountId;
    accountName;

    connectedCallback() {
        this.handleSubscribe();
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleSubscribe() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, Comrevo, (parameter) => {
                this.accountId = parameter.accountId;
                this.accountName = parameter.accountName;
                this.title = this.accountName + "'s Contacts";
                this.getContacts();
            });
        }
    }

    async getContacts() {
        this.contacts = await getAccountContacts({ accountId: this.accountId });
        if (this.contacts.length > 0) {
            this.hasContacts = true;
            this.title = this.accountName + "'s Contacts";
        } else {
            this.hasContacts = false;
            this.title = "No Contacts Found!";
        }
    }
    

    handleUnsubscribe() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }
}
