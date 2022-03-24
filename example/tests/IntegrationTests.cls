@IsTest
private class IntegrationTests {
    @IsTest
    private static void canCreateRecordsWithoutACustomTestDataBuilder() {
        Contact anyContact = (Contact)SObjectTestDataBuilder.of(Contact.SObjectType)
            .with(Contact.LastName, 'Parra')
            .insertNew();
        SObjectTestDataBuilder.commitRecords();
        System.assertNotEquals(null, anyContact?.Id, 'Expected a record returned.');
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected a single DML statement');
    }

    @IsTest
    private static void canCreateRecordsUsingCustomTestDataBuilderWhenItExists() {
        Account anyAccount = (Account)SObjectTestDataBuilder.of(Account.SObjectType).insertNew();
        SObjectTestDataBuilder.commitRecords();
        System.assertNotEquals(null, anyAccount?.Id, 'Expected a record returned.');
        System.assertEquals('ACME', anyAccount.Name, 'Expected the default name specified in the builder class.');
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected a single DML statement');
    }

    @IsTest
    private static void canCreateRecordsDirectlyThroughTheirBuilders() {
        Account anyAccount = new AccountTestDataBuilder().insertNew();
        SObjectTestDataBuilder.commitRecords();
        System.assertNotEquals(null, anyAccount?.Id, 'Expected a record returned.');
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected a single DML statement');
    }

    @IsTest
    private static void canCreateWithChildren() {
        Account anyAccount = new AccountTestDataBuilder().withChildContact('Parra').insertNew();
        SObjectTestDataBuilder.commitRecords();
        Account insertedAccount = [SELECT Id, (SELECT Id FROM Contacts) FROM  Account WHERE Id = :anyAccount.Id];
        System.assertEquals(1, insertedAccount.Contacts.size(), 'Expected a contact to have been created for the account.');
        System.assertEquals(2, Limits.getDmlStatements(), 'Expected 2 DML statements, one for the parent and one for the child.');
    }

    @IsTest
    private static void canCreateWithMultipleChildren() {
        Account anyAccount = new AccountTestDataBuilder()
            .withChildContact('Parra')
            .withChildContact('Garcia').insertNew();
        SObjectTestDataBuilder.commitRecords();
        Account insertedAccount = [SELECT Id, (SELECT Id FROM Contacts) FROM  Account WHERE Id = :anyAccount.Id];
        System.assertEquals(2, insertedAccount.Contacts.size(), 'Expected two child contacts.');
        System.assertEquals(2, Limits.getDmlStatements(), 'Expected 2 DML statements, one for all children.');
    }

