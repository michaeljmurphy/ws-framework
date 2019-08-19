
public with sharing class TestWebService
    extends VirtualWebService
    implements IWebService
    , System.Queueable
    , Database.AllowsCallouts {

    public void execute(QueueableContext ctx) {
        super.callout();
    }

    override
    public void retry() {
        super.retry();
    }

    override
    public void error() {
        super.error();
    }

    override
    public HttpResponse callout() {
        System.debug('1');

        return super.callout();
    }

    public void deserialize() {
        
    }
}
