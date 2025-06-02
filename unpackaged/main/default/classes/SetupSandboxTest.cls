@isTest
class SetupSandboxTest {
    @isTest
    static void test() {
        Global_Setting__c GS = new Global_Setting__c();
        INSERT GS;
        
        Test.testSandboxPostCopyScript(
            new SetupSandbox(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
    }
}