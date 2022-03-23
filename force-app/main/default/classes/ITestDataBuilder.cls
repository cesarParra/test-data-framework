/**
 * @description Base interface to create custom test data builders.
 */
public interface ITestDataBuilder {
    /**
     * @description Sets the value for a field.
     * @param field The field for which the value will be set.
     * @param value The value to set.
     * @return An updated version of this instance.
     */
    ITestDataBuilder with(SObjectField field, Object value);
    ITestDataBuilder withChild(ITestDataBuilder childBuilder, SObjectField relationshipField);
    SObjectType getSObjectType();
    SObject createNew();
    List<SObject> createNew(Integer numberOfRecords);
    SObject insertNew();
    List<SObject> insertNew(Integer numberOfRecords);
}
