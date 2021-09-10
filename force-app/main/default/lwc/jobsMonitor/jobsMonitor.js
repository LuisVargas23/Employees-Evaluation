/***************************************************************************************************
 * copyright © 2021
 * Files    :   jobsMonitor.html
 *              jobsMonitor.js
 *              jobsMonitor.js-meta.xml
 *              
 * Purpose: Show all running jobs related to the evaluation period automation. 
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
 * 7/29/2021                    Luis Vargas      Initial Creation
 ***************************************************************************************************/


import { LightningElement, wire } from 'lwc';
import getAllCurrentlyScheduledJobs from "@salesforce/apex/SchedulerServiceController.getAllCurrentlyScheduledJobs";
import getCurrentTimeZone from "@salesforce/apex/SchedulerServiceController.getCurrentTimeZone";
import USER_ID from '@salesforce/user/Id';
import getUserRole from '@salesforce/apex/FormController.getUserRole';

export default class JobsMonitor extends LightningElement {
  cronJobNameSemestral = "Start the evaluation period";
  cronJobNameSemestralEnd = "Finish the evaluation period";
  cronJobNameDaily = "Send daily reminders";
  cronJobNameReminder = "Send daily reminders before the evaluation begins";
  visible=false;
  jobs;
  loading;
  timeZone;
  userRole;

  //Get current logged user time zone, to show date time details in an understandable way.s
  getTimeZone() {
    getCurrentTimeZone()
      .then(result => {
        if(result){
          this.timeZone = result;
          console.log('Job Monitor: '+this.timeZone);
        }
        else{
          console.log("we were unable to load the timezone");     
        }
      }) 
      .catch(error => {
        console.log(error.message);
      });
  }
  
  //Get all the scheduled jobs related to the evaluation period automation. 
  getAllScheduledCron() {
    getAllCurrentlyScheduledJobs({ 
        cronJobNameSemestral: this.cronJobNameSemestral,
        cronJobNameSemestralEnd: this.cronJobNameSemestralEnd,
        cronJobNameDaily: this.cronJobNameDaily,
        cronJobNameReminder: this.cronJobNameReminder,
      })
      .then(result => {
        if(result){
            this.jobs = result
        }
        else{
          console.log("we were unable to load the job");
        }
      }) 
      .catch(error => {
        console.log(error.message);
        this.stopLoading(500);
      });
  }

  //Simulates a waiting time with the help og the lightning spinner component
  stopLoading(timeoutValue) {
    setTimeout(() => {
      this.loading = false;
    }, timeoutValue);
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
        this.userRole='*';  

        console.log(error.message);
      });
  }

  //Enable to choose what you fire first, in this case the loading simulation and refresh questions  
  connectedCallback() {
    this.getTimeZone();
    this.getUserRoleToValidateAccess();
    this.loading = true;
    this.stopLoading(1000);
    this.getAllScheduledCron();
  }

}