import { LightningElement, api, wire } from 'lwc';
import getDateFields from '@salesforce/apex/DateFieldDayViewerController.getDateFields';

export default class DateFieldDayViewer extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api fieldSetName; // Deprecated - no longer used
    dateFields = [];
    error;
    title = '';

    @wire(getDateFields, { objectApiName: '$objectApiName', recordId: '$recordId' })
    wiredFields({ error, data }) {
        if (data) {
            this.dateFields = data.filter(field => field.label !== 'RecordType');
            this.setTitle(data);
            this.error = undefined;
        } else if (error) {
            console.error('Error fetching date fields:', error);
            this.error = 'Unable to load date fields. Please try again.';
            this.dateFields = [];
        }
    }

    setTitle(data) {
        const recordTypeField = data.find(field => field.label === 'RecordType');
        const recordType = recordTypeField?.value;
        this.title = recordType ? `${recordType} Days` : `${this.objectApiName} Days`;
    }

    get hasDateFields() {
        return this.dateFields && this.dateFields.length > 0;
    }

    get hasError() {
        return Boolean(this.error);
    }
}