@isTest
private class FormScoreCreationTest {
    @TestSetup
    private static void makeData(){
        List<Question__c> sampleQuestionList = new List<Question__c>();
        for(integer i = 1; i <= 10; i++){
            Question__c myQuestion = new Question__c();
            myQuestion.Question_Text__c = 'This is the Question ' + i + ' ?';
            myQuestion.Category__c = 'Soft Skills';
            myQuestion.Available_in_Pool__c = true;
            myQuestion.For__c = 'Group 1; Group 2';
            myQuestion.For_Manager__c = false;
            myQuestion.Points__c = 3;
            sampleQuestionList.add(myQuestion);
        }
         for(integer i = 11; i <= 20; i++){
            Question__c myQuestion = new Question__c();
            myQuestion.Question_Text__c = 'This is the Question ' + i + ' ?';
            myQuestion.Category__c = 'Hard Skills';
            myQuestion.Available_in_Pool__c = true;
            myQuestion.For__c = 'Group 2; Group 3';
            myQuestion.For_Manager__c = false;
            myQuestion.Points__c = 4;
            sampleQuestionList.add(myQuestion);
        }
        for(integer i = 21; i <= 30; i++){
            Question__c myQuestion = new Question__c();
            myQuestion.Question_Text__c = 'This is the Question ' + i + ' ?';
            myQuestion.Category__c = 'Personal';
            myQuestion.Available_in_Pool__c = true;
            myQuestion.For__c = 'Group 3; Group 4';
            myQuestion.For_Manager__c = false;
            myQuestion.Points__c = 5;
            sampleQuestionList.add(myQuestion);
        }
        for(integer i = 31; i <= 50; i++){
            Question__c myQuestion = new Question__c();
            myQuestion.Question_Text__c = 'This is the Question ' + i + ' ?';
            myQuestion.Category__c = 'Hard Skills';
            myQuestion.Available_in_Pool__c = true;
            myQuestion.For__c = 'Group 5';
            myQuestion.For_Manager__c = true;
            myQuestion.Points__c = 6;
            sampleQuestionList.add(myQuestion);
        }
        insert sampleQuestionList;
        
        List<Group> groups = new List<Group>();
        for(integer i = 1; i <= 5; i++){
            Group g = new Group(Name = 'Group ' + i);
            groups.add(g);
        }
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            insert groups;
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        integer count = 0;
        List<User> users = new List<User>();
        for(Group g : groups){
            for(integer i = 1; i <= 5; i++){
                count ++;
                User u = new User(Alias = 'standt' + count, 
                                  Email='standarduser' + count + '@testorgarturonf.com', 
                                  EmailEncodingKey='UTF-8', 
                                  LastName='Testing' + count, 
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  ProfileId = p.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', 
                                  UserName='standarduser' + count + '@testorgarturonf.com'
                                 );
                users.add(u);
            }
        }
        insert(users);
        
        for(integer i = 1; i < users.size(); i++){
        	users[i].ManagerId = users[i-1].Id;
        }
        update(users);
        
        count = 0;
        List<GroupMember> gms = new List<GroupMember>();
        for(Group g : groups){
            for(integer i = 1; i <= 5; i++){
                
                GroupMember gm = new GroupMember();
                gm.GroupId = g.Id;
                gm.UserOrGroupId = users[count].Id;
                gms.add(gm);
        		count ++;
            }
        }
        System.runAs ( thisUser ) {
        	insert(gms);
        }
        
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
		System.runAs ( thisUser ) {
            insert r;
        }
        User u = new User(Alias = 'standt' + 99, 
                          Email='standarduser' + 99 + '@testorgarturonf.com', 
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing' + 99, 
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='standarduser' + 99 + '@testorgarturonf.com',
                          UserRoleId = r.Id
                         );
        System.runAs ( thisUser ) {
        	insert(u);
        }
        Group g = new Group(Name = 'Group 99');
        System.runAs ( thisUser ) {
        	insert(g);
        }
        List<Group> groupsIDB = [Select Id, Type, RelatedId From Group];
        GroupMember gm = new GroupMember();
        gm.GroupId = g.Id;
        for(Group g2 : groupsIDB){
            if(g2.RelatedId == r.Id && g2.Type == 'RoleAndSubordinates'){
                gm.UserOrGroupId = g2.Id;
            }
        }
        System.runAs ( thisUser ) {
        	insert(gm);
        }
        
    }
    @isTest
    private static void test1(){
        test.startTest();
        List<Group> groups = [Select Id, Name From Group Where Name Like 'Group%'];
        List<User> users = [Select Id From User Where Name Like 'Testing%'];
        List<GroupMember> gms = [Select Id, GroupId, UserOrGroupId From GroupMember];
        List<GroupMember> fgms = new List<GroupMember>();
        List<Question__c> questions = [Select Id From Question__c];
        List<Id> groupsIds = new List<Id>();
        List<Id> usersIds = new List<Id>();
        integer counter = 0;
        groupsIds.addAll((new Map<Id,SObject>(groups)).keySet());
        usersIds.addAll((new Map<Id,SObject>(users)).keySet());
        for(GroupMember gm : gms){
            if(groupsIds.contains(gm.GroupId)){
                fgms.add(gm);
            }
            if(usersIds.contains(gm.UserOrGroupId)){
                counter ++;
            }
        }
        test.stopTest();
        system.assertEquals(6, groups.size());
        system.assertEquals(26, users.size());
        system.assertEquals(26, fgms.size());
        system.assertEquals(25, counter);
        system.assertEquals(50, questions.size());
    }
    @isTest
    private static void test2(){
        test.startTest();
        FormScoreCreation.Create();
        List<Form__c> forms = [Select ID, Total_Points__c, Answer__c from Form__c order by total_points__c];
        for(form__c f : forms){
            f.Answer__c = 9;
        }
        update(forms);
        FormScoreCreation.updateLastCompletedEval();
        test.stopTest();
        system.assertEquals(400, forms.size());
        for(integer i = 0; i<50; i++){
            system.assertEquals(30.0,forms[i].Total_Points__c);
        }
        for(integer i = 50; i<100; i++){
            system.assertEquals(50.0,forms[i].Total_Points__c);
        }
        for(integer i = 100; i<200; i++){
            system.assertEquals(70.0,forms[i].Total_Points__c);
        }
        for(integer i = 200; i<300; i++){
            system.assertEquals(90.0,forms[i].Total_Points__c);
        }
        for(integer i = 300; i<400; i++){
            system.assertEquals(120.0,forms[i].Total_Points__c);
        }
    }
    @isTest
    private static void test3(){
        test.startTest();
        FormScoreCreation.Create();
        List<Forms_Group__c> formsGroups = [Select Id From Forms_Group__c];
        test.stopTest();
        system.assertEquals(25,formsGroups.size());
    }
}