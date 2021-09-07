/***************************************************************************************************
 * copyright © 2021
 * Files    :   createQuestion.html
 *  *           createQuestion.js
 *              createQuestion.js-meta.xml
 *              createQuestion.css
 *              
 * Purpose  : Popup/Modal window that lets you create questions in the Question Pool (Question__c).
 * 
 * Parent Component : questionPool
 * 
 * Created By: Luis Vargas on 7/29/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 7/29/2021                    Luis Vargas      Initial Creation
 ***************************************************************************************************/
import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import QUESTION_OBJECT from '@salesforce/schema/Question__c';
import QUESTION_FIELD from '@salesforce/schema/Question__c.Question_Text__c';
import CATEGORY_FIELD from '@salesforce/schema/Question__c.Category__c';
import POINTS_FIELD from '@salesforce/schema/Question__c.Points__c';

export default class createQuestion extends LightningElement {
    @api showmodal = false;
    @api picklistValues;
    questionId;
    question = '';
    category = '';

    //populates picklist values
    get options() {
        console.log(this.picklistValues);

        return this.picklistValues;         
    }

    //Handle create question to save introduced values
    handleQuestionChange(event) {
        this.questionId = undefined;
        this.question = event.target.value;
    }
    handleCategoryChange(event) {
        this.questionId = undefined;
        this.category = event.target.value;
    }

    //Create questions on the Question Pool (Question__c Object)
    createQuestion() {
        const fields = {};
        fields[QUESTION_FIELD.fieldApiName] = this.question;
        fields[CATEGORY_FIELD.fieldApiName] = this.category;
        fields[POINTS_FIELD.fieldApiName] = 5;
        const recordInput = { apiName: QUESTION_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then((question) => {
                this.questionId = question.id;
                //refreshApex(this.question);
                this.question = undefined;
                this.category = undefined;
                this.createQuestionModal();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Question created',
                        variant: 'success'
                    })
                );
                
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error creating question',
                        variant: 'error'
                    })
                );
                
            });
    }

    //Close popup/modal when the 'x' icon is pressed
    closeModal(){
        this.questionId = undefined;
        this.category = undefined;
        this.question = undefined;
        this.dispatchEvent(new CustomEvent('close'));
    }
    createQuestionModal(){
        this.questionId = undefined;
        this.category = undefined;
        this.question = undefined;
        this.dispatchEvent(new CustomEvent('create'));

    }
}