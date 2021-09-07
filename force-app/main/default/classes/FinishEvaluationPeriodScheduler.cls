/***************************************************************************************************
 * copyright © 2021
 * Files    :   FinishEvaluationPeriodScheduler.cls
 *              
 * Purpose  : Sends an Email notification as a reminder that the Evaluation Period has finished, 
 *            sends another Email with a list of low score employees and creates a job that 
 *            executes  the aforementioned actions in 6 months.
 * 
 * Referred from: SchedulerServiceController.cls
 *                  
 * Test Class Class: FinishEvaluationPeriodSchedulerTest.cls
 * 
 * Created By: Luis Vargas 8/6/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 8/6/2021                    Luis Vargas      Initial Creation
 ***************************************************************************************************/

global with sharing class FinishEvaluationPeriodScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
        //Send Email notifications
        //SendNotificationEmailService.sendFinishSemestralNotificationEmail();
        SendNotificationEmailService myBatch = new SendNotificationEmailService('2'); 
        Id batchId = Database.executeBatch(myBatch,10);
        SendNotificationEmailService myBatch2 = new SendNotificationEmailService('5'); 
        Id batchId2 = Database.executeBatch(myBatch2,10);
        ScoreController.submitScoreCardsForApproval();
        FormScoreCreation.updateLastCompletedEval();
        //Get the current 'EXECUTING' job
        Id jobId =  context.getTriggerId();
        CronTrigger myCronTrigger = SchedulerService.getCronTrigger(jobId); 
         /*Autoschedule to run again this class in six months. A TimeStamp is added 
        to the name to avoid a duplicity exception, because of the running Job.*/
        String CronExpression = SchedulerService.addSixMonths(myCronTrigger.CronExpression);
        String jobName = 'Finish the evaluation period';
        FinishEvaluationPeriodScheduler sh2 = new FinishEvaluationPeriodScheduler();
        String m = String.Valueof(Datetime.now().millisecond());
        System.schedule(jobName+' '+m, CronExpression , sh2);
    }
}

