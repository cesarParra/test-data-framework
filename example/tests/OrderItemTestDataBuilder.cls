@IsTest
public with sharing class OrderItemTestDataBuilder extends SObjectTestDataBuilder implements ITestDataBuilder {
    public override SObjectType getSObjectType() {
        return OrderItem__c.SObjectType;
    }

    public OrderItemTestDataBuilder with(SObjectField field, Object value) {
        return (OrderItemTestDataBuilder) withData(field, value);
    }

    public OrderItem__c registerNewForInsert() {
        return (OrderItem__c) this.registerSObjectForInsert();
    }

    public List<OrderItem__c> registerNewForInsert(Integer numberOfRecords) {
        return this.registerSObjectsForInsert(numberOfRecords);
    }

    public OrderItemTestDataBuilder withChild(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        return (OrderItemTestDataBuilder)this.withChildData(childBuilder, relationshipField);
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object> {
            OrderItem__c.Order__c => bindTo(SObjectTestDataBuilder.of(Order__c.SObjectType)),
            OrderItem__c.Product__c => bindTo(SObjectTestDataBuilder.of(Product__c.SObjectType))
        };
    }
}
