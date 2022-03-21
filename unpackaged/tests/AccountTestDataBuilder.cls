public with sharing class AccountTestDataBuilder extends SObjectTestDataBuilder {
    public ITestDataBuilder with(SObjectField field, Object value) {
        this.withData(field, value);
        return this;
    }

    public override SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public Account buildNew() {
        return (Account)this.insertSObject();
    }

    public List<SObject> buildNew(Integer numberOfRecords) {
        return this.insertSObjects(numberOfRecords);
    }

    public AccountTestDataBuilder withChildContact() {
        this.withChildren(SObjectTestDataBuilder.of(Contact.SObjectType), Contact.AccountId);
        return this;
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object> {
            Account.Name => 'ACME'
        };
    }
}
