public interface ITestDataBuilder {
    ITestDataBuilder with(SObjectField field, Object value);
    SObjectType getSObjectType();
    SObject buildNew();
    List<SObject> buildNew(Integer numberOfRecords);
}
