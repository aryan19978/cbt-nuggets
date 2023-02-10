global class DeleteDisSchLogScheduleTest implements Schedulable {
    global DeleteDisSchLogScheduleTest(){
        
    }
    global void execute(SchedulableContext sc) {
        Delete [select id,name from n2de__Distributor_schedule_log__c limit 10000];
    }
}