import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class redirectToRecord2 extends  NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    connectedCallback() {
        console.log('Redirect Record ' , this.recordId + ' ' + this.objectApiName);
      
        if (this.recordId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });
        } else {
            // Optional: Handle error or missing data
            console.error('Missing recordId or objectApiName');
        }
    }
}