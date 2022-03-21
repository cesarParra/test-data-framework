@IsTest
private class IntegrationTests {
    @IsTest
    private static void canCreateRecordsWithoutACustomTestDataBuilder() {
        Contact anyContact = (Contact)SObjectTestDataBuilder.of(Contact.SObjectType).buildNew();
        System.assertNotEquals(null, anyContact?.Id, 'Expected a record returned.');
    }

    @IsTest
    private static void canCreateRecordsUsingCustomTestDataBuilderWhenItExists() {
        Account anyAccount = (Account)SObjectTestDataBuilder.of(Account.SObjectType).buildNew();
        System.assertNotEquals(null, anyAccount?.Id, 'Expected a record returned.');
        System.assertEquals('ACME', anyAccount.Name, 'Expected the default name specified in the builder class.');
    }

    @IsTest
    private static void canCreateRecordsDirectlyThroughTheirBuilders() {
        Account anyAccount = new AccountTestDataBuilder().buildNew();
        System.assertNotEquals(null, anyAccount?.Id, 'Expected a record returned.');
    }

    @IsTest
    private static void canCreateWithChildren() {
        Account anyAccount = new AccountTestDataBuilder().withChildContact().buildNew();
        // TODO: Better way of getting the children without having to query
        Account insertedAccount = [SELECT Id, (SELECT Id FROM Contacts) FROM  Account WHERE Id = :anyAccount.Id];
        System.assertEquals(1, insertedAccount.Contacts.size(), 'Expected a contact to have been created for the account.');
    }
}
