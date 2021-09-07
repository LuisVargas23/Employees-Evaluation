/***************************************************************************************************
 * copyright © 2021
 * Files    :   SendNotificationEmailService.cls
 *              
 * Purpose  : 
 *
 * Referred from: 
 *                   
 * Test Class Class: ScoreControllerTest.cls
 * 
 * Created By: Luis Vargas on 8/6/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 8/13/2021                    Luis Vargas      Initial Creation
 ***************************************************************************************************/

public with sharing class ScoreController {
    public static List<Score__c> getLowScoreCards(){
        Datetime startEvaluationPeriod = system.Now()-7;
        return [SELECT Id, Employee__r.Name, Score__c, CreatedDAte
                                        FROM Score__c
                                        WHERE Score__c < 3 AND CreatedDate >= :startEvaluationPeriod];
    }

    
    @AuraEnabled
    public static Score__c getMyScoreCard(String Name){
        return [SELECT Id, Employee__r.Name, Score__c, Recommendations__c
                                        FROM Score__c WHERE Employee__r.Name = :Name Limit 1];
                                        
    }

    

    public static List<Score__c> getHighScoreCards(){
        Datetime startEvaluationPeriod = system.Now()-7;
        List<Score__c> myHighScoreCards = new List<Score__c>();
        for(Score__c myScore :[SELECT Id, Employee__r.Name, Score__c, CreatedDAte, Recommendations__c FROM Score__c WHERE Score__c >= 9 AND CreatedDate > :startEvaluationPeriod]){
            if(!String.isBlank(myScore.Recommendations__c)){
                myHighScoreCards.add(myScore);
            }
        }
        
        return myHighScoreCards;

    }

    public static Approval.ProcessResult[] publicResults = null;
    public static void submitScoreCardsForApproval(){        
        List<Score__c> scoreCards = getHighScoreCards();
        // Create an approval request for Score__c    
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        for(Score__c myScore:scoreCards){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('Submitting approval request');        
            req.setObjectId(myScore.id);
            requests.add(req);

        }    
        // Submit the approval request for the score cards       
        Approval.ProcessResult[] results = null;
        try {
                results = Approval.process(requests, true);
                publicResults = results;
            }catch (System.DmlException e) {
            System.debug('Exception Is ' + e.getMessage());
            }


    }     
    


}
