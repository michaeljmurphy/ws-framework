/* @author: michael murphy
 * @date: <2019-08-19>
 * @description: Schedule retries of failed callouts
 * @history: <2019-08-19>: michael murphy: Created
 * */


public with sharing class WebServiceScheduler
    implements System.Schedulable, Database.AllowsCallouts {
    System.Queueable wsImp;

    public WebServiceScheduler(System.Queueable wsImp) {
        this.wsImp = wsImp;
    }

    public void execute(SchedulableContext ctx) {
        if(wsImp instanceOf IWebService) {
            System.enqueueJob(wsImp);            
        } else {
            throw new WebServiceSchedulerException('WebServiceScheduler should not schedule classes which do not implement IWebService');
        }
    }

    public class WebServiceSchedulerException extends Exception {}
}
