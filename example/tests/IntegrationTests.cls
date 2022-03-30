@IsTest
private class IntegrationTests {
    @IsTest
    private static void canCreateRecordsWithoutACustomTestDataBuilder() {
        Contact anyContact = (Contact)SObjectTestDataBuilder.of(Contact.SObjectType)
            .with(Contact.LastName, 'Parra')
            .registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, anyContact?.Id, 'Expected a record returned.');
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected a single DML statement');
    }

    @IsTest
    private static void canBeCalledMultipleTimes() {
        Contact anyContact = (Contact)SObjectTestDataBuilder.of(Contact.SObjectType)
            .with(Contact.LastName, 'Parra')
            .registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        Contact anotherContact = (Contact)SObjectTestDataBuilder.of(Contact.SObjectType)
            .with(Contact.LastName, 'Garcia')
            .registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, anyContact?.Id, 'Expected a record returned.');
        System.assertNotEquals(null, anotherContact?.Id, 'Expected a record returned.');
    }

    @IsTest
    private static void canCreateRecordsUsingCustomTestDataBuilderWhenItExists() {
        Account anyAccount = new AccountTestDataBuilder()
            .withName('ACME')
            .withAddress('123 Street Name', 'San Francisco', 'CA', '90222', 'USA')
            .registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, anyAccount?.Id, 'Expected a record returned.');
        System.assertEquals('ACME', anyAccount.Name, 'Expected the default name specified in the builder class.');
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected a single DML statement');
    }

    @IsTest
    private static void canCreateRecordsDirectlyThroughTheirBuilders() {
        Account anyAccount = new AccountTestDataBuilder().registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, anyAccount?.Id, 'Expected a record returned.');
        System.assertEquals(1, Limits.getDmlStatements(), 'Expected a single DML statement');
    }

    @IsTest
    private static void canCreateWithChildren() {
        Account anyAccount = new AccountTestDataBuilder()
            .withChildContact('Parra')
            .registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        Account insertedAccount = [SELECT Id, (SELECT Id FROM Contacts) FROM  Account WHERE Id = :anyAccount.Id];
        System.assertEquals(1, insertedAccount.Contacts.size(), 'Expected a contact to have been created for the account.');
        System.assertEquals(2, Limits.getDmlStatements(), 'Expected 2 DML statements, one for the parent and one for the child.');
    }

    @IsTest
    private static void canCreateWithMultipleChildren() {
        Account anyAccount = new AccountTestDataBuilder()
            .withChildContact('Parra')
            .withChildContact('Garcia')
            .registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        Account insertedAccount = [SELECT Id, (SELECT Id FROM Contacts) FROM  Account WHERE Id = :anyAccount.Id];
        System.assertEquals(2, insertedAccount.Contacts.size(), 'Expected two child contacts.');
        System.assertEquals(2, Limits.getDmlStatements(), 'Expected 2 DML statements, one for all children.');
    }

    @IsTest
    private static void canGetAnyRecordFromThePreviouslyCreated() {
        new AccountTestDataBuilder().registerNewForInsert(2);
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
        Account anyAccount = new AccountTestDataBuilder().withChildContact('Parra').registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        List<Contact> accountChildren = SObjectTestDataBuilder.getChildrenOfTypeById(anyAccount.Id, Contact.SObjectType);
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
            .registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, grandParentAccount.Id, 'Expected the grand parent to have been inserted.');
        System.assertEquals('Grandparent', grandParentAccount.Name, 'Expected the data to have been correctly set.');

        Account parentAccount = (Account)SObjectTestDataBuilder.getChildrenOfTypeById(grandParentAccount.Id, Account.SObjectType)[0];
        System.assertNotEquals(null, parentAccount.Id, 'Expected the parent to have been created.');
        System.assertEquals('Parent', parentAccount.Name, 'Expected the data to have been correctly set.');
        System.assertEquals(grandParentAccount.Id, parentAccount.ParentId, 'Expected the relationship to have been correctly created.');
    }

    @IsTest
    private static void supportsDefaultRelationshipBindings() {
        Order__c orderRecord = (Order__c)new OrderTestDataBuilder().registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, orderRecord, 'Expected the record to have been inserted.');
        System.assertNotEquals(null, orderRecord.Customer__c, 'Expected the Customer relationship to have been populated.');
    }

    @IsTest
    private static void supportsBuildersWithMultipleRelationshipBindings() {
        // OrderItemTestDataBuilder is child of both Order and Product, and Order is in turn child of Account
        OrderItem__c itemRecord = (OrderItem__c)new OrderItemTestDataBuilder().registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, itemRecord.Id);
        System.assertNotEquals(null, itemRecord.Order__c);
        System.assertNotEquals(null, itemRecord.Product__c);
    }

    @IsTest
    private static void supportsMultipleBuildersWithMultipleRelationshipBindings() {
        OrderItem__c itemRecord = (OrderItem__c)new OrderItemTestDataBuilder().registerNewForInsert();
        OrderItem__c itemRecord2 = (OrderItem__c)new OrderItemTestDataBuilder().registerNewForInsert();
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
    private static void anErrorIsThrownWhenWithChildrenAndLateBindingAreUsedAtTheSameTime() {
        // This way of registering parent-child relationships is incorrect because we are both
        // calling withChild to specify the parent-to-child relationship and also calling with
        // with a late binding from the child to the parent.
        // Only one method of registering relationships should be used at a time.
        try {
            SObjectTestDataBuilder.of(Order__c.SObjectType).withChild(
                SObjectTestDataBuilder.of(OrderItem__c.SObjectType).
                    with(OrderItem__c.Order__c, SObjectTestDataBuilder.lateBinding(Order__c.SObjectType)),
                OrderItem__c.Order__c
            ).registerNewForInsert();

            System.assert(false, 'Expected an exception to have been thrown.');
        } catch (SObjectTestDataBuilder.SObjectTestDataBuilderException e) {
            System.assert(true, 'An exception was expected');
        } catch (Exception e) {
            System.assert(false, 'Expected an SObjectTestDataBuilder.SObjectTestDataBuilderException, but got ' + e.getTypeName());
        }
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
            .registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        System.assertNotEquals(null, grandParentAccount.Id, 'Expected the grand parent to have been inserted.');
        System.assertEquals('Grandparent', grandParentAccount.Name, 'Expected the data to have been correctly set.');

        Account parentAccount = (Account)SObjectTestDataBuilder.getChildrenOfTypeById(grandParentAccount.Id, Account.SObjectType)[0];
        System.assertNotEquals(null, parentAccount.Id, 'Expected the parent to have been created.');
        System.assertEquals('Parent', parentAccount.Name, 'Expected the data to have been correctly set.');
        System.assertEquals(grandParentAccount.Id, parentAccount.ParentId, 'Expected the relationship to have been correctly created.');

        Account childAccount = (Account)SObjectTestDataBuilder.getChildrenOfTypeById(parentAccount.Id, Account.SObjectType)[0];
        System.assertNotEquals(null, childAccount.Id, 'Expected child parent to have been created.');
        System.assertEquals('Child', childAccount.Name, 'Expected the data to have been correctly set.');
        System.assertEquals(parentAccount.Id, childAccount.ParentId, 'Expected the relationship to have been correctly created.');
    }

    @IsTest
    private static void kitchenSinkExample() {
        // Relationships:
        // Order => Parents: Account, Pricebook2
        // OrderItem => Parents: Order, PricebookEntry
        // PricebookEntry => Parents: Product2, Pricebook2

        SObjectTestDataBuilder.registerBuilder(PricebookEntry.SObjectType, IntegrationTests.PriceBookEntryBuilder.class);
        SObjectTestDataBuilder.registerBuilder(Order.SObjectType, IntegrationTests.OrderBuilder.class);
        SObjectTestDataBuilder.registerBuilder(OrderItem.SObjectType, IntegrationTests.OrderItemBuilder.class);

        ITestDataBuilder orderItemRecord = SObjectTestDataBuilder.of(OrderItem.SObjectType)
            .with(OrderItem.UnitPrice, 100.00)
            .with(OrderItem.Quantity, 1);
        Order orderRecord = (Order)SObjectTestDataBuilder.of(Order.SObjectType)
            .withChild(orderItemRecord, OrderItem.OrderId)
            .registerNewForInsert();
        SObjectTestDataBuilder.commitRecords();

        // Assert that the relationships were correctly created
        System.assertNotEquals(null, orderRecord.Id);
        OrderItem itemRecord = (OrderItem)SObjectTestDataBuilder.getChildrenOfTypeById(orderRecord.Id, OrderItem.SObjectType)[0];
        System.assertNotEquals(null, itemRecord.Id);
        System.assertEquals(orderRecord.Id, itemRecord.OrderId);

        // Assert that the correct records were inserted to the database
        List<Order> dbOrders = [SELECT Id, (SELECT Id FROM OrderItems) FROM Order];
        System.assertEquals(1, dbOrders.size());
        System.assertEquals(1, dbOrders[0].OrderItems.size());
    }

    public class PriceBookEntryBuilder extends SObjectTestDataBuilder implements ITestDataBuilder {
        public override SObjectType getSObjectType() {
            return PricebookEntry.SObjectType;
        }

        public PriceBookEntryBuilder with(SObjectField field, Object value) {
            return (PriceBookEntryBuilder)withData(field, value);
        }

        public PricebookEntry registerNewForInsert() {
            return (PricebookEntry) this.registerSObjectForInsert();
        }

        public List<PricebookEntry> registerNewForInsert(Integer numberOfRecords) {
            return this.registerSObjectsForInsert(numberOfRecords);
        }

        protected override Map<SObjectField, Object> getDefaultValueMap() {
            return new Map<SObjectField, Object> {
                PricebookEntry.Product2Id => bindTo(SObjectTestDataBuilder.of(Product2.SObjectType)),
                PricebookEntry.Pricebook2Id => Test.getStandardPricebookId(),
                PricebookEntry.UnitPrice => 100
            };
        }
    }

    public class OrderBuilder extends SObjectTestDataBuilder implements ITestDataBuilder {
        public override SObjectType getSObjectType() {
            return Order.SObjectType;
        }

        public OrderBuilder with(SObjectField field, Object value) {
            return (OrderBuilder)withData(field, value);
        }

        public Order registerNewForInsert() {
            return (Order) this.registerSObjectForInsert();
        }

        public List<Order> registerNewForInsert(Integer numberOfRecords) {
            return this.registerSObjectsForInsert(numberOfRecords);
        }

        protected override Map<SObjectField, Object> getDefaultValueMap() {
            return new Map<SObjectField, Object> {
              Order.Status => 'Draft',
              Order.AccountId => bindTo(SObjectTestDataBuilder.of(Account.SObjectType)),
              Order.EffectiveDate => Date.today(),
              Order.Pricebook2Id => Test.getStandardPricebookId()
            };
        }
    }

    public class OrderItemBuilder extends SObjectTestDataBuilder implements ITestDataBuilder {
        public override SObjectType getSObjectType() {
            return OrderItem.SObjectType;
        }

        public OrderItemBuilder with(SObjectField field, Object value) {
            return (OrderItemBuilder)withData(field, value);
        }

        public OrderItem registerNewForInsert() {
            return (OrderItem) this.registerSObjectForInsert();
        }

        public List<OrderItem> registerNewForInsert(Integer numberOfRecords) {
            return this.registerSObjectsForInsert(numberOfRecords);
        }

        protected override Map<SObjectField, Object> getDefaultValueMap() {
            return new Map<SObjectField, Object> {
                OrderItem.PricebookEntryId => bindTo(SObjectTestDataBuilder.of(PricebookEntry.SObjectType)),
                OrderItem.OrderId => bindTo(SObjectTestDataBuilder.of(Order.SObjectType))
            };
        }
    }
}
