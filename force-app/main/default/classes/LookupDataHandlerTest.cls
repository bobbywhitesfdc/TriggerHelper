/**
* Unit test for LookupDataHandler
**/
@IsTest(IsParallel=true)
public class LookupDataHandlerTest {
    public static final Integer CHUNK_MAX = 200;
    
    
    @testsetup
    public static void setup() {
        
    }
    
    /**
     * Test the requestItem method - positive
     **/ 
    public static testmethod void testRequestItemGood() {
        LookupDataHandler ldh = new LookupDataHandler();
        
        final String TESTTOPIC = 'User';
        final Id testId = UserInfo.getUserId();
        
        Test.StartTest();
        ldh.requestItemDetail(testId);        
        Test.StopTest();
        
        System.AssertEquals(TESTTOPIC,ldh.getDefaultTopic(testId),'Topic name must match expected');
        System.AssertNotEquals(null,ldh.getKeySetForTopic(TESTTOPIC),'Keyset must be returned for topic');
        System.Assert(ldh.isRequestedItemDetail(testId),'Key must report as requested');
    }
    
    /**
     * Test the requestItem method - positive
     **/ 
    public static testmethod void testRequestItemExtIdGood() {
        LookupDataHandler ldh = new LookupDataHandler();
        
        final String TESTTOPIC = 'Products';
        final String testKey = 'Banana';
        
        Test.StartTest();
        ldh.requestExternalId(TESTTOPIC,testKey);        
        Test.StopTest();
        
        System.AssertNotEquals(null,ldh.getKeySetForTopic(TESTTOPIC),'Keyset must be returned for topic');
        System.Assert(ldh.isRequestedExternalId(TESTTOPIC,testKey),'Key must report as requested');
    }
    
    /**
     * Test the requestItem method - negative for null value
     **/ 
    public static testmethod void testRequestItemNull() {
        LookupDataHandler ldh = new LookupDataHandler();
                
        try {
            Test.StartTest();
            ldh.requestItemDetail(null);
            System.Assert(false,'Must not reach this line! Exception expected');
            Test.StopTest();
        } catch (DesignByContractUtil.DBCAssertionException dbcex) {
            System.Assert(true,'Expected!');
            System.Assert(!ldh.isRequestedItemDetail(null),'Must not show as requested');
        }        
    }
    
    /**
     * Test the query method - positive
     **/ 
    public static testmethod void testGetDetailItemSingle() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        
        final String TESTTOPIC = 'User';
        final Id testId = UserInfo.getUserId();

        
        Test.StartTest();
        ldh.requestItemDetail(testId);        
        User result = (User) ldh.getItemDetail(testId);
        Test.StopTest();
        
        System.AssertNotEquals(null,result,'Must have a valid result');
        System.AssertEquals(testId,result.Id,'Id field must match requested value');
        System.AssertNotEquals(null,result.FirstName,'FirstName field must be set');
        System.AssertNotEquals(null,result.LastName,'LastName field must be set');
        System.AssertNotEquals(null,result.Profile.Name,'Profile.Name field must be set');
        System.AssertNotEquals(null,result.IsActive,'IsActive field must be set');
        System.AssertNotEquals(null,result.Email,'Email field must be set');
        
    }
    
    
    /**
     * Test the query method - positive
     **/ 
    public static testmethod void testGetDetailItemMultiples() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        
        final String TESTTOPIC = 'User';

        final Id testId = UserInfo.getUserId();
        
        final Map<Id,User> testUsers = new Map<Id,User>([select id from User Limit :CHUNK_MAX]);
        
        for (Id currentId : testUsers.keyset()) {
           System.debug('Requesting: ' + currentId);
           ldh.requestItemDetail(currentId); 
        }
        
        
        Test.StartTest();

        ldh.requestItemDetail(testId); // Specific id of running user
                        
        Test.StopTest();
        
        final Set<Id> combinedKeys = new Set<Id>();
        combinedKeys.addall(testUsers.keyset());
        combinedKeys.add(testId);
        final Set<Id> requestedKeys = ldh.getRequestedItemDetailKeys(User.SObjectType);
        for (Id currentId : requestedKeys) {
            System.Assert(combinedKeys.contains(currentId),'Only test users are expected to be in the requested Keyset! No extras!' + testId);
        }
        
        for (Id currentId : testUsers.keyset()) {
           System.Assert(requestedKeys.contains(currentId),'key must have been requested in advance');
           User result = (User) ldh.getItemDetail(currentId);
           System.AssertNotEquals(null,result,'Requested id must be returned');
           System.AssertEquals(result.Id,currentId,'Requested id field must be accessible');
        }               
    }
    
    /**
     * Test the query method - Not Requested
    **/ 
    public static testmethod void testGetDetailItemNotRequested() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        
        final String TESTTOPIC = 'User';
        final Id testId = UserInfo.getUserId();
        
        
        //ldh.requestItemDetail(testId); // For this test, don't ask for the item in advance
        try {
            Test.StartTest();
            User result = (User) ldh.getItemDetail(testId);
            Test.StopTest();
            System.Assert(false,'Must not reach this line!');
            
        } catch (DesignByContractUtil.DBCAssertionException dbcex) {
            System.Assert(true,'Expected!');
        }                
        
    }
    
    public static testmethod void testRequestRelatedList() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        
        final String TESTTOPIC = 'RelatedTasks';
        final Id testId = UserInfo.getUserId();
        
        Test.StartTest();
        ldh.requestRelatedList(TESTTOPIC,testId);        
        Test.StopTest();
        
        System.AssertNotEquals(null,ldh.getKeySetForTopic(TESTTOPIC),'Keyset must be returned for topic');
        System.Assert(ldh.getKeySetForTopic(TESTTOPIC).contains(testId),'Keyset must contain our testId');
        
    }
    /**
     * Test the requestRelatedList method - negative for null value
     **/ 
    public static testmethod void testRequestRelatedListNull() {
        LookupDataHandler ldh = new LookupDataHandler();
        final String TESTTOPIC = 'RelatedTasks';
                
        try {
            Test.StartTest();
            ldh.requestRelatedList(TESTTOPIC,null);
            System.Assert(false,'Must not reach this line! Exception expected');
            Test.StopTest();
        } catch (DesignByContractUtil.DBCAssertionException dbcex) {
            System.Assert(true,'Expected!');
        }        
    }
    
    private static void createTestData() {
        // Create some test accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i=0; i < 10; i++) {
            testAccounts.add(new Account(name='test'+i));
        }
        insert testAccounts;
        
        // Create tasks for the test accounts
        List<Task> testTasks = new List<Task>();
        Set<Id> testIds = new Set<Id>();
        for (Account current : [select id, name from Account]) {
            // Request the tasks now while we're iterating the list
            testIds.add(current.Id);
            for (Integer j=0; j < 5; j++) {
                testTasks.add(new Task(WhatId=current.Id, Subject='Task'+j));
            }
        }
        insert testTasks;

    }
    
    public static testmethod void testGetRelatedList() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        final String TESTTOPIC = 'RelatedTasks';
        
        createTestData();
        
        final Set<Id> testIds = new Set<Id>();

        for (Account current : [select id, name from Account]) {
            testIds.add(current.Id);
            ldh.requestRelatedList(TESTTOPIC,current.Id);
        }
        
        
        
        Test.StartTest();
        
        for (Id current : testIds) {
           List<Task> results = (List<Task>) ldh.getRelatedList(TESTTOPIC,current);
           System.AssertNotEquals(null,results,'Results cannot be null');
           System.AssertEquals(5,results.size(),'Wrong size result list');
            for (Task result : results) {
                System.AssertEquals(current,result.WhatId,'Foreign Key must match requested');
            }
        }
        
        Test.StopTest();
        
        // Inspect the requestedIds, look for extras
        for (Id requestedId : ldh.getRequestedRelatedListKeys(TESTTOPIC)) {
            System.Assert(testIds.contains(requestedId),'Found extra requestedId not expected:' + requestedId);
        }
        
    }
    
    /**
     * Negative Test to demonstrate error handling on a bad topic SOQL definition -- invalid field
     **/ 
    public static testmethod void negativeTopicDefBadField() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        final String TESTTOPIC = 'RelatedTasksNegative1';
        
        createTestData();
        
        final Set<Id> testIds = new Set<Id>();

        for (Account current : [select id, name from Account]) {
            testIds.add(current.Id);
            ldh.requestRelatedList(TESTTOPIC,current.Id);
        }
        
        
        
        Test.StartTest();
        
        final Id testId = [select id from Account limit 1].id;
        
        try {
           List<Task> results = (List<Task>) ldh.getRelatedList(TESTTOPIC,testId); 
            System.Assert(false,'Must not reach this line');
        } catch (QueryTopicException qtex) {
            System.Assert(true,'Expected');
        }

        
        Test.StopTest();
        
        
    }
    
    public static testmethod void testGetDefaultTopicNeg() {
        LookupDataHandler ldh = new LookupDataHandler();
        final Id testId = TestUtility.generateFakeId(Case.SObjectType);
        final String topic = ldh.getDefaultTopic(testId);
        System.Debug('Default topic: ' + topic);
        System.AssertNotEquals(null,topic,'Topic cannot be null');
    }
    
    /**
     * Negative Test to demonstrate error handling on a Missing definition
     **/ 
    public static testmethod void negativeTopicMissing() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
    
        Test.StartTest();
        
        final Id testId = TestUtility.generateFakeId(Opportunity.SObjectType);
                
        try {
            ldh.requestItemDetail(testId);
            ldh.getItemDetail(testId);
            System.Assert(false,'Must not reach this line');
        } catch (QueryTopicException qtex) {
            System.Assert(true,'Expected');
        }
       
        Test.StopTest();                
    } 
    
    /**
     * Negative Test to demonstrate error handling on a Missing definition
     **/ 
    public static testmethod void negativeDetailTopicSOQL() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        

    
        Test.StartTest();
        
        final Id testId = TestUtility.generateFakeId(BusinessBrand.SObjectType);
        final String topic = ldh.getDefaultTopic(testId);
                
        try {
            ldh.requestItemDetail(testId);
            ldh.getItemDetail(testId);
            System.Assert(false,'Must not reach this line');
        } catch (QueryTopicException qtex) {
            System.Assert(true,'Expected');
        }
       
        Test.StopTest();                
    } 

    /**
     * Negative Test to demonstrate error handling on a Missing definition
     **/ 
    public static testmethod void negativeDetailTopicExternalId() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        

    
        Test.StartTest();
        
        final String topic = 'ObviouslyBadTopic';
        final String keyValue = 'bad value';
                
        try {
            ldh.requestExternalId(topic,keyValue);
            ldh.getExternalId(topic,keyValue);
            System.Assert(false,'Must not reach this line');
        } catch (QueryTopicException qtex) {
            System.Assert(true,'Expected');
        }
       
        Test.StopTest();                
    }     

    /**
     * Negative Test to demonstrate error handling on a Bad SOQL definition
     **/ 
    public static testmethod void negativeTopicConfigExternalId() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        

    
        Test.StartTest();
        
        // Config exists for this topic, but the SOQL defined in it is incorrect
        final String topic = 'ProductsBad';
        final String keyValue = 'Banana';
                
        try {
            ldh.requestExternalId(topic,keyValue);
            ldh.getExternalId(topic,keyValue);
            System.Assert(false,'Must not reach this line');
        } catch (QueryTopicException qtex) {
            System.Assert(true,'Expected');
        }
       
        Test.StopTest();                
    }     
    
    /**
     * Negative Test to demonstrate error handling on a Missing definition
     **/ 
    public static testmethod void negativeDetailTopicRelatedList() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        

    
        Test.StartTest();
        
        final String topic = 'ObviouslyBadTopic';
        final Id keyValue = TestUtility.generateFakeId(BusinessBrand.SObjectType);

                
        try {
            ldh.requestRelatedList(topic, keyValue);
            ldh.getRelatedList(topic,keyValue);
            System.Assert(false,'Must not reach this line');
        } catch (QueryTopicException qtex) {
            System.Assert(true,'Expected');
        }
       
        Test.StopTest();                
    }     

    /**
     * Test the query by ExternalId method - positive
     **/ 
    public static testmethod void testGetExternalIdSingle() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        
        final String TESTTOPIC = 'Products';
        final String testKey = 'Banana';
        
        Product2 testData = new Product2(StockKeepingUnit=TESTKEY,Name='Fresh Banana');
        insert testData;

        
        Test.StartTest();
        ldh.requestExternalId(TESTTOPIC,testKey);        
        Product2 result = (Product2) ldh.getExternalId(TESTTOPIC,testKey);
        Test.StopTest();
        
        System.AssertNotEquals(null,result,'Must have a valid result');
        System.AssertNotEquals(null,result.Id,'Must have a valid result.Id');
        System.AssertEquals(testKey,result.StockKeepingUnit,'ExternalId field must match requested value');        
    }
    /**
     * Test the query by ExternalId method - positive for multiple value
     **/ 
    public static testmethod void testGetExternalIdMultiples() {
        QueryTopicFactory.context='UnitTest';
        LookupDataHandler ldh = new LookupDataHandler();
        
        /** Create test data **/
        final String TESTTOPIC = 'Products';
        final Set<String> goodKeys = new Set<String> { 'Banana', 'Apple','Pear','Kiwi' };
        final Set<String> badKeys = new Set<String> { 'Rocks', 'Sticks'};
        final Set<String> allKeys = new Set<String>(goodKeys);
        allKeys.addAll(badKeys);
        
        List<SObject> myTestDataSet = new List<SObject>();
        for (String current : goodKeys) {
            myTestDataSet.add(new Product2(StockKeepingUnit=current,Name='BrandX ' + current));            
        }
        insert myTestDataSet;

        // Request the data
        for (String currentKey : allKeys ) {
           ldh.requestExternalId(TESTTOPIC,currentKey);
           System.Assert(ldh.isRequestedExternalId(TESTTOPIC, currentKey),'Must be requested in KeySet');
        }
        
        Test.StartTest();
        // Get the good data
        for (String currentKey : goodKeys ) {
           Product2 result = (Product2) ldh.getExternalId(TESTTOPIC,currentKey);
           System.AssertNotEquals(null,result,'Must have a valid result');
           System.AssertNotEquals(null,result.Id,'Must have a valid result.Id');
           System.AssertEquals(currentKey,result.StockKeepingUnit,'ExternalId field must match requested value');        
        }
        
        // Test for bad keys now and expect no hits
        for (String currentKey : badKeys ) {
           Product2 result = (Product2) ldh.getExternalId(TESTTOPIC,currentKey);
           System.AssertEquals(null,result,'Bad Key must not have a valid result');
        }
        Test.StopTest();
        
        for (String currentKey : new Set<String> { 'Aliens', 'Mythological Creatures'}) {
           System.Assert(!ldh.getRequestedExternalIdKeys(TESTTOPIC).contains(currentKey),'Unrequested key not expected: ' + currentKey);
        }
    }

}