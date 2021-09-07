/***************************************************************************************************
 * copyright © 2021
 * Files    :   questionPool.html
 *              questionPool.js
 *              questionPool.js-meta.xml
 *              
 * Purpose: Create, read, update, and delete (CRUD) questions in the Question Pool (Question__c).
 * 
 * Child Components: pagination
 *                   createQuestion
 *
 * Helper Classes: QuestionController.cls
 *                 FormController.cls
 * 
 * Created By: Luis Vargas on 7/29/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 7/29/2021                    Luis Vargas      Initial Creation
 ***************************************************************************************************/

import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import getQuestions from '@salesforce/apex/QuestionController.getQuestions';
import getCategoryPicklistValues from '@salesforce/apex/QuestionController.getCategoryPicklistValues';
import QUESTION_FIELD from '@salesforce/schema/Question__c.Question_Text__c';
import ACTIVATE_FIELD from '@salesforce/schema/Question__c.Available_in_Pool__c';
import CATEGORY_FIELD from '@salesforce/schema/Question__c.Category__c';
import ID_FIELD from '@salesforce/schema/Question__c.Id';
import USER_ID from '@salesforce/user/Id';
import getUserRole from '@salesforce/apex/FormController.getUserRole';

export default class questionPool extends NavigationMixin(LightningElement) {
    recordId
    picklist;
    visibleQuestions;
    visibleQuestionsHold;
    loading;
    userRole;
    visible;
    memoryPage=1;
    @track boolgotochild=true
    @track currentPage=1
    @track questions;
    @track showCreateQuestion = false;
    @track showDeleteWarning = false
    @track showSaveWarning = false
    @track saveFlag = false
    @track fromDeleteFlag = false
    @track fromSaveFlag = false
    @track categoryPicklist;
    @track toggleSave = 'Save';
   
    /** Wired Apex result so it can be refreshed programmatically */
     wiredQuestionsResult;
   
    // Get questions from the Question__c Object
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

    picklistHandler() {
        getCategoryPicklistValues()
          .then(result => {
            if(result){
                this.picklist = result;
                this.categoryPicklist = this.ComputePicklistValues(this.picklist)
            }
            else{
                this.error = result;
                this.picklist = undefined;
            }
          }) 
          .catch(error => {
            console.log(error.message);
          });
      }

    //Populate category combobox
    value = ''
    ComputePicklistValues(picklistValues){
        if(picklistValues){
        let options = picklistValues.reduce((previousValue, currentValue,index)=>{
            previousValue.push({
                label : currentValue,
                value : currentValue
            })
            return previousValue
            },[ ])         
        return options
        }
     }
    get options() {
        return this.categoryPicklist;         
    }

    //Hide Create Question popup and display fresh data in the form
    hideCreateQuestionModal(event) {
        this.showCreateQuestion = false; 
        this.handlebutton();
        refreshApex(this.wiredQuestionsResult );
        return;
        //return this.getAllQuestions();
      }

      hideCreateQuestionModalWithoutLoad(){
          this.showCreateQuestion = false; 
        return refreshApex(this.wiredQuestionsResult );
        

      }
  
    //Show Create Question popup and check if there are changes before show it
    showCreateQuestionModal() {
    if(this.saveFlag){
        this.showSaveWarning = true
        this.fromSaveFlag = true;
    }
    else{
         this.showCreateQuestion = true;

        }
    }

    // Navigation to Home 
    navigateToHome(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }

  
    //Know if a change exists in the inputs fields
    handleEditChange(event) {
        this.value = event.detail.value;
        this.saveFlag = true
    }
        
    //Show Delete Question popup, get the record id of the question and check if there are changes before show it
    showDeleteQuestionModal(event){
        if(this.saveFlag){
            this.showSaveWarning = true
            this.fromDeleteFlag = true
        }
        else{
            this.showDeleteWarning = true 
               }
        this.recordId = event.target.dataset.recordid;      
    }

    //Hide the Delete Question popup
    hideDeleteQuestionModal(){
        this.showDeleteWarning = false
    }

