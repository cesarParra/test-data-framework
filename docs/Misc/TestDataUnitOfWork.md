# TestDataUnitOfWork

`ISTEST`

Provides an implementation of the Enterprise Application Architecture Unit Of Work, as defined by Martin Fowler http://martinfowler.com/eaaCatalog/unitOfWork.html &quot;When you&apos;re pulling data in and out of a database, it&apos;s important to keep track of what you&apos;ve changed; otherwise, that data won&apos;t be written back into the database. Similarly you have to insert new objects you create and remove any objects you delete.&quot; &quot;You can change the database with each change to your object model, but this can lead to lots of very small database calls, which ends up being very slow. Furthermore it requires you to have a transaction open for the whole interaction, which is impractical if you have a business transaction that spans multiple requests. The situation is even worse if you need to keep track of the objects you&apos;ve read so you can avoid inconsistent reads.&quot; &quot;A Unit of Work keeps track of everything you do during a business transaction that can affect the database. When you&apos;re done, it figures out everything that needs to be done to alter the database as a result of your work.&quot; In an Apex context this pattern provides the following specific benefits - Applies bulkfication to DML operations, insert, update and delete - Manages a business transaction around the work and ensures a rollback occurs (even when exceptions are later handled by the caller) - Honours dependency rules between records and updates dependent relationships automatically during the commit

## Constructors
### `TestDataUnitOfWork(List<Schema.SObjectType> sObjectTypes)`

Constructs a new UnitOfWork to support work against the given object list

#### Parameters
|Param|Description|
|---|---|
|`sObjectTypes`|A list of objects given in dependency order (least dependent first)|

### `TestDataUnitOfWork(List<Schema.SObjectType> sObjectTypes, UnresolvedRelationshipBehavior unresolvedRelationshipBehavior)`

Constructs a new UnitOfWork to support work against the given object list

#### Parameters
|Param|Description|
|---|---|
|`sObjectTypes`|A list of objects given in dependency order (least dependent first)|
|`unresolvedRelationshipBehavior`|If AttemptOutOfOrderRelationships and a relationship is registered                                       where a parent is inserted after a child then will update the child                                       post-insert to set the relationship. If IgnoreOutOfOrder then                                       relationship will not be set.|

### `TestDataUnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml)`

Constructs a new UnitOfWork to support work against the given object list

#### Parameters
|Param|Description|
|---|---|
|`sObjectTypes`|A list of objects given in dependency order (least dependent first)|
|`dml`|Modify the database via this class|

### `TestDataUnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml, UnresolvedRelationshipBehavior unresolvedRelationshipBehavior)`

Constructs a new UnitOfWork to support work against the given object list

#### Parameters
|Param|Description|
|---|---|
|`sObjectTypes`|A list of objects given in dependency order (least dependent first)|
|`dml`|Modify the database via this class|
|`unresolvedRelationshipBehavior`|If AttemptOutOfOrderRelationships and a relationship is registered                                       where a parent is inserted after a child then will update the child                                       post-insert to set the relationship. If IgnoreOutOfOrder then relationship                                       will not be set.|

---
## Methods
### `onCommitWorkStarting()`
### `onCommitWorkFinishing()`
### `registerNew(SObject record, ITestDataCallback.ITestDataCallback callback)`

Register a newly created SObject instance to be inserted when commitWork is called

#### Parameters
|Param|Description|
|---|---|
|`record`|A newly created SObject instance to be inserted during commitWork|
|`callback`|TestDataCallback.ITestDataCallback to be called before and after record insert.|

### `registerRelationship(SObject record, Schema.SObjectField relatedToField, SObject relatedTo)`

Register a relationship between two records that have yet to be inserted to the database. This information will be  used during the commitWork phase to make the references only when related records have been inserted to the database.

#### Parameters
|Param|Description|
|---|---|
|`record`|An existing or newly created record|
|`relatedToField`|A SObjectField reference to the lookup field that relates the two records together|
|`relatedTo`|A SObject instance (yet to be committed to the database)|

### `commitWork()`

Takes all the work that has been registered with the UnitOfWork and commits it to the database

---
## Enums
### UnresolvedRelationshipBehavior

Unit of work has two ways of resolving registered relationships that require an update to resolve (e.g. parent and child are same sobject type, or the parent is inserted after the child): AttemptResolveOutOfOrder - Update child to set the relationship (e.g. insert parent, insert child, update child) IgnoreOutOfOrder (default behaviour) - Do not set the relationship (e.g. leave lookup null)


---
## Classes
### SimpleDML
#### Methods
##### `dmlInsert(List&lt;SObject&gt; objList)`
###### Parameters
|Param|Description|
|---|---|

##### `dmlUpdate(List&lt;SObject&gt; objList)`
###### Parameters
|Param|Description|
|---|---|

---

### UnitOfWorkException

UnitOfWork Exception


---
## Interfaces
### IDML
#### Methods
##### `dmlInsert(List&lt;SObject&gt; objList)`
###### Parameters
|Param|Description|
|---|---|

##### `dmlUpdate(List&lt;SObject&gt; objList)`
###### Parameters
|Param|Description|
|---|---|

---

