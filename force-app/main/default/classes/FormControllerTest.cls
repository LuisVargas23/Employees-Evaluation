@isTest
public with sharing class FormControllerTest {
    @TestSetup
    static void makeData(){
        User userAdmin = [select Id, Name from User where Id =:userinfo.getuserid()];
        List<User> orgUsers = [SELECT ID, Email, IsActive 
                                FROM USER WHERE IsActive=TRUE
                                AND Id != :userAdmin.Id 
                                AND EMail != 'autoproc@00d5e000002i6bleas' 
                                AND EMail != 'integration@example.com'
                                AND EMail != 'insightssecurity@example.com'
                                AND Email != 'automatedclean@00d5e000002i6bleas'
                                AND EMail != 'noreply@00d5e000002i6bleas'];
        for(User u:orgUsers){
            u.IsActive=false;
        }
        update orgUsers;

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
            scoreCards.add(myScore);

            myScore.Employee__c = thisUser2.Id;
            Score__c myScore2 = new Score__c();
            myScore2.Start_Date__c	 = system.Today();
            myScore2.Employee__c = thisUser2.Id;
            myScore2.Group__c='All Employees';
            scoreCards.add(myScore2);
            
            insert scoreCards;
  
            List<form__c> myForms = new List<form__c>(); 
            for(integer i=0;i<10;i++){
                form__c myForm = new form__c();
                myForm.Start_Date__c = system.Today();
                myForm.Points__c = 5;
                myForm.Score__c = myScore.id;
                myForm.Question_Text__c = 'This is a dump question ' + i;
                myForm.Category__c = 'Soft Skills';
                myForm.For__c = 'All Employees';
                myForm.Employee__c = thisUser.Id;
                myForms.add(myForm);
            }
            for(integer i=10;i<20;i++){
                form__c myForm2 = new form__c();
                myForm2.Start_Date__c = system.Today();
                myForm2.Points__c = 5;
                myForm2.Score__c = myScore.id;
                myForm2.Question_Text__c = 'This is a dump question ' + i;
                myForm2.Category__c = 'Personal';
                myForm2.For__c = 'All Employees';
                myForm2.Employee__c = thisUser2.Id;
                myForms.add(myForm2);
            }

            for(integer i=20;i<25;i++){
                form__c myForm2 = new form__c();
                myForm2.Start_Date__c = system.Today();
                myForm2.Points__c = 5;
                myForm2.For_Manager__c = true;
                myForm2.Score__c = myScore.id;
                myForm2.Question_Text__c = 'This is a dump question ' + i;
                myForm2.For__c = 'All Employees';
                myForm2.Employee__c = thisUser2.Id;
                myForms.add(myForm2);
            }


            insert myForms;
        }

    }

    @isTest
    static void getFormsTest(){
        List<form__c> myForms = new List<form__c>(); 
        test.startTest();
        myForms = FormController.getForms();
        test.stopTest();
        system.assertEquals(25, myForms.size());
    }

    @isTest
    static void getUserRoleTest() {
        User thisUser = [SELECT ID, NAME, EMAIL FROM USER WHERE EMAIL = 'adminuser@testorg.com' LIMIT 1];
        string myId = (String) thisUser.Id;
        User myUser = new User(); 
        test.startTest();
        myUser = FormController.getUserRole(myId);
        System.debug([SELECT ID, Employee__r.NAME, Group__c, Employee__r.Username
            FROM Score__c]);
        test.stopTest();
        system.assertEquals('My HHRR Role', myUser.UserRole.Name);

    }


    @isTest
    static void getUsersTest() {
        List<User> allUsers = [SELECT Id, isActive FROM User WHERE isActive=true];
        List<User> myUsers = new List<User>();
        test.startTest();
        myUsers = FormController.getUsers();
        test.stopTest();
        system.assertEquals(AllUsers.size(), myUsers.size());

    }

    @isTest
    static void getForPicklistValuesTest(){
        List<String> myPickList = FormController.getForPicklistValues();
        system.assertEquals(8, myPickList.size());
    }


    @isTest
    static void getUserFormsTest() {
        User thisUser = [SELECT ID, NAME, UserName FROM USER WHERE EMAIL = 'adminuser2@testorg.com'  LIMIT 1];
        test.startTest();
        List<String> myForms = FormController.getUserForms(thisUser.UserName, thisUser.Name);
        system.debug(myForms);
        test.stopTest();
        system.assertEquals(1, myForms.size());
        system.assertEquals('All Employees', myForms[0]);


    }

    @isTest
    static void getSubordinatesTest() {
    User mU = [
        SELECT ID, NAME, Username
        FROM USER 
        WHERE EMAIL = 'adminuser@testorg.com'
        WITH SECURITY_ENFORCED
        LIMIT 1
    ];
    test.startTest();
    List<User> mySubs = FormController.getSubordinates(mU.Name);
    test.stopTest();
    system.assertEquals(1, mySubs.size());
    
    }

    @isTest
    static void getQuestionsC_Employee_Test(){
        User u = [
            SELECT ID, NAME, UserName
            FROM USER 
            WHERE EMAIL = 'adminuser@testorg.com'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        List<Form__c> myFormQuestions = new List<Form__c>(); 
        test.startTest();
        myFormQuestions = FormController.getQuestionsC('All Employees', false, u.UserName, u.Name, u.Name);
        test.stopTest();
        system.assertEquals(10, myFormQuestions.size());
        
    }



    @isTest
    static void getQuestionsC_Manager_Test(){
        User u = [
            SELECT ID, NAME, UserName
            FROM USER 
            WHERE EMAIL = 'adminuser2@testorg.com'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        List<Form__c> myFormQuestions = new List<Form__c>(); 
        test.startTest();
        myFormQuestions = FormController.getQuestionsC('All Employees', true, u.Name, u.Name, 'Testing2');
        test.stopTest();
        system.assertEquals(5, myFormQuestions.size());
    }
   @isTest
    static void getAllCategoryQuestions(){
        User u = [
            SELECT ID, NAME, UserName
            FROM USER 
            WHERE EMAIL = 'adminuser2@testorg.com'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        User u2 = [
            SELECT ID, NAME, UserName
            FROM USER 
            WHERE EMAIL = 'adminuser@testorg.com'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
       test.startTest();
       List<FormController.QuestionListWrapper> myQuestionsByCat = FormController.getAllCategoryQuestions('All Employees', false, u.Name, u.Name, u.Name);
       List<FormController.QuestionListWrapper> myQuestionsByCat2 = FormController.getAllCategoryQuestions('All Employees', false, u2.Name, u2.Name, u2.Name);
       test.stopTest();
       system.assertEquals('Personal',myQuestionsByCat[0].category);
       system.assertEquals('Soft Skills',myQuestionsByCat2[0].category);


    }
   
}