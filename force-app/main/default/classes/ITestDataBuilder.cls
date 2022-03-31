/**
 * @description Base interface to create custom test data builders. Any custom TestDataBuilder must implement this
 *              interface and extend {@link SObjectTestDataBuilder}.
 */
public interface ITestDataBuilder {
    ITestDataBuilder with(SObjectField field, Object value);
    ITestDataBuilder withChild(ITestDataBuilder childBuilder, SObjectField relationshipField);
    SObjectType getSObjectType();
    SObject registerNewForInsert();
    List<SObject> registerNewForInsert(Integer numberOfRecords);
}
