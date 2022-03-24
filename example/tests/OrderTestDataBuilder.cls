public with sharing class OrderTestDataBuilder extends SObjectTestDataBuilder implements ITestDataBuilder {
    public override SObjectType getSObjectType() {
        return Order__c.SObjectType;
    }

    public OrderTestDataBuilder with(SObjectField field, Object value) {
        return (OrderTestDataBuilder) withData(field, value);
    }

    public Order__c insertNew() {
        return (Order__c) this.insertSObject();
    }

    public List<SObject> insertNew(Integer numberOfRecords) {
        return this.insertSObjects(numberOfRecords);
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object> {
            Order__c.Customer__c => bindTo(SObjectTestDataBuilder.of(Account.SObjectType))
        };
    }
}
