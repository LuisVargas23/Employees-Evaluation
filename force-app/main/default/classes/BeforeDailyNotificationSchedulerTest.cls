@isTest
public with sharing class BeforeDailyNotificationSchedulerTest {
   
    @isTest
    static void BeforeDailyNotificationJobTest() {   
        String CRON_EXP = '0 00 0 24-27 2-2 ? 2022-2022';   
        Test.startTest();
        String jobId = System.schedule('Send daily reminders before the evaluation begins Test', CRON_EXP, new BeforeDailyNotificationScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, State, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        Test.stopTest();
        List<CronTrigger> ctList = [SELECT Id, CronExpression, State, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(1, ctList.size(),'Scheduler not working');
    }
}