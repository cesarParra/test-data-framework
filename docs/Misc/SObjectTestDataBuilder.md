# SObjectTestDataBuilder

Provides base functionality for building SObject records for testing purposes. Any custom TestDataBuilder              must extend this class as well as implement [ITestDataBuilder](/Misc/ITestDataBuilder.md).

## Constructors
### `SObjectTestDataBuilder()`
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

### `static registerBuilder(SObjectType objectTypeType builderType, )`

Registers a custom TestDataBuilder for a specific SObjectType. The Type must be a class              that both extends SObjectTestDataBuilder and implements [ITestDataBuilder](/Misc/ITestDataBuilder.md).              Use this method to force the usage of your provided TestDataBuilder instead of letting the              `of` method automatically find a test data builder for it to use.

#### Parameters
|Param|Description|
|---|---|
|`objectType`|The SObjectType for the builder.||`builderType`|A class that both extends SObjectTestDataBuilder and implements {@link ITestDataBuilder}.|
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

### `static getChildrenOfTypeById(Id recordIdSObjectType objectType, )`
#### Parameters
|Param|Description|
|---|---|

### `static commitRecords()`
### `static lateBinding(SObjectType objectType)`
#### Parameters
|Param|Description|
|---|---|

### `getSObjectType()`
### `beforeInsert(SObject record)`
#### Parameters
|Param|Description|
|---|---|

### `afterInsert(SObject record)`
#### Parameters
|Param|Description|
|---|---|

### `getA(SObjectType objectType)`
#### Parameters
|Param|Description|
|---|---|

### `getSObjectTypes()`
### `isEmpty()`
### `getAll()`
### `getAllNotInserted()`
### `getAllChildren()`
### `getChildrenOfByType(Id recordIdSObjectType objectType, )`
#### Parameters
|Param|Description|
|---|---|

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
