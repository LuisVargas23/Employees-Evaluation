@isTest
public with sharing class MetadataDeployTest {

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void updateCustomMetadataTest(){
        Instruction__mdt currentData = new Instruction__mdt();
        String dataToUpdate = 'Hello World';
        test.startTest();
        String myCustomMetaData = MetadataDeploy.updateCustomMetadata(currentData, dataToUpdate);
        test.stopTest();
        system.assertEquals('Success', myCustomMetaData);

    }

    @isTest
    static void updateCustomMetadata2Test(){
        Instruction__mdt currentData = new Instruction__mdt();
        String dataToUpdate = 'Hello World';
        test.startTest();
        String myCustomMetaData = MetadataDeploy.updateCustomMetadata2(currentData, dataToUpdate);
        test.stopTest();
        system.assertEquals('Success', myCustomMetaData);
        
    }

    @IsTest
    static void testMyCallback() {
        // Instantiate the callback.
        Metadata.DeployCallback callback = new MetadataDeploy();
        // Create test result and context objects.
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.numberComponentErrors = 1;
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
        // Invoke the callback's handleResult method.
        callback.handleResult(result, context);
    }

    @IsTest
    static void fieldWrapperTest(){
   
    MetadataDeploy.FieldWrapper myClass = new  MetadataDeploy.FieldWrapper();
    myClass.fieldName = 'Test';
    myClass.fieldAPIName = 'Test_API';
    
}

    

    
}