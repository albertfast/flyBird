import { LightningElement, api, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountClass.getAccounts';
import { MessageContext, publish } from 'lightning/messageService';
import Comrevo from '@salesforce/messageChannel/Comrevo__c';

export default class AccountChild2 extends LightningElement {

  @api searchTextChild2;

  @wire (MessageContext) messageContext;
  columns = [
    {label:'Account Id', fieldName: 'Id'},
    {label:'Account Name', fieldName: 'Name'},
    {label:'Action', fieldName:'Action', type:'button', typeAttributes: 
    {
        label : 'View Contacts',
        value : 'view_contacts'
    }
    }
  ]
  // [] defines array
  // {} defines object 
  rows= [
    {Id:'58asd56dj', Name: 'Albert Goal'},
    {Id:'42asd56dj', Name: 'Jack Lucky'},
    {Id:'752ag41dj', Name: 'Bora Olur'},
    {Id:'62vdsfvdj', Name: 'Deniz Baskasi'}
  ]
  currentId;
  currentName;
  handleRowAction(event){
    if (event.detail.action.value == 'view_contacts') {
        this.currentId = event.detail.row.Id;
        this.currentName = event.detail.row.Name;

        const payload = 
        {
          accountId : event.detail.row.Id,
          accountName : event.detail.row.Name
        };

        publish(this.messageContext,Comrevo,payload);
        
    }
    
  }
  @wire(getAccounts, {searchTextClass:'$searchTextChild2'}) accountRecords;
}


