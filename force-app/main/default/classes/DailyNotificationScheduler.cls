/*************************************************************************************
 * copyright © 2021
 * Files    :   DailyNotificationScheduler.cls
 *              
 * Purpose  : Sends an Email reminder during 5 days, during the evaluation period, to 
 *            let the employees know that they must submit the forms before the *            Evaluation Period ends. The job starts one day after the Evaluation    
 *            Period begins and finish a day before ends.
 *            Also creates a job that executes the aforementioned action in 6 months.
 *       
 * Referred from: SchedulerServiceController.cls
 *                  
 * Test Class Class: DailyNotificationSchedulerTest.cls
 * 
 * Created By: Luis Vargas 8/6/2021
 * 
 *------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------
 * 8/6/2021                    Luis Vargas      Initial Creation
 ************************************************************************************/

global with sharing class DailyNotificationScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
      //Send an Email notification
      //SendNotificationEmailService.sendDailyNotificationEmail();
      SendNotificationEmailService myBatch = new SendNotificationEmailService('3'); 
      Id batchId = Database.executeBatch(myBatch,10);
      //Get the current 'EXECUTING' job
      Id jobId =  context.getTriggerId();
      CronTrigger myCronTrigger = SchedulerService.getCronTrigger(jobId); 
      /*Autoschedule to run again this class in six months, is a recurrency, so we have to make sure that only happens once. A TimeStamp is added to the name to avoid a duplicity exception, because of the running Job.*/
      String jobName = 'Send daily reminders';
      String CronExpression = SchedulerService.addSixMonthsAndDays(myCronTrigger.CronExpression,5);
      DailyNotificationScheduler sh3 = new DailyNotificationScheduler();
      String m = String.Valueof(Datetime.now().millisecond());
      if(myCronTrigger.TimesTriggered==1){
        System.schedule(jobName+' '+m, CronExpression , sh3);
      }
    }
}