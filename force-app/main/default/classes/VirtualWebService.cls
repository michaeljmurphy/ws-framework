/* @author: michael murphy
 * @date: <2019-08-19>
 * @description: this is where methods which may be overriden live for ws.  All ws should extend me
 * @history: <2019-08-19>: michael murphy: Created
 * */

public virtual class VirtualWebService {
    protected WebServiceSetting__mdt wsSetting;
    protected String thisClassName;


    public VirtualWebService() {
        this.thisClassName = String.valueOf(this).split(':')[0];
        this.wsSetting = getWsSettings(this.thisClassName);
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
        throw new VirtualWebServiceException();
    }


    protected virtual void retry() {
        if(!wsSetting.retry__c)
            { return; }
        
        Type t;

        try {
            t = Type.forName(String.valueOf(this).split(':')[0]);
        } catch (Exception e) {
            System.debug(e.getMessage());
            error();
        }
        
        System.schedule(thisClassName + String.valueOf(DateTime.now())
                        , '0 ' + String.valueOf(wsSetting.Retry_Interval_Mins__c) + ' * * * ?'
                        , new WebServiceScheduler((System.Queueable)t.newInstance()));
    }

    protected virtual HttpResponse callout() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse(); 

        req.setEndpoint(this.wsSetting.uri__c);
        req.setMethod(this.wsSetting.verb__c);
        res = h.send(req);

        if(!String.valueOf(res.getStatusCode()).startsWith('2'))
            { retry(); }

        return res;
    }

    public class VirtualWebServiceException extends Exception {}
}
