/***************************************************************************************************
 * copyright © 2021
 * Files    :   BeforeDailyNotificationScheduler.cls
 *              
 * Purpose  : Sends an Email reminder during 3 days, beginning 3 days before the evaluation period 
 *            starts, to let the employees know that an Evaluation Period is cooming up. Creates 
 *            a job that executes the aforementioned action in 6 months.
 *
 * Referred from: SchedulerServiceController.cls
 *                  
 * Test Class Class: BeforeDailyNotificationSchedulerTest.cls
 * 
 * Created By: Luis Vargas 8/6/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 8/6/2021                    Luis Vargas      Initial Creation
 ***************************************************************************************************/

global with sharing class BeforeDailyNotificationScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
      //Send an Email notification
      //SendNotificationEmailService.sendBeforeDailyNotificationEmail();
      SendNotificationEmailService myBatch = new SendNotificationEmailService('4'); 
      Id batchId = Database.executeBatch(myBatch,10);
      //Get the current 'EXECUTING' job
      Id jobId =  context.getTriggerId();
      CronTrigger myCronTrigger = SchedulerService.getCronTrigger(jobId); 
      /*Autoschedule to run again this class in six months, is a recurrency, so we have to make sure that 
      only happens once. A TimeStamp is added to the name to avoid a duplicity exception, because of the 
      running Job.*/
      String jobName = 'Send daily reminders before the evaluation begins';
      String CronExpression = SchedulerService.addSixMonthsAndDays(myCronTrigger.CronExpression,3);
      BeforeDailyNotificationScheduler sh4 = new BeforeDailyNotificationScheduler();
      String m = String.Valueof(Datetime.now().millisecond());
      
      if(myCronTrigger.TimesTriggered==1){
          System.schedule(jobName+' '+m, CronExpression , sh4);
      }
    }
}