@isTest
private class RecursiveTriggerHandlerTest {
	
	@isTest 
	private static void test1() {
		Test.startTest();

		RecursiveTriggerHandler.isFirstTime = true;
		System.assertEquals(true,RecursiveTriggerHandler.isFirstTime);
		
		Test.stopTest();
	}
	
}