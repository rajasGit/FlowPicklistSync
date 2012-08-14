FlowPicklistSync
===================

Flow Apex Plug-in and a sample Flow to show how you can use Flow to use existing Picklist definitions without re-creating
them as Choices in Flow.

Contents
--------
1. Custom object which will be used by Flow to keep track of the picklist values
2. Flow Apex Plug-in which will populate the Custom Object with the latest picklist values for a given SObject and a field name
3. Sample Flow to see how you can use the Account Industry picklist field values and the Lead Status picklist field values

Instructions( When using Salesforce Ant)
-----------------------------------------
1. Get the package
2. Modify the build.properties file to point to your salesforce instance
3. run 'ant deployUnpackaged'
4. You can run the included Flow to see how Flow can use the Account Industry picklist field values and the Lead Status picklist field values

Mechanics
---------
1. The Apex Plug-in uses the Describe APIs to populate the picklist values of any SObject/Field in the custom object.
2. The Flow has a dynamic choice which is configured to go against this custom object.
3. If you want to re-use the picklist values in a Flow, simple drag and drop the Apex Plug-in *before* you want to show the information to the user
   making sure you specifiy the SObject and the field name (All API Names) in the Apex Plug-in