    @IsTest
    private static void canGetAnyRecordFromThePreviouslyCreated() {
        new AccountTestDataBuilder().insertNew(2);
        SObjectTestDataBuilder.commitRecords();
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected the insertNew operation to have consumed a single DML statement.');
        Account anyAccount = (Account)SObjectTestDataBuilder.getAny(Account.SObjectType);
        System.assertNotEquals(null, anyAccount.Id, 'Expected an account.');
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected getAny to have returned .' +
            'an account from the previously created.');
    }

    @IsTest
    private static void canBetAnyWithoutHavingInsertedPreviously() {
        Account anyAccount = (Account)SObjectTestDataBuilder.getAny(Account.SObjectType);
        SObjectTestDataBuilder.commitRecords();
        System.assertNotEquals(null, anyAccount.Id, 'Expected an account.');
    }

    @IsTest
    private static void canGetTheChildrenCreatedThroughABuilder() {
        Account anyAccount = new AccountTestDataBuilder().withChildContact('Parra').insertNew();
        SObjectTestDataBuilder.commitRecords();
        List<Contact> accountChildren = SObjectTestDataBuilder.getChildrenOfByType(anyAccount.Id, Contact.SObjectType);
        System.assertEquals(1, accountChildren.size(), 'Expected a child returned.');
        System.assertEquals(anyAccount.Id, accountChildren[0].AccountId, 'Expected the parent correctly set.');
    }

    @IsTest
    private static void supportsRecursiveRelationships() {
        Account grandParentAccount = (Account)SObjectTestDataBuilder.of(Account.SObjectType)
            .with(Account.Name, 'Grandparent')
            .withChild(
                SObjectTestDataBuilder.of(Account.SObjectType)
                    .with(Account.Name, 'Parent'),
                Account.ParentId)
            .insertNew();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, grandParentAccount.Id, 'Expected the grand parent to have been inserted.');
        System.assertEquals('Grandparent', grandParentAccount.Name, 'Expected the data to have been correctly set.');

        Account parentAccount = (Account)SObjectTestDataBuilder.getChildrenOfByType(grandParentAccount.Id, Account.SObjectType)[0];
        System.assertNotEquals(null, parentAccount.Id, 'Expected the parent to have been created.');
        System.assertEquals('Parent', parentAccount.Name, 'Expected the data to have been correctly set.');
        System.assertEquals(grandParentAccount.Id, parentAccount.ParentId, 'Expected the relationship to have been correctly created.');
    }

    @IsTest
    private static void supportsDefaultRelationshipBindings() {
        Order__c orderRecord = (Order__c)new OrderTestDataBuilder().insertNew();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, orderRecord, 'Expected the record to have been inserted.');
        System.assertNotEquals(null, orderRecord.Customer__c, 'Expected the Customer relationship to have been populated.');
    }

    @IsTest
    private static void supportsBuildersWithMultipleRelationshipBindings() {
        // OrderItemTestDataBuilder is child of both Order and Product, and Order is in turn child of Account
        OrderItem__c itemRecord = (OrderItem__c)new OrderItemTestDataBuilder().insertNew();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, itemRecord.Id);
        System.assertNotEquals(null, itemRecord.Order__c);
        System.assertNotEquals(null, itemRecord.Product__c);
    }

    @IsTest
    private static void supportsMultipleBuildersWithMultipleRelationshipBindings() {
        OrderItem__c itemRecord = (OrderItem__c)new OrderItemTestDataBuilder().insertNew();
        OrderItem__c itemRecord2 = (OrderItem__c)new OrderItemTestDataBuilder().insertNew();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, itemRecord.Id);
        System.assertNotEquals(null, itemRecord.Order__c);
        System.assertNotEquals(null, itemRecord.Product__c);

        System.assertNotEquals(null, itemRecord2.Id);
        System.assertNotEquals(null, itemRecord2.Order__c);
        System.assertNotEquals(null, itemRecord2.Product__c);

        Integer usedDml = Limits.getDmlStatements();
        Account accountRecord = (Account)SObjectTestDataBuilder.getAny(Account.SObjectType);
        System.assertNotEquals(null, accountRecord?.Id, 'Should be able get to a pre-inserted account.');

        Product__c productRecord = (Product__c)SObjectTestDataBuilder.getAny(Product__c.SObjectType);
        System.assertNotEquals(null, productRecord?.Id, 'Should be able to get a pre-inserted product');

        Order__c orderRecord = (Order__c)SObjectTestDataBuilder.getAny(Order__c.SObjectType);
        System.assertNotEquals(null, orderRecord?.Id, 'Should be able to get a pre-inserted order');

        System.assertEquals(usedDml, Limits.getDmlStatements(),
            'Expected to not have increased the number of DML statements by getting pre-inserted records from the builder.');
    }

    @IsTest
    private static void supportsRecursiveRelationshipsAcrossMultipleLevels() {
        Account grandParentAccount = (Account)SObjectTestDataBuilder.of(Account.SObjectType)
            .with(Account.Name, 'Grandparent')
            .withChild(
                SObjectTestDataBuilder.of(Account.SObjectType)
                    .with(Account.Name, 'Parent')
                    .withChild(
                        SObjectTestDataBuilder.of(Account.SObjectType).with(Account.Name, 'Child'),
                        Account.ParentId
                    ),
                Account.ParentId)
            .insertNew();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, grandParentAccount.Id, 'Expected the grand parent to have been inserted.');
        System.assertEquals('Grandparent', grandParentAccount.Name, 'Expected the data to have been correctly set.');

        Account parentAccount = (Account)SObjectTestDataBuilder.getChildrenOfByType(grandParentAccount.Id, Account.SObjectType)[0];
        System.assertNotEquals(null, parentAccount.Id, 'Expected the parent to have been created.');
        System.assertEquals('Parent', parentAccount.Name, 'Expected the data to have been correctly set.');
        System.assertEquals(grandParentAccount.Id, parentAccount.ParentId, 'Expected the relationship to have been correctly created.');

        Account childAccount = (Account)SObjectTestDataBuilder.getChildrenOfByType(parentAccount.Id, Account.SObjectType)[0];
        System.assertNotEquals(null, childAccount.Id, 'Expected child parent to have been created.');
        System.assertEquals('Child', childAccount.Name, 'Expected the data to have been correctly set.');
        System.assertEquals(parentAccount.Id, childAccount.ParentId, 'Expected the relationship to have been correctly created.');
    }

    // TODO: This is getting out of control. Let's instead create our own data structure that is a bit simpler to get that
    // to work first. Once we can get that to work then let's come back here and see if we can take care of this more
    // complex structure. Let's use this as our kitchen sink example that everything can work, including even having
    // defaulted relationships in custom TestDataBuilder implementations
//    @IsTest
//    private static void canCreateMultipleLevelsOfChildren() {
//        Account anyAccount = new Account(Name = 'Test');
//        insert anyAccount;
//        Pricebook2 book = new Pricebook2();
//        insert
//        PricebookEntry entry = new PricebookEntry(UnitPrice = 100);
//        insert entry;
//
//        ITestDataBuilder orderItemRecord = SObjectTestDataBuilder.of(OrderItem.SObjectType)
//            .with(OrderItem.PricebookEntryId, entry.Id)
//            .with(OrderItem.UnitPrice, 100);
//        ITestDataBuilder productBuilder = SObjectTestDataBuilder.of(Product2.SObjectType)
//            .withChild(orderItemRecord, OrderItem.Product2Id); // TODO: A way to now be able to get the generated record out of this
//        Order orderRecord = (Order)SObjectTestDataBuilder.of(Order.SObjectType)
//            .with(Order.AccountId, anyAccount.Id) // TODO: See how we can make this dynamic
//            .with(Order.EffectiveDate, Date.today()) // TODO: Why did this not default? Answer: Because I commented out callbacks
//            .with(Order.Status, 'Draft') // TODO: Why did this not default? Answer: Because I commented out. But still we want to be better about defaulting restricted picklists
//            .withChild(orderItemRecord, OrderItem.OrderId)
//            .insertNew();
//        SObjectTestDataBuilder.commitRecords();
//    }

    // TODO: What happens when calling commit multiple times
}
