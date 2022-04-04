# DefaultTestDataBuilder

`ISTEST`

Base TestDataBuilder implementation that provides default dummy data. This class gets used as a fallback              for SObjectTypes for which a custom TestDataImplementation could not be found


**See** [DefaultTestData](/Misc/DefaultTestData.md)


**See** [SObjectTestDataBuilder](/Misc/SObjectTestDataBuilder.md)


**See** [ITestDataBuilder](/Misc/ITestDataBuilder.md)

## Constructors
### `DefaultTestDataBuilder(SObjectType objectType)`

Constructs a new DefaultTestDataBuilder.

#### Parameters
|Param|Description|
|---|---|
|`objectType`|The SObjectType for this builder.|

---
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

DefaultTestDataBuilder

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

DefaultTestDataBuilder

**Description**

Updated DefaultTestDataBuilder instance.

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

### `override getSObjectType()`

Returns the SObjectType for this builder.

#### Return

**Type**

SObjectType

**Description**

The SObjectType for this builder.

---
