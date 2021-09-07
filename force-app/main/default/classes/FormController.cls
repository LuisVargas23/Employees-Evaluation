/***************************************************************************************************
 * copyright © 2021
 * Files    :   FormController.cls
 *              
 * Purpose  : 
 * 
 * Referred from: 
 *                  
 * Test Class Class: FormControllerTest.cls
 * 
 * Created By: Luis Vargas 8/6/2021
 *
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 8/6/2021                    Luis Vargas      Initial Creation
 *                             Magdiel Aldana 
 ***************************************************************************************************/

public with sharing class FormController {
    //Retrieve available forms from the Form__c object
    @AuraEnabled(cacheable=false)
    public static List<Form__c> getForms() {
        return [
            SELECT Id, Name, Answer__c, Category__c, Employee__c, For__c, For_Manager__c, Manager__c, Points__c, Question_Score__c, Question_Text__c, Score__c, Start_Date__c, Total_Points__c				
            FROM Form__c 
            WITH SECURITY_ENFORCED
        ];
    }

    @AuraEnabled(cacheable=false)
    public static User getUserRole(String userId) {
        return [
            SELECT Id, Name, UserRole.Name			
            FROM User
            WHERE Id IN (:userId)
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

    }

    //Retrieve active Users in the Org
    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        return [SELECT Id, Name, Username 
        FROM User 
          WHERE IsActive = True
        WITH SECURITY_ENFORCED];
    }

    //Retrieve active picklist values in the For__c field from the Form__c object.
    @AuraEnabled(cacheable=true)
    public static List<String> getForPicklistValues(){
        List<Schema.PicklistEntry> entries = new List<Schema.PicklistEntry>(Form__c.For__c.getDescribe().getPickListValues());
        // Only return active picklist values
        List<String> picklistValues = new List<String>();
        List<Schema.PicklistEntry> activeEntries = new List<Schema.PicklistEntry>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                
                picklistValues.add((String)entry.getValue());
            }
        }
        return picklistValues;
    }

    //Get user's assigned forms
    @AuraEnabled(cacheable=true)
    public static List<String> getUserForms(String userName, String Name) {
        Score__c forms = [
            SELECT ID, Employee__r.NAME, Group__c, Employee__r.Username
            FROM Score__c
            WHERE (Employee__r.Username = :userName OR Employee__r.Name = :Name)
            AND Group__c excludes ('')
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        List<String> picklistValues = new List<String>();
        picklistValues = forms.Group__c.Split(';');

        return picklistValues;
    }
    


    //Get subordinates of a Manager
    @AuraEnabled(cacheable=false)
    public static List<User> getSubordinates(String managerName) {
        return [
            SELECT ID, NAME, MANAGERID, Manager.Name
            FROM USER 
            WHERE Manager.Name = :managerName
            WITH SECURITY_ENFORCED
         
        ];
        
    }
    
    @AuraEnabled(cacheable=false)
    public static List<QuestionListWrapper> getAllCategoryQuestions(String form, Boolean IsManager, String userName, String name, String subordinateName){
        List<QuestionListWrapper> catQuestionList = new List<QuestionListWrapper>();
        List<String> catList = QuestionController.getCategoryPicklistValues();
        List<Form__c> questionPool = getQuestionsC(form, IsManager, userName, name, subordinateName);
      
        if(!catList.isEmpty()){
            for(String cat : catList){
                QuestionListWrapper catWrapper = new QuestionListWrapper();
                List<Form__c> myList = new List<Form__c>();
                for(Form__c question:questionPool){
                    if(question.Category__c == cat){
                        myList.add(question);
                    }
                    
                }
                if(!myList.IsEmpty()){
                    catWrapper.category = cat;
                    catWrapper.questionsList = myList;
                    catQuestionList.add(catWrapper);

                } 
            }
        }
        return catQuestionList;
    }
      
    @AuraEnabled(cacheable=false)
    public static List<Form__c> getQuestionsC(String form, Boolean IsManager, String userName, String name, String subordinateName) {
        return [
            SELECT Id, Question_Text__c, Answer__c, Category__c, Points__c, For__c, Score__c, For_Manager__c
            FROM Form__c 
            WHERE For__c = :form  AND For_Manager__c = :IsManager AND (Employee__r.Name = :name OR Employee__r.UserName = :userName )
            WITH SECURITY_ENFORCED
            ORDER BY Category__c ASC
        ];
    }

    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class QuestionListWrapper{
        @AuraEnabled
        public String category{get;set;}
        @AuraEnabled
        public List<Form__c> questionsList{get;set;}
     
    }
}