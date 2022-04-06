# SObjectTestDataBuilder

Provides base functionality for building SObject records for testing purposes. Any custom TestDataBuilder              must extend this class as well as implement [ITestDataBuilder](/Misc/ITestDataBuilder.md).

## Constructors
### `SObjectTestDataBuilder()`

Constructs a new SObjectTestDataBuilder.

---
## Methods
### `static of(SObjectType objectType)`

Factory method that creates a new [ITestDataBuilder](/Misc/ITestDataBuilder.md) for the provided SObjectType.

#### Parameters
|Param|Description|
|---|---|
|`objectType`|The SObjectType for which to create a {@link ITestDataBuilder} for.|

#### Return

**Type**

ITestDataBuilder

**Description**

New [ITestDataBuilder](/Misc/ITestDataBuilder.md) instance.

### `static registerBuilder(SObjectType objectType, Type builderType)`

Registers a custom TestDataBuilder for a specific SObjectType. The Type must be a class              that both extends SObjectTestDataBuilder and implements [ITestDataBuilder](/Misc/ITestDataBuilder.md).              Use this method to force the usage of your provided TestDataBuilder instead of letting the              `of` method automatically find a test data builder for it to use.

#### Parameters
|Param|Description|
|---|---|
|`objectType`|The SObjectType for the builder.|
|`builderType`|A class that both extends SObjectTestDataBuilder and implements {@link ITestDataBuilder}.|

### `static getAny(SObjectType objectType)`

Gets a record for the provided SObjectType. If a record has previously been created              for the provided SObjectType then it will be used, saving a trip to the database, otherwise              a new one will be created and the database will be called.

#### Parameters
|Param|Description|
|---|---|
|`objectType`|The SObjectType to get a record for.|

#### Return

**Type**

SObject

**Description**

The SObject for the provided type.

### `static getChildrenOfTypeById(Id recordId, SObjectType objectType)`

Returns any children record that might have been created through a `withChild` call              for the specified record Id.

#### Parameters
|Param|Description|
|---|---|
|`recordId`|The Id of the parent record.|
|`objectType`|The SObjectType for the children.|

#### Return

**Type**

List&lt;SObject&gt;

**Description**

A list with the children records.

### `static commitRecords()`

Commits all registered records to the database.

### `static lateBinding(SObjectType objectType)`

Returns a new LateBinding instance of the specified SObjectType.

#### Parameters
|Param|Description|
|---|---|
|`objectType`|The SObjectType for the LateBinding instance.|

#### Return

**Type**

LateBinding

**Description**

New LateBinding instance.

### `getSObjectType()`

Returns the SObjectType for this builder.

#### Return

**Type**

SObjectType

**Description**

The SObjectType for this builder.

### `beforeInsert(SObject record)`

Override this method if you want any logic to be executed before inserting the SObject              for this builder into the database.

#### Parameters
|Param|Description|
|---|---|
|`record`|The SObject that will be inserted into the database.|

### `afterInsert(SObject record)`

Override this method if you want any logic to be executed after inserting the SObject              for this builder into the database.

#### Parameters
|Param|Description|
|---|---|
|`record`|The SObject that will be inserted into the database.|

---
## Classes
### LateBinding
#### Constructors
##### `LateBinding(ITestDataBuilder builder)`
###### Parameters
|Param|Description|
|---|---|

##### `LateBinding(SObjectType objectType)`
###### Parameters
|Param|Description|
|---|---|

---
#### Methods
##### `setRelationshipField(SObjectField field)`
###### Parameters
|Param|Description|
|---|---|

---

### SObjectTestDataBuilderException

---
