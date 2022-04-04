/**
 * @description Callback with methods to be executed before and after database calls.
 *              Do not implement directly, rather extend {@link SObjectTestDataBuilder} and override
 *              the methods provided there.
 */
public interface ITestDataCallback {
    void beforeInsert(SObject record);
    void afterInsert(SObject record);
}
