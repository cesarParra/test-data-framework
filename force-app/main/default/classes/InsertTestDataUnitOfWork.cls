// TODO: Refactor functionality into the fflib_UoW and get rid of this
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
            registration.Callback.beforeInsert(registration.Records);
            recordsToInsert.addAll(registration.Records);
        }
        insert recordsToInsert;
        for (UnitOfWorkRegistration registration : this.registrations) {
            registration.Callback.afterInsert(registration.Records);
        }
    }

    private class UnitOfWorkRegistration {
        private List<SObject> Records { get; private set; }
        private ITestDataCallback Callback { get; private set; }

        public UnitOfWorkRegistration(List<SObject> records, ITestDataCallback callback) {
            this.Records = records;
            this.Callback = callback;
        }
    }
}
