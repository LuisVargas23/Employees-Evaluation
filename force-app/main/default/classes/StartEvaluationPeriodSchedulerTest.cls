@isTest
public with sharing class StartEvaluationPeriodSchedulerTest {
    @isTest
    static void startSemestralScheduledJobTest() {   
        String CRON_EXP = '0 00 0 23 2 ? 2022';   
        Test.startTest();
        String jobId = System.schedule('Start the evaluation period Test', CRON_EXP, new StartEvaluationPeriodScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, State, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        Test.stopTest();
        List<CronTrigger> ctList = [SELECT Id, CronExpression, State, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(1, ctList.size(),'Scheduler not working');
    }
}