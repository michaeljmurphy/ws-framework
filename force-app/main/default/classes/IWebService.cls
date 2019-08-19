/* @author: michael murphy
 * @date: <2019-08-19 Mon>
 * @description: interface for web services
 * @history: <2019-08-19 Mon> : michael murphy: Created
 * */

public interface IWebService {
    HttpResponse callout();
    void error();
    void retry();
    void deserialize();
}
