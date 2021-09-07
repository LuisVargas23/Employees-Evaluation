/***************************************************************************************************
 * copyright © 2021
 * Files    :   configForms.html
 *              configForms.js
 *              configForms.js-meta.xml
 *              
 * Purpose: Configure forms to show in the Evaluation Period.
 * 
 *
 * Helper Classes: QuestionController.cls
 *                 FormController.cls
 *                 ScoreController.cls
 *                 InstructionController.cls
 * 
 * Created By: Carlos Nuñez 29/7/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request         Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 29/7/2021                        Carlos Nunez      Release
 * 3/9/2021      Carolina Perez     Luis Vargas       Bug fixes
 ***************************************************************************************************/

import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import getQuestions from '@salesforce/apex/QuestionController.getQuestions2';
import getCategoryPicklistValues from '@salesforce/apex/QuestionController.getCategoryPicklistValues';
import getAvailableInPicklistValues from '@salesforce/apex/QuestionController.getAvailableInPicklistValues';
import FORMANAGER_FIELD from '@salesforce/schema/Question__c.For_Manager__c';
import FOR_FIELD from '@salesforce/schema/Question__c.For__c';
import POINTS_FIELD from '@salesforce/schema/Question__c.Points__c';
import ID_FIELD from '@salesforce/schema/Question__c.Id';
import getEmployeeInstructions from '@salesforce/apex/InstructionController.getEmployeeInstructions';
import setEmployeeInstructions from '@salesforce/apex/InstructionController.setEmployeeInstructions';
import getManagerInstructions from '@salesforce/apex/InstructionController.getManagerInstructions';
import setManagerInstructions from '@salesforce/apex/InstructionController.setManagerInstructions';
import getUserRole from '@salesforce/apex/FormController.getUserRole';
import USER_ID from '@salesforce/user/Id';

export default class ConfigForms extends LightningElement {
    userRole;
    visible;
    loading;
    questions;
    picklist;
    picklist2;
    picklist2Old;

    visibleQuestions;
    visibleQuestions2 = [];
    visibleQuestionsHold;
    @track toggleSave = 'Save';
    /** Wired Apex result so it can be refreshed programmatically */
    wiredQuestionsResult;
    wiredEIResult;
    ei;
    counter = -1;
    ccat = 0;
    ccat2 = 0;
    ccat3 = 0;
    repeatconstant = 2;
    selectedGroups = [];
    valuesUpdated = false;
    afterWarning = false;


    @track SaveFlag = false;
    @track showSaveWarning = false;


    // Get employee instructions
    @wire(getEmployeeInstructions)
    eiHandler(result) {
        this.wiredIEResult = result;
        if (result.data) {
            this.ei = result.data
        } else if (result.error) {
            this.error = result.error;
            this.ei = undefined;
        }
    }

    // Get manager instructions
    @wire(getManagerInstructions)
    miHandler(result) {
        this.wiredMIResult = result;
        if (result.data) {
            this.mi = result.data;
        } else if (result.error) {
            this.error = result.error;
            this.mi = undefined;
        }
    }
   
    // Get questions
    @wire(getQuestions)
    questionsHandler(result) {
        this.wiredQuestionsResult = result;
        if (result.data) {
            this.questions = result.data
        } else if (result.error) {
            this.error = result.error;
            this.questions = undefined;
        }
    }

    // Get category picklist values
    @wire(getCategoryPicklistValues)
    picklistHandler2(result2) {
        this.picklistResult2 = result2;
        if (result2.data) {
            this.picklist2 = result2.data
        } else if (result2.error) {
            this.error2 = result2.error;
            this.picklist2 = undefined;
        }
    }

    // Get available in picklist values
    @wire(getAvailableInPicklistValues)
    picklistHandler(result) {
        this.picklistResult = result;
        if (result.data) {
            this.picklist = result.data
        } else if (result.error) {
            this.error = result.error;
            this.picklist = undefined;
        }
    }

    // Populate availiable in combobox
    get options() {
        return this.ComputePicklistValues(this.picklist);
    }

