global class TimeLogRollupBatchScheduler implements Schedulable {
    global void execute(SchedulableContext ctx){
      TimeLogRollupBatch batch = new TimeLogRollupBatch();
      Database.executebatch(batch, 200);
    }

}