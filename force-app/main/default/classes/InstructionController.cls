public class InstructionController {
	@AuraEnabled(cacheable=true)
    public static Instruction__mdt getEmployeeInstructions(){
        return [SELECT MasterLabel, QualifiedApiName, Instruction__c FROM Instruction__mdt WHERE MasterLabel like 'EmployeeInstructions' LIMIT 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static void setEmployeeInstructions(string s){
        Instruction__mdt e = [SELECT MasterLabel, QualifiedApiName, Instruction__c FROM Instruction__mdt WHERE MasterLabel like 'EmployeeInstructions' LIMIT 1];
        MetadataDeploy.updateCustomMetadata(e, s);
        system.debug(s);
    }
    
    @AuraEnabled(cacheable=true)
    public static Instruction__mdt getManagerInstructions(){
        return [SELECT MasterLabel, QualifiedApiName, Instruction__c FROM Instruction__mdt WHERE MasterLabel like 'ManagerInstructions' LIMIT 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static void setManagerInstructions(string s){
        Instruction__mdt e = [SELECT MasterLabel, QualifiedApiName, Instruction__c FROM Instruction__mdt WHERE MasterLabel like 'ManagerInstructions' LIMIT 1];
        MetadataDeploy.updateCustomMetadata2(e, s);
        system.debug(s);
    }
}