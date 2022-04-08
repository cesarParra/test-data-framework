<div align="center">
  <h1>Salesforce Test Data Framework</h1>
  <p>
    Easy and intuitive way to create Salesforce unit test data.
  </p>

<h4>
    <a href="https://cesarparra.github.io/test-data-framework">Documentation</a>
  <span> · </span>
    <a href="https://github.com/cesarParra/test-data-framework/issues">Report Bug</a>
  <span> · </span>
    <a href="https://github.com/cesarParra/test-data-framework/issues">Request Feature</a>
  </h4>
</div>

<br />

## 💡 About

The Salesforce Test Data Framework allows you to intuitively create Salesforce SObject data for your
unit tests using a fluent language. 

It provides base support for any SObject, standard or custom, out of the box, but allows you
to adapt it to your custom needs.

## 🏁 Getting Started

### 🏃 Deploying

To deploy clone or download this repo and push the contents of `force-app/main/default/classes` to your org.

### Usage

#### Quick Start

Tip: See the `IntegrationTests` class for more in depth example usages of the framework.

A record can be created through the following syntax

```apex
Contact anyContact = (Contact)SObjectTestDataBuilder.of(Contact.SObjectType).registerNewForInsert();
SObjectTestDataBuilder.commitRecords();
```

`SObjectTestDataBuilder.of` receives an `SObjectType` for the type of record that you want to create. Calling
`registerNewForInsert` on the returned object will queue up the record for bulk insertion once 
`SObjectTestDataBuilder.commitRecords()` gets called.

You can also create multiple records by using the `registerNewForInsert` overload that takes the number
of records to create

```apex
List<Contact> multipleContacts = (List<Contact>)SObjectTestDataBuilder.of(Contact.SObjectType).registerNewForInsert(5);
SObjectTestDataBuilder.commitRecords();
```

By default, the framework will try to resolve for any required fields on the SObject. In the `Contact` example,
the `LastName` field is a required text field, so the framework will use a `String` from the `DefaultTestData`
class to fill up that field.

Feel free to modify that class to change the defaults for any of the different field types.

During record creation you can also explicitly specify any field data you want to create by chaining `with` calls
and passing an SObjectField and a value:

```apex
Contact anyContact = (Contact)SObjectTestDataBuilder.of(Contact.SObjectType)
        .with(Contact.FirstName, 'John')
        .with(Contact.LastName, 'Smith')
        .registerNewForInsert();
SObjectTestDataBuilder.commitRecords();
```

#### Relationships

When creating test data you might want to also create relationship records, either parent-to-child
or child-to-parent, which are both supported by the framework.

To create a **parent-to-child** relationship you can use the `withChild` method:

```apex
Account accountWithChild = (Account)SObjectTestDataBuilder.of(Account.SObjectType)
        .withChild(
                SObjectTestDataBuilder.of(Contact.SObjectType),
                Contact.AccountId
        )
        .registerNewForInsert();
SObjectTestDataBuilder.commitRecords();
```

The `withChild` method takes 2 arguments: a builder for the child (which can be obtained by calling `SObjectTestDataBuilder.of`)
and the relationship field between the 2 objects.

**Retrieving child records**

Once the records have been inserted to the database (after the call to `SObjectTestDataBuilder.commitRecords()`) you do not
need to query the database to get the reference to the children. Instead, the framework keeps a reference of all inserted records
so you can retrieve the children by using the `SObjectTestDataBuilder.getChildrenOfTypeById` method:

```apex
List<Contact> accountChildren = SObjectTestDataBuilder.getChildrenOfTypeById(accountWithChild.Id, Contact.SObjectType);
```

To create **child-to-parent** relationships the framework has the concept of "late binding", which is a way to specify
a relationship between objects without calling the database until necessary for bulkification purposes.

The late binding is used with the regular `with` method that is used to specify any field value. But instead
of passing a record ID value (which *is* valid as well, but will not take advantage of bulkification) you pass
in a `SObjectTestDataBuilder.LateBinding` object, which can be obtained by calling the `SObjectTestDataBuilder.lateBinding`
method:

```apex
SObjectTestDataBuilder.of(OrderItem__c.SObjectType)
                    .with(OrderItem__c.Order__c, SObjectTestDataBuilder.lateBinding(Order__c.SObjectType))
                    .registerNewForInsert();
SObjectTestDataBuilder.commitRecords();
```

This will create both the `OrderItem__c` and the parent `Order__c`.

#### Custom Builders

When creating SObjects you will probably want more control over the data than what the default builder gives you. The framework
also allows you to create custom builders for different SObjectTypes.

To create a custom builder you will need to **both** extend `SObjectTestDataBuilder` and implement `ITestDataBuilder`.
For the framework to automatically detect your custom builder it also **needs* to have a name that ends in `TestDataBuilder` 
(though there is a way to explicitly specify the builder to the framework, explained below):

```apex
@IsTest
public with sharing class OrderTestDataBuilder extends SObjectTestDataBuilder implements ITestDataBuilder {
  public override SObjectType getSObjectType() {
    return Order__c.SObjectType;
  }

  public OrderTestDataBuilder with(SObjectField field, Object value) {
    return (OrderTestDataBuilder) withData(field, value);
  }

  public Order__c registerNewForInsert() {
    return (Order__c) this.registerSObjectForInsert();
  }

  public List<SObject> registerNewForInsert(Integer numberOfRecords) {
    return this.registerSObjectsForInsert(numberOfRecords);
  }

  protected override Map<SObjectField, Object> getDefaultValueMap() {
    return new Map<SObjectField, Object> {
            Order__c.Customer__c => bindTo(SObjectTestDataBuilder.of(Account.SObjectType))
    };
  }
}
```

Creating a custom builder gives you the following functionality:
* Allows you to create additional `withSomeField` method, which will make your code more fluent
* You can optionally override the `getDefaultValueMap` method, which will allow you to create default data tailored to the SObject.
  * Note by the example that you can use late binding by calling the `bindTo` method automatically provided to you when extending `SObjectTestDataBuilder`.
* You can optionally override the `beforeInsert` and `afterInsert` methods, which will allow you to execute code before and after hitting the database for the insertion of your records.

#### Default resolution vs. Explicitly specifying

By default, the framework will look for any class that ends with `TestDataBuilder` to try and automatically resolve with test data builder to use.
When one is not found then the `DefaultTestDataBuilder` will be used, which will attempt to resolve required fields with default data. But you can also
explicitly specify which builder to use to the framework in the unit test itself, in case you want to either override the automatic resolution and use a different builder,
or if you simply don't want to follow the naming convention.

You can do that by using the `SObjectTestDataBuilder.registerBuilder` method:

```apex
SObjectTestDataBuilder.registerBuilder(Order.SObjectType, CustomOrderBuilder.class);
```

### 🧪 Tests

This repo provides the `IntegrationTests` class with examples of all functionality provided by the framework. The
`kitchenSinkExample` provides an example of a complex hierarchy of objects.

## 🚧 Roadmap

* [ ] Release as unmanaged package
* [ ] In-memory support


## 🤝Contributing

Contributions are always welcome!


## ⚖️License

Distributed under the MIT License. See LICENSE file for more information.
