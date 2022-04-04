# ITestDataBuilder

Base interface to create custom test data builders. Any custom TestDataBuilder must implement this              interface and extend [SObjectTestDataBuilder](/Misc/SObjectTestDataBuilder.md).

## Methods
### `with(SObjectField field, Object value)`

Sets the value for the field specified by the SObjectField.

#### Parameters
|Param|Description|
|---|---|
|`field`|The SObjectField to set the value for.|
|`value`|The value to set.|

#### Return

**Type**

ITestDataBuilder

**Description**

Updated DefaultTestDataBuilder instance.

### `withChild(ITestDataBuilder childBuilder, SObjectField relationshipField)`

Registers a child to be inserted for the SObject that will be built by this builder.

#### Parameters
|Param|Description|
|---|---|
|`childBuilder`|An {@link ITestDataBuilder} instance that represents the child that will be related to this                     record.|
|`relationshipField`|The SObjectField that represents how the 2 SObjectTypes are related.|

#### Return

**Type**

ITestDataBuilder

**Description**

Updated DefaultTestDataBuilder instance.

### `getSObjectType()`

Returns the SObjectType for this builder.

#### Return

**Type**

SObjectType

**Description**

The SObjectType for this builder.

### `registerNewForInsert()`

Registers this record for insertion into the database once `SObjectTestDataBuilder.commitRecords()`              is called.

#### Return

**Type**

SObject

**Description**

The record that will be inserted into the database.

### `registerNewForInsert(Integer numberOfRecords)`

Registers records in bulk to be inserted into the database by this builder once              `SObjectTestDataBuilder.commitRecords()` is called.

#### Parameters
|Param|Description|
|---|---|
|`numberOfRecords`|The number of records to insert.|

#### Return

**Type**

List&lt;SObject&gt;

**Description**

The records that will be inserted into the database.

---
