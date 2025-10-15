import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';
import checkCaseDuplicates from '@salesforce/apex/CaseCloneController.checkCaseDuplicates';
import getCaseDetails from '@salesforce/apex/CaseCloneController.getCaseDetails';

export default class CaseCloneWithDuplicateCheck extends NavigationMixin(LightningElement) {
    @api recordId; // Current case record ID - automatically passed by Flow
    @api availableActions = []; // Available flow actions
    
    @track showDuplicateModal = false;
    @track duplicateCases = [];
    @track isLoading = false;
    @track currentCase = {};
    @track error;

    // Flow-specific properties
    @track isInFlow = false;
    @track flowFinished = false;

    connectedCallback() {
        // Detect if we're running in a Flow
        this.isInFlow = this.availableActions && this.availableActions.length > 0;
        
        if (this.recordId) {
            this.initializeComponent();
        } else {
            this.error = 'No case record ID provided';
        }
    }

    async initializeComponent() {
        this.isLoading = true;
        try {
            // Load case details and check duplicates in parallel
            const [caseData, duplicates] = await Promise.all([
                getCaseDetails({ caseId: this.recordId }),
                checkCaseDuplicates({ caseId: this.recordId })
            ]);

            this.currentCase = caseData;
            
            if (duplicates && duplicates.length > 0) {
                this.duplicateCases = duplicates;
                this.showDuplicateModal = true;
            } else {
                // No duplicates found, proceed directly to clone
                this.proceedToClone();
            }
        } catch (error) {
            console.error('Error during initialization:', error);
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleProceedToClone() {
        this.showDuplicateModal = false;
        this.proceedToClone();
    }

    handleCancel() {
        this.showDuplicateModal = false;
        
        if (this.isInFlow) {
            // In Flow - finish the flow
            this.finishFlow();
        } else {
            // Not in Flow - navigate back to case
            this.navigateToCase();
        }
    }

    proceedToClone() {
        console.log('proceedToClone called - isInFlow:', this.isInFlow);
        console.log('Current case data:', this.currentCase);
        
        if (this.isInFlow) {
            // In Flow - navigate to clone and finish flow
            this.navigateToClone();
            // Small delay before finishing flow to ensure navigation starts
            setTimeout(() => {
                this.finishFlow();
            }, 100);
        } else {
            // Not in Flow - direct navigation
            this.navigateToClone();
        }
    }

    navigateToClone() {
        // Build the exact clone URL format that Salesforce uses
        const baseUrl = window.location.origin;
        const recordTypeParam = this.currentCase.RecordTypeId ? 
            `&recordTypeId=${this.currentCase.RecordTypeId}` : '';
        
        const cloneUrl = `${baseUrl}/lightning/r/Case/${this.recordId}/clone?` +
                        `useRecordTypeCheck=1&count=1` +
                        `&backgroundContext=${encodeURIComponent(`/lightning/r/Case/${this.recordId}/view`)}` +
                        recordTypeParam;
        
        console.log('Navigating to clone URL:', cloneUrl);
        
        // Use window.open to navigate to the clone page
        window.open(cloneUrl, '_self');
    }

    navigateToCase() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }

    handleViewDuplicate(event) {
        event.preventDefault();
        const caseId = event.target.dataset.caseId || 
                      event.currentTarget.dataset.caseId ||
                      event.target.closest('[data-case-id]')?.dataset.caseId;
        
        if (caseId) {
            // Open in new tab to allow user to compare
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: caseId,
                    actionName: 'view'
                }
            }).then(url => {
                window.open(url, '_blank');
            });
        }
    }

    // Flow-specific methods
    finishFlow() {
        if (this.availableActions.find(action => action === 'FINISH')) {
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        }
    }

    nextFlow() {
        if (this.availableActions.find(action => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    handleError(error) {
        let message = 'An unexpected error occurred';
        
        if (error.body) {
            if (error.body.message) {
                message = error.body.message;
            } else if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                message = error.body.pageErrors[0].message;
            } else if (error.body.fieldErrors) {
                const fieldErrors = Object.values(error.body.fieldErrors).flat();
                if (fieldErrors.length > 0) {
                    message = fieldErrors[0].message;
                }
            }
        } else if (error.message) {
            message = error.message;
        }

        this.error = message;
        this.showToast('Error', message, 'error');
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    get duplicateCount() {
        return this.duplicateCases?.length || 0;
    }

    get hasDuplicates() {
        return this.duplicateCases && this.duplicateCases.length > 0;
    }

    get modalAriaLabel() {
        return `Duplicate cases found modal with ${this.duplicateCount} potential duplicates`;
    }

    get duplicateCountMessage() {
        const count = this.duplicateCount;
        return count === 1 ? 
            `We found ${count} potential duplicate case that might match the case you're trying to clone.` :
            `We found ${count} potential duplicate cases that might match the case you're trying to clone.`;
    }

    // Getters for Flow compatibility
    get isFlowEnvironment() {
        return this.isInFlow;
    }

    get showFlowButtons() {
        return this.isInFlow && !this.showDuplicateModal;
    }
}