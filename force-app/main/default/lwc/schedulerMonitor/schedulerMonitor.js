/***************************************************************************************************
 * copyright © 2021
 * Files    :   schedulerMonitor.html
 *              schedulerMonitor.js
 *              schedulerMonitor.js-meta.xml
 *              
 * Purpose: Let you schedule an evaluation period.
 * 
 * Helper Classes: SchedulerServiceController.cls
 *                 FormController.cls
 * 
 * Created By: Luis Vargas on 7/29/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 7/29/2021                    Luis Vargas     Initial Creation
 ***************************************************************************************************/
import { LightningElement, wire, track } from "lwc";
import getCurrentlyScheduledJobs from "@salesforce/apex/SchedulerServiceController.getCurrentlyScheduledJobs";
import scheduleJob from "@salesforce/apex/SchedulerServiceController.scheduleJob";
import deleteScheduledJob from "@salesforce/apex/SchedulerServiceController.deleteScheduledJob";
import getCurrentTimeZone from "@salesforce/apex/SchedulerServiceController.getCurrentTimeZone";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserRole from '@salesforce/apex/FormController.getUserRole';
import USER_ID from '@salesforce/user/Id';

export default class EmailSchedulerService extends LightningElement {
  cronJobNameSemestral = "Start the evaluation period";
  cronJobNameSemestralEnd = "Finish the evaluation period";
  cronJobNameDaily = "Send daily reminders";
  cronJobNameReminder = "Send daily reminders before the evaluation begins";
  visible;
  timeZone;
  nextFireTime; 
  nextStopTime;
  evaluationSemestralEndCronAsString;
  evaluationDailyCronAsString;
  evaluationReminderCronAsString;
  userRole;
  loading;
  inputTimeOpen=false;
  @track currentCronAsTime;


  
  getTimeZone() {
    getCurrentTimeZone()
      .then(result => {
        if(result){
          this.timeZone = result;
        }
        else{
          console.log("we were unable to load the timezone");     
        }
      }) 
      .catch(error => {
        console.log(error.message);
      });
  }

