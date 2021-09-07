/***************************************************************************************************
 * copyright © 2021
 * Files    :   SendNotificationEmailService.cls
 *              
 * Purpose  : Sends Email notifications
 *
 * Referred from: StartEvaluationPeriodScheduler.cls
 *                FinishEvaluationPeriodScheduler.cls
 *                DailyNotificationScheduler.cls
 *                BeforeDailyNotificationScheduler.cls
 *                   
 * Test Class Class: SendNotificationEmailServiceTest.cls
 * 
 * Created By: Luis Vargas on 8/6/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 8/6/2021                    Luis Vargas      Initial Creation
 ***************************************************************************************************/

global with sharing class SendNotificationEmailService implements Database.Batchable<sObject>  {

    public SendNotificationEmailService(String strParam) {
        strParameter = strParam;
    }
    private String strParameter;
    public static List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
    //public static  List<Id> Users = getUserIds();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator([SELECT Id, Name, IsActive, UserRole.Name, Email FROM User WHERE IsActive=true AND Email != 'noreply@00d5e000002i6bleas' AND Email != 'autoproc@00d5e000002i6bleas' AND Email != 'automatedclean@00d5e000002i6bleas' AND Email != 'insightssecurity@example.com' AND Email != 'integration@example.com' AND Email='luis.vargas@theksquaregroup.com' WITH SECURITY_ENFORCED]);

    }
    global void execute(Database.BatchableContext BC, List<User> usrList) {
       switch on strParameter {
            when '1' {		// when block 1
                sendStartSemestralNotificationEmail(usrList);
            }	
            when '2' {		// when block 2
                sendFinishSemestralNotificationEmail(usrList);

            }
            when '3' {		// when block 3
                sendDailyNotificationEmail(usrList);
            }
            when '4' {		// when block 4
                sendBeforeDailyNotificationEmail(usrList);
            }   
            when '5' {		// when block 5
                sendLowScoreEmail(usrList);
            } 
            
            when else {		  // default block, optional
                system.debug('error');
            }
        }
        
    
    }

    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
        system.debug('Done');
    }

    public static void sendStartSemestralNotificationEmail(List<User> myUsers){
        List<Id> Users = new List<Id>();
        for(User u:myUsers){
            Users.add(u.Id);
        }
        Messaging.reserveSingleEmailCapacity(10);
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        mail.setSaveAsActivity(false); 
        EmailTemplate thisEmailTemplate = getEmailTemplate('Evaluation_App_Start_Evaluation_Period');
        mail.setTemplateID(thisEmailTemplate.Id); 
        mail.setTargetObjectIds(Users);
        mail.setSenderDisplayName('Evaluations App');
        mail.setBccSender(false);     
        mail.setUseSignature(false);    
        results = Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });       
       
    }

    public static void sendFinishSemestralNotificationEmail(List<User> myUsers){
        List<Id> Users = new List<Id>();
        for(User u:myUsers){
            Users.add(u.Id);
        }
        Messaging.reserveSingleEmailCapacity(10);
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        mail.setSaveAsActivity(false); 
        mail.setSenderDisplayName('Evaluations App');
        EmailTemplate thisEmailTemplate = getEmailTemplate('Evaluation_App_Finish_Evaluation_Period');
        mail.setTemplateID(thisEmailTemplate.Id); 
        mail.setTargetObjectIds(Users);    
        mail.setBccSender(false);     
        mail.setUseSignature(false);    
        results = Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });       
    }
    
    public static void sendDailyNotificationEmail(List<User> myUsers){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String thisDate = String.Valueof(SchedulerServiceController.getCurrentlyScheduledJobs('Send daily reminders'));
        EmailTemplate thisEmailTemplate = getEmailTemplate('Evaluation_App_Daily_Reminder');
        ThisEmailTemplate.Body=thisEmailTemplate.Body.replace('{FinishEvaluationPeriod}', thisDate);
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/n/Evaluation_Forms';
        ThisEmailTemplate.Body=thisEmailTemplate.Body.replace('{OrgLink}', baseUrl);
        for(User u:myUsers){
           // Messaging.reserveSingleEmailCapacity(10);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
            mail.setSaveAsActivity(false); 
            mail.setSenderDisplayName('Evaluations App');
            mail.setSubject(ThisEmailTemplate.Subject);
            mail.setPlainTextBody(ThisEmailTemplate.Body);
            mail.setTemplateID(thisEmailTemplate.Id); 
            mail.setTargetObjectId(u.id);    
            mail.setBccSender(false);     
            mail.setUseSignature(false);    
            mail.setSaveAsActivity(false);
            mails.add(mail);
           }
        results = Messaging.sendEmail(mails);  
    }

    public static void sendBeforeDailyNotificationEmail(List<User> myUsers){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String thisDate = String.ValueOf(SchedulerServiceController.getCurrentlyScheduledJobs('Send daily reminders before the evaluation begins'));
        EmailTemplate thisEmailTemplate = getEmailTemplate('Evaluation_App_Before_EE_Starts_Reminder');
        ThisEmailTemplate.Body=thisEmailTemplate.Body.replace('{StartEvaluationPeriod}', thisDate);
        for(User u:myUsers){
           // Messaging.reserveSingleEmailCapacity(10);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
            mail.setSaveAsActivity(false); 
            mail.setSenderDisplayName('Evaluations App');
            mail.setSubject(ThisEmailTemplate.Subject);
            mail.setPlainTextBody(ThisEmailTemplate.Body);
            mail.setTemplateID(thisEmailTemplate.Id); 
            mail.setTargetObjectId(u.Id);    
            mail.setBccSender(false);     
            mail.setUseSignature(false);    
            mail.setSaveAsActivity(false);
            mails.add(mail);
            }
            results = Messaging.sendEmail(mails);
      
    }

    public static void sendLowScoreEmail(List<User> myUsers){
        system.debug(myUsers);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate thisEmailTemplate = getEmailTemplate('Evaluation_App_Low_Score_Email_Notification_HTML');
        List<score__c> myScoreCards = ScoreController.getLowScoreCards();
        String htmlBody = '';
        for(score__c thisScoreCard:myScoreCards){
            String htmlParagraph = '<div align="center"><br><table width="650" border="0" align="center" cellpadding="0" cellspacing="0">'+'<tr>'+'<td height="20" width="100%" style="font-size: 14px; line-height: 14px;">' + thisScoreCard.employee__r.Name + '</td>' + '<td height="20" width="100%" style="font-size: 14px; line-height: 14px;">' + thisScoreCard.score__c + ' </td></tr></table><br></div>';
            htmlBody = htmlBody + htmlParagraph;
        }
        ThisEmailTemplate.Body=thisEmailTemplate.Body.replace('{ScoreTable}', htmlBody);
        for(User u:myUsers){
            if(u.UserRole.Name == 'HHRR' || u.UserRole.Name == 'HR'){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
               // Messaging.reserveSingleEmailCapacity(10);
                mail.setSaveAsActivity(false); 
                mail.setSenderDisplayName('Evaluations App');
                mail.setSubject(ThisEmailTemplate.Subject);
                //mail.setPlainTextBody(ThisEmailTemplate.Body);
                mail.setHTMLBody(ThisEmailTemplate.Body);
                mail.setTemplateID(thisEmailTemplate.Id); 
                mail.setTargetObjectId(u.Id);    
                mail.setBccSender(false);     
                mail.setUseSignature(false);    
                mail.setSaveAsActivity(false);
                mails.add(mail);
                }

            results = Messaging.sendEmail(mails);
        }
    
    }

    public static EmailTemplate getEmailTemplate(String templateName){
        
        return [SELECT Id, HTMLValue, Body, Subject, DeveloperName
                FROM EmailTemplate 
                WHERE DeveloperName = :templateName 
                WITH SECURITY_ENFORCED];
    }  

}