/***************************************************************************************************
 * copyright © 2021
 * Files    :   SchedulerService.cls
 *              
 * Purpose  : 
 *
 * Referred from: StartEvaluationPeriodScheduler.cls
 *                FinishEvaluationPeriodScheduler.cls
 *                DailyNotificationScheduler.cls
 *                BeforeDailyNotificationScheduler.cls
 *                   
 * Test Class Class: SchedulerServiceTest.cls
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 8/6/2021                    Luis Vargas      Initial Creation
 ***************************************************************************************************/

 public with sharing class SchedulerService{

  //Get job details based on his jobId
  public static CronTrigger getCronTrigger(Id jobId){       
    return [
      SELECT Id, CronJobDetail.Name, State, CronExpression, NextFireTime, TimesTriggered
      FROM CronTrigger WHERE Id=:jobId
      WITH SECURITY_ENFORCED
      LIMIT 1
      ];
  }

  //Add six months to a cron expression
  public static String addSixMonths(String stringFromUser){
    List<String> cronList = stringFromUser.split(' ');
    Date myDate = Date.newInstance(Integer.valueOf(cronList[6]),Integer.valueOf(cronList[4]),Integer.valueOf(cronList[3]));
    String stringUpgraded = stringFromUser.substring(0,6);
    Date sixMonthLater = myDate.addMonths(6);
    String newDay = String.valueOf(sixMonthLater.Day());
    String newMonth = String.valueOf(sixMonthLater.Month());
    String newYear = String.valueOf(sixMonthLater.Year());
    stringUpgraded = stringUpgraded + ' ' + newDay + ' ' + newMonth + ' ? ' + newYear;
    return stringUpgraded;
  }

  //Add six months and the specified days to a cron expression
  public static String addSixMonthsAndDays(String stringFromUser, Integer days){
    String stringUpgraded = stringFromUser.substring(0,6);
    List<String> cronList = stringFromUser.split(' ');
    Integer Day = Integer.valueOf(cronList[3].split('-')[0]);
    Integer Month = Integer.valueOf(cronList[4].split('-')[0]);
    Integer Year = Integer.valueOf(cronList[6].split('-')[0]);
    Date myDate = Date.newInstance(Year,Month,Day);
    Date sixMonthLater = myDate.addMonths(6);
    Date sixMonthLaterPlusDays = sixMonthLater.addDays(days);
    String newDay = String.valueOf(sixMonthLater.Day());
    String newDayPlus= String.valueOf(sixMonthLaterPlusDays.Day());
    String newMonth = String.valueOf(sixMonthLater.Month());
    String newMonthPlus = String.valueOf(sixMonthLaterPlusDays.Month());
    String newYear = String.valueOf(sixMonthLater.Year());
    String newYearPlus = String.valueOf(sixMonthLaterPlusDays.Year());
    stringUpgraded = stringUpgraded + ' ' + newDay + '-' + newDayPlus + ' ' + newMonth  + '-' + newMonthPlus  + ' ? ' + newYear + '-' + newYearPlus;
    return stringUpgraded;
    }
  }