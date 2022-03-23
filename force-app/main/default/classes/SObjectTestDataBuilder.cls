// TODO: Now that we are using fflib, let's see what we can do about defaulting parents. For example having a contact having a defualt AccountId
// how can we do that with the least amount of DMLs possible

// TODO: Rename everything that says insert now that we are not directly inserting here
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

    public static void commitRecords() {
        fflib_SObjectUnitOfWork uOW = new fflib_SObjectUnitOfWork(
            new List<SObjectType>(testDataHistory.getSObjectTypes()),
            fflib_SObjectUnitOfWork.UnresolvedRelationshipBehavior.AttemptResolveOutOfOrder
        );
        for (HistoryItem item : testDataHistory.getAllParents()) {
            System.debug('Registering parent');
            uOW.registerNew(item.getRecord());
        }

        for (HistoryItem item : testDataHistory.getAllChildren()) {
            System.debug('Registering child');
            // TODO: Add ability to use the relationship that has the External Id and test how many DML operations that uses
            uOW.registerNew(item.getRecord(), item.getRelationshipField(), item.getParentRecord());
        }
        uOW.commitWork();
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

    public SObjectTestDataBuilder withChild(ITestDataBuilder childBuilder, SObjectField relationshipField) {
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
        return this.insertSObjects(numberOfRecordsToInsert, null, null);
    }

    protected List<SObject> insertSObjects(Integer numberOfRecordsToInsert, SObjectField parentRelationship, SObject relatedTo) {
        List<SObject> recordsToInsert = createNew(numberOfRecordsToInsert);
        testDataHistory.log(recordsToInsert, relatedTo, parentRelationship);
        insertChildren(recordsToInsert);
        clear();
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

    private void insertChildren(List<SObject> insertedRecords) {
        for (SObject insertedRecord : insertedRecords) {
            for (ChildRelationship relationship : this.registeredRelationships) {
                SObjectTestDataBuilder relationshipAsTestData = (SObjectTestDataBuilder)relationship.ChildBuilder; // TODO: Cleaner way of doing this?
                relationshipAsTestData.insertSObjects(1, relationship.RelationshipField, insertedRecord);
            }
        }
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
        public SObjectField RelationshipField { get; private set; }

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

        public void log(List<SObject> insertedRecords, SObject parentRecord, SObjectField relationshipField) {
            for (SObject insertedRecord : insertedRecords) {
                HistoryItem item = new HistoryItem(insertedRecord, parentRecord, relationshipField);
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

        public Set<SObjectType> getSObjectTypes() {
            return this.insertedRecordsByType.keySet();
        }

        public List<HistoryItem> getAllParents() {
            List<HistoryItem> items = new List<HistoryItem>();
            for (HistoryItem item : this.getAll()) {
                if (item.isParent()) {
                    items.add(item);
                }
            }
            return items;
        }

        public List<HistoryItem> getAllChildren() {
            List<HistoryItem> items = new List<HistoryItem>();
            for (HistoryItem item : this.getAll()) {
                if (!item.isParent()) {
                    items.add(item);
                }
            }
            return items;
        }

        private List<HistoryItem> getAll() {
            List<HistoryItem> items = new List<HistoryItem>();
            for (List<HistoryItem> currentItems : this.insertedRecordsByType.values()) {
                items.addAll(currentItems);
            }
            return items;
        }

        public List<SObject> getChildrenOfByType(Id recordId, SObjectType objectType) {
            List<SObject> children = new List<SObject>();
            List<HistoryItem> itemsByType = this.insertedRecordsByType.get(objectType);
            if (itemsByType == null) {
                // If no record of that type has been logged then there are no children.
                return children;
            }
            for (HistoryItem item : itemsByType) {
//                System.debug('Item: ' + item.getRecord().get(Account.Name));
//                System.debug('Item Id: ' + item.getRecord().get(Account.Id));
//                System.debug('Items Parent: ' + item.getParentRecord());
                if (item.getParentRecord()?.Id == recordId) {
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
        private SObject parentRecord;
        private SObjectField relationshipToParent;

        public HistoryItem(SObject record) {
            this.record = record;
        }

        public HistoryItem(SObject record, SObject parentRecord, SObjectField relationshipField) {
            this.record = record;
            this.parentRecord = parentRecord;
            this.relationshipToParent = relationshipField;
        }

        public SObject getRecord() {
            return this.record;
        }

        public SObject getParentRecord() {
            return this.parentRecord;
        }

        public SObjectField getRelationshipField() {
            return this.relationshipToParent;
        }

        public Boolean isParent() {
            return this.parentRecord == null;
        }
    }
}