/**
  Test Utility to create object data
**/
@isTest
public with sharing class TestDataFactory {
    
    private static final String CRM_TYPE = 'SF2CRM_SYNC_ENABLER';
    private static final String CRM_TRANSFORM = 'Enabled';
    public static final Integer DEFAULT_BATCH_SIZE = 200;

    public sObject insertObject(SObjectType type, Boolean doInsert, Map<String,Object> options){
        sObject obj = type.newSObject();
        buildObject(obj, options);
        if(doInsert) {
            insert obj;
        }
        
        return obj;
    }

    /**
     * Responsible for Creating the sObject required for insertion with the right data from options provided.
     **/ 
    private void buildObject(sObject obj, Map<String,Object> options){
        if(options != null){
            for(String option : options.keySet()){
                obj.put(option, options.get(option));
            }
        } 
    }

    
    /**
     * Ensures that all values required are a part of the options list 
     **/ 
    public void overrideDefaultOptions(Map<String,Object> options, Map<String,Object> testDefaultOptions){
        if (options == null || testDefaultOptions == null) {return;}

        for(String option : testDefaultOptions.keySet()){
            if(!options.containsKey(option)){
                options.put(option, testDefaultOptions.get(option));
            }
        }
    }
   
}