/***************************************************************************************************
 * copyright © 2021
 * Files    :   StartEvaluationPeriodScheduler.cls
 *              
 * Purpose  : Sends an Email notification as a reminder that the Evaluation Period has begun, 
 *            creates all the configured forms for the Evaluation Period that has just begun and 
 *            creates a job that executes the aforementioned actions in 6 months.
 * 
 * Referred from: SchedulerServiceController.cls
 *                  
 * Test Class Class: StartEvaluationPeriodSchedulerTest.cls
 * 
 * Created By: Luis Vargas on 8/6/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 8/6/2021                    Luis Vargas      Initial Creation
 ***************************************************************************************************/

global with sharing class StartEvaluationPeriodScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
        //Send Email notification and create forms
        //SendNotificationEmailService.sendStartSemestralNotificationEmail();
        SendNotificationEmailService myBatch = new SendNotificationEmailService('1'); 
        Id batchId = Database.executeBatch(myBatch,10);
        FormScoreCreation.Create();
        //Get the current 'EXECUTING' job
        Id jobId =  context.getTriggerId();
        CronTrigger myCronTrigger = SchedulerService.getCronTrigger(jobId); 
        /*Autoschedule to run again this class in six months. A TimeStamp is added 
        to the name to avoid a duplicity exception, because of the running Job.*/
        String CronExpression = SchedulerService.addSixMonths(myCronTrigger.CronExpression);
        String jobName = 'Start the evaluation period';
        StartEvaluationPeriodScheduler sh1 = new StartEvaluationPeriodScheduler();
        String m = String.Valueof(Datetime.now().millisecond());
        System.schedule(jobName+' '+m, CronExpression , sh1);
    }
}

