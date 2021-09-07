/*********************************************************************************************************************
 * copyright © 2021
 * Files    :   FormScoreCreation.cls
 *              
 * Purpose:
 * 
 * Referred from: StartEvaluationPeriodScheduler.cls
 *                
 *                
 *                  
 * Test Class Class: FormScoreCreationTest.cls
 * 
 * -------------------------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------------------------
 * 8/17/2021                    Carlos Nuñez     create (main method, future method.)
 * 8/17/2021                    Carlos Nuñez     updateUsersByGroup (called by main method to update user groups)
 * 8/17/2021                    Carlos Nuñez     createForms (called by main method to generate the forms)
 * 8/17/2021                    Carlos Nuñez     getAllSubRoleIds (auxiliary method called by updateUsersByGroup)
 * 8/17/2021                    Carlos Nuñez     format (auxiliary method called by updateUsersByGroup)
 * 8/23/2021                    Carlos Nuñez     updateLastCompletedEval (updatesT the last completed eval by employee)
 *********************************************************************************************************************/
public with sharing class FormScoreCreation {
    
   
    public static void create(){
        List<Group> publicGroups = [Select Id, Name, Type, RelatedId From Group];
        List<GroupMember> groupMembers = [Select GroupId, UserOrGroupId From GroupMember];
        List<User> users = [Select Id, Name, ManagerId, UserRoleId From User Where isActive =: true];
        List<UserRole> userRoles = [Select Id, ParentRoleId From UserRole];
        List<Score__c> scores = new List<Score__c>();
        for(User u : users){
            Score__c s = new Score__c();
            s.Employee__c = u.id;
            s.Manager__c = u.ManagerId;
            s.Start_Date__c = date.today();
            s.OwnerId = u.id;
            s.Last_Eval_Period__c = true;
            scores.add(s);
        }
        for(Group g : publicGroups){
            Set<Id> groupMembersIds = new Set<Id>();
            for(GroupMember gm : groupMembers){
                if(gm.GroupId == g.Id){
                    groupMembersIds.add(gm.UserOrGroupId);
                }
            }
            if(groupMembersIds.size()>0){
                updateUsersByGroup(g.Name, groupMembersIds, publicGroups, users, userRoles, scores);
            }
        }
        createForms(publicGroups, groupMembers, scores);
    }
    
    public static void updateUsersByGroup(string groupName, Set<Id> groupMembersIds, List<Group> publicGroups, List<User> allUsers, List<UserRole> userRoles, List<Score__c> currentScores){
        Set<Id> userIds = new Set<Id>();
        Set<Id> nonUserIds = new Set<Id>();
        Set<Id> rolesIds = new Set<Id>();
        Set<Id> findSubordinatesOfIds = new Set<Id>();
        Set<Id> groupsAsMemberIds = new Set<Id>();
        List<User> users = new List<User>();
        for(Id groupMemberId : groupMembersIds){
            if(String.valueOf(groupMemberId).startsWith('005')){
                userIds.add(groupMemberId);
            }
            else if(String.valueOf(groupMemberId).startsWith('00G')){
                nonUserIds.add(groupMemberId);
            }
        }
        List<Group> nonUsers = new List<Group>();
        for(Group g : publicGroups){
            if(nonUserIds.contains(g.id)){
                nonUsers.add(g);
            }
        }
        for(Group g : nonUsers){
            if(g.Type == 'Role'){
                rolesIds.add(g.RelatedId);
            }
            else if(g.Type == 'RoleAndSubordinates'){
                rolesIds.add(g.RelatedId);
                findSubordinatesOfIds.add(g.RelatedId);
            }
            else if(g.Type == 'Regular'){
                groupsAsMemberIds.add(g.RelatedId);
            }
        }
        rolesIds.addAll(getAllSubRoleIds(findSubordinatesOfIds, userRoles));
        for(User u : allUsers){
            if(userIds.contains(u.Id) || rolesIds.contains(u.UserRoleId)){
                users.add(u);
            }
        }
        system.debug(users.size());
        List<Score__c> scores = new List<Score__c>();
		for(User u : users){
            system.debug(u.Name);
            List<String> values = new List<String>();
            Boolean flag = false;
            for(Score__c s : currentScores){
                if(s.Employee__c == u.id){
                    values.add(s.Group__c);
                    values.add(groupName);
                    s.Group__c = format(values);
                    flag = true;
                    scores.add(s);
                }
            }
        }
        upsert(scores);
    }
    
    public static void createForms(List<Group> publicGroups, List<GroupMember> groupMembers, List<Score__c> scores){
        List<Question__c> questions = [Select id, Question_Text__c, For__c, Category__c, Points__c, For_Manager__c from question__c where for__c != null];
        List<String> groups = new List<String>();
        List<Form__c> forms = new list<Form__c>();
        List<Form__c> forms2 = new list<Form__c>();
        List<Forms_Group__c> fgs = new list<Forms_Group__c>();
        Form__c f;
        Forms_Group__c fg;
        for(Group g : publicGroups){
            List <GroupMember> gm = new List<GroupMember>();
            for(GroupMember grme : groupMembers){
                if(grme.GroupId == g.Id){
                    gm.add(grme);
                }
            }
            
            if(gm.size() > 0){
                groups.add(g.Name);
            }
        }
        for(Score__c s2 : scores){
            if(s2.Group__c != null){
                decimal points = 0.0;
                forms.clear();
                for(String p : groups){
                    decimal points2 = 0.0;
                	for(Question__c q : questions){
                        if(s2.Group__c.contains(p) && q.For__c.contains(p) && q.For_Manager__c == false){
                            f = new Form__c();
                            f.Employee__c = s2.Employee__c;
                            f.Manager__c = s2.Manager__c;
                            f.Start_Date__c = date.today();
                            f.Points__c = q.Points__c;
                            f.Question_Text__c = q.Question_Text__c;
                            f.Score__c = s2.Id;
                            f.For__c = p;
                            f.Category__c = q.Category__c;
                            f.Active_Period__c = true;
                            forms.add(f);
                            points+=q.Points__c;
                            points2+=q.Points__c;
                        }
                        if(s2.Group__c.contains(p) && q.For__c.contains(p) && q.For_Manager__c == true && s2.Manager__c != null){
                            f = new Form__c();
                            f.Employee__c = s2.Employee__c;
                            f.Manager__c = s2.Manager__c;
                            f.Start_Date__c = date.today();
                            f.Points__c = q.Points__c;
                            f.Question_Text__c = q.Question_Text__c;
                            f.Score__c = s2.Id;
                            f.For_Manager__c = true;
                            f.For__c = p;
                            f.Category__c = q.Category__c;
                            f.Active_Period__c = true;
                            forms.add(f);
                            points+=q.Points__c;
                            points2+=q.Points__c;
                        }                        
                    }
                    if(points2 > 0){
                        fg = new Forms_Group__c();
                        fg.Group__c = p;
                        fg.Score__c = s2.Id;
                        fg.Total_Form_Points__c = points2;
                        fg.Active_Period__c = true;
                        fgs.add(fg);
                    }
                }
                for(Form__c f2 : forms){
                    f2.Total_Points__c = points;
                    forms2.add(f2);
                }
            }
        }
        insert(forms2);
        insert(fgs);
    }

    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds, List<UserRole> userRoles) {
        Set<ID> currentRoleIds = new Set<ID>();
        for(UserRole ur : userRoles){
            if(roleIds.contains(ur.ParentRoleId) && ur.ParentRoleId != null){
                currentRoleIds.add(ur.Id);
            }
        }
        if(currentRoleIds.size() > 0)
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds, userRoles));
        return currentRoleIds;
    }
    
    public static String format(Set<String> values) {
        if (values == null) return null;
        List<String> l = new List<String>(values);
        l.sort();
        return format(l);
    }
    
    public static String format(List<String> values) {
        if (values == null) return null;
        return String.join(values, ';');
    }
    
    public static void updateLastCompletedEval(){
        List<Score__c> scores = [Select Id, Last_Eval_Period__c, Min_Question_Score__c, Last_Completed_Eval__c, Employee__c From Score__c];
        List<Score__c> latestScores = new List<Score__c>();
        List<Score__c> lastCompleted = new List<Score__c>();
        List<Forms_Group__c> formsGroups = [Select Id, Score__c, Group__c, Form_Score__c, Total_Form_Points__c From Forms_Group__c Where Active_Period__c = :true];
        List<Form__c> forms = [Select Id, Score__c, For__c, Answer__c, Points__c From Form__c Where Active_Period__c = :true];
        for(Score__c s : scores){
            if(s.Last_Eval_Period__c == true){
                latestScores.add(s);
            }
            if(s.Last_Completed_Eval__c == true){
                lastCompleted.add(s);
            }
        }
        
        for(Score__c s : latestScores){
            for(Forms_Group__c fg : formsGroups){
                if(fg.Score__c == s.Id && s.Min_Question_Score__c > 0){
                    decimal points = 0;
                    for(Form__c f : forms)
                    {
                        if(fg.Score__c == f.Score__c && fg.Group__c == f.For__c){
                            points += f.Answer__c*f.Points__c;
                        }
                    }
                    fg.Form_Score__c = points/fg.Total_Form_Points__c;
                }
            }
               
            s.Last_Eval_Period__c = false;
            if(s.Min_Question_Score__c > 0){
                s.Last_Completed_Eval__c = true;
                for(Score__c s2 : lastCompleted){
                    if(s.Employee__c == s2.Employee__c){
                        s2.Last_Completed_Eval__c = false;
                    }
                }
            }
        }
        for(Forms_Group__c fg : formsGroups)
        {
            fg.Active_Period__c = false;
        }
        for(Form__c f : forms)
        {
            f.Active_Period__c = false;
        }
        update(latestScores);
        update(lastCompleted);
        update(formsGroups);
        update(forms);
    }
}