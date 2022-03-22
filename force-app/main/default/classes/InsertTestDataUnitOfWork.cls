@IsTest
public class InsertTestDataUnitOfWork {
    private List<UnitOfWorkRegistration> registrations;

    public InsertTestDataUnitOfWork() {
        this.registrations = new List<UnitOfWorkRegistration>();
    }

    public void register(List<SObject> records, ITestDataCallback callback) {
        this.registrations.add(new UnitOfWorkRegistration(records, callback));
    }

    public void commitWork() {
        List<SObject> recordsToInsert = new List<SObject>();
        for (UnitOfWorkRegistration registration : this.registrations) {
            registration.callback.beforeInsert(registration.records);
            recordsToInsert.addAll(registration.records);
        }
        insert recordsToInsert;
        for (UnitOfWorkRegistration registration : this.registrations) {
            registration.callback.afterInsert(registration.records);
        }
    }

    private class UnitOfWorkRegistration {
        private List<SObject> records { get; private set; }
        private ITestDataCallback callback { get; private set; }

        public UnitOfWorkRegistration(List<SObject> records, ITestDataCallback callback) {
            this.records = records;
            this.callback = callback;
        }
    }
}
