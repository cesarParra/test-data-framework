public with sharing class AccountTestDataBuilder extends SObjectTestDataBuilder {
    public ITestDataBuilder with(SObjectField field, Object value) {
        this.withData(field, value);
        return this;
    }

    public override SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public Account getNew() {
        return (Account)this.insertSObject();
    }

    public List<SObject> getNew(Integer numberOfRecords) {
        return this.insertSObjects(numberOfRecords);
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object> {
            Account.Name => 'ACME'
        };
    }
}
