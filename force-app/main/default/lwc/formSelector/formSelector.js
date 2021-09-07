/***************************************************************************************************
 * copyright © 2021
 * Files    :   formSelector.html
 *              formSelector.js
 *              formSelector.js-meta.xml
 *              
 * Purpose: Detects your position inside the company and let you choose and fill your evaluation forms.
 * 
 * Child Component: evaluationForm
 *
 * Helper Classes: QuestionController.cls
 *                 FormController.cls
 *                 SchedulerServiceController.cls
 * 
 * Created By: Luis Vargas on 8/7/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 9/3/2021                    Luis Vargas      Release with bug fixed
 ***************************************************************************************************/

import { LightningElement, wire, track } from 'lwc';
import getCategoryPicklistValues from '@salesforce/apex/QuestionController.getCategoryPicklistValues';
import getUserForms from '@salesforce/apex/FormController.getUserForms';
import getSubordinates from '@salesforce/apex/FormController.getSubordinates';
import USER_ID from '@salesforce/user/Id';
import USER_ROLE from '@salesforce/schema/User.UserRole.Name';
import getCurrentlyScheduledJobs from "@salesforce/apex/SchedulerServiceController.getCurrentlyScheduledJobs";
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getUserRole from '@salesforce/apex/FormController.getUserRole';


export default class FormSelector extends NavigationMixin(LightningElement) {
   
    //Template's flags
    showManagerForm;
    showManagerSubordinates;
    showSubordinatesForms;
    showEmployeesForm;
    showRecommentation;
    showSaveWarning = false;
    employeeEvaluationPeriod=false;
    formVisibility = true
    evaluationPeriod = true
    

    //--------
    cronJobNameSemestralEnd = "Finish the evaluation period";
    //userHasManager = false
    isManager=false
    loading=false
    nextFireTime;
    nextStopTime
    disableCombo;
    formNewTemp
    subordinates=[];
    mySubordinateForms;
    picklistCategory;
    usersList;
    submitButton = false
    userName;
    userUserName
    userRole;
    userData;
    picklist
    picklistResult

    @track subordinateForm;
    @track mySubordinate;
    @track form
    @track formNew
    @track evaluationTaken;
    @track evaluateSubordinates = false
   
    gettingTheSubordinates(){
        getSubordinates({managerName: this.userName}).then(result => {
            if(result){
                for(let i = 0;i<result.length;i++){
                    this.subordinates.push(result[i].Name);
                }
                if(result.length != 0){
                    this.isManager=true
                    this.showManagerForm=true
                    this.employeeEvaluationPeriod=false
                }
                else{
                    this.isManager=false
                    this.showManagerForm=false
                    this.employeeEvaluationPeriod=true;
                }
            }
            else{
                this.subordinates  = false;
                this.isManager=false
            }
        });
    }

    picklistHandler(){
        getUserForms({userName: this.userUserName}).then(result => {
            if(result){
                this.picklist = result

            }
            else{
                this.picklist = undefined;
            }
        });
    }

    loadForms(event){
        this.mySubordinate = event.detail.value;
        this.subordinateForm = null
        this.showSubordinatesForms=true;
        this.subordinatesFormsHandler()
    }

    subordinatesFormsHandler(){
        getUserForms({userName: this.mySubordinate, Name: this.mySubordinate}).then(result => {
            if(result){
                    this.mySubordinateForms = result;              
                }
            else{
                console.log('Error')
                this.mySubordinateForms  = undefined;
            }
            }).catch((error) => {
                console.log('Error')
                this.mySubordinateForms  = undefined;
            });
        }

    // Get categories picklist values
    @wire(getCategoryPicklistValues)
    picklistHandler2(result) {
        this.wired2QuestionsResult = result;
        if (result.data) {
            this.picklistCategory = result.data
        } else if (result.error) {
            this.error = result.error;
            this.picklistCategory = undefined;
        }
    }     

