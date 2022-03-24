@IsTest
public with sharing class DefaultTestDataBuilder extends SObjectTestDataBuilder {
    private SObjectType objectType;

    public DefaultTestDataBuilder(SObjectType objectType) {
        super();
        this.objectType = objectType;
    }

    public ITestDataBuilder with(SObjectField field, Object value) {
        this.withData(field, value);
        return this;
    }

    public SObject insertNew() {
        return this.insertSObject();
    }

    public List<SObject> insertNew(Integer numberOfRecords) {
        return this.insertSObjects(numberOfRecords);
    }

    public override SObjectType getSObjectType() {
        return this.objectType;
    }

    public override void beforeInsert(List<SObject> records) {
        for (SObject currentRecord : records) {
            for (SObjectField currentField : currentRecord.getSObjectType().getDescribe().fields.getMap().values()) {
                DescribeFieldResult fieldResult = currentField.getDescribe();
                if (isFieldRequired(fieldResult)) {
                    resolveDefaultValue(fieldResult, currentRecord, currentField);
                }
            }
        }
    }

    // TODO: Can we also default relationships using the bind?
    private void resolveDefaultValue(DescribeFieldResult fieldResult, SObject currentRecord, SObjectField currentField) {
        if (fieldResult.getType() == DisplayType.BOOLEAN) {
            currentRecord.put(currentField, DefaultTestData.DEFAULT_BOOLEAN);
        }
        else if (fieldResult.getType() == DisplayType.COMBOBOX || fieldResult.getType() == DisplayType.ENCRYPTEDSTRING ||
            fieldResult.getType() == DisplayType.MULTIPICKLIST || fieldResult.getType() == DisplayType.PICKLIST ||
            fieldResult.getType() == DisplayType.STRING || fieldResult.getType() == DisplayType.TEXTAREA) {
            currentRecord.put(currentField, DefaultTestData.TEXT);
        }
        else if (fieldResult.getType() == DisplayType.CURRENCY || fieldResult.getType() == DisplayType.DOUBLE ||
            fieldResult.getType() == DisplayType.INTEGER || fieldResult.getType() == DisplayType.LONG) {
            currentRecord.put(currentField, DefaultTestData.DEFAULT_NUMBER);
        }
        else if (fieldResult.getType() == DisplayType.DATE) {
            currentRecord.put(currentField, DefaultTestData.DEFAULT_DATE);
        }
        else if (fieldResult.getType() == DisplayType.DATETIME) {
            currentRecord.put(currentField, DefaultTestData.DEFAULT_DATE_TIME);
        }
        else if (fieldResult.getType() == DisplayType.EMAIL) {
            currentRecord.put(currentField, DefaultTestData.EMAIL);
        }
        else if (fieldResult.getType() == DisplayType.PERCENT) {
            currentRecord.put(currentField, DefaultTestData.PERCENT);
        }
        else if (fieldResult.getType() == DisplayType.PHONE) {
            currentRecord.put(currentField, DefaultTestData.PHONE_NUMBER);
        }
        else if (fieldResult.getType() == DisplayType.URL) {
            currentRecord.put(currentField, DefaultTestData.URL);
        }
    }

    private Boolean isFieldRequired(DescribeFieldResult field) {
        return field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate();
    }
}
