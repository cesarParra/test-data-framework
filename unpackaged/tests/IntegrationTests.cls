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
        Account insertedAccount = [SELECT Id, (SELECT Id FROM Contacts) FROM  Account WHERE Id = :anyAccount.Id];
        System.assertEquals(1, insertedAccount.Contacts.size(), 'Expected a contact to have been created for the account.');
        System.assertEquals(2, Limits.getDmlStatements(), 'Expected 2 DML statements, one for the parent and one for the child.');
    }

    @IsTest
    private static void canCreateWithMultipleChildren() {
        Account anyAccount = new AccountTestDataBuilder().withChildContact().withChildContact().insertNew();
        Account insertedAccount = [SELECT Id, (SELECT Id FROM Contacts) FROM  Account WHERE Id = :anyAccount.Id];
        System.assertEquals(2, insertedAccount.Contacts.size(), 'Expected two child contacts.');
        System.assertEquals(2, Limits.getDmlStatements(), 'Expected 2 DML statements, one for all children.');
    }

    @IsTest
    private static void canGetAnyRecordFromThePreviouslyCreated() {
        new AccountTestDataBuilder().insertNew(2);
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected the insertNew operation to have consumed a single DML statement.');
        Account anyAccount = (Account)SObjectTestDataBuilder.getAny(Account.SObjectType);
        System.assertNotEquals(null, anyAccount.Id, 'Expected an account.');
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected getAny to have returned .' +
            'an account from the previously created.');
    }

    @IsTest
    private static void canGetTheChildrenCreatedThroughABuilder() {
        Account anyAccount = new AccountTestDataBuilder().withChildContact().insertNew();
        List<Contact> accountChildren = SObjectTestDataBuilder.getChildrenOfByType(anyAccount.Id, Contact.SObjectType);
        System.assertEquals(1, accountChildren.size(), 'Expected a child returned.');
    }

    // TODO: this is a limitation. Let's see if we can solve it and also maintain certain level of bulkification
//    @IsTest
//    private static void canCreateMultipleLevelsOfChildren() {
//        Account grandParent = (Account)SObjectTestDataBuilder.of(Account.SObjectType)
//            .with(Account.Name, 'Grandparent')
//            .withChildren(SObjectTestDataBuilder.of(Account.SObjectType)
//                .with(Account.Name, 'Parent')
//                .withChildren(
//                    SObjectTestDataBuilder.of(Account.SObjectType).with(Account.Name, 'Child'),
//                    Account.ParentId),
//                Account.ParentId)
//            .insertNew();
//
//        System.assertEquals('Grandparent', grandParent.Name, 'Expected the grandparent created with the correct data.');
//
//        Account parent = (Account)SObjectTestDataBuilder.getChildrenOfByType(grandParent.Id, Account.SObjectType)[0];
//        System.assertEquals(grandParent.Id, parent.ParentId, 'Expected the parent to be correctly related.');
//        System.assertEquals('Parent', parent.Name, 'Expected the parent to have been created with the correct data.');
//
//        Account child = (Account)SObjectTestDataBuilder.getChildrenOfByType(parent.Id, Account.SObjectType)[0];
//        System.assertEquals(parent.Id, child.ParentId, 'Expected the child to be correctly related.');
//        System.assertEquals('Child', child.Name, 'Expected the child to have been created with the correct data.');
//    }
}
