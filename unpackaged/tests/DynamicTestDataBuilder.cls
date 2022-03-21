@IsTest
public with sharing class DynamicTestDataBuilder extends SObjectTestData implements ITestDataBuilder {
    private static final Boolean DEFAULT_BOOLEAN = false;
    private static final String DEFAULT_TEXT = 'Any Text';

    private SObjectType objectType;

    public DynamicTestDataBuilder(SObjectType objectType) {
        super();
        this.objectType = objectType;
    }

    public ITestDataBuilder with(SObjectField field, Object value) {
        this.withData(field, value);
        return this;
    }

    public SObject getNew() {
        return super.insertSObject();
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object>();
    }

    protected override SObjectType getSObjectType() {
        return this.objectType;
    }

    protected override void beforeInsert(List<SObject> records) {
        // TODO: Use constants for these
        for (SObject currentRecord : records) {
            for (SObjectField currentField : currentRecord.getSObjectType().getDescribe().fields.getMap().values()) {
                DescribeFieldResult fieldResult = currentField.getDescribe();
                if (isFieldRequired(fieldResult)) {
                    if (fieldResult.getType() == DisplayType.BOOLEAN) {
                        currentRecord.put(currentField, DEFAULT_BOOLEAN);
                    }
                    if (fieldResult.getType() == DisplayType.COMBOBOX || fieldResult.getType() == DisplayType.ENCRYPTEDSTRING ||
                        fieldResult.getType() == DisplayType.MULTIPICKLIST || fieldResult.getType() == DisplayType.PICKLIST ||
                        fieldResult.getType() == DisplayType.STRING || fieldResult.getType() == DisplayType.TEXTAREA) {
                        currentRecord.put(currentField, DEFAULT_TEXT);
                    }
                    if (fieldResult.getType() == DisplayType.CURRENCY || fieldResult.getType() == DisplayType.DOUBLE ||
                        fieldResult.getType() == DisplayType.INTEGER || fieldResult.getType() == DisplayType.LONG) {
                        currentRecord.put(currentField, 100);
                    }
                    if (fieldResult.getType() == DisplayType.DATE) {
                        currentRecord.put(currentField, Date.today());
                    }
                    if (fieldResult.getType() == DisplayType.DATETIME) {
                        currentRecord.put(currentField, Datetime.now());
                    }
                    if (fieldResult.getType() == DisplayType.EMAIL) {
                        currentRecord.put(currentField, 'example@email.com');
                    }
                    if (fieldResult.getType() == DisplayType.PERCENT) {
                        currentRecord.put(currentField, 0.5);
                    }
                    if (fieldResult.getType() == DisplayType.PHONE) {
                        currentRecord.put(currentField, '555-555-5555');
                    }
                    if (fieldResult.getType() == DisplayType.URL) {
                        currentRecord.put(currentField, 'https://www.example.com');
                    }
                }
            }
        }
    }

    private Boolean isFieldRequired(DescribeFieldResult field) {
        return field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate();
    }
}
