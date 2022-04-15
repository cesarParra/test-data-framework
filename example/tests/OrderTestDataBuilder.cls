@IsTest
public with sharing class OrderTestDataBuilder extends SObjectTestDataBuilder implements ITestDataBuilder {
    public override SObjectType getSObjectType() {
        return Order__c.SObjectType;
    }

    public OrderTestDataBuilder with(SObjectField field, Object value) {
        return (OrderTestDataBuilder) withData(field, value);
    }

    public Order__c registerNewForInsert() {
        return (Order__c) this.registerSObjectForInsert();
    }

    public List<SObject> registerNewForInsert(Integer numberOfRecords) {
        return this.registerSObjectsForInsert(numberOfRecords);
    }

    public OrderTestDataBuilder withChild(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        return (OrderTestDataBuilder)this.withChildData(childBuilder, relationshipField);
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object> {
            Order__c.Customer__c => bindTo(SObjectTestDataBuilder.of(Account.SObjectType))
        };
    }
}
