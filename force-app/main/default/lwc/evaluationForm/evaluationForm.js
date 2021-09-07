/***************************************************************************************************
 * copyright © 2021
 * Files    :   evaluationForm.html
 *              evaluationForm.js
 *              evaluationForm.js-meta.xml
 *              
 * Purpose: Shows you the questions to evaluation in the selected evaluation form.
 * 
 * Parent Component: formSelector
 *
 * Helper Classes: QuestionController.cls
 *                 FormController.cls
 *                 SchedulerServiceController.cls
 *                 ScoreController.cls
 *                 InstructionController.cls
 * 
 * Created By: Luis Vargas and Magdiel Aldana 8/7/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 9/3/2021                     Luis Vargas      Bug fixes
 ***************************************************************************************************/


import { LightningElement, wire, track, api } from 'lwc';
import getForPicklistValues from '@salesforce/apex/FormController.getForPicklistValues';
import getCategoryPicklistValues from '@salesforce/apex/QuestionController.getCategoryPicklistValues';
import getUsers from '@salesforce/apex/FormController.getUsers';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';
import USER_ROLE from '@salesforce/schema/User.UserRole.Name';
import { getRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Form__c.Id';
import SCORE_FIELD from '@salesforce/schema/Form__c.Answer__c';
import DATE_FIELD from '@salesforce/schema/Form__c.Date_Time_Completed__c';
import getCurrentDateTime from '@salesforce/apex/SchedulerServiceController.getCurrentDateTime';
import getMyScoreCard from '@salesforce/apex/ScoreController.getMyScoreCard'; 
import RECOMMENDATION_FIELD from '@salesforce/schema/Score__c.Recommendations__c';
import SCOREID_FIELD from '@salesforce/schema/Score__c.Id';
import { NavigationMixin } from 'lightning/navigation';
import getEmployeeInstructions from '@salesforce/apex/InstructionController.getEmployeeInstructions';
import getManagerInstructions from '@salesforce/apex/InstructionController.getManagerInstructions';
import getAllCategoryQuestions from '@salesforce/apex/FormController.getAllCategoryQuestions';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class Form extends NavigationMixin(LightningElement) {
    
    @track showFormModal = false
    @track showSaveWarning = false
    @api formselection
    @api manager;
    @api username;
    @api employeename;
    @api subordinatename
    @api showRecommendation;
    @track gotQuestions=true;
    wiredCategoryResult;
    picklistCategory;
    usersList;
    submitButton = false
    userName;
    userRole;
    userData;
    employeeInstructions
    managerInstructions

    questionMap = new Map();
    fieldsVisibility=false
    footerfieldsVisibility=false
    disableSubmit=true
    loading
    questionsArray=[];
    category
    questionsByCat
    wiredquestionsByCategory
    templatePosition = []
    currentDate;
    wiredDateTimeResult;
    wiredInstructionsResult;
    wiredMInstructionsResult;

   
   connectedCallback() {
       console.log(this.formselection);
       console.log(this.manager);
       console.log(this.subordinatename);
       console.log(this.username);

        this.questionsByCat=undefined;
        this.allQuestions=[];
        this.getquestionsByCategory();
        this.getDateTimeHandler();
        refreshApex(this.wiredInstructionsResult);
        refreshApex(this.wiredMInstructionsResult);
    }

    // Get employee instructions
    @wire(getEmployeeInstructions)
    enmployeeInstructionsHandler(result) {
        this.wiredInstructionsResult = result
        if (result.data) {
            this.employeeInstructions = result.data;
        } else if (result.error) {
            this.error = result.error;
            this.employeeInstructions = undefined;
        }
    }

    @wire(getManagerInstructions)
    managerInstructionsHandler(result) {
        this.wiredMInstructionsResult = result
        if (result.data) {
            this.managerInstructions = result.data;
        } else if (result.error) {
            this.error = result.error;
            this.mangerInstructions = undefined;
        }
    }

     // Get UserName
    @wire(getRecord, { recordId: USER_ID, fields: ['User.Name', USER_ROLE]})
    userData({error, data}) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.userData = data;
            this.userName = this.userData.fields.Name.value;
            if (data.fields.UserRole.value != null) {
                this.userRole=data.fields.UserRole.value.fields.Name.value;
           }
     

        }

    } 

    @wire(getForPicklistValues)
    picklistHandler(result) {
        if (result.data) {
            this.picklistForm = result.data        
        } else if (result.error) {
            this.error = result.error;
            this.picklistForm = undefined;
            this.submitButton = true;

        }
    } 

    getDateTimeHandler() {
        getCurrentDateTime()
          .then(result => {
            if(result){
                this.currentDate = result
            }
            else{
                this.error = result;
            }
          }) 
          .catch(error => {
            console.log(error.message);
          });
      }

     // Get categories picklist values
     @wire(getCategoryPicklistValues)
     picklistHandler(result) {
         this.wiredCategoryResult = result;
         if (result.data) {
             this.picklistCategory = result.data
         } else if (result.error) {
             this.error = result.error;
             this.picklistCategory = undefined;
         }
     }     

     // Get categories picklist values
     @wire(getUsers)
     usersHandler(result) {
         if (result.data) {
             this.usersList = result.data

         } else if (result.error) {
             this.error = result.error;
             this.usersList = undefined;
         }
     }    

     // Navigation to Home, 
     cancelHandler(){
            this[NavigationMixin.Navigate]({
                type: 'standard__navItemPage',
                attributes: {
                    //Name of any CustomTab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs
                    apiName: 'Evaluation_Forms'
                },
            });
        }
    
    submitFormHandler(event) {
        this.getDateTimeHandler();
        if(this.allQuestions.length != 0){
            let allValid=true;
            for(let i=0;i<this.allQuestions.length;i++){
                if(this.template.querySelectorAll("[data-field='Answer__c']")[i].value==''){
                    allValid=false;
                }
        }
        if(allValid){
            let counter = 0
            for(let i=0;i<this.allQuestions.length;i++){   
                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.allQuestions[i].Id;
                fields[SCORE_FIELD.fieldApiName] = parseInt(this.template.querySelectorAll("[data-field='Answer__c']")[i].value);
                fields[DATE_FIELD.fieldApiName] = this.currentDate;

                //Create a config object that had info about fields. 
                
                const recordInput = {
                    fields: fields
                };
                //Invoke the method updateRecord()
                updateRecord(recordInput).then(() => {
                    this.loading = true;
                    counter++
                    if(counter == this.allQuestions.length){
                            this.stopLoading(1000);
                            this.showFormModal = true
                            if(this.subordinatename){
                            this.updateRecommendation();
                             }
                            else{
                                return;
                            }
                    } 
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error submitting form',
                            variant: 'error'
                        })
                    )
                });
            }
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill all the questions',
                    variant: 'error'
                })
            )
        }
    }
    else{
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please fill all the questions',
                variant: 'error'
            })
        )


    }
    
    }

    recommendationEventHandler(event){
        this.recommendation = event.target.value;

    }

    updateRecommendation(){
        const fields = {};
        fields[SCOREID_FIELD.fieldApiName] = this.scoreId;
        fields[RECOMMENDATION_FIELD.fieldApiName] = this.recommendation;
        const recordInput = {
            fields: fields
        };
        //Invoke the method updateRecord()
        updateRecord(recordInput).then(() => {
                console.log('Form sent')
                return;
             }).catch((error) => {
            console.log('Error sending form')
        });
    
    }

     // show/hide form modal
    showFormSubmissionModal(){
        //this.submitButtonHandler();
       this.showFormModal = true
    }

    hideFormSubmissionModal(){
        this.showFormModal = false
        this.fieldsVisibility=false
        this.loading=true
        this.stopLoading(1000);
        this.getquestionsByCategory();
        this.cancelHandler();
    }

     // Populate users combobox
     value = ''
     ComputePicklistValues(usersValues){
         if(usersValues){
         let options = usersValues.reduce((previousValue, currentValue,index)=>{
             previousValue.push({
                 label : currentValue.Name,
                 value : currentValue.Name
             })
             return previousValue
             },[ ])         
         return options
         }
      }
 
    get users() {
        if(this.usersList){
         return this.ComputePicklistValues(this.usersList);     
        }   
     }

     myFormName;
     @api get formName(){
         return this.myFormName;
     }
     
     set formName(value){
         if(value){
         this.myFormName = value;
        }
        
     }

     allQuestions=[]
     @api evaluationTaken=false;
        getquestionsByCategory(){
        getAllCategoryQuestions({
            form: this.formselection,
            IsManager: this.manager,
            name: this.subordinatename,
            subordinateName: this.subordinatename,
            userName: this.username
        }).then(result => {
            if(result){
                if(this.formselection){
                    for(let i=0;i<result.length;i++){
                        this.allQuestions.push(result[i].questionsList)
                        this.allQuestions = this.allQuestions.flat();
                    }
                    this.fieldsVisibility=true
                    this.footerfieldsVisibility=true
                    this.disableSubmit=false

                }
            
                this.evaluationTaken=false;
                for(let i = 0;i<result.length;i++){
                    for(let j = 0;j<result[i].questionsList.length;j++){
                    if(result[i].questionsList[j].Answer__c){
                        console.log(result[i].questionsList[j].Answer__c);
                        this.evaluationTaken = true;
                        this.fieldsVisibility=false
                        this.disableSubmit=true
                    }
                    }
                }

                this.questionsByCat = result
                this.getMyScoreCardHandler();
                this.handleFormEventChange();
                }
           
            else{
                console.log('here you are Error')

                console.log('Error')


            }
        });
    
    }
    
    get questionsbycat(){
        
        return this.questionsByCat;
    }

    recommendation;
    scoreId;
    getMyScoreCardHandler(){
        getMyScoreCard({
            Name: this.subordinatename
        }).then(result => {
            if(result){
                 this.recommendation=result.Recommendations__c;
                 this.scoreId=result.Id
                }
           
            else{
                console.log('Error')
            }
        }).catch(error => {
            console.log(error.message);
            console.log('Probably you are not a manager');

          });
    
    }

    value='';
    get rating() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' },
            { label: '6', value: '6' },
            { label: '7', value: '7' },
            { label: '8', value: '8' },
            { label: '9', value: '9' },
            { label: '10', value: '10' }
        ];
    }

    //Simulates a waiting time with the help of the lightning spinner component
    stopLoading(timeoutValue) {
        setTimeout(() => {
        this.loading = false;
        this.fieldsVisibility=true;
        }, timeoutValue);
    }

    handleFormEventChange(){
        const selectedEvent = new CustomEvent("formchange", {
        detail: this.evaluationTaken
      });
  
      // Dispatches the event.
      this.dispatchEvent(selectedEvent);
    }
    

}