  scheduleApexJob() {
    if(this.evaluationSemestralCronAsString && this.evaluationSemestralEndCronAsString  && this.evaluationSemestralEndCronAsString && this.evaluationReminderCronAsString){
    this.loading = true;

    scheduleJob({
      cronStringSemestral: this.evaluationSemestralCronAsString,
      cronStringSemestralEnd: this.evaluationSemestralEndCronAsString,
      cronStringDaily: this.evaluationDailyCronAsString,
      cronStringReminder: this.evaluationReminderCronAsString,
      cronJobNameSemestral: this.cronJobNameSemestral,
      cronJobNameSemestralEnd: this.cronJobNameSemestralEnd,
      cronJobNameDaily: this.cronJobNameDaily,
      cronJobNameReminder: this.cronJobNameReminder,

    })
      .then(data => {
        if (data) {
          this.stopLoading(500);
          this.getScheduledCron();
          this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Jobs scheduled',
                variant: 'success'
            })
        );

        } else {
          this.stopLoading(500);
          this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Unable to Schedule Job',
            variant: 'error'
        })
      );
        }
      })
      .catch(error => {
        this.stopLoading(500);
        console.log(error.message);
      });
    }
    else{
      this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message: 'Please choose a correct time and date',
            variant: 'error'
        })
      );
    }
  }

  deleteJob() {
    this.loading = true;
    deleteScheduledJob({
      cronJobNameSemestral: this.cronJobNameSemestral,
      cronJobNameSemestralEnd: this.cronJobNameSemestralEnd,
      cronJobNameDaily: this.cronJobNameDaily,
      cronJobNameReminder: this.cronJobNameReminder,
                        })
      .then(data => {
        if (data) {
          this.stopLoading(500);
          this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Jobs deleted',
                variant: 'success'
            })         
          );

        } else {
          this.stopLoading(100);this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'we were unable to delete this job',
                variant: 'error'
            })
         );
        }
      })
      .catch(error => {
        this.stopLoading(100);
        console.log(error.message);
      });
  }

  handleTimeChange(event) {
    if(event.target.value != null && (new Date(event.target.value) > new Date())){
      
      if(new Date(event.target.value) < (new Date()).setDate(new Date().getDate() + 3)){
        this.dispatchEvent(
          new ShowToastEvent({
              title: 'Warning',
              message: 'Date is too close',
              variant: 'warning'
          })
       );
      }
      
      let date = new Date(event.target.value);
      let day = date.getDate()
      let month = date.getMonth()+1
      let year = date.getFullYear()

      let datePlus7 = new Date(event.target.value);
      datePlus7.setDate(datePlus7.getDate() + 7)
      let dayPlus7 = datePlus7.getDate()
      let monthPlus7 = datePlus7.getMonth()+1
      let yearPlus7 = datePlus7.getFullYear()

      let datePlus1 = new Date(event.target.value);
      datePlus1.setDate(datePlus1.getDate() + 1)
      let dayPlus1 = datePlus1.getDate()
      let monthPlus1 = datePlus1.getMonth()+1
      let yearPlus1 = datePlus1.getFullYear()

      let datePlus6 = new Date(event.target.value);
      datePlus6.setDate(datePlus6.getDate() + 6)
      let dayPlus6 = datePlus6.getDate()
      let monthPlus6 = datePlus6.getMonth()+1
      let yearPlus6 = datePlus6.getFullYear()

      let dateMinus4 = new Date(event.target.value);
      dateMinus4.setDate(dateMinus4.getDate() - 3)
      let dayMinus4 = dateMinus4.getDate()
      let monthMinus4 = dateMinus4.getMonth()+1
      let yearMinus4 = dateMinus4.getFullYear()

      let dateMinus1 = new Date(event.target.value);
      dateMinus1.setDate(dateMinus1.getDate() - 1)
      let dayMinus1 = dateMinus1.getDate()
      let monthMinus1 = dateMinus1.getMonth()+1
      let yearMinus1 = dateMinus1.getFullYear()
    
      let time = event.target.value.substring(12, 19);
      let [hour, minute, seconds] = time.split(":");
      this.evaluationSemestralCronAsString = `0 ${minute} ${hour} ${day} ${month} ? ${year}`;
      this.evaluationSemestralEndCronAsString = `0 ${minute} ${hour} ${dayPlus7} ${monthPlus7} ? ${yearPlus7}`;
      this.evaluationDailyCronAsString = `0 ${minute} ${hour} ${dayPlus1}-${dayPlus6} ${monthPlus1}-${monthPlus6} ? ${yearPlus1}-${yearPlus6}`;
      this.evaluationReminderCronAsString = `0 ${minute} ${hour} ${dayMinus4}-${dayMinus1} ${monthMinus4}-${monthMinus1} ? ${yearMinus4}-${yearMinus1}`;
    
    }
    else{
      this.evaluationSemestralCronAsString = null;
      this.evaluationSemestralEndCronAsString = null;;
      this.evaluationDailyCronAsString = null;
      this.evaluationReminderCronAsString = null;
    
      this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message: 'Please choose a correct time and date',
            variant: 'error'
        })
    );
    }
  }

  getScheduledCron() {
    getCurrentlyScheduledJobs({ 
      cronStringSemestral: this.cronJobNameSemestral
                                })
      .then(result => {
        if(result){
          this.nextFireTime = new Date(result);
          this.stopLoading(500);
        }
        else{
          console.log("we were unable to load the job");
  
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
    isEvaluationPeriod(){
        if((this.nextStopTime  < this.nextFireTime) && this.nextStopTime!=undefined && this.nextFireTime!=undefined){
            this.currentCronAsTimeEnd = true;
            this.currentCronAsTime = false;
          this.inputTimeOpen=false

            }
        else if(this.nextStopTime==undefined || this.nextFireTime==undefined){
          this.currentCronAsTime = false;
          this.currentCronAsTimeEnd = false;
          this.inputTimeOpen=true

         
        }
        else{
          this.currentCronAsTime = true;
          this.currentCronAsTimeEnd = false;
          this.inputTimeOpen=false

            
        }
    }

  getUserRoleToValidateAccess() {
    getUserRole({userId: USER_ID})
      .then(result => {
        if(result){
          this.userRole =  result.UserRole.Name;
          console.log(this.userRole);
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

  connectedCallback() {
    this.getUserRoleToValidateAccess();
    this.getScheduledCron();
    this.loading = true;
    this.stopLoading(1000);

  }

  stopLoading(timeoutValue) {
    setTimeout(() => {
      this.loading = false;
    }, timeoutValue);
  }
}