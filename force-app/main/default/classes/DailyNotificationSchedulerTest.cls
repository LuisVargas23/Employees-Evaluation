@isTest
public with sharing class DailyNotificationSchedulerTest {
    @isTest
    static void DailyNotificationJobTest() {   
        String CRON_EXP = '0 00 0 24-1 2-3 ? 2022-2022';   
        Test.startTest();
        String jobId = System.schedule('Send daily reminders Test', CRON_EXP, new DailyNotificationScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, State, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        Test.stopTest();
        List<CronTrigger> ctList = [SELECT Id, CronExpression, State, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(1, ctList.size(),'Scheduler not working');
    }
}