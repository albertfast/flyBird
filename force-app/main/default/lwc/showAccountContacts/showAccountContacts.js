import { MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import { LightningElement, api, wire } from 'lwc';
import Comrevo from '@salesforce/messageChannel/Comrevo__c';
import getAccountContacts from '@salesforce/apex/AccountClass.getAccountContacts';
import LightningConfirm from 'lightning/confirm';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class ShowAccountContacts extends LightningElement {
    subscription = null;
    title='Contacts';
    contacts;
    hasContacts;
    isAccountSelected=false;
    isAddContactClicked=false;
    isEditClicked=false;
    @api recordId;
   
    editableContactId;    

    @wire (MessageContext) messageContext;
    accountId;
    accountName;
    connectedCallback()
    {
        this.handleSubscribe();
    }

    disconnectedCallback()
    {
        this.handleUnsubscribe();
    }
    handleSubscribe()
    {
        if (!this.subscription) {
            this.subscription=subscribe(this.messageContext,Comrevo,
                (parameter)=>
                {
                    this.accountId=parameter.accountId;
                    this.accountName=parameter.accountName;
                    this.title=this.accountName+"'s Contacts";
                    this.getContacts();
                }
                );
        }
    }

    async getContacts()
    {
      this.contacts = await getAccountContacts({accountId: this.accountId});
      this.hasContacts = this.contacts.length>0?true:false;
      this.isAccountSelected=true;
    }
    handleUnsubscribe() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    handleAddContact(event)
    {
        this.isAddContactClicked=true;

    }

    handleAddContactCancel(event)
    {
        this.isAddContactClicked=false;
    }

    handleEdit(event)
    {
        this.isEditClicked=true;
        this.editableContactId= event.target.dataset.contactId;
    }

    handleEditCancel(event)
    {
        this.isEditClicked=false;
    }

    handleSuccess(event)
    {
        this.isEditClicked=false;
        this.isAddContactClicked=false;
        this.getContacts();
    }

    async handleDelete(event) {
        this.editableContactId = event.target.dataset.contactId; // Assigning correct value
        const result = await LightningConfirm.open({
            message: 'Are you sure want to delete contact?',
            variant: 'headerless',
            label: 'this is the aria-label value',
        });
    
        if (result) {
            try {
                // Using this.editableContactId here
                await deleteRecord(this.editableContactId);
                this.getContacts();
                this.showToast();
            } catch(error) {
                console.error('Error deleting record: ', error);
            }
        }
    }
    

    showToast() {
        const event = new ShowToastEvent({
            title: 'Delete Contact',
            message:
                'The Contact Succesfully Deleted!',
        });
        this.dispatchEvent(event);
    }
}