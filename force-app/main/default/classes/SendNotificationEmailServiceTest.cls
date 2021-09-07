@isTest
public with sharing class SendNotificationEmailServiceTest {
    @TestSetup
    static void makeData(){
        List<User> usersToSendEMail = new List<User>();
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'admint', Email='Lvargas.itt@gmail.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        usersToSendEMail.add(u);

        String uniqueUserName2 = 'adminuser2' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        User u2 = new User(Alias = 'admint', Email='Lvargas@doconsulting.net',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName2);
        usersToSendEMail.add(u2);

        insert usersToSendEMail;

        DailyNotificationScheduler dns = new DailyNotificationScheduler();
        String CRON_EXP = '0 15 18 17-22 8-8 ? 2022-2022';
        System.schedule('Send daily reminders', CRON_EXP, dns);

        BeforeDailyNotificationScheduler bdns = new BeforeDailyNotificationScheduler();
        String CRON_EXP2 = '0 15 18 14-16 8-8 ? 2022-2022';
        System.schedule('Send daily reminders before the evaluation begins', CRON_EXP2, bdns);

        User thisUser = [ select Id from User where Id = :u.Id ];
        User thisUser2 = [ select Id from User where Id = :u2.Id ];
        System.runAs (thisUser) {
            List<Score__c> scoreCards = new List<Score__c>();
            Score__c myScore = new Score__c();
            myScore.Start_Date__c	 = system.Today();
            myScore.Employee__c = thisUser.Id;
            myScore.Group__c='All Employees';
            myScore.Employee__c = thisUser.Id;
            myScore.Recommendations__c = 'This is a dump recommendation';
            scoreCards.add(myScore);

           
            Score__c myScore2 = new Score__c();
            myScore2.Start_Date__c	 = system.Today();
            myScore2.Employee__c = thisUser2.Id;
            myScore2.Group__c='All Employees';
            myScore2.Recommendations__c = 'This is a dump recommendation';

            scoreCards.add(myScore2);
            
            insert scoreCards;
  
            List<form__c> myForms = new List<form__c>(); 
            List<form__c> myForms2 = new List<form__c>(); 

            for(integer i=0;i<10;i++){
                form__c myForm = new form__c();
                myForm.Start_Date__c = system.Today();
                myForm.Points__c = 5;
                myForm.Answer__c = 10;
                myForm.Total_Points__c = 50;
                myForm.Score__c = myScore.id;
                myForm.Question_Text__c = 'This is a dump question ' + i;
                myForm.For__c = 'All Employees';
                myForm.Employee__c = thisUser.Id;
                myForms.add(myForm);
            }
            insert myForms;

            for(integer i=10;i<20;i++){
                form__c myForm2 = new form__c();
                myForm2.Start_Date__c = system.Today();
                myForm2.Points__c = 5;
                myForm2.Answer__c = 2;
                myForm2.Total_Points__c = 50;
                myForm2.Score__c = myScore.id;
                myForm2.Question_Text__c = 'This is a dump question ' + i;
                myForm2.For__c = 'All Employees';
                myForm2.Employee__c = thisUser2.Id;
                myForms2.add(myForm2);
            }
            insert myForms2;

        }
                        
    }

    @isTest static void sendStartSemestralNotificationEmailTest(){
        Test.startTest();
        List<User> myUsers = [SELECT Id, Name, IsActive, UserRole.Name, Email 
                              FROM User 
                              WHERE IsActive=true AND Email != 'noreply@00d5e000002i6bleas' AND Email != 'autoproc@00d5e000002i6bleas' AND Email != 'automatedclean@00d5e000002i6bleas' AND Email != 'insightssecurity@example.com' AND Email != 'integration@example.com' 
                              WITH SECURITY_ENFORCED];

       //ID batchjobid = Database.executeBatch(new SendNotificationEmailService('1'));
        SendNotificationEmailService.sendStartSemestralNotificationEmail(myUsers);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1,invocations);
        System.assertEquals(true, SendNotificationEmailService.results.get(0).isSuccess());
    }

    @isTest static void sendFinishSemestralNotificationEmailTest(){
        Test.startTest();
        List<User> myUsers = [SELECT Id, Name, IsActive, UserRole.Name, Email 
                              FROM User 
                              WHERE IsActive=true AND Email != 'noreply@00d5e000002i6bleas' AND Email != 'autoproc@00d5e000002i6bleas' AND Email != 'automatedclean@00d5e000002i6bleas' AND Email != 'insightssecurity@example.com' AND Email != 'integration@example.com' 
                              WITH SECURITY_ENFORCED];

        //ID batchjobid = Database.executeBatch(new SendNotificationEmailService('2'));

        SendNotificationEmailService.sendFinishSemestralNotificationEmail(myUsers);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1,invocations);
        System.assertEquals(true, SendNotificationEmailService.results.get(0).isSuccess());

    }

    @isTest static void sendDailyNotificationEmailTest(){
        Test.startTest();
        List<User> myUsers = [SELECT Id, Name, IsActive, UserRole.Name, Email 
                              FROM User 
                              WHERE IsActive=true AND Email != 'noreply@00d5e000002i6bleas' AND Email != 'autoproc@00d5e000002i6bleas' AND Email != 'automatedclean@00d5e000002i6bleas' AND Email != 'insightssecurity@example.com' AND Email != 'integration@example.com' 
                              WITH SECURITY_ENFORCED];

        //ID batchjobid = Database.executeBatch(new SendNotificationEmailService('3'));
        SendNotificationEmailService.sendDailyNotificationEmail(myUsers);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1,invocations);
        System.assertEquals(true, SendNotificationEmailService.results.get(0).isSuccess());
    }

    @isTest static void sendBeforeDailyNotificationEmailTest(){
        Test.startTest();
        List<User> myUsers = [SELECT Id, Name, IsActive, UserRole.Name, Email 
                              FROM User 
                              WHERE IsActive=true AND Email != 'noreply@00d5e000002i6bleas' AND Email != 'autoproc@00d5e000002i6bleas' AND Email != 'automatedclean@00d5e000002i6bleas' AND Email != 'insightssecurity@example.com' AND Email != 'integration@example.com' 
                              WITH SECURITY_ENFORCED];

        //ID batchjobid = Database.executeBatch(new SendNotificationEmailService('4'));

        SendNotificationEmailService.sendBeforeDailyNotificationEmail(myUsers);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1,invocations);
        System.assertEquals(true, SendNotificationEmailService.results.get(0).isSuccess());

    }

    @isTest static void sendLowScoreEmailTest(){
        Test.startTest();
        List<User> myUsers = [SELECT Id, Name, IsActive, UserRole.Name, Email 
        FROM User 
        WHERE IsActive=true AND Email != 'noreply@00d5e000002i6bleas' AND Email != 'autoproc@00d5e000002i6bleas' AND Email != 'automatedclean@00d5e000002i6bleas' AND Email != 'insightssecurity@example.com' AND Email != 'integration@example.com' 
        WITH SECURITY_ENFORCED];

        //ID batchjobid = Database.executeBatch(new SendNotificationEmailService('5'));

        SendNotificationEmailService.sendLowScoreEmail(myUsers);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(myUsers.size(),invocations);
        System.assertEquals(true, SendNotificationEmailService.results.get(0).isSuccess());

    }

    @isTest static void BatchableClassTest1(){
        Test.startTest();
        SendNotificationEmailService myBatch = new SendNotificationEmailService('1'); 
        Database.executeBatch(myBatch,10);
        Test.stopTest();
        System.assertEquals(true, SendNotificationEmailService.results.get(0).isSuccess());
    }

    

    @isTest static void BatchableClassTest2(){
        Test.startTest();
        SendNotificationEmailService myBatch = new SendNotificationEmailService('2'); 
        Database.executeBatch(myBatch,10);
        Test.stopTest();
        System.assertEquals(true, SendNotificationEmailService.results.get(0).isSuccess());


    }

    @isTest static void BatchableClassTest3(){
        Test.startTest();
        SendNotificationEmailService myBatch = new SendNotificationEmailService('3'); 
        Database.executeBatch(myBatch,10);
        Test.stopTest();

    }

    @isTest static void BatchableClassTest4(){
        Test.startTest();
        SendNotificationEmailService myBatch = new SendNotificationEmailService('4'); 
        Database.executeBatch(myBatch,10);
        Test.stopTest();
        System.assertEquals(true, SendNotificationEmailService.results.get(0).isSuccess());


    }

    @isTest static void BatchableClassTest5(){
        Test.startTest();
        SendNotificationEmailService myBatch = new SendNotificationEmailService('5'); 
        Database.executeBatch(myBatch,10);
        Test.stopTest();
        System.assertEquals(true, SendNotificationEmailService.results.get(0).isSuccess());


    }
    
}
