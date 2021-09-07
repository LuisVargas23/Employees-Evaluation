@isTest
public with sharing class QuestionControllerTest {
    @TestSetup
    static void makeData(){
        List<Question__c> sampleQuestionList = new List<Question__c>();
        for(integer i = 0; i<10;i++){
            Question__c myQuestion = new Question__c();
            myQuestion.Question_Text__c = 'This is the Question ' + i + ' ?';
            myQuestion.Category__c = 'Soft Skills';
            myQuestion.Available_in_Pool__c = false;
            sampleQuestionList.add(myQuestion);
                
        }
        for(integer i = 10; i<20;i++){
            Question__c myQuestion = new Question__c();
            myQuestion.Question_Text__c = 'This is the Question ' + i + ' ?';
            myQuestion.Category__c = 'Hard Skills';
            myQuestion.Available_in_Pool__c = true;
            sampleQuestionList.add(myQuestion);
                
        }
        insert sampleQuestionList;

        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'admint', Email='adminuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        insert u;
    }

    @isTest
    static void getQuestionsTest(){
        User u = [SELECT Id FROM User WHERE Email='adminuser@testorg.com'];
        Test.startTest();
        System.runAs(u){
            List<Question__c> questionPool = QuestionController.getQuestions();
        
        Test.stopTest();
        system.assertEquals(20,questionPool.size());
        system.assertEquals('This is the Question ' + '19' + ' ?',questionPool[0].Question_Text__c, 'The order is descending');
        }
    }

    @isTest
    static void getQuestions2Test(){
        User u = [SELECT Id FROM User WHERE Email='adminuser@testorg.com'];
        Test.startTest();
        System.runAs(u){
            List<Question__c> questionPool = QuestionController.getQuestions2();
        
        Test.stopTest();
        system.assertEquals(10,questionPool.size());
        system.assertEquals('Hard Skills',questionPool[0].Category__c);
        }
    }

    @isTest
    static void getCategoryPicklistValuesTest(){
        Test.startTest();
        List<String> picklistEntries = QuestionController.getCategoryPicklistValues();
        Test.stopTest();
        system.assertEquals('Soft Skills', picklistEntries[0]);
    }
    
    @isTest
    static void getAvailableInPicklistValuesTest(){
        Test.startTest();
        List<String> picklistEntries = QuestionController.getAvailableInPicklistValues();
        Test.stopTest();
        system.assertEquals('All Employees', picklistEntries[0]);
    }
}