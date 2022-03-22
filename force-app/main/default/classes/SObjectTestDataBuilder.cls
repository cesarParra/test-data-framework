public abstract class SObjectTestDataBuilder implements ITestDataBuilder, ITestDataCallback {
    private static TestDataBuilderCache builderCache = new TestDataBuilderCache();
    private static History testDataHistory = new History();
    private List<ChildRelationship> registeredRelationships;
    protected Map<SObjectField, Object> customValueMap;
    private Map<SObjectField, Object> defaultValueMapCached {
        get {
            if (defaultValueMapCached == null) {
                defaultValueMapCached = getDefaultValueMap();
            }
            return defaultValueMapCached;
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

    public static SObject getAny(SObjectType objectType) {
        SObject previouslyInserted = testDataHistory.getA(objectType);
        if (previouslyInserted != null) {
            return previouslyInserted;
        }
        return of(objectType).insertNew();
    }

    public static List<SObject> getChildrenOfByType(Id recordId, SObjectType objectType) {
        return testDataHistory.getChildrenOfByType(recordId, objectType);
    }

    public abstract SObjectType getSObjectType();

    public SObject createNew() {
        return this.createNew(1)[0];
    }

    public List<SObject> createNew(Integer numberOfRecords) {
        List<SObject> recordsToInsert = new List<SObject>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            SObject recordToInsert = build();
            recordsToInsert.add(recordToInsert);
        }
        return recordsToInsert;
    }

    public SObjectTestDataBuilder withChildren(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        // TODO: Ability to insert many children at a time
        System.debug('Registering a children rel');
        this.registeredRelationships.add(new ChildRelationship(childBuilder, relationshipField));
        return this;
    }

    public virtual void beforeInsert(List<SObject> records) {}
    public virtual void afterInsert(List<SObject> records) {}

    protected SObjectTestDataBuilder withData(SObjectField field, Object value) {
        this.customValueMap.put(field, value);
        return this;
    }

    protected SObject insertSObject() {
        return this.insertSObjects(1)[0];
    }

    protected List<SObject> insertSObjects(Integer numberOfRecordsToInsert) {
        List<SObject> recordsToInsert = createNew(numberOfRecordsToInsert);
        commitInsert(recordsToInsert);
        return recordsToInsert;
    }

    protected virtual Map<SObjectField, Object> getDefaultValueMap() {
        return new Map<SObjectField, Object>();
    }

    private SObject build() {
        SObject instance = this.getSObjectType().newSObject(null, true);

        for (SObjectField defaultField : defaultValueMapCached.keySet()) {
            if (!customValueMap.containsKey(defaultField)) {
                // Skip any field that has been overridden through the custom value map
                instance.put(defaultField, defaultValueMapCached.get(defaultField));
            }
        }

        for (SObjectField customField : customValueMap.keySet()) {
            if (customValueMap.get(customField) != null) {
                instance.put(customField, customValueMap.get(customField));
            }
        }

        return instance;
    }

    private void commitInsert(List<SObject> records) {
        InsertTestDataUnitOfWork insertWork = new InsertTestDataUnitOfWork();
        insertWork.register(records, this);
        insertWork.commitWork();
        testDataHistory.log(records);
        insertChildren(records);
        clear();
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
                List<SObject> children = relationship.ChildBuilder.createNew(1);
                bulkWork.register(children, callback);
                testDataHistory.logWithParent(children, insertedRecord.Id);
            }
        }
        bulkWork.commitWork();
    }

    private void clear() {
        customValueMap = new Map<SObjectField, Object>();
        registeredRelationships = new List<ChildRelationship>();
    }

    private class TestDataBuilderCache {
        private Boolean initialized;
        private Map<SObjectType, Type> builderTypeBySObjectType;

        public TestDataBuilderCache() {
            this.initialized = false;
            this.builderTypeBySObjectType = new Map<SObjectType, Type>();
        }

        public ITestDataBuilder getFor(SObjectType objectType) {
            if (this.initialized == false) {
                initializeCache();
            }

            Type builderType = this.builderTypeBySObjectType.get(objectType);
            if (builderType == null) {
                return null;
            }
            return (ITestDataBuilder)builderType.newInstance();
        }

        private void initializeCache() {
            List<ApexClass> testDataBuilderClass = [SELECT Name, NamespacePrefix FROM ApexClass WHERE Name LIKE '%TestDataBuilder%'];
            for (ApexClass currentClass : testDataBuilderClass) {
                try {
                    Type currentClassType = Type.forName(currentClass.NamespacePrefix, currentClass.Name);
                    Object currentClassInstance = currentClassType.newInstance();
                    if (currentClassInstance instanceof ITestDataBuilder) {
                        ITestDataBuilder builderInstance = (ITestDataBuilder)currentClassInstance;
                        this.builderTypeBySObjectType.put(builderInstance.getSObjectType(), currentClassType);
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

    private class History {
        Map<SObjectType, List<HistoryItem>> insertedRecordsByType;

        public History() {
            this.insertedRecordsByType = new Map<SObjectType, List<HistoryItem>>();
        }

        public void log(List<SObject> insertedRecords) {
            for (SObject insertedRecord : insertedRecords) {
                HistoryItem item = new HistoryItem(insertedRecord);
                log(item);
            }
        }

        public void logWithParent(List<SObject> insertedRecords, Id parentRecordId) {
            for (SObject insertedRecord : insertedRecords) {
                HistoryItem item = new HistoryItem(insertedRecord, parentRecordId);
                log(item);
            }
        }

        public SObject getA(SObjectType objectType) {
            List<HistoryItem> historiesForType = insertedRecordsByType.get(objectType);
            if (historiesForType != null) {
                return historiesForType[0].getRecord();
            }
            return null;
        }

        public List<SObject> getChildrenOfByType(Id recordId, SObjectType objectType) {
            List<SObject> children = new List<SObject>();
            List<HistoryItem> itemsByType = this.insertedRecordsByType.get(objectType);
            if (itemsByType == null) {
                // If no record of that type has been logged then there are no children.
                return children;
            }
            for (HistoryItem item : itemsByType) {
                if (item.getParentRecordId() == recordId) {
                    children.add(item.getRecord());
                }
            }
            return children;
        }

        private void log(HistoryItem item) {
            List<HistoryItem> historiesByType = insertedRecordsByType.get(item.getRecord().getSObjectType());
            if (historiesByType == null) {
                historiesByType = new List<HistoryItem>();
            }
            historiesByType.add(item);
            insertedRecordsByType.put(item.getRecord().getSObjectType(), historiesByType);
        }
    }

    private class HistoryItem {
        private SObject record;
        private Id parentRecordId;

        public HistoryItem(SObject record) {
            this.record = record;
        }

        public HistoryItem(SObject record, Id parentRecordId) {
            this.record = record;
            this.parentRecordId = parentRecordId;
        }

        public SObject getRecord() {
            return this.record;
        }

        public Id getParentRecordId() {
            return this.parentRecordId;
        }
    }
}
