@IsTest
private class IntegrationTests {
    @IsTest
    private static void canCreateRecordsWithoutACustomTestDataBuilder() {
        Contact anyContact = (Contact)SObjectTestDataBuilder.of(Contact.SObjectType).getNew();
        System.assertNotEquals(null, anyContact?.Id, 'Expected a record returned.');
    }

    @IsTest
    private static void canCreateRecordsUsingCustomTestDataBuilderWhenItExists() {
        Account anyAccount = (Account)SObjectTestDataBuilder.of(Account.SObjectType).getNew();
        System.assertNotEquals(null, anyAccount?.Id, 'Expected a record returned.');
        System.assertEquals('ACME', anyAccount.Name, 'Expected the default name specified in the builder class.');
    }

    @IsTest
    private static void canCreateRecordsDirectlyThroughTheirBuilders() {
        Account anyAccount = new AccountTestDataBuilder().getNew();
        System.assertNotEquals(null, anyAccount?.Id, 'Expected a record returned.');
    }

    // can create with children
}
