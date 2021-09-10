public with sharing class SampleData {
    public static void create(){
        List<Form__c> forms = new List<Form__c>();
        List<Forms_Group__c> formsGroups = new List<FormS_Group__c>();
        List<User> users = [Select Id, ManagerId From User Where IsActive = True];
        
        for(User u : users){
            for(integer i = 1; i <= 5; i++){
                score__c s = new score__c();
                if(i == 1){
                    s.Last_Completed_Eval__c = true;
                }
                s.Employee__c = u.id;
                s.OwnerId = u.id;
                s.Start_Date__c = date.today()-i;
                if(u.ManagerId != NULL){
                    s.Manager__c = u.ManagerId;
                }
                insert(s);
                for(integer k = 1; k <= 3; k++){
                    Forms_Group__c fg = new Forms_Group__c();
                    fg.Score__c = s.Id;
                    fg.Form_Score__c = (Integer.valueof((Math.random() * 3))+7);
                    if(k == 1){
                        fg.Group__c = 'All Employees';
                    } else if(k == 2){
                        fg.Group__c = 'Jr. Salesforce Dev';
                    } else if(k == 3){
                        fg.Group__c = 'Mexico Group';
                    }
                    formsGroups.add(fg);
                }
                for(integer j = 1; j <= 5; j++){
                    Form__c f = new Form__c();
                    f.Employee__c = s.Employee__c;
                    f.Start_Date__c = s.Start_Date__c;
                    f.Points__c = 5;
                    f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                    f.Total_Points__c = 70;
                    f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                    f.Score__c = s.Id;
                    f.Category__c = 'Other';
                    forms.add(f);
                }
                for(integer j = 6; j <= 10; j++){
                    Form__c f = new Form__c();
                    f.Employee__c = s.Employee__c;
                    f.Start_Date__c = s.Start_Date__c;
                    f.Points__c = 5;
                    f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                    f.Total_Points__c = 70;
                    f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                    f.Score__c = s.Id;
                    f.Category__c = 'Personal';
                    forms.add(f);
                }
                for(integer j = 11; j <= 15; j++){
                    Form__c f = new Form__c();
                    f.Employee__c = s.Employee__c;
                    f.Start_Date__c = s.Start_Date__c;
                    f.Points__c = 5;
                    f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                    f.Total_Points__c = 70;
                    f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                    f.Score__c = s.Id;
                    f.Category__c = 'Technical Skills';
                    forms.add(f);
                }
                for(integer j = 16; j <= 20; j++){
                    Form__c f = new Form__c();
                    f.Employee__c = s.Employee__c;
                    f.Start_Date__c = s.Start_Date__c;
                    f.Points__c = 5;
                    f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                    f.Total_Points__c = 70;
                    f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                    f.Score__c = s.Id;
                    f.Category__c = 'Soft Skills';
                    forms.add(f);
                }
            }
        }
        
        insert(forms);
        insert(formsGroups);
    }
    
    public static void create2(){
        //Delete([Select id from score__c]);
        //FormScoreCreation.create();
        List<Form__c> forms = new List<Form__c>();
        List<Forms_Group__c> formsGroups = new List<FormS_Group__c>();
        User u = [Select id from User Where name like 'Employees Evaluation Team' limit 1];
        for(integer i = 1; i <= 10; i++){
            score__c s = new score__c();
            if(i == 1){
                s.Last_Completed_Eval__c = true;
            }
            s.Employee__c = u.id;
            s.OwnerId = u.id;
            s.Start_Date__c = date.today()-i;
            insert(s);
            for(integer k = 1; k <= 3; k++){
                Forms_Group__c fg = new Forms_Group__c();
                fg.Score__c = s.Id;
                fg.Form_Score__c = (Integer.valueof((Math.random() * 3))+7);
                fg.Group__c = 'Group ' + k;
                formsGroups.add(fg);
            }
            for(integer j = 1; j <= 5; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Other';
                forms.add(f);
            }
            for(integer j = 6; j <= 10; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Personal';
                forms.add(f);
            }
            for(integer j = 11; j <= 15; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Technical Skills';
                forms.add(f);
            }
            for(integer j = 16; j <= 20; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Soft Skills';
                forms.add(f);
            }
        }
        u = [Select id from User Where name like 'Elainer Toribio' limit 1];
        for(integer i = 1; i <= 10; i++){
            score__c s = new score__c();
            if(i == 1){
                s.Last_Completed_Eval__c = true;
            }
            s.Employee__c = u.id;
            s.OwnerId = u.id;
            s.Start_Date__c = date.today()-i;
            insert(s);
            for(integer k = 1; k <= 3; k++){
                Forms_Group__c fg = new Forms_Group__c();
                fg.Score__c = s.Id;
                fg.Form_Score__c = (Integer.valueof((Math.random() * 3))+7);
                fg.Group__c = 'Group ' + k;
                formsGroups.add(fg);
            }
            for(integer j = 1; j <= 5; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Other';
                forms.add(f);
            }
            for(integer j = 6; j <= 10; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Personal';
                forms.add(f);
            }
            for(integer j = 11; j <= 15; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Technical Skills';
                forms.add(f);
            }
            for(integer j = 16; j <= 20; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Soft Skills';
                forms.add(f);
            }
        }
        u = [Select id from User Where name like 'Manager CPerez' limit 1];
        for(integer i = 1; i <= 10; i++){
            score__c s = new score__c();
            if(i == 1){
                s.Last_Completed_Eval__c = true;
            }
            s.Employee__c = u.id;
            s.OwnerId = u.id;
            s.Start_Date__c = date.today()-i;
            insert(s);
            for(integer k = 1; k <= 3; k++){
                Forms_Group__c fg = new Forms_Group__c();
                fg.Score__c = s.Id;
                fg.Form_Score__c = (Integer.valueof((Math.random() * 3))+7);
                fg.Group__c = 'Group ' + k;
                formsGroups.add(fg);
            }
            for(integer j = 1; j <= 5; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Other';
                forms.add(f);
            }
            for(integer j = 6; j <= 10; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Personal';
                forms.add(f);
            }
            for(integer j = 11; j <= 15; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Technical Skills';
                forms.add(f);
            }
            for(integer j = 16; j <= 20; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Soft Skills';
                forms.add(f);
            }
        }
        u = [Select id from User Where name like 'HHRR Role CPerez' limit 1];
        for(integer i = 1; i <= 10; i++){
            score__c s = new score__c();
            if(i == 1){
                s.Last_Completed_Eval__c = true;
            }
            s.Employee__c = u.id;
            s.OwnerId = u.id;
            s.Start_Date__c = date.today()-i;
            insert(s);
            for(integer k = 1; k <= 3; k++){
                Forms_Group__c fg = new Forms_Group__c();
                fg.Score__c = s.Id;
                fg.Form_Score__c = (Integer.valueof((Math.random() * 3))+7);
                fg.Group__c = 'Group ' + k;
                formsGroups.add(fg);
            }
            for(integer j = 1; j <= 5; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Other';
                forms.add(f);
            }
            for(integer j = 6; j <= 10; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Personal';
                forms.add(f);
            }
            for(integer j = 11; j <= 15; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Technical Skills';
                forms.add(f);
            }
            for(integer j = 16; j <= 20; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Soft Skills';
                forms.add(f);
            }
        }
        u = [Select id from User Where name like 'Employee CPerez' limit 1];
        for(integer i = 1; i <= 10; i++){
            score__c s = new score__c();
            if(i == 1){
                s.Last_Completed_Eval__c = true;
            }
            s.Employee__c = u.id;
            s.OwnerId = u.id;
            s.Start_Date__c = date.today()-i;
            insert(s);
            for(integer k = 1; k <= 3; k++){
                Forms_Group__c fg = new Forms_Group__c();
                fg.Score__c = s.Id;
                fg.Form_Score__c = (Integer.valueof((Math.random() * 3))+7);
                fg.Group__c = 'Group ' + k;
                formsGroups.add(fg);
            }
            for(integer j = 1; j <= 5; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Other';
                forms.add(f);
            }
            for(integer j = 6; j <= 10; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Personal';
                forms.add(f);
            }
            for(integer j = 11; j <= 15; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Technical Skills';
                forms.add(f);
            }
            for(integer j = 16; j <= 20; j++){
                Form__c f = new Form__c();
                f.Employee__c = s.Employee__c;
                f.Start_Date__c = s.Start_Date__c;
                f.Points__c = 5;
                f.Answer__c = (Integer.valueof((Math.random() * 5))+4);
                f.Total_Points__c = 70;
                f.Question_Text__c = 'Test Q ' + i + ' ' + j;
                f.Score__c = s.Id;
                f.Category__c = 'Soft Skills';
                forms.add(f);
            }
        }
        insert(forms);
        insert(formsGroups);
    }
}