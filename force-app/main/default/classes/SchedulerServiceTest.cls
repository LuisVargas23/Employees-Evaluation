@isTest
public with sharing class SchedulerServiceTest {
        @isTest
        static void addSixMonthsTest(){
            String CRON_EXP = '0 00 0 7 2 ? 2022';
            Test.startTest();
            String CRON_EXP_EXPECTED = SchedulerService.addSixMonths(CRON_EXP);
            Test.stopTest();
            System.assertEquals('0 00 0 7 8 ? 2022', CRON_EXP_EXPECTED, 'The method is not working properly');

        }

        @isTest
        static void addSixMonths_CrossYear_Test(){
            String CRON_EXP = '0 00 0 7 8 ? 2022';
            Test.startTest();
            String CRON_EXP_EXPECTED = SchedulerService.addSixMonths(CRON_EXP);
            Test.stopTest();
            System.assertEquals('0 00 0 7 2 ? 2023', CRON_EXP_EXPECTED, 'The method is not working properly');

        }

        @isTest
        static void addSixMonthsAndDays_3Days_Test(){
            String CRON_EXP = '0 00 0 3-6 2-2 ? 2021-2021';
            Test.startTest();
            String CRON_EXP_EXPECTED = SchedulerService.addSixMonthsAndDays(CRON_EXP, 3);
            Test.stopTest();
            System.assertEquals('0 00 0 3-6 8-8 ? 2021-2021', CRON_EXP_EXPECTED, 'The method is not working properly');

        }

        @isTest
        static void addSixMonthsAndDays_3Days_CrossMonth_Test(){
            String CRON_EXP = '0 00 0 27-2 2-3 ? 2021-2021';
            Test.startTest();
            String CRON_EXP_EXPECTED = SchedulerService.addSixMonthsAndDays(CRON_EXP, 3);
            Test.stopTest();
            System.assertEquals('0 00 0 27-30 8-8 ? 2021-2021', CRON_EXP_EXPECTED, 'The method is not working properly');

        }

        @isTest
        static void addSixMonthsAndDays_3Days_CrossYear_Test(){
            String CRON_EXP = '0 00 0 29-1 12-1 ? 2021-2022';
            Test.startTest();
            String CRON_EXP_EXPECTED = SchedulerService.addSixMonthsAndDays(CRON_EXP, 3);
            Test.stopTest();
            System.assertEquals('0 00 0 29-2 6-7 ? 2022-2022', CRON_EXP_EXPECTED, 'The method is not working properly');

        }


        @isTest
        static void addSixMonthsAndDays_5Days_Test(){
            String CRON_EXP = '0 00 0 8-13 2-2 ? 2021-2021';
            Test.startTest();
            String CRON_EXP_EXPECTED = SchedulerService.addSixMonthsAndDays(CRON_EXP, 6);
            Test.stopTest();
            System.assertEquals('0 00 0 8-14 8-8 ? 2021-2021', CRON_EXP_EXPECTED, 'The method is not working properly');

        }

        @isTest
        static void addSixMonthsAndDays_5Days_CrossMonth_Test(){
            String CRON_EXP = '0 00 0 27-4 2-3 ? 2021-2021';
            Test.startTest();
            String CRON_EXP_EXPECTED = SchedulerService.addSixMonthsAndDays(CRON_EXP, 6);
            Test.stopTest();
            System.assertEquals('0 00 0 27-2 8-9 ? 2021-2021', CRON_EXP_EXPECTED, 'The method is not working properly');

        }

        @isTest
        static void addSixMonthsAndDays_5Days_CrossYear_Test(){
            String CRON_EXP = '0 00 0 31-5 12-1 ? 2021-2022';
            Test.startTest();
            String CRON_EXP_EXPECTED = SchedulerService.addSixMonthsAndDays(CRON_EXP, 6);
            Test.stopTest();
            System.assertEquals('0 00 0 30-6 6-7 ? 2022-2022', CRON_EXP_EXPECTED, 'The method is not working properly');

        }

       
}

