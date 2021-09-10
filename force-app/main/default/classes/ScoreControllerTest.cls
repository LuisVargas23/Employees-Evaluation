@isTest
public with sharing class ScoreControllerTest {
    @TestSetup
    static void createTestData(){
        UserRole r = new UserRole(DeveloperName = 'MyHHRRRole', Name = 'My HHRR Role');
        insert r;

        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@testorg.com';
        String uniqueUserName2 = 'adminuser2' + DateTime.now().getTime() + '@testorg.com';

        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'admint', Email='adminuser@testorg.com',
        EmailEncodingKey='UTF-8', UserRoleId = r.Id, IsActive = True, LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        insert u;

         
        User u2 = new User(Alias = 'admint2', Email='adminuser2@testorg.com',
        EmailEncodingKey='UTF-8', UserRoleId = r.Id, IsActive = True, LastName='Testing2', ManagerId=u.id, LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName2);
        insert u2;

      
      
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

    
    @isTest
    static void getMyScoreCardTest(){
        Test.startTest();
        User thisUser = [SELECT ID, NAME, EMAIL FROM USER WHERE EMAIL = 'adminuser@testorg.com' LIMIT 1];
        Score__c myScoreCard = ScoreController.getMyScoreCard(thisUser.Name);
        User thisUser2 = [SELECT ID, NAME, EMAIL FROM USER WHERE EMAIL = 'adminuser2@testorg.com' LIMIT 1];
        Score__c myScoreCard2 = ScoreController.getMyScoreCard(thisUser2.Name);
        Test.stopTest();
        System.assertEquals(12, myScoreCard.Score__c);
        System.assertEquals(0, myScoreCard2.Score__c);
    }

   @isTest
    static void getLowScoreCardsTest(){
        Test.startTest();
        List<Score__c> currentLowScores  = ScoreController.getLowScoreCards();
        Test.stopTest();
        for(Score__c myScore:currentLowScores){
            System.assertEquals(0, myScore.Score__c);
        }
       
    }

    @isTest
    static void getHighScoreCardsTest(){
        Test.startTest();
        List<Score__c> currentHightScores = ScoreController.getHighScoreCards();
        Test.stopTest();
        for(Score__c myScore:currentHightScores){
            System.assertEquals(12, myScore.score__c);
        }
       
    }

    @isTest
    static void submitScoreCardsForApprovalTest(){
        Test.startTest();
        ScoreController.submitScoreCardsForApproval();
        Test.stopTest();    
        for(Approval.ProcessResult myResult:ScoreController.publicResults){
            system.assertEquals(true, myResult.isSuccess());
        }


    }



  
}