    // Populate combobox
    @track value = ' '
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
        return this.ComputePicklistValues(this.picklist);         
    }

    get subordinatesOptions() {
        return this.ComputePicklistValues(this.subordinates);         
    }

    get subordinatesFormOptions() {
        return this.ComputePicklistValues(this.mySubordinateForms);         
    }

    get managerOptions() {   
        return [
            { label: 'Autoevaluation', value: 'Autoevaluation' },
            { label: 'Evaluate Subordinates', value: 'Evaluate Subordinates' },
        ];
    }

    handleFormChange(event) {
        this.value=event.detail.value
        this.disableCombo = true        
        if(this.formNew){
            this.form = this.formNew
            this.formNewTemp = event.detail.value;
           if(!this.evaluationTaken){
                this.showSaveWarning = true;
            }
            else{
                this.changeTheForm();
                console.log('error')
            }
        }
        else{
            this.formNew = event.detail.value;
            this.loading = true;
            this.formVisibility=false
            this.stopLoading(1000);
            this.showSaveWarning = false
        }
        console.log(this.formNew);

    }

    handleEvaluationTaken(event){
        this.evaluationTaken=event.detail;
    }

    handleEvaluationChange(event) {
        this.showSubordinatesForms=false;
        if(event.detail.value  == 'Autoevaluation'){
            this.showEmployeesForm = true
            this.employeeEvaluationPeriod = true
            this.evaluateSubordinates=false;
            this.showManagerSubordinates=false
            this.showRecommentation=false;
            this.isManager = false;
        }
        else if(event.detail.value == 'Evaluate Subordinates'){
            this.showRecommentation = true;
            this.showManagerSubordinates=true;
            this.showEmployeesForm = false;
            this.employeeEvaluationPeriod = false
        }else{
            this.isManager = true;
        }    
    }

    // Get UserName

    @wire(getRecord, { recordId: USER_ID, fields: ['User.Name', USER_ROLE, 'User.Username']})
    userData({error, data}) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } 
            else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading users',
                    message,
                    variant: 'error',
                }),
            );
        } 
        else if (data) {
            this.userData = data;
            this.userName = this.userData.fields.Name.value;
            this.userUserName = this.userData.fields.Username.value;
  
            if(this.userUserName){
                this.picklistHandler();
                this.gettingTheSubordinates();
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
          else{
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

    hideFormChangeModal(event){
        this.value = this.formNew
        this.showSaveWarning = false
    }   

    changeTheForm(){
        this.loading = true;
        this.formVisibility=false
        this.stopLoading(1000);
        this.formNew = this.formNewTemp
        this.showSaveWarning = false;
    }

    stopLoading(timeoutValue) {
        setTimeout(() => {
        this.loading = false;
        this.formVisibility=true
        }, timeoutValue);
    }
        
    connectedCallback() {
        this.loading = true;
        this.getUserRoleToValidateAccess();
        this.stopLoading(1000);
        this.getScheduledCron();
 
    }
    
    cronJobNameSemestral = "Start the evaluation period";
    getScheduledCron() {
        getCurrentlyScheduledJobs({ 
        cronStringSemestral: this.cronJobNameSemestral
                                    })
        .then(result => {
            if(result){
               this.nextFireTime = new Date(result);
            }
            else{
                this.nextFireTime = undefined;
            }
            this.getScheduledCronEnd();
        }) 
        .catch(error => {
            console.log(error.message);

        });
    }

    getScheduledCronEnd() {
        getCurrentlyScheduledJobs({ 
        cronStringSemestral: this.cronJobNameSemestralEnd
        })
        .then(result => {
            if(result){                
                this.nextStopTime = new Date(result);
            }
            else{
                this.nextStopTime = undefined;
            }
            this.isEvaluationPeriod();
        }) 
        .catch(error => {
            console.log(error.message);

        });
    }

    evaluationPeriodWarningNoHHRR;
    isEvaluationPeriod(){
         if((this.nextStopTime  < this.nextFireTime) && this.nextStopTime!=undefined && this.nextFireTime!=undefined){
            this.evaluationPeriod=true
            }
        else if(this.nextStopTime==undefined || this.nextFireTime==undefined){
            this.evaluationPeriod=false

            if(this.userRole != 'HHRR' && this.userRole != 'HR'){
                this.evaluationPeriodWarningNoHHRR=true;

            }else{
                this.evaluationPeriodWarningNoHHRR=false
                this.evaluationPeriodWarning=false
            }
        }
        else{
            this.evaluationPeriod=false
            this.evaluationPeriodWarning=true
            
        }
    }

}