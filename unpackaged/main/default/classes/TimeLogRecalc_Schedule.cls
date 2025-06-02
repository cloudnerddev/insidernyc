global class TimeLogRecalc_Schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        TimeLogRecalc_Batch batchRun = new TimeLogRecalc_Batch(); 
        ID batchId = Database.executeBatch(batchRun,1);
        
    }
}