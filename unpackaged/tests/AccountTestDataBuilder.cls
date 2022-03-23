public with sharing class AccountTestDataBuilder extends SObjectTestDataBuilder {
    public ITestDataBuilder with(SObjectField field, Object value) {
        this.withData(field, value);
        return this;
    }

    public override SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public Account insertNew() {
        return (Account)this.insertSObject();
    }

    public List<SObject> insertNew(Integer numberOfRecords) {
        return this.insertSObjects(numberOfRecords);
    }

    public AccountTestDataBuilder withChildContact(String lastName) {
        this.withChild(
            SObjectTestDataBuilder.of(Contact.SObjectType).with(Contact.LastName, lastName),
            Contact.AccountId
        );
        return this;
    }

    protected override Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object> {
            Account.Name => 'ACME'
        };
    }
}
