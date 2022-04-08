# ITestDataCallback

Callback with methods to be executed before and after database calls.              Do not implement directly, rather extend [SObjectTestDataBuilder](/Misc/SObjectTestDataBuilder.md) and override              the methods provided there.

## Methods
### `beforeInsert(SObject record)`

Executes before inserting the SObject              for this builder into the database.

#### Parameters
|Param|Description|
|---|---|
|`record`|The SObject that will be inserted into the database.|

### `afterInsert(SObject record)`

Executes after inserting the SObject              for this builder into the database.

#### Parameters
|Param|Description|
|---|---|
|`record`|The SObject that will be inserted into the database.|

---
