@IsTest
public with sharing class AccountTestDataBuilder extends SObjectTestDataBuilder {
    public ITestDataBuilder with(SObjectField field, Object value) {
        this.withData(field, value);
        return this;
    }

    public override SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public Account registerNewForInsert() {
        return (Account)this.registerSObjectForInsert();
    }

    public List<SObject> registerNewForInsert(Integer numberOfRecords) {
        return this.registerSObjectsForInsert(numberOfRecords);
    }

    public AccountTestDataBuilder withName(String name) {
        return (AccountTestDataBuilder)this.withData(Account.Name, name);
    }

    public AccountTestDataBuilder withAddress(String street, String city, String state, String postalCode, String country) {
        return (AccountTestDataBuilder)this.withData(Account.BillingStreet, street)
            .withData(Account.BillingCity, city)
            .withData(Account.BillingState, state)
            .withData(Account.BillingPostalCode, postalCode)
            .withData(Account.BillingCountry, country);
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