    //Hide the unsaved changes warning modal, and reset all the flags
    hideSaveQuestionsModal(){
        this.showSaveWarning = false
        this.saveFlag = false
        this.visibleQuestions = this.visibleQuestionsHold
        if(this.fromSaveFlag){
            this.showCreateQuestion = true;
            this.fromSaveFlag = false
        }
        if(this.fromDeleteFlag){
            this.showDeleteWarning = true
            this.fromDeleteFlag = false
        }
        return refreshApex(this.wiredQuestionsResult);
    }

    resetValues(){
        for(let i=0;i<this.visibleQuestions.length;i++){      
            this.template.querySelectorAll("[data-field='Question_Text__c']")[i].value = this.visibleQuestions[i].Question_Text__c;
            this.template.querySelectorAll("[data-field='Available_in_Pool__c']")[i].checked = this.visibleQuestions[i].Available_in_Pool__c;
            this.template.querySelectorAll("[data-field='Category__c']")[i].value = this.visibleQuestions[i].Category__c;
        } 
    }

    handleDiscardChanges(){
        this.resetValues();
        this.hideSaveQuestionsModal();

    }

    // Delete a question from the Question Pool (Question__c Object)
    deleteQuestion(event) {
        this.hideDeleteQuestionModal()
        deleteRecord(this.recordId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Question deleted',
                        variant: 'success'
                    })
                );
                refreshApex(this.wiredQuestionsResult);
                this.handlebutton();

                return; 
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting question',
                        message: 'Error deleting question',
                        variant: 'error'
                    })
                );
            });
    }

    //Update questions on the Question Pool (Question__c Object)
    updateQuestions(event) {
        if(this.visibleQuestions != 0){
        this.toggleSave = 'Saving';
        //map the data to the fields
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);
        if(allValid){
            let counter = 0
            for(let i=0;i<=this.visibleQuestions.length;i++){       
                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.visibleQuestions[i].Id;
                fields[QUESTION_FIELD.fieldApiName] = this.template.querySelectorAll("[data-field='Question_Text__c']")[i].value;
                fields[ACTIVATE_FIELD.fieldApiName] = this.template.querySelectorAll("[data-field='Available_in_Pool__c']")[i].checked;
                fields[CATEGORY_FIELD.fieldApiName] = this.template.querySelectorAll("[data-field='Category__c']")[i].value;
               
                //Create a config object that had info about fields.   
                const recordInput = {
                    fields: fields
                };
                //Invoke the method updateRecord()
                updateRecord(recordInput).then(() => {
                    this.loading = true;
                    counter++
                    if(counter == this.visibleQuestions.length){
                            this.stopLoading(1000);
                            this.toggleSave = 'Save';
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Questions updated',
                                    variant: 'success'
                                })
                            );
                            this.hideSaveQuestionsModal();
                            return refreshApex(this.wiredQuestionsResult);
                    } 
                })
                .catch((error) => {
                    this.stopLoading(1000);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error updating questions',
                            variant: 'error'
                        })
                    )
                    this.toggleSave = 'Save';
                });
            }
        }
    }
    else{
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'There are no questions to update',
                variant: 'error'
            })
        )
   

    }
       
    }
    
    //Do the pagination if is neccesary
    updateQuestionHandler(event){
    this.memoryPage = event.detail.page;
    if(this.saveFlag){
        this.showSaveWarning = true
    }
    else{
        this.visibleQuestions = [...event.detail.records]
        
    }
    this.visibleQuestionsHold = [...event.detail.records]


    }
    //Simulates a waiting time with the help of the lightning spinner component
    stopLoading(timeoutValue) {
        setTimeout(() => {
        this.loading = false;
        this.boolgotochild = true
        this.reRender = false
        }, timeoutValue);
    }

    handlebutton(){
        this.reRender = true
        this.currentPage = this.memoryPage
        this.boolgotochild = false
        this.loading=true
        this.stopLoading(300);
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

    //Enable to choose what you fire first, in this case the loading simulation and refresh questions
    connectedCallback() {
        this.getUserRoleToValidateAccess();
        this.picklistHandler();
        this.loading = true;
        this.stopLoading(1000);
     }

    }