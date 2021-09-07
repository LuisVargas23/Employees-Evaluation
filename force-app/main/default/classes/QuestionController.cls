/***************************************************************************************************
 * copyright © 2021
 * Files    :   QuestionController.cls
 *              
 * Purpose:
 * 
 * Referred from: questionPool LWC
 *                createQuestion LWC
 *                configForm LWC
 *                  
 * Test Class Class: QuestionControllerTest.cls
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 7/25/2021                    Luis Vargas      Initial Creation
 * 7/27/2021                    Carlos Nuñez     Create getQuestions2 Method
 * 8/12/2021                    Carlos Nuñez     Create getAvailableInPicklistValues Method
 ***************************************************************************************************/
public with sharing class QuestionController {

    //Retrieve questions from the Question__c Object
    @AuraEnabled(cacheable=true)
    public static List<Question__c> getQuestions() {
        return [
            SELECT Id, Name, Question_Text__c, Available_in_Pool__c, Category__c, For_Manager__c, For__c, Points__c
            FROM Question__c 
            WITH SECURITY_ENFORCED
            ORDER BY Name DESC
        ];
    }

    //Retrieve visible questions (Available_in_Pool__c field equals true) from the Question__c Object
    @AuraEnabled(cacheable=true)
    public static List<Question__c> getQuestions2() {
        return [
            SELECT Id, Name, Question_Text__c, Available_in_Pool__c, Category__c, For_Manager__c, For__c, Points__c
            FROM Question__c
            WHERE Available_in_Pool__c = true
            WITH SECURITY_ENFORCED
            ORDER BY Category__c ASC
        ];
    }

    //Retrieve active categories from Category__c field in the Question__c Object
    @AuraEnabled(cacheable=true)
    public static List<String> getCategoryPicklistValues(){
        List<Schema.PicklistEntry> entries = new List<Schema.PicklistEntry>(Question__c.Category__c.getDescribe().getPickListValues());
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
    
    //Retrieve active options from For__c field in the Question__c Object
    @AuraEnabled(cacheable=true)
    public static List<String> getAvailableInPicklistValues(){
        List<String> picklistValues = new List<String>();
        List<Group> publicGroups = [Select ID, Name From Group];
        for(Group g : publicGroups){
            List <GroupMember> gm = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :g.Id];
            if(gm.size() > 0){
                picklistValues.add(g.Name);
            }
        }        
        return picklistValues;
    }


    

	

}