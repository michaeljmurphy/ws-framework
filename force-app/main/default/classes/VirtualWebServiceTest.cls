/* @author: michael murphy
 * @date: <2019-08-22>
 * @description: test class for virtual web service / ws fwk
 * @history: <2019-08-22>: michael murphy: Created
 * */


@isTest
public class VirtualWebServiceTest {
    private static String STATIC_RESOURCE_MOCK = 'WebServiceCalloutMock';

    @testSetup
    public static void testSetup() {
        
    }


    @isTest
    public static void testCallout() {
        setUpMock(201);

        TestWebService t = new TestWebService();
        HttpResponse res = t.callout();
    }


    @isTest
    public static void testRetry() {
        String testClassName = 'TestWebService';
        
        setUpMock(401);

        TestWebService t = new TestWebService();

        Test.startTest();

        HttpResponse res = t.callout();

        Test.stopTest();

        System.assert([select id, cronjobdetail.name
                       from crontrigger
                       where cronjobdetail.name
                       like :(testClassName + '%')].size() > 0);
    }

    @isTest
    public static void testTestWebService() {
        // line runner
        setUpMock(201);

        TestWebService t = new TestWebService();

        try {
            t.error();
        } catch (Exception e) {
            System.assert(e.getMessage() == Label.VirtualWebServiceUndefinedException);
        }

        t.deserialize(); // not implemented

        t.retry();

        System.enqueueJob(new TestWebService());
    }

    private static void setUpMock(Integer statusCode) {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(STATIC_RESOURCE_MOCK);
        mock.setStatusCode(statusCode);
        
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);        
    }

}
