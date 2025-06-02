public class RunTimeLogRollupForCase {
    
    public class InputWrapper {
        @InvocableVariable(required=true)
        public Id caseId;
    }

    @InvocableMethod(label='Run Time Log Rollup Batch for Case' description='Runs the TimeLogRollupBatch for the provided Case Id')
    public static void runBatch(List<InputWrapper> inputList) {
        for (InputWrapper input : inputList) {
            if (input.caseId != null) {
                try {
                    Database.executeBatch(new TimeLogRollupBatch(input.caseId), 1);
                } catch (Exception e) {
                    
                }
            } 
        }
    }
}