# DefaultTestDataBuilder

`ISTEST`

Base TestDataBuilder implementation that provides default dummy data. This class gets used as a fallback              for SObjectTypes for which a custom TestDataImplementation could not be found


**See** [DefaultTestData](/Misc/DefaultTestData.md)


**See** [SObjectTestDataBuilder](/Misc/SObjectTestDataBuilder.md)


**See** [ITestDataBuilder](/Misc/ITestDataBuilder.md)

## Constructors
### `DefaultTestDataBuilder(SObjectType objectType)`
#### Parameters
|Param|Description|
|---|---|

---
## Methods
### `with(SObjectField fieldObject value, )`
#### Parameters
|Param|Description|
|---|---|

### `withChild(ITestDataBuilder childBuilderSObjectField relationshipField, )`
#### Parameters
|Param|Description|
|---|---|

### `registerNewForInsert()`
### `registerNewForInsert(Integer numberOfRecords)`
#### Parameters
|Param|Description|
|---|---|

### `override getSObjectType()`
---
