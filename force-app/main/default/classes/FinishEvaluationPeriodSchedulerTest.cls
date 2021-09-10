@isTest
public with sharing class FinishEvaluationPeriodSchedulerTest {
    @isTest
    static void finishSemestralScheduledJobTest() {   
        String CRON_EXP = '0 00 0 2 3 ? 2022';   
        Test.startTest();
        String jobId = System.schedule('Finish the evaluation period Test', CRON_EXP, new FinishEvaluationPeriodScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, State, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        Test.stopTest();
        List<CronTrigger> ctList = [SELECT Id, CronExpression, State, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(1, ctList.size(),'Scheduler not working');
    }
}