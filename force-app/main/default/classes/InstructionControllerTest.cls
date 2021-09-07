@isTest
private class InstructionControllerTest {
    @isTest
    private static void test1(){
        test.startTest();
        InstructionController.setEmployeeInstructions('Employee Instructions Test 1');
        Instruction__mdt employeeInstructions = InstructionController.getEmployeeInstructions();
        test.stopTest();
        system.assertNotEquals(null, employeeInstructions.Instruction__c);
    }
     @isTest
    private static void test2(){
        test.startTest();
        InstructionController.setManagerInstructions('Manager Instructions Test 1');
        Instruction__mdt managerInstructions = InstructionController.getManagerInstructions();
        test.stopTest();
        system.assertNotEquals(null, managerInstructions.Instruction__c);
    }
}