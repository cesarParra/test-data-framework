public interface ITestDataCallback {
    void beforeInsert(List<SObject> records);
    void afterInsert(List<SObject> records);
}
