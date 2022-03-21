public abstract class SObjectTestDataBuilder implements ITestDataBuilder {
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

    public SObjectTestDataBuilder() {
        customValueMap = new Map<SObjectField, Object>();
    }

    public static ITestDataBuilder of(SObjectType objectType) {
        ITestDataBuilder builder = builderCache.getFor(objectType);
        if (builder == null) {
            return new DynamicTestDataBuilder(objectType);
        }
        return builder;
    }

    public abstract SObjectType getSObjectType();

    protected SObjectTestDataBuilder withData(SObjectField field, Object value) {
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
}
