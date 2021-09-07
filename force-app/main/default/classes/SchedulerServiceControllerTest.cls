@isTest
public with sharing class SchedulerServiceControllerTest {
    @TestSetup
    static void makeData(){
        User userAdmin = [select Id, Name from User where Id =:userinfo.getuserid()];
        System.debug(userAdmin);
        List<User> orgUsers = [SELECT ID, Email, IsActive 
                                FROM USER WHERE IsActive=TRUE
                                AND Id != :userAdmin.Id 
                                AND EMail != 'autoproc@00d5e000002i6bleas' 
                                AND EMail != 'integration@example.com'
                                AND EMail != 'insightssecurity@example.com'
                                AND Email != 'automatedclean@00d5e000002i6bleas'
                                AND EMail != 'noreply@00d5e000002i6bleas'];
        System.debug(orgUsers);

        for(User u:orgUsers){
            u.IsActive=false;
        }
        update orgUsers;

        SchedulerServiceController.deleteScheduledJob('Start the evaluation period', 'Finish the evaluation period', 'Send daily reminders', 'Send daily reminders before the evaluation begins');

        StartEvaluationPeriodScheduler sep = new StartEvaluationPeriodScheduler();
        String CRON_EXP = '0 15 18 17 8 ? 2022';
        System.schedule('Start the evaluation period Test Setup', CRON_EXP, sep);

        FinishEvaluationPeriodScheduler fep = new FinishEvaluationPeriodScheduler();
        String CRON_EXP2 = '0 15 18 17 8 ? 2022';
        System.schedule('Finish the evaluation period Test Setup', CRON_EXP2, fep);

        DailyNotificationScheduler dns = new DailyNotificationScheduler();
        String CRON_EXP3 = '0 15 18 17-22 8-8 ? 2022-2022';
        System.schedule('Send daily reminders Test Setup', CRON_EXP3, dns);

        BeforeDailyNotificationScheduler bdns = new BeforeDailyNotificationScheduler();
        String CRON_EXP4 = '0 15 18 14-16 8-8 ? 2022-2022';
        System.schedule('Send daily reminders before the evaluation begins Test Setup', CRON_EXP4, bdns);
        
    }

    @isTest
    static void getCurrentDateTimeTest() {
       system.assertEquals(Datetime.now(),SchedulerServiceController.getCurrentDateTime());
   
    }

    @isTest
    static void getCurrentTimeZoneTest() {
        system.assertEquals(string.ValueOf(UserInfo.getTimeZone()),SchedulerServiceController.getCurrentTimeZone());
        
    }

    @isTest
    static void getCurrentlyScheduledJobsTest(){
        
        DateTime nextTrigger = SchedulerServiceController.getCurrentlyScheduledJobs('Start the evaluation period Test Setup');
        system.debug(nextTrigger);
        
    }

    @isTest
    static void scheduleJobTest(){
        String CRON_EXP = '0 00 0 23 2 ? 2022';   
        String CRON_NAME = 'Start the evaluation period Test2';
        String CRON_EXP2 = '0 00 0 2 3 ? 2022';  
        String CRON_NAME2 = 'Finish the evaluation period Test2';
        String CRON_EXP3 = '0 00 0 24-1 2-3 ? 2022-2022';   
        String CRON_NAME3 = 'Send daily reminders Test2';
        String CRON_EXP4 = '0 00 0 19-22 2-2 ? 2022-2022';  
        String CRON_NAME4 = 'Send daily reminders before the evaluation begins Test2';
        test.startTest();
        Boolean scheduleJob = SchedulerServiceController.scheduleJob(CRON_EXP, CRON_EXP2, CRON_EXP3, CRON_EXP4, CRON_NAME, CRON_NAME2, CRON_NAME3, CRON_NAME4);
        test.stopTest();
        system.assertEquals(true, scheduleJob);

        }

    @isTest
    static void deleteJobTest(){
        String CRON_NAME = 'Start the evaluation period Test Setup';
        String CRON_NAME2 = 'Finish the evaluation period Test Setup';
        String CRON_NAME3 = 'Send daily reminders Test Setup';
        String CRON_NAME4 = 'Send daily reminders before the evaluation begins Test Setup';
        test.startTest();
        Boolean scheduleJob = SchedulerServiceController.deleteScheduledJob(CRON_NAME, CRON_NAME2, CRON_NAME3, CRON_NAME4);
        test.stopTest();
        system.assertEquals(true, scheduleJob);
        
    }

    @isTest
    static void getAllCurrentlyScheduledJobsTest(){
        String CRON_NAME = 'Start the evaluation period Test Setup';
        String CRON_NAME2 = 'Finish the evaluation period Test Setup';
        String CRON_NAME3 = 'Send daily reminders Test Setup';
        String CRON_NAME4 = 'Send daily reminders before the evaluation begins Test Setup';
        test.startTest();
        List<CronTrigger> myJobs = SchedulerServiceController.getAllCurrentlyScheduledJobs(CRON_NAME, CRON_NAME2, CRON_NAME3, CRON_NAME4);
        test.stopTest();
        system.assertEquals(4, myJobs.size());
        
    }
    
    
}
