public abstract class SObjectTestDataBuilder implements ITestDataBuilder, ITestDataCallback {
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
            return new DefaultTestDataBuilder(objectType);
        }
        return builder;
    }

    // TODO: Integration test
    // TODO: Overload that takes a quantity of records
    public static SObject buildAny(SObjectType objectType) {
        // TODO: Build a cache of previously saved records by type, so that we can get it from there
        return of(objectType).insertNew();
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
        return this.insertSObjects(1)[0];
    }

    public SObject createNew() {
        return this.createNew(1)[0];
    }

    protected List<SObject> insertSObjects(Integer numberOfRecordsToInsert) {
        List<SObject> recordsToInsert = createNew(numberOfRecordsToInsert);
        commitInsert(recordsToInsert);
        return recordsToInsert;
    }

    public List<SObject> createNew(Integer numberOfRecords) {
        List<SObject> recordsToInsert = new List<SObject>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            SObject recordToInsert = build();
            recordsToInsert.add(recordToInsert);
        }
        customValueMap.clear();
        return recordsToInsert;
    }

    private void commitInsert(List<SObject> records) {
        InsertTestDataUnitOfWork insertWork = new InsertTestDataUnitOfWork();
        insertWork.register(records, this);
        insertWork.commitWork();
        insertChildren(records);
    }

    protected virtual Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object>();
    }
    public virtual void beforeInsert(List<SObject> records) {}
    public virtual void afterInsert(List<SObject> records) {}

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
        InsertTestDataUnitOfWork bulkWork = new InsertTestDataUnitOfWork();
        for (SObject insertedRecord : insertedRecords) {
            for (ChildRelationship relationship : this.registeredRelationships) {
                relationship.ChildBuilder.with(relationship.RelationshipField, insertedRecord.Id);
                ITestDataCallback callback = new NullTestDataCallback();
                if (relationship.ChildBuilder instanceof ITestDataCallback) {
                    callback  = (ITestDataCallback)relationship.ChildBuilder;
                }
                bulkWork.register(relationship.ChildBuilder.createNew(1), callback);
            }
        }
        bulkWork.commitWork();
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
