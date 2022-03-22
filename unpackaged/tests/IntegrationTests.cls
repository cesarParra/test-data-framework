@IsTest
private class IntegrationTests {
    @IsTest
    private static void canCreateRecordsWithoutACustomTestDataBuilder() {
        Contact anyContact = (Contact)SObjectTestDataBuilder.of(Contact.SObjectType).insertNew();
        System.assertNotEquals(null, anyContact?.Id, 'Expected a record returned.');
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected a single DML statement');
    }

    @IsTest
    private static void canCreateRecordsUsingCustomTestDataBuilderWhenItExists() {
        Account anyAccount = (Account)SObjectTestDataBuilder.of(Account.SObjectType).insertNew();
        System.assertNotEquals(null, anyAccount?.Id, 'Expected a record returned.');
        System.assertEquals('ACME', anyAccount.Name, 'Expected the default name specified in the builder class.');
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected a single DML statement');
    }

    @IsTest
    private static void canCreateRecordsDirectlyThroughTheirBuilders() {
        Account anyAccount = new AccountTestDataBuilder().insertNew();
        System.assertNotEquals(null, anyAccount?.Id, 'Expected a record returned.');
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected a single DML statement');
    }

    @IsTest
    private static void canCreateWithChildren() {
        Account anyAccount = new AccountTestDataBuilder().withChildContact().insertNew();
        // TODO: Better way of getting the children without having to query
        Account insertedAccount = [SELECT Id, (SELECT Id FROM Contacts) FROM  Account WHERE Id = :anyAccount.Id];
        System.assertEquals(1, insertedAccount.Contacts.size(), 'Expected a contact to have been created for the account.');
        System.assertEquals(2, Limits.getDmlStatements(), 'Expected 2 DML statements, one for the parent and one for the child.');
    }

    @IsTest
    private static void canCreateWithMultipleChildren() {
        Account anyAccount = new AccountTestDataBuilder().withChildContact().withChildContact().insertNew();
        // TODO: Better way of getting the children without having to query
        Account insertedAccount = [SELECT Id, (SELECT Id FROM Contacts) FROM  Account WHERE Id = :anyAccount.Id];
        System.assertEquals(2, insertedAccount.Contacts.size(), 'Expected two child contacts.');
        System.assertEquals(2, Limits.getDmlStatements(), 'Expected 2 DML statements, one for all children.');
    }
}
