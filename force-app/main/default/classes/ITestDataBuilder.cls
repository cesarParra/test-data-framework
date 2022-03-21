/**
 * @description
 * @group
 */
public interface ITestDataBuilder {
    ITestDataBuilder with(SObjectField field, Object value);
    SObject getNew();
    // TODO: Maybe we can have a getAny here that tries to see if there's already an existing one to avoid queries
}
