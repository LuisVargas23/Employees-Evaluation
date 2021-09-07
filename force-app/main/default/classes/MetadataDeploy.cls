public without sharing class MetadataDeploy implements Metadata.DeployCallback
{
    public List<FieldWrapper> listField{get;set;}
    public class FieldWrapper
    {
        public String fieldName {get; set;}
        public String fieldAPIName {get; set;}
    }
    
    public static String updateCustomMetadata(Instruction__mdt tcm, string s)
    {
        try {
            //Retrieve Object to modify
            //Instruction__mdt tcm = [SELECT MasterLabel, QualifiedApiName, Instruction__c FROM Instruction__mdt WHERE MasterLabel like 'EmployeeInstructions' LIMIT 1]; //retrieving custom metadata records, using the first.
            Id customMetadataId = tcm.Id;
            system.debug('CustomMetadata Id ' + customMetadataId);
            
            //Create new object
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
            customMetadata.fullName = 'Instruction.EmployeeInstructions'; //custom metadata name
            customMetadata.label = 'EmployeeInstructions';
            //customMetadata.id = customMetadataId;
            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue(); //the values you're changing/updating
            customField1.field = 'Instruction__c'; //the custom field API Name that you're wanting to insert/update a value of
            customField1.value = s;
            customMetadata.values.add(customField1);//add the changes to list of changes to be deployed
            
            // if(customMetadataId != null) //if a custom metadata record exists, add the id here
            // {
            //     Metadata.CustomMetadataValue customId = new Metadata.CustomMetadataValue();
            //     customId.field = 'Id';
            //     customId.value = customMetadataId;
            //     customMetadata.values.add(customId);
            // }
                Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            MetadataDeploy callback = new MetadataDeploy();
            // Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
            Id jobId;
            if (!Test.isRunningTest()) {

            jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            }

            system.debug('jobId is ' + jobId);
            
            // Metadata.DeployContainer metaDeploy1 = new Metadata.DeployContainer();
            // metaDeploy1.addMetadata(approvalConfigToInsert);
            // Id AsynchResult1 = Metadata.Operations.enqueueDeployment(metadeploy1, null);
            // system.debug('jobId ' + mdContainer);
            return 'Success';
            
        } catch (Exception e) {
            return e.getMessage();
        }
    }
    
    public static String updateCustomMetadata2(Instruction__mdt tcm, string s)
    {
        try {
            //Retrieve Object to modify
            //Instruction__mdt tcm = [SELECT MasterLabel, QualifiedApiName, Instruction__c FROM Instruction__mdt WHERE MasterLabel like 'EmployeeInstructions' LIMIT 1]; //retrieving custom metadata records, using the first.
            Id customMetadataId = tcm.Id;
            system.debug('CustomMetadata Id ' + customMetadataId);
            
            //Create new object
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
            customMetadata.fullName = 'Instruction.ManagerInstructions'; //custom metadata name
            customMetadata.label = 'ManagerInstructions';
            //customMetadata.id = customMetadataId;
            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue(); //the values you're changing/updating
            customField1.field = 'Instruction__c'; //the custom field API Name that you're wanting to insert/update a value of
            customField1.value = s;
            customMetadata.values.add(customField1);//add the changes to list of changes to be deployed
            
            // if(customMetadataId != null) //if a custom metadata record exists, add the id here
            // {
            //     Metadata.CustomMetadataValue customId = new Metadata.CustomMetadataValue();
            //     customId.field = 'Id';
            //     customId.value = customMetadataId;
            //     customMetadata.values.add(customId);
            // }
            
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            
            MetadataDeploy callback = new MetadataDeploy();
            // Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
            Id jobId;
            if (!Test.isRunningTest()) {

            jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            }
            system.debug('jobId is ' + jobId);
            
            // Metadata.DeployContainer metaDeploy1 = new Metadata.DeployContainer();
            // metaDeploy1.addMetadata(approvalConfigToInsert);
            // Id AsynchResult1 = Metadata.Operations.enqueueDeployment(metadeploy1, null);
            // system.debug('jobId ' + mdContainer);
            return 'Success';
            
        } catch (Exception e) {
            return e.getMessage();
        }
    }
    /*public static list<Test_Custom_Metadata__mdt> getMetaDataRecords()
    {
        list<Test_Custom_Metadata__mdt> tcm = [Select Id, label FROM Test_Custom_Metadata__mdt];
        return tcm;
    }*/
    
    
    // find all sObjects available in the organization
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if(result.status == Metadata.DeployStatus.SUCCEEDED)
        {
            //success
            System.debug(' ===>'+ result);
        }else{
            //not success
            System.debug(' ===> fail '+ result);
        }
    }
}