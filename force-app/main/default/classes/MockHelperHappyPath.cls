/**
 * Mock Helper class for testing the HappyPath of the MockTriggerHandler.
 **/ 
@isTest
public with sharing class MockHelperHappyPath extends MockITriggerHelper implements ITriggerHelper {

    public String getName() {
        return MockHelperHappyPath.class.getName();
    }
   
}