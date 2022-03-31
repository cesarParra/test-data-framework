/**
 * @description Base TestDataBuilder implementation that provides default dummy data. This class gets used as a fallback
 *              for SObjectTypes for which a custom TestDataImplementation could not be found
 * @see DefaultTestData
 * @see SObjectTestDataBuilder
 * @see ITestDataBuilder
 */
@IsTest
public with sharing class DefaultTestDataBuilder extends SObjectTestDataBuilder implements ITestDataBuilder {
    private SObjectType objectType;

    public DefaultTestDataBuilder(SObjectType objectType) {
        super();
        this.objectType = objectType;
    }

    public DefaultTestDataBuilder with(SObjectField field, Object value) {
        this.withData(field, value);
        return this;
    }

    public DefaultTestDataBuilder withChild(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        return (DefaultTestDataBuilder)this.withChildData(childBuilder, relationshipField);
    }

    public SObject registerNewForInsert() {
        return this.registerSObjectForInsert();
    }

    public List<SObject> registerNewForInsert(Integer numberOfRecords) {
        return this.registerSObjectsForInsert(numberOfRecords);
    }

    public override SObjectType getSObjectType() {
        return this.objectType;
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        Map<SObjectField, Object> defaultValueMap = new Map<SObjectField, Object>();
        for (SObjectField currentField : getSObjectType().getDescribe().fields.getMap().values()) {
            DescribeFieldResult fieldResult = currentField.getDescribe();
            if (isFieldRequired(fieldResult)) {
                defaultValueMap.put(currentField, resolveDefaultValue(fieldResult));
            }
        }
        return defaultValueMap;
    }

    private Object resolveDefaultValue(DescribeFieldResult fieldResult) {
        if ((fieldResult.getType() == DisplayType.ID || fieldResult.getType() == DisplayType.REFERENCE)
            && fieldResult.getReferenceTo().size() > 0) {
            return bindTo(SObjectTestDataBuilder.of(fieldResult.getReferenceTo()[0]));
        }
        if (fieldResult.getType() == DisplayType.BOOLEAN) {
            return DefaultTestData.DEFAULT_BOOLEAN;
        }
        if (fieldResult.getType() == DisplayType.COMBOBOX || fieldResult.getType() == DisplayType.ENCRYPTEDSTRING ||
            fieldResult.getType() == DisplayType.MULTIPICKLIST || fieldResult.getType() == DisplayType.PICKLIST ||
            fieldResult.getType() == DisplayType.STRING || fieldResult.getType() == DisplayType.TEXTAREA) {
            return DefaultTestData.TEXT;
        }
        if (fieldResult.getType() == DisplayType.CURRENCY || fieldResult.getType() == DisplayType.DOUBLE ||
            fieldResult.getType() == DisplayType.INTEGER || fieldResult.getType() == DisplayType.LONG) {
            return DefaultTestData.DEFAULT_NUMBER;
        }
        if (fieldResult.getType() == DisplayType.DATE) {
            return DefaultTestData.DEFAULT_DATE;
        }
        if (fieldResult.getType() == DisplayType.DATETIME) {
            return DefaultTestData.DEFAULT_DATE_TIME;
        }
        if (fieldResult.getType() == DisplayType.EMAIL) {
            return DefaultTestData.EMAIL;
        }
        if (fieldResult.getType() == DisplayType.PERCENT) {
            return DefaultTestData.PERCENT;
        }
        if (fieldResult.getType() == DisplayType.PHONE) {
            return DefaultTestData.PHONE_NUMBER;
        }
        if (fieldResult.getType() == DisplayType.URL) {
            return DefaultTestData.URL;
        }

        throw new SObjectTestDataBuilder.SObjectTestDataBuilderException('Could not resolve default field for ' +
            fieldResult.getName());
    }

    private Boolean isFieldRequired(DescribeFieldResult field) {
        return field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate();
    }
}
