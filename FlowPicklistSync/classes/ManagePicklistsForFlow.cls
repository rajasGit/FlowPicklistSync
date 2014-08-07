global Class ManagePicklistsForFlow implements Process.Plugin {


    global Process.PluginResult invoke(Process.PluginRequest request) {    

        String ObjectAPIName = (String) request.inputParameters.get('ObjectAPIName');
        String FieldAPIName = (String) request.inputParameters.get('FieldAPIName');
        
        Map<String,Object> result = new Map<String,Object>();
    
        ManagePicklist(ObjectAPIName, FieldAPIName);
 
        return new Process.PluginResult(result); 

    }
  
  private void deleteValuesFromTable(String objectName, String fieldName) {
    List<PicklistForFlow__c> plList =
      [select Id
       from PicklistForFlow__c
       where ObjectName__c = :objectName
       and PicklistFieldName__c = :fieldName];
    
    delete plList;
  }


    private void ManagePicklist(String ObjectAPIName, String FieldAPIName) {
 
    Schema.SObjectType sot = Schema.getGlobalDescribe().get(ObjectAPIName);
    Schema.DescribeSOBjectResult sotDesc = sot.getDescribe();
    Schema.DescribeFieldResult F = sotDesc.fields.getMap().get(FieldAPIName).getDescribe();
    List<Schema.PicklistEntry> P = F.getPicklistValues();
    Set<String> fieldValues = new Set<String>();
    Map<String, PicklistForFlow__c> flowMap;
    List<PicklistForFlow__c> toInsert = new List<PicklistForFlow__c>();
    
    for (PicklistEntry aPickListval : P) {
      fieldValues.add(aPickListval.getValue());
    }
    
    deleteValuesFromTable(ObjectAPIName, FieldAPIName);
    

    for (PicklistEntry aPickListval: P) {
        /*PicklistForFlow__c[] fpv = [select Name from PicklistForFlow__c where ObjectName__c = :ObjectAPIName and PicklistFieldName__c = :FieldAPIName and PickListValue__c = :aPickListval.getValue()];
        if (fpv.size() == 0 ) {
            PicklistForFlow__c newFpv = new PicklistForFlow__c(ObjectName__c = ObjectAPIName, PickListValue__c = aPickListval.getValue(), PicklistFieldName__c =FieldAPIName, PickListLabel__c =aPickListval.getLabel()  );
            Database.insert(newFpv);
        }*/
        toInsert.add(new PicklistForFlow__c(
          ObjectName__c = ObjectAPIName,
          PickListValue__c = aPickListval.getValue(),
          PicklistFieldName__c = FieldAPIName,
          PickListLabel__c = aPickListval.getLabel()));
    }
    
    if (!toInsert.isEmpty()) {
      insert toInsert;
    }
    
    }


    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.description = 'This Flow Plug-in can be used to manage picklist values of any Field outside of the object definition to be used by Flow.';
        result.tag = 'Picklist Utils';
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('ObjectAPIName', 
                Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('FieldAPIName',                                                   
                Process.PluginDescribeResult.ParameterType.STRING, true)
                };

        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{     
                };
   
        
        return result;
    }


        static testMethod void basicTest() {

        // Create dummy lead
        Account testAccount = new Account(Name='acme');
        insert testAccount;

        ManagePicklistsForFlow aPicklistPlugin = new ManagePicklistsForFlow();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('ObjectAPIName','Account');
        inputParams.put('FieldAPIName','Industry');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aPicklistPlugin.invoke(request);
        
        
        Schema.DescribeFieldResult F = Account.Industry.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        
        PicklistForFlow__c[] fpv = [select PicklistFieldName__c from PicklistForFlow__c where ObjectName__c = 'Account' and PicklistFieldName__c = 'Industry'];
        
        System.AssertEquals(P.size(), fpv.size());
        
        
        //Make sure another call to the plugin does not result in duplicate entries
        result = aPicklistPlugin.invoke(request);        
        fpv = [select PicklistFieldName__c from PicklistForFlow__c where ObjectName__c = 'Account' and PicklistFieldName__c = 'Industry'];
        
        System.AssertEquals(P.size(), fpv.size());
                
        }

        
                

        static testMethod void describeTest() {

            ManagePicklistsForFlow aPicklistPlugin = new ManagePicklistsForFlow();
            Process.PluginDescribeResult result = aPicklistPlugin.describe();
                
            System.AssertEquals(result.inputParameters.size(), 2);
            System.AssertEquals(result.OutputParameters.size(), 0);
        
        }
        
        
}