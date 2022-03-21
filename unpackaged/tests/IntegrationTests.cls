@IsTest
private class IntegrationTests {
    @IsTest
    private static void canCreateRecordsWithoutACustomTestDataClass() {
        Contact anyContact = (Contact)SObjectTestData.of(Contact.SObjectType).getNew();
        System.assertNotEquals(null, anyContact?.Id, 'Expected a record returned.');
    }

    // can create new
    // can create through custom test data classes
    // whether you do it through SObjectTestData and custom test data classes they are complementary
    // can create with children
}
