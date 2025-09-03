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
            this.dateFields = data.filter(field => field.label !== 'RecordType').map(field => {
                // Keep raw database values as strings and add day name
                if (field.value) {
                    const fieldValue = field.value;
                    let dateString = fieldValue;
                    
                    // For DateTime fields, extract just the date part as string
                    if (field.isDateTime === 'true' && fieldValue.includes('T')) {
                        // DateTime format: "2024-01-15T10:30:00.000Z" -> "2024-01-15"
                        dateString = fieldValue.split('T')[0];
                    }
                    
                    // Create date instance with US timezone and format as mm/dd/yyyy
                    let dayName = '';
                    let formattedDate = dateString;
                    
                    if (dateString && dateString.includes('-')) {
                        try {
                            const [year, month, day] = dateString.split('-');
                            // Create date object with US timezone (EST/EDT)
                            const dateObj = new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
                            
                            // Get day name with US timezone
                            dayName = dateObj.toLocaleDateString('en-US', { 
                                weekday: 'long',
                                timeZone: 'America/New_York'
                            });
                            
                            // Format date as mm/dd/yyyy
                            formattedDate = `${month.padStart(2, '0')}/${day.padStart(2, '0')}/${year}`;
                            
                        } catch (error) {
                            console.warn('Could not parse date:', dateString);
                            // Fallback: try to convert yyyy-mm-dd to mm/dd/yyyy manually
                            const [year, month, day] = dateString.split('-');
                            formattedDate = `${month}/${day}/${year}`;
                        }
                    }
                    
                    return {
                        ...field,
                        value: formattedDate,
                        dayName: dayName
                    };
                }
                // Return field as-is if no value
                return field;
            });
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