public abstract class SObjectTestData {
    private static TestDataBuilderCache builderCache = new TestDataBuilderCache();
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

    public SObjectTestData() {
        customValueMap = new Map<SObjectField, Object>();
    }

    public static ITestDataBuilder of(SObjectType objectType) {
        ITestDataBuilder builder = builderCache.getFor(objectType);
        if (builder == null) {
            return new DynamicTestDataBuilder(objectType);
        }
        return builder;
    }

    protected abstract Map<SObjectField, Object> getDefaultValueMap();
    protected abstract SObjectType getSObjectType();

    protected SObjectTestData withData(SObjectField field, Object value) {
        this.customValueMap.put(field, value);
        return this;
    }

    protected SObject insertSObject() {
        SObject instance = build();
        customValueMap.clear();
        beforeInsert(new List<SObject> { instance });
        insert instance;
        afterInsert(new List<SObject> { instance });
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

    protected virtual void beforeInsert(List<SObject> records) {}
    protected virtual void afterInsert(List<SObject> records) {}

    private SObject build() {
        SObject instance = getSObjectType().newSObject(null, true);

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

    private class TestDataBuilderCache {
        private Boolean initialized;

        public TestDataBuilderCache() {
            this.initialized = false;
        }

        public ITestDataBuilder getFor(SObjectType objectType) {
            if (this.initialized == false) {
                // TODO: Query for all test data builder classes and populate the cache
            }

            // TODO: return from cache
            return null;
        }
    }
}
