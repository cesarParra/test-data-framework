public abstract class SObjectTestDataBuilder implements ITestDataBuilder {
    private static TestDataBuilderCache builderCache = new TestDataBuilderCache();
    private List<ChildRelationship> registeredRelationships;
    protected Map<SObjectField, Object> customValueMap;
    private Map<SObjectField, Object> defaultValueMap {
        get {
            if (defaultValueMap == null) {
                defaultValueMap = getDefaultValueMap();
            }
            return defaultValueMap;
        }
        set;
    }

    public SObjectTestDataBuilder() {
        customValueMap = new Map<SObjectField, Object>();
        registeredRelationships = new List<ChildRelationship>();
    }

    // TODO: Maybe we can have an "in memory" overload (using an enum) here that allows us to
    // use this same API but just creating everything in memory. We can use sfab style
    // of JSON manipulation to create child relationships
    // sfab style will also allow us to easily populate non-writable fields like formulas
    // In the overload we can even specify if we want "fake Ids" to be created for us when we are in "in memory mode"
    public static ITestDataBuilder of(SObjectType objectType) {
        ITestDataBuilder builder = builderCache.getFor(objectType);
        if (builder == null) {
            return new DynamicTestDataBuilder(objectType);
        }
        return builder;
    }

    // TODO: Integration test
    // TODO: Overload that takes a quantity of records
    public static SObject buildAny(SObjectType objectType) {
        // TODO: Build a cache of previously saved records by type, so that we can get it from there
        return of(objectType).buildNew();
    }

    public abstract SObjectType getSObjectType();

    protected SObjectTestDataBuilder withData(SObjectField field, Object value) {
        this.customValueMap.put(field, value);
        return this;
    }

    protected SObjectTestDataBuilder withChildren(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        // TODO: Ability to insert many children at a time
        this.registeredRelationships.add(new ChildRelationship(childBuilder, relationshipField));
        return this;
    }

    protected SObject insertSObject() {
        SObject instance = build();
        customValueMap.clear();
        beforeInsert(new List<SObject> { instance });
        insert instance;
        afterInsert(new List<SObject> { instance });
        insertChildren(new List<SObject> { instance });
        return instance;
    }

    protected List<SObject> insertSObjects(Integer numberOfRecordsToInsert) {
        List<SObject> recordsToInsert = new List<SObject>();
        for (Integer i = 0; i < numberOfRecordsToInsert; i++) {
            SObject recordToInsert = build();
            recordsToInsert.add(recordToInsert);
        }
        customValueMap.clear();
        beforeInsert(recordsToInsert);
        insert recordsToInsert;
        afterInsert(recordsToInsert);
        return recordsToInsert;
    }

    protected virtual Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object>();
    }
    protected virtual void beforeInsert(List<SObject> records) {}
    protected virtual void afterInsert(List<SObject> records) {}

    private SObject build() {
        SObject instance = this.getSObjectType().newSObject(null, true);

        for (SObjectField defaultField : defaultValueMap.keySet()) {
            if (!customValueMap.containsKey(defaultField)) {
                // Skip any field that has been overridden through the custom value map
                instance.put(defaultField, defaultValueMap.get(defaultField));
            }
        }

        for (SObjectField customField : customValueMap.keySet()) {
            if (customValueMap.get(customField) != null) {
                instance.put(customField, customValueMap.get(customField));
            }
        }

        return instance;
    }

    private void insertChildren(List<SObject> insertedRecords) {
        // TODO: Bulkify rather than inserting one by one
        for (SObject insertedRecord : insertedRecords) {
            for (ChildRelationship relationship : this.registeredRelationships) {
                relationship.ChildBuilder.with(relationship.RelationshipField, insertedRecord.Id).buildNew();
            }
        }
    }

    private class TestDataBuilderCache {
        private Boolean initialized;
        private Map<SObjectType, ITestDataBuilder> builderByType;

        public TestDataBuilderCache() {
            this.initialized = false;
            this.builderByType = new Map<SObjectType, ITestDataBuilder>();
        }

        public ITestDataBuilder getFor(SObjectType objectType) {
            if (this.initialized == false) {
                initializeCache();
            }

            return this.builderByType.get(objectType);
        }

        private void initializeCache() {
            List<ApexClass> testDataBuilderClass = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name LIKE '%TestDataBuilder%'];
            for (ApexClass currentClass : testDataBuilderClass) {
                try {
                    Type currentClassType = Type.forName(currentClass.NamespacePrefix, currentClass.Name);
                    Object currentClassInstance = currentClassType.newInstance();
                    if (currentClassInstance instanceof ITestDataBuilder) {
                        ITestDataBuilder builderInstance = (ITestDataBuilder)currentClassInstance;
                        this.builderByType.put(builderInstance.getSObjectType(), builderInstance);
                    }
                } catch (Exception e) {
                    // An error might occur when creating the type. If it does we move on and don't add it to the cache.
                }
            }

            this.initialized = true;
        }
    }

    private class ChildRelationship {
        public ITestDataBuilder ChildBuilder { get; private set; }
        public  SObjectField RelationshipField { get; private set; }

        public ChildRelationship(ITestDataBuilder childBuilder, SObjectField relationshipField) {
            this.ChildBuilder = childBuilder;
            this.RelationshipField = relationshipField;
        }
    }
}
