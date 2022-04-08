# Classes
## Miscellaneous

### [DefaultTestData](/Misc/DefaultTestData.md)

Provides default data for the [DefaultTestDataBuilder](/Misc/DefaultTestDataBuilder.md) class.

### [DefaultTestDataBuilder](/Misc/DefaultTestDataBuilder.md)

Base TestDataBuilder implementation that provides default dummy data. This class gets used as a fallback              for SObjectTypes for which a custom TestDataImplementation could not be found

### [ITestDataBuilder](/Misc/ITestDataBuilder.md)

Base interface to create custom test data builders. Any custom TestDataBuilder must implement this              interface and extend [SObjectTestDataBuilder](/Misc/SObjectTestDataBuilder.md).

### [ITestDataCallback](/Misc/ITestDataCallback.md)

Callback with methods to be executed before and after database calls.              Do not implement directly, rather extend [SObjectTestDataBuilder](/Misc/SObjectTestDataBuilder.md) and override              the methods provided there.

### [SObjectTestDataBuilder](/Misc/SObjectTestDataBuilder.md)

Provides base functionality for building SObject records for testing purposes. Any custom TestDataBuilder              must extend this class as well as implement [ITestDataBuilder](/Misc/ITestDataBuilder.md).

### [TestDataUnitOfWork](/Misc/TestDataUnitOfWork.md)

Provides an implementation of the Enterprise Application Architecture Unit Of Work, as defined by Martin Fowler http://martinfowler.com/eaaCatalog/unitOfWork.html &quot;When you&apos;re pulling data in and out of a database, it&apos;s important to keep track of what you&apos;ve changed; otherwise, that data won&apos;t be written back into the database. Similarly you have to insert new objects you create and remove any objects you delete.&quot; &quot;You can change the database with each change to your object model, but this can lead to lots of very small database calls, which ends up being very slow. Furthermore it requires you to have a transaction open for the whole interaction, which is impractical if you have a business transaction that spans multiple requests. The situation is even worse if you need to keep track of the objects you&apos;ve read so you can avoid inconsistent reads.&quot; &quot;A Unit of Work keeps track of everything you do during a business transaction that can affect the database. When you&apos;re done, it figures out everything that needs to be done to alter the database as a result of your work.&quot; In an Apex context this pattern provides the following specific benefits - Applies bulkfication to DML operations, insert, update and delete - Manages a business transaction around the work and ensures a rollback occurs (even when exceptions are later handled by the caller) - Honours dependency rules between records and updates dependent relationships automatically during the commit
