import { LightningElement, api, wire } from 'lwc';
import getDateFields from '@salesforce/apex/DateFieldDayViewerController.getDateFields';

export default class DateFieldDayViewer extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api fieldSetName;

    dateFields;
    error;
    title;

    @wire(getDateFields, { objectApiName: '$objectApiName', recordId: '$recordId', fieldSetName: '$fieldSetName' })
    wiredFields({ error, data }) {
        if (data) {
            const weekday = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
            console.log('Date fields data:', data);

            this.dateFields = data
                .filter(field => field.label !== 'RecordType')
                .map(field => {
                    const dateObj = new Date(field.value.replace(' ', 'T'));
                    return {
                        label: field.label,
                        value: field.value.replace(' ', 'T'),
                        day: weekday[dateObj.getDay()]
                    };
            });

            let recordTypeField = data.find(field => field.label === 'RecordType');
            let recordType = recordTypeField ? recordTypeField.value : null;
            

            this.title = recordType ? `${recordType} Days` : `${this.objectApiName} Days`;

            console.log('Processed date fields:', this.dateFields);
            this.error = undefined;
        } else if (error) {
            console.error('Error fetching date fields:', error);
            this.error = 'Error loading date fields';
            this.dateFields = undefined;
        }
    }

}