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


