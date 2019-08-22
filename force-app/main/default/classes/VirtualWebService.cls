/* @author: michael murphy
 * @date: <2019-08-19>
 * @description: this is where methods which may be overriden live for ws.  All ws should extend me
 * @history: <2019-08-19>: michael murphy: Created
 * */

public virtual class VirtualWebService {
    private static String GET = 'GET';

    protected Map<String, String> urlParameters;

    protected WebServiceSetting__mdt wsSetting;
    protected String thisClassName;


    public VirtualWebService() {
        this.thisClassName = String.valueOf(this).split(':')[0];
        this.wsSetting = getWsSettings(this.thisClassName);
        this.urlParameters = new Map<String, String> ();
    }

    protected WebServiceSetting__mdt getWsSettings(String wsName) {
        return [SELECT id
                , developername
                , retry__c
                , retry_interval_mins__c
                , uri__c
                , verb__c
                , body__c
                FROM WebServiceSetting__mdt
                WHERE developername = :wsName];
    }

    protected virtual void error() {
        throw new VirtualWebServiceException(Label.VirtualWebServiceUndefinedException);
    }

    protected void unscheduleExistingJobs() {
        List<CronTrigger> ct = [SELECT id
                                FROM crontrigger
                                WHERE cronjobdetail.name
                                LIKE :(thisClassName + '%')];

        for (CronTrigger i : ct)
            { System.abortJob(i.id); }
    }

    protected void scheduleNextRetry(Type t) {
        DateTime schedTime = DateTime.now().addMinutes((Integer)wsSetting.Retry_Interval_Mins__c);
        String cron = schedTime.second()
            + ' ' + schedTime.minute()
            + ' ' + schedTime.hour()
            + ' ' + schedTime.day()
            + ' ' + schedTime.month()
            + ' ? ' + schedTime.year();
        
        System.schedule(thisClassName + ' - ' + String.valueOf(DateTime.now())
                        , cron
                        , new WebServiceScheduler((System.Queueable)t.newInstance()));
    }


    protected virtual void retry() {
        if(!wsSetting.retry__c)
            { return; }
        
        Type t;

        try {
            t = Type.forName(thisClassName);
        } catch (Exception e) {
            System.debug(e.getMessage());
            error();
        }

        unscheduleExistingJobs();

        scheduleNextRetry(t);
    }


    protected Boolean checkResponseAndRetry(HttpResponse res) {
        return String.valueOf(res.getStatusCode()).startsWith('2');
    }

    protected virtual HttpResponse callout() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse(); 
        String uri = this.wsSetting.uri__c;

        if(!urlParameters.keySet().isEmpty()) {
            uri += '?';

            for(String i : urlParameters.keySet())
                { uri += i + '=' + urlParameters.get(i) + '&'; }

            uri = uri.removeEnd('&');
            uri = EncodingUtil.urlEncode(uri, 'UTF-8');
        }

        req.setEndpoint(uri);
        req.setMethod(this.wsSetting.verb__c);
        
        res = h.send(req);

        if(checkResponseAndRetry(res)) {
            unscheduleExistingJobs();
            return res;
        } else {
            retry();
            return null;
        }
        
    }

    protected VirtualWebService addUrlParameter(String key, String value) {
        urlParameters.put(key, value);
        return this;
    }


    public class VirtualWebServiceException extends Exception {}
}
