@IsTest
public with sharing class TestDataCallback {
    public interface ITestDataCallback {
        void beforeInsert(SObject record);
        void afterInsert(SObject record);
    }

    // TODO: I don't think this is needed anymore, so we can just keep the interface
    public with sharing class NullTestDataCallback implements ITestDataCallback {
        public void beforeInsert(SObject record) {}
        public void afterInsert(SObject record) {}
    }
}
