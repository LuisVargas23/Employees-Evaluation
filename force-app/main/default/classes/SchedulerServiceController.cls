/***************************************************************************************************
 * copyright © 2021
 * Files    :   SchedulerServiceController.cls
 *              
 * Purpose  : 
 *
 * Referred from: StartEvaluationPeriodScheduler.cls
 *                FinishEvaluationPeriodScheduler.cls
 *                DailyNotificationScheduler.cls
 *                BeforeDailyNotificationScheduler.cls
 *                   
 * Test Class Class: SchedulerServiceControllerTest.cls
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 8/6/2021                    Luis Vargas      Initial Creation
 ***************************************************************************************************/

public with sharing class SchedulerServiceController {
  
    //Get current Salesforce Platform's dateTime
    @AuraEnabled
    public static Datetime getCurrentDateTime() {
    return Datetime.now();
    }

    //Get current Salesforce Platform's timezone
    @AuraEnabled(cacheable=true)
    public static String getCurrentTimeZone() {
    return string.ValueOf(UserInfo.getTimeZone());
    }

    //Get the datetime when the next evaluation period starts
    @AuraEnabled
    public static DateTime getCurrentlyScheduledJobs(String cronStringSemestral){
        String searchCronJob1 = cronStringSemestral+'%';
        List<CronTrigger> cronTriggers = [
            SELECT Id, NextFireTime, CreatedDate, State
            FROM CronTrigger
            WHERE CronJobDetail.Name like :searchCronJob1 AND State != 'DELETED'
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
            LIMIT 1
            ];
            if(cronTriggers.size() == 1){
            DateTime cronSchedule = cronTriggers[0].NextFireTime;
                return cronSchedule;
            }
            else{
                return null;
            }
        
    }

    //Get all scheduled jobs related to the Employees Evaluation App
    @AuraEnabled
    public static List<CronTrigger> getAllCurrentlyScheduledJobs(  
      String cronJobNameSemestral, 
      String cronJobNameSemestralEnd, 
      String cronJobNameDaily, 
      String cronJobNameReminder
      ) {
          String searchCronJob1 = cronJobNameSemestral+'%';
          String searchCronJob2 = cronJobNameSemestralEnd+'%';
          String searchCronJob3 = cronJobNameDaily+'%';
          String searchCronJob4 = cronJobNameReminder+'%';


        return [
            SELECT Id, CronJobDetail.Name, PreviousFireTime, NextFireTime, State, StartTime
            FROM CronTrigger
            WHERE CronJobDetail.Name like :searchCronJob1
            OR CronJobDetail.Name like :searchCronJob2
            OR CronJobDetail.Name like :searchCronJob3
            OR CronJobDetail.Name like :searchCronJob4
            WITH SECURITY_ENFORCED
            ORDER BY NextFireTime
            ];
       
    }

    //Schedule jobs base on user's input
    @AuraEnabled
    public static Boolean scheduleJob(
            String cronStringSemestral, 
            String cronStringSemestralEnd, 
            String cronStringDaily, 
            String cronStringReminder, 
            String cronJobNameSemestral, 
            String cronJobNameSemestralEnd, 
            String cronJobNameDaily, 
            String cronJobNameReminder
            ){
            try {
                StartEvaluationPeriodScheduler sh1 = new StartEvaluationPeriodScheduler();
                FinishEvaluationPeriodScheduler sh2 = new FinishEvaluationPeriodScheduler();
                DailyNotificationScheduler sh3 = new DailyNotificationScheduler();
                BeforeDailyNotificationScheduler sh4 = new BeforeDailyNotificationScheduler();
                System.schedule(cronJobNameSemestral, cronStringSemestral, sh1);
                System.schedule(cronJobNameSemestralEnd, cronStringSemestralEnd, sh2);
                System.schedule(cronJobNameDaily, cronStringDaily, sh3);
                System.schedule(cronJobNameReminder, cronStringReminder, sh4);
                return true;
            } catch (Exception e) {
                System.debug(e.getMessage());
                return false;
            }
    }

    //Delete all scheduled jobs related to the Employees Evaluation App
    @AuraEnabled
    public static Boolean deleteScheduledJob(
            String cronJobNameSemestral, 
            String cronJobNameSemestralEnd, 
            String cronJobNameDaily, 
            String cronJobNameReminder) {
            String searchCronJob1 = cronJobNameSemestral+'%';
            String searchCronJob2 = cronJobNameSemestralEnd+'%';
            String searchCronJob3 = cronJobNameDaily+'%';
            String searchCronJob4 = cronJobNameReminder+'%';
        try {
            List<CronTrigger> cronTriggers = [
            SELECT Id, CronExpression
            FROM CronTrigger
            WHERE CronJobDetail.Name like :searchCronJob1
            OR CronJobDetail.Name like :searchCronJob2
            OR CronJobDetail.Name like :searchCronJob3
            OR CronJobDetail.Name like :searchCronJob4
            WITH SECURITY_ENFORCED
            ];
            for(Integer i = 0; i < cronTriggers.size();i++){
            System.abortJob(cronTriggers[i].Id);
            }
            return true;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return false;
        }
    }
}