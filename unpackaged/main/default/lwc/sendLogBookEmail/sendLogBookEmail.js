import { LightningElement, api, track } from 'lwc';
import { FlowNavigationFinishEvent } from "lightning/flowSupport";
import getLogBookDetails from '@salesforce/apex/SendLogBookEmailController.getLogBookDetails';
import usingEmailTemplate from '@salesforce/apex/SendLogBookEmailController.usingEmailTemplate';

export default class SendLogBookEmail extends LightningElement {

    @api recordId;
    @api availableActions = [];
    @track subjectList = [];
    @track selectedSubject = [];
    @track selectedIdStr;
    @track showSpinner = false;
    @track showTemplateBtn = false;
    @track disableTemplateBtn = true;

    connectedCallback(){
        this.showSpinner = true;
        getLogBookDetails({'recordId' : this.recordId})
        .then(result => {
            let subList = [];
            result.forEach(element => {
                subList.push({
                    'label' : element.Subject,
                    'value' : element.Id
                })
            });
            this.subjectList = subList;
            if(subList.length > 0){
                this.showTemplateBtn = true;
            }
        })
        .catch(error => {
            console.log(error);
        })
        .finally(() => {
            this.showSpinner = false;
        })
    }

    handleChange(event){
        this.selectedSubject = event.target.value;
        let str = '';
        this.selectedSubject.forEach(element => {
            str += element + ';';
        })
        this.selectedIdStr = str;
        this.disableTemplateBtn = this.selectedSubject.length == 0 ? true : false; 
    }


    handleEmailTemplate(){
        this.showSpinner = true;
        usingEmailTemplate({'recordIds' : this.selectedSubject})
        .then(result =>{
            if (this.availableActions.find((action) => action === "FINISH")) {
                this.dispatchEvent(new FlowNavigationFinishEvent());
            } 
        })
        .catch(error => {
            this.showSpinner = false;
            console.log(error);
        })
    }
}