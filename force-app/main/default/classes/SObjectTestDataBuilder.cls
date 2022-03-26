public abstract class SObjectTestDataBuilder implements ITestDataBuilder, TestDataCallback.ITestDataCallback {
    private static TestDataBuilderCache builderCache = new TestDataBuilderCache();
    private static History testDataHistory = new History();
    private static List<LateBinding> allBindings = new List<LateBinding>();

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
        return of(objectType).registerNewForInsert();
    }

    public static List<SObject> getChildrenOfTypeById(Id recordId, SObjectType objectType) {
        return testDataHistory.getChildrenOfByType(recordId, objectType);
    }

    public static void commitRecords() {
        // TODO: Ensure that this can be called multiple times
        List<LateBinding> allLateBindings = new List<LateBinding>();
        while (allBindings.size() > 0) {
            // Using this technique because throughout this process the allBindings list could be modified
            // if more parents need to be added up the chain when registerNewForInsert gets called.
            LateBinding binding = allBindings.remove(0);
            allLateBindings.add(binding);
            SObject parentRecord = binding.builder.registerNewForInsert();
            binding.setCreatedParent(parentRecord);
        }

        if (testDataHistory.isEmpty()) {
            return;
        }

        List<SObjectType> workTypes = getSObjectTypesToRegisterToUnitOfWorkInOrder(allLateBindings);
        fflib_SObjectUnitOfWork uOW = new fflib_SObjectUnitOfWork(workTypes,
            fflib_SObjectUnitOfWork.UnresolvedRelationshipBehavior.AttemptResolveOutOfOrder
        );

        for (HistoryItem item : testDataHistory.getAll()) {
            uOW.registerNew(item.getRecord(), item.callback);
        }

        for (LateBinding binding : allLateBindings) {
            uOW.registerRelationship(binding.childRecord, binding.relationshipField, binding.parentRecord);
        }

        for (HistoryItem item : testDataHistory.getAllChildren()) {
            // If any of the records to insert have a relationship we register that as well
            uOW.registerRelationship(item.getRecord(), item.getRelationshipField(), item.getParentRecord());
        }
        uOW.commitWork();
    }

    private static List<SObjectType> getSObjectTypesToRegisterToUnitOfWorkInOrder(List<LateBinding> allLateBindingsTemp) {
        List<SObjectType> workTypes = new List<SObjectType>();
        for (Integer i = allLateBindingsTemp.size() - 1; i >= 0; i--) {
            // Using the reverse order of the parents, as the last records are the top-most parents
            SObjectType currentType = allLateBindingsTemp[i].parentRecord.getSObjectType();
            if (!workTypes.contains(currentType)) {
                workTypes.add(currentType);
            }
        }

        // Registering anything else that might not have been including through bindings (simpler relationships)
        for (SObjectType loggedType : testDataHistory.getSObjectTypes()) {
            if (!workTypes.contains(loggedType)) {
                workTypes.add(loggedType);
            }
        }
        return workTypes;
    }

    public abstract SObjectType getSObjectType();

    public List<SObject> createNew(Integer numberOfRecords) {
        List<SObject> recordsToInsert = new List<SObject>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            SObject recordToInsert = build();
            recordsToInsert.add(recordToInsert);
        }
        return recordsToInsert;
    }

    public SObjectTestDataBuilder withChild(ITestDataBuilder childBuilder, SObjectField relationshipField) {
        this.registeredRelationships.add(new ChildRelationship(childBuilder, relationshipField));
        return this;
    }

    public virtual void beforeInsert(SObject record) {}
    public virtual void afterInsert(SObject record) {}

    protected LateBinding bindTo(ITestDataBuilder builder) {
        return new LateBinding(builder);
    }

    protected SObjectTestDataBuilder withData(SObjectField field, Object value) {
        this.customValueMap.put(field, value);
        return this;
    }

    protected SObject registerSObjectForInsert() {
        return this.registerSObjectsForInsert(1)[0];
    }

    protected List<SObject> registerSObjectsForInsert(Integer numberOfRecordsToInsert) {
        return this.registerSObjects(numberOfRecordsToInsert, null, null);
    }

    protected List<SObject> registerSObjects(Integer numberOfRecordsToInsert, SObjectField parentRelationship, SObject relatedTo) {
        List<SObject> recordsToInsert = createNew(numberOfRecordsToInsert);
        testDataHistory.log(recordsToInsert, relatedTo, parentRelationship, this);
        registerChildren(recordsToInsert);
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
                Object fieldValue = defaultValueMapCached.get(defaultField);
                if (checkIfBinding(fieldValue, instance, defaultField)) {
                    continue;
                }
                instance.put(defaultField, fieldValue);
            }
        }

        for (SObjectField customField : customValueMap.keySet()) {
            if (customValueMap.get(customField) != null) {
                Object fieldValue = customValueMap.get(customField);
                if (checkIfBinding(fieldValue, instance, customField)) {
                    continue;
                }
                instance.put(customField, fieldValue);
            }
        }

        return instance;
    }

    private Boolean checkIfBinding(Object fieldValue, SObject record, SObjectField relationshipField) {
        if (fieldValue instanceof LateBinding) {
            LateBinding binding = (LateBinding)fieldValue;
            binding.setRelationshipField(relationshipField);
            binding.setChildRecord(record);
            allBindings.add(binding);
            return true;
        }
        return false;
    }

    private void registerChildren(List<SObject> insertedRecords) {
        for (SObject insertedRecord : insertedRecords) {
            for (ChildRelationship relationship : this.registeredRelationships) {
                SObjectTestDataBuilder relationshipAsTestData = (SObjectTestDataBuilder)relationship.ChildBuilder; // TODO: Cleaner way of doing this?
                relationshipAsTestData.registerSObjects(1, relationship.RelationshipField, insertedRecord);
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

    public class LateBinding {
        private ITestDataBuilder builder;
        private SObjectField relationshipField;
        private SObject childRecord;
        private SObject parentRecord;

        public LateBinding(ITestDataBuilder builder) {
            this.builder = builder;
        }

        public LateBinding setRelationshipField(SObjectField field) {
            this.relationshipField = field;
            return this;
        }

        private void setChildRecord(SObject childRecord) {
            this.childRecord = childRecord;
        }

        private void setCreatedParent(SObject parentRecord) {
            this.parentRecord = parentRecord;
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

        public void log(List<SObject> insertedRecords, SObject parentRecord, SObjectField relationshipField,
            TestDataCallback.ITestDataCallback callback) {
            for (SObject insertedRecord : insertedRecords) {
                HistoryItem item = new HistoryItem(insertedRecord, parentRecord, relationshipField, callback);
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

        public Boolean isEmpty() {
            return this.getAll().isEmpty();
        }

        public List<HistoryItem> getAll() {
            List<HistoryItem> items = new List<HistoryItem>();
            for (List<HistoryItem> currentItems : this.insertedRecordsByType.values()) {
                items.addAll(currentItems);
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

        public List<SObject> getChildrenOfByType(Id recordId, SObjectType objectType) {
            List<SObject> children = new List<SObject>();
            List<HistoryItem> itemsByType = this.insertedRecordsByType.get(objectType);
            if (itemsByType == null) {
                // If no record of that type has been logged then there are no children.
                return children;
            }
            for (HistoryItem item : itemsByType) {
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
        private TestDataCallback.ITestDataCallback callback;

        public HistoryItem(SObject record, SObject parentRecord, SObjectField relationshipField,
            TestDataCallback.ITestDataCallback callback) {
            this.record = record;
            this.parentRecord = parentRecord;
            this.relationshipToParent = relationshipField;
            this.callback = callback;
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

    public class SObjectTestDataBuilderException extends Exception {}
}
