# ITestDataBuilder

Base interface to create custom test data builders. Any custom TestDataBuilder must implement this              interface and extend [SObjectTestDataBuilder](/Misc/SObjectTestDataBuilder.md).

## Methods
### `with(SObjectField fieldObject value, )`
#### Parameters
|Param|Description|
|---|---|

### `withChild(ITestDataBuilder childBuilderSObjectField relationshipField, )`
#### Parameters
|Param|Description|
|---|---|

### `getSObjectType()`
### `registerNewForInsert()`
### `registerNewForInsert(Integer numberOfRecords)`
#### Parameters
|Param|Description|
|---|---|

---