    value = ''
    ComputePicklistValues(picklistValues){
        if(picklistValues){
            if(this.counter<this.visibleQuestions.length-1){
                this.counter++
            }
            else{
                this.counter = 0;
            }
            let options = picklistValues.reduce((previousValue, currentValue,index)=>{
                if(this.visibleQuestions[this.counter].For__c){
                    if(this.visibleQuestions[this.counter].For__c.includes(currentValue)){
                        previousValue.push({
                            label : currentValue,
                            value : currentValue,
                            selected : true
                        })
                    }
                    else{
                        previousValue.push({
                            label : currentValue,
                            value : currentValue,
                            selected : false
                        })
                    }
                }
                else{
                    previousValue.push({
                        label : currentValue,
                        value : currentValue,
                        selected : false
                    })
                }
                return previousValue
            },[ ])
                  
        return options
        }
    }

    // Update records on the current page
    updateQuestions(event) {

        //map the data to the fields
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if(allValid){
            this.toggleSave = 'Saving';
            let counter = 0;
            if(!this.valuesUpdated){
                for(let i = 0; i<this.visibleQuestions.length; i++){
                    //console.log(JSON.parse(JSON.stringify(this.template.querySelectorAll('c-mutli-select-picklist')[i].vals())).join(';'));
                    this.selectedGroups[i] = JSON.parse(JSON.stringify(this.template.querySelectorAll('c-mutli-select-picklist')[i].vals())).join(';');
                }
            }
            this.valuesUpdated = false;
            for(let i=0;i<this.visibleQuestions.length;i++){
                //console.log(i);

                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.visibleQuestions[i].Id;
                fields[POINTS_FIELD.fieldApiName] = this.template.querySelectorAll("[data-field='Points__c']")[i].value;
                fields[FORMANAGER_FIELD.fieldApiName] = this.template.querySelectorAll("[data-field='For_Manager__c']")[i].checked;
                //console.log("value: ", i);
                //console.log(this.selectedGroups[i]);
                //console.log(this.visibleQuestions[i].For__c);
                fields[FOR_FIELD.fieldApiName] = this.selectedGroups[i];
                
                //Create a config object that had info about fields. 
                const recordInput = {
                    fields: fields
                };

                //Invoke the method updateRecord()
                updateRecord(recordInput).then(() => {
                    counter++
                    if(counter == this.visibleQuestions.length){
                        setTimeout(() => {
                            this.toggleSave = 'Save';
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Forms updated',
                                    variant: 'success'
                                })
                            );
                            this.hideSaveQuestionsModal()
                            return refreshApex(this.wiredQuestionsResult, this.picklistResult);
                        }, 50); 
                    } 
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error updating forms',
                            variant: 'error'
                        })
                    )
                    this.toggleSave = 'Save';
                });
            }
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please check the score values',
                    variant: 'error'
                })
            )
        }
        setEmployeeInstructions({ s: this.template.querySelectorAll("[data-field='EmployeeInstructions']")[0].value })
        {
        }
        setManagerInstructions({ s: this.template.querySelectorAll("[data-field='ManagerInstructions']")[0].value })
        {
        }
    }

   updateQuestionHandler(event){
        this.counter = -1;
        if(this.valuesready){
            for(let i = 0; i < this.visibleQuestions.length; i++){
                let values = JSON.parse(JSON.stringify(this.template.querySelectorAll('c-mutli-select-picklist')[i].vals())).join(';');
                if(this.selectedGroups[i] != values){
                    //console.log("Updating Values");
                    this.selectedGroups[i] = values;
                    this.saveFlag = true;
                    this.valuesUpdated = true;
                }
            }
        }
      //  console.log(this.saveFlag)
        if(this.saveFlag){
            this.showSaveWarning = true;
        }
        else{
            //console.log("Pretty sure this runs first");
            this.visibleQuestions = [...event.detail.records];
            this.visibleQuestions2 = [];
            for(let j = 0; j < this.picklist2.length; j++){
                let qbycat = [];
                for(let i = 0; i < this.visibleQuestions.length; i++){
                    if(this.visibleQuestions[i].Category__c == this.picklist2[j]){
                        qbycat.push(this.visibleQuestions[i]);
                    }
                }
                this.visibleQuestions2.push(qbycat);
            }
        }
        this.visibleQuestionsHold = [...event.detail.records];
        this.picklist2Old = this.picklist2;
    }

    
    //Get Questions By Cat
    get questionsbycat(){
        let r = this.ccat;
        if(this.ccat3 < 8)
        {
            this.ccat3++;
        }
        else{
            if(this.ccat<this.picklist2.length-1 || this.ccat2<this.repeatconstant){
                if(this.ccat2<this.repeatconstant){
                    
                    this.ccat2++;
                }
                else{
                    this.ccat2 = 0;
                    this.ccat++;
                }
            }
            else{
                this.ccat = 0;
                this.ccat2 = 0;
            }
        }
        //console.log(r);
       // console.log(this.visibleQuestions2[r]);
        if(this.visibleQuestions2[r]){
            if(this.visibleQuestions2[r].length == 0){
                this.repeatconstant = 1;
                return undefined;
            }
            else{
                this.repeatconstant = 2;
            }
        }
        //console.log(this.ccat, " ", this.ccat2);
        if(this.ccat3 >= 8)
        {
            refreshApex(this.wiredQuestionsResult, this.picklistResult);
            return this.visibleQuestions2[r];

        }
    }

    stopLoading(timeoutValue) {
        setTimeout(() => {
        this.loading = false;
        }, timeoutValue);
    }
        
    connectedCallback(){
        console.log("connected callback")
        this.getUserRoleToValidateAccess();   
        this.loading = true;
        this.stopLoading(1000);
        this.valuesready = false;
        refreshApex(this.wiredQuestionsResult, this.picklistResult);
        //refreshApex(this.wiredQuestionsResult)
        
    }

    disconnectedCallback(){
        console.log("dosconnected callback")

        refreshApex(this.wiredQuestionsResult, this.picklistResult);
    }

    handleEditChange(event) {
        this.value = event.detail.value;
        this.saveFlag = true
    }

    hideSaveQuestionsModal(){
        this.counter = -1;
        this.showSaveWarning = false;
        this.saveFlag = false;
        this.visibleQuestions = this.visibleQuestionsHold;
        this.picklist2 = this.picklist2Old;
        this.visibleQuestions2 = [];
        for(let j = 0; j < this.picklist2.length; j++){
            let qbycat = [];
            for(let i = 0; i < this.visibleQuestions.length; i++){
                if(this.visibleQuestions[i].Category__c == this.picklist2[j]){
                    qbycat.push(this.visibleQuestions[i]);
                }
            }
            this.visibleQuestions2.push(qbycat);
        }
    
        //this.afterWarning = true;
       return refreshApex(this.wiredQuestionsResult, this.picklistResult);
       //return refreshApex(this.wiredQuestionsResult);


    }

    renderedCallback(){
        
        if(!this.saveFlag){
            if(this.visibleQuestions){
                /*if(this.afterWarning){
                    refreshApex(this.wiredQuestionsResult, this.picklistResult);
                    this.afterWarning = false;
                    console.log(this.counter);
                }*/
                if(this.visibleQuestions.length == this.template.querySelectorAll('c-mutli-select-picklist').length){
                    console.log("RenderedCallBack");

                    console.log(this.visibleQuestions.length);

                    for(let i = 0; i<this.visibleQuestions.length; i++){
                        console.log(JSON.parse(JSON.stringify(this.template.querySelectorAll('c-mutli-select-picklist')[i].vals())).join(';'));
                        this.selectedGroups[i] = JSON.parse(JSON.stringify(this.template.querySelectorAll('c-mutli-select-picklist')[i].vals())).join(';');
                    }
                    this.valuesready = true;
                }
                //console.log("Length of visible questions: ", this.visibleQuestions.length);
                //console.log("Length of querySelectorAll: ", this.template.querySelectorAll('c-mutli-select-picklist').length);
            }
        }
    }

    getUserRoleToValidateAccess() {
        getUserRole({userId: USER_ID})
          .then(result => {
            if(result){
              this.userRole =  result.UserRole.Name;
              if(this.userRole == 'HHRR' || this.userRole == 'HR'){
                this.visible = true;
              }
            }
            else{
              console.log("we were unable to load the timezone");     
            }
          }) 
          .catch(error => {
            this.userRole='N/A';  

            console.log(error.message);
          });
      }

   
}