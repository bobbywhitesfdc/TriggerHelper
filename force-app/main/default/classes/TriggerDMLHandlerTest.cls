/**
 * Unit test for TriggerDMLHandler
 *  
 **/ 
@isTest(isParallel=true)
public class TriggerDMLHandlerTest {
    // For tests that do batch inserts
    public static final Integer BATCHSIZE=10;
    
    private static Boolean isEven(final Integer n) {
        return Math.Mod(n,2) == 0;
    }
    private static Boolean isOdd(final Integer n) {
        return Math.Mod(n,2) != 0;
    }

    /**
     * Reproduce a problem seen in FIT  -- failure to Sort the Collection containing two or more different SObject Types:
     * See: https://stackoverflow.com/questions/22194740/system-typeexception-cannot-have-more-than-10-chunks-in-a-single-operation
     *  
     * FATAL_ERROR: System.TypeException: Cannot have more than 10 chunks in a single operation. 
     * Please rearrange the data to reduce chunking. 
     * Class.DMLExecutor.updateData: line 11, column 1 
     * Class.TriggerDMLHandler.updateObjects: line 136, column 1 
     * Class.TriggerDMLHandler.applyDML: line 226, column 1 
     * Class.AbstractTriggerHandlerBase.afterUpdate: line 241, column 1 
     * Class.TriggerDispatcher.run: line 23, column 1 
     * Trigger.CaseTrigger: line 3, column 1
     **/ 
    public static testmethod void stressfulMixedBatchInsert() {
        final Integer MIXEDBATCHSIZE = 10; // Smallest batch to produce the error
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        List<SObject> testData = new List<SObject>();
        for(Integer i=0; i < MIXEDBATCHSIZE; i++) {
            SObject testRecordT1 = new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated');
            testData.add(testRecordT1);
            dmlHandler.addForInsert(testRecordT1);
            SObject testRecordT2 = new Task(Subject='Test Subject'+i);
            dmlHandler.addForInsert(testRecordT2);
            System.AssertNotEquals(testRecordT1.getSObjectType(),testRecordT2.getSObjectType(),'Types must be different');
        }
        System.AssertEquals(MIXEDBATCHSIZE*2,dmlHandler.toInsert.size(),'Test data size incorrect');
        
        try {
            // Prove that the Unsorted List will fail
            insert dmlHandler.toInsert; // Before sorting
            System.Assert(false,'Must not reach this line or test is invalid');
        } catch(System.TypeException stex) {
            System.Debug('Forced error:' + stex.getMessage());
            System.Assert(true,'Caught expected exception');
        }
        
        
        Test.StartTest();
        
        List<Database.SaveResult> results = dmlHandler.insertObjects(); // Apply the inserts in one shot
        System.AssertEquals(MIXEDBATCHSIZE*2,results.size(),'Result set size incorrect');
        
        Test.StopTest();
        
        for(Database.SaveResult current : results) {
            System.AssertEquals(true,current.isSuccess(),'No failures expected');
        }
        
    }
    /**
     * Reproduce a problem seen in FIT  -- failure to Sort the Collection containing two or more different SObject Types:
     * See: https://stackoverflow.com/questions/22194740/system-typeexception-cannot-have-more-than-10-chunks-in-a-single-operation
     *  
     * FATAL_ERROR: System.TypeException: Cannot have more than 10 chunks in a single operation. 
     * Please rearrange the data to reduce chunking. 
     * Class.DMLExecutor.updateData: line 11, column 1 
     * Class.TriggerDMLHandler.updateObjects: line 136, column 1 
    **/ 
    public static testmethod void stressfulMixedBatchUpdate() {
        final Integer MIXEDBATCHSIZE = 10; // Smallest batch to produce the error
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        List<SObject> testData = new List<SObject>();
        for(Integer i=0; i < MIXEDBATCHSIZE; i++) {
            SObject testRecordT1 = new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated');
            testData.add(testRecordT1);
            SObject testRecordT2 = new Task(Subject='Test Subject'+i);
            testData.add(testRecordT2);
            System.AssertNotEquals(testRecordT1.getSObjectType(),testRecordT2.getSObjectType(),'Types must be different');
        }
        
        System.AssertEquals(MIXEDBATCHSIZE*2,testData.size(),'Test data size incorrect');
        
        testData.sort(); // Ensure it can be inserted
        
        insert testData;
        
        // Now that it's been inserted, we'll make a harmless update
        List<Trigger_Framework_Mock__c> justMocks = new List<Trigger_Framework_Mock__c>();
        List<Task> justTasks = new List<Task>();
        for(SObject current : testData) {
            if (current.Id.getSobjectType() == Trigger_Framework_Mock__c.SObjectType) {
                ((Trigger_Framework_Mock__c) current).name = 'ACME';
                justMocks.add((Trigger_Framework_Mock__c)current);
            } else {
                ((Task) current).status = 'Closed'; 
                justTasks.add((Task)current);
            }
        }
        
        // Jumble the records up,alternating by kind to max out the batches
        for (Integer j=0;  j < MIXEDBATCHSIZE; j++) {
            dmlHandler.putForUpdate(justMocks[j]);
            dmlHandler.putForUpdate(justTasks[j]);
        }
                
        List<SObject> copyOfValues = dmlHandler.toUpdate.values();
        
        try {
            // Prove that the Unsorted List will fail
            update copyOfValues;
            System.Assert(false,'Must not reach this line or test is invalid');
        } catch(System.TypeException stex) {
            System.Debug('Forced error:' + stex.getMessage());
            System.Assert(true,'Caught expected exception');
        }
        
        Test.StartTest();
        
        List<Database.SaveResult> results = dmlHandler.updateObjects(); // Apply the inserts in one shot
        System.AssertEquals(MIXEDBATCHSIZE*2,results.size(),'Result set size incorrect');
        
        Test.StopTest();
        
        for(Database.SaveResult current : results) {
            System.AssertEquals(true,current.isSuccess(),'No failures expected');
        }
        
    }
    /**
     * Reproduce a problem seen in FIT  -- failure to Sort the Collection containing two or more different SObject Types:
     * See: https://stackoverflow.com/questions/22194740/system-typeexception-cannot-have-more-than-10-chunks-in-a-single-operation
     *  
     * FATAL_ERROR: System.TypeException: Cannot have more than 10 chunks in a single operation. 
     * Please rearrange the data to reduce chunking. 
     * Class.DMLExecutor.updateData: line 11, column 1 
     * Class.TriggerDMLHandler.updateObjects: line 136, column 1 
    **/ 
    public static testmethod void stressfulMixedBatchDelete() {
        final Integer MIXEDBATCHSIZE = 10; // Smallest batch to produce the error
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        List<SObject> testData = new List<SObject>();
        for(Integer i=0; i < MIXEDBATCHSIZE; i++) {
            SObject testRecordT1 = new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated');
            testData.add(testRecordT1);
            SObject testRecordT2 = new Task(Subject='Test Subject'+i);
            testData.add(testRecordT2);
            System.AssertNotEquals(testRecordT1.getSObjectType(),testRecordT2.getSObjectType(),'Types must be different');
        }
        
        System.AssertEquals(MIXEDBATCHSIZE*2,testData.size(),'Test data size incorrect');
        
        testData.sort(); // Ensure it can be inserted
        
        insert testData;
        
        // Now that it's been inserted, we'll make a harmless update
        List<Trigger_Framework_Mock__c> justMocks = new List<Trigger_Framework_Mock__c>();
        List<Task> justTasks = new List<Task>();
        for(SObject current : testData) {
            if (current.Id.getSobjectType() == Trigger_Framework_Mock__c.SObjectType) {
                justMocks.add((Trigger_Framework_Mock__c)current);
            } else {
                justTasks.add((Task)current);
            }
        }
        
        // Jumble the records up,alternating by kind to max out the batches
        for (Integer j=0;  j < MIXEDBATCHSIZE; j++) {
            dmlHandler.addForDelete(justMocks[j]);
            dmlHandler.addForDelete(justTasks[j]);
        }
        
        
        List<SObject> copyOfValues = dmlHandler.toDelete.values();
        
        try {
            // Prove that the Unsorted List will fail
            delete copyOfValues;
            System.Assert(false,'Must not reach this line or test is invalid');
        } catch(System.TypeException stex) {
            System.Debug('Forced error:' + stex.getMessage());
            System.Assert(true,'Caught expected exception');
        }
        
        Test.StartTest();
        
        List<Database.DeleteResult> results = dmlHandler.deleteObjects(); // Apply the inserts in one shot
        System.AssertEquals(MIXEDBATCHSIZE*2,results.size(),'Result set size incorrect');
        
        Test.StopTest();
        
        for(Database.DeleteResult current : results) {
            System.AssertEquals(true,current.isSuccess(),'No failures expected');
        }
        
    }
    
    /**
     * Reproduce a problem seen in FIT  -- failure to Sort the Collection containing two or more different SObject Types:
     * See: https://stackoverflow.com/questions/22194740/system-typeexception-cannot-have-more-than-10-chunks-in-a-single-operation
     *  
     * FATAL_ERROR: System.TypeException: Cannot have more than 10 chunks in a single operation. 
     * Please rearrange the data to reduce chunking. 
     * Class.DMLExecutor.updateData: line 11, column 1 
     * Class.TriggerDMLHandler.updateObjects: line 136, column 1 
    **/ 
    public static testmethod void stressfulMixedBatchUndelete() {
        final Integer MIXEDBATCHSIZE = 10; // Smallest batch to produce the error
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        List<SObject> testData = new List<SObject>();
        for(Integer i=0; i < MIXEDBATCHSIZE; i++) {
            SObject testRecordT1 = new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated');
            testData.add(testRecordT1);
            SObject testRecordT2 = new Task(Subject='Test Subject'+i);
            testData.add(testRecordT2);
            System.AssertNotEquals(testRecordT1.getSObjectType(),testRecordT2.getSObjectType(),'Types must be different');
        }
        
        System.AssertEquals(MIXEDBATCHSIZE*2,testData.size(),'Test data size incorrect');
        
        testData.sort(); // Ensure it can be inserted
        
        insert testData;
        delete testData;
        
        // Now that it's been delete, we'll queue it for Undelete
        List<Trigger_Framework_Mock__c> justMocks = new List<Trigger_Framework_Mock__c>();
        List<Task> justTasks = new List<Task>();
        
        // Prep the data
        for(SObject current : testData) {
            if (current.Id.getSobjectType() == Trigger_Framework_Mock__c.SObjectType) {
                justMocks.add((Trigger_Framework_Mock__c)current);
            } else {
                justTasks.add((Task)current);
            }
        }
        
        // Jumble the records up,alternating by kind to max out the batches
        for (Integer j=0;  j < MIXEDBATCHSIZE; j++) {
            dmlHandler.addForUndelete(justMocks[j]);
            dmlHandler.addForUndelete(justTasks[j]);
        }
        
        // Unsorted values
        List<SObject> copyOfValues = dmlHandler.toUndelete.values();
        
        Test.StartTest();
        
        List<Database.UndeleteResult> results = dmlHandler.undeleteObjects(); 
        System.AssertEquals(MIXEDBATCHSIZE*2,results.size(),'Result set size incorrect');
        
        Test.StopTest();
        
        for(Database.UndeleteResult current : results) {
            System.AssertEquals(true,current.isSuccess(),'No failures expected');
        }
        
    }

    public static testmethod void getContext() {
        Test.StartTest();
        System.AssertEquals(TriggerDMLHandler.class.getName(),(new TriggerDMLHandler()).getContext(),'Expected to see the classname here');
        Test.StopTest();
    } 
    
    public static testmethod void toStringVanilla() {
        Test.StartTest();
        System.AssertEquals('TriggerDMLHandler w/DMLExecutor:[]',(new TriggerDMLHandler()).toString(),'Expected to see the correct DML executor here');
        Test.StopTest();
        
    }
    public static testmethod void toStringMocked() {
        Test.StartTest();
        System.AssertEquals('TriggerDMLHandler w/MockDMLExecutor:[]',(new TriggerDMLHandler(new MockDMLExecutor())).toString(),'Expected to see the correct DML executor here');
        Test.StopTest();
        
    }
    public static testmethod void addForInsertHappy() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Name='Boone', RequiredField__c='Populated');
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        dmlHandler.addForInsert(myMock);
        Test.StopTest();
        
        System.AssertEquals(1,dmlHandler.toInsert.size(),'toInsert collection size incorrect');
        System.AssertEquals(myMock,dmlHandler.toInsert[0],'expected to find my record in toInsert collection');
    }

    public static testmethod void addForPublishHappy() {
        Test.StartTest();
        final TriggerMockPE__e  myMock = new TriggerMockPE__e(RequiredField__c='Populated');
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        dmlHandler.addForPublish(myMock);
        Test.StopTest();
        
        System.AssertEquals(1,dmlHandler.toPublish.size(),'toPublish collection size incorrect');
        System.AssertEquals(myMock,dmlHandler.toPublish[0],'expected to find my record in toPublish collection');
    }
    
    public static testmethod void addForUpsertHappy() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Name='Boone', RequiredField__c='Populated',MockExternalId__c='123456');
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        dmlHandler.putForUpsert(myMock,Trigger_Framework_Mock__c.fields.MockExternalId__c);
        Test.StopTest();
        
        System.AssertEquals(1,dmlHandler.toUpsert.size(),'toUpsert collection size incorrect');
        System.AssertEquals(myMock,dmlHandler.toUpsert.values()[0],'expected to find my record in toUpsert collection');
    }
    
        public static testmethod void addForUpsertNull() {
        Test.StartTest();
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            dmlHandler.putForUpsert(null,Trigger_Framework_Mock__c.fields.MockExternalId__c);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toUpsert.size(),'toUpsert collection size incorrect');
    }

    public static testmethod void addForUpsertHasId() {
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Id=TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType)
                                                                                                   ,Name='Boone', RequiredField__c='Populated');

        Test.StartTest();
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            dmlHandler.putForUpsert(myMock,Trigger_Framework_Mock__c.fields.MockExternalId__c);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toUpsert.size(),'toUpsert collection size incorrect');
    }

    public static testmethod void addForUpsertNoExternalId() {
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Name='Boone', RequiredField__c='Populated');

        Test.StartTest();
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            dmlHandler.putForUpsert(myMock,Trigger_Framework_Mock__c.fields.MockExternalId__c);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toUpsert.size(),'toUpsert collection size incorrect');
    }

    public static testmethod void addForUpsertMultipleExtIdFields() {
        // Create with 1st ID field
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Name='Boone', RequiredField__c='Populated',MockExternalId__c='111');
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        dmlHandler.putForUpsert(myMock,Trigger_Framework_Mock__c.fields.MockExternalId__c);

        Test.StartTest();
        
        try {
            // Add a second time, but changing the KEY field
            dmlHandler.putForUpsert(myMock,Trigger_Framework_Mock__c.fields.RequiredField__c);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(1,dmlHandler.toUpsert.size(),'toUpsert collection size incorrect');
    }

    
    public static testmethod void addForInsertNull() {
        Test.StartTest();
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            dmlHandler.addForInsert(null);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toInsert.size(),'toInsert collection size incorrect');
    }
    
    public static testmethod void addForPublishNonPE() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Name='Boone', RequiredField__c='Populated',MockExternalId__c='111');
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        try {
            dmlHandler.addForPublish(myMock);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toPublish.size(),'toPublish collection size incorrect');
    }
    
    
    public static testmethod void addForInsertHasId() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Id=TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType)
                                                                                                   ,Name='Boone', RequiredField__c='Populated');
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            dmlHandler.addForInsert(myMock);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toInsert.size(),'toInsert collection size incorrect');
    }
    
    public static testmethod void addForDeleteHappy() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Id=TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType));
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        dmlHandler.addForDelete(myMock);
        Test.StopTest();
        
        System.AssertEquals(1,dmlHandler.toDelete.size(),'toDelete collection size incorrect');
        System.AssertEquals(myMock,dmlHandler.toDelete.get(myMock.id),'expected to find my record in toDelete collection');
    }
    
    public static testmethod void addForDeleteNull() {
        Test.StartTest();
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            dmlHandler.addForDelete(null);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toDelete.size(),'toInsert collection size incorrect');
    }
    
    public static testmethod void addForDeleteNoId() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c();
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            dmlHandler.addForDelete(myMock);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toDelete.size(),'toDelete collection size incorrect');
    }

    public static testmethod void addForUndeleteHappy() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Id=TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType));
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        dmlHandler.addForUndelete(myMock);
        Test.StopTest();
        
        System.AssertEquals(1,dmlHandler.toUndelete.size(),'toUndelete collection size incorrect');
        System.AssertEquals(myMock,dmlHandler.toUndelete.get(myMock.id),'expected to find my record in toUndelete collection');
    }
    
    public static testmethod void addForUndeleteNull() {
        Test.StartTest();
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            dmlHandler.addForUndelete(null);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toUndelete.size(),'toUndelete collection size incorrect');
    }
    
    public static testmethod void addForUnDeleteNoId() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c();
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            dmlHandler.addForUndelete(myMock);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toUndelete.size(),'toUndelete collection size incorrect');
    }
    
     public static testmethod void getForUpdateHappyNone() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Id=TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType));
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        final SObject result = dmlHandler.getForUpdate(myMock);
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toUpdate.size(),'toUpdate collection size incorrect');
        System.AssertNotEquals(null,result,'Result is guaranteed not to be null');
        System.AssertEquals(myMock,result,'expected NOT to find my record in toUpdate collection, but have it returned as the candidate');
    }
    
     public static testmethod void getForUpdateExistsHappy() {
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Id=TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType),Name='Boone',RequiredField__c='Populated');
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        dmlHandler.putForUpdate(myMock);
         
        Test.StartTest();
        final SObject result = dmlHandler.getForUpdate(myMock);
        Test.StopTest();
        
        System.AssertEquals(1,dmlHandler.toUpdate.size(),'toUpdate collection size incorrect');
        System.AssertNotEquals(null,result,'Result is guaranteed not to be null');
        System.AssertEquals(myMock,result,'expected to find my record in toUpdate collection');
    }

     public static testmethod void getForUpdateChangedTwice() {
         final String ORIGINALVALUE=null;
         final String CHANGEDVALUE='ACME';
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Id=TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType),Name=ORIGINALVALUE,RequiredField__c='Populated');
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        dmlHandler.putForUpdate(myMock);
        final Trigger_Framework_Mock__c found = (Trigger_Framework_Mock__c)dmlHandler.getForUpdate(myMock);
        final Trigger_Framework_Mock__c second = found.clone();
        second.Id = found.id; // Clone doesn't set the ID
        second.name=CHANGEDVALUE;
         
        System.AssertEquals(ORIGINALVALUE,found.name,'Sanity check on original name value');
        dmlHandler.putForUpdate(second);
         
        Test.StartTest();
        final Trigger_Framework_Mock__c result = (Trigger_Framework_Mock__c)dmlHandler.getForUpdate(second);        
        Test.StopTest();
        
        System.AssertEquals(1,dmlHandler.toUpdate.size(),'toUpdate collection size incorrect');
        System.AssertEquals(second,result,'expected to find my record in toUpdate collection');
        System.AssertEquals(CHANGEDVALUE,second.name,'Expected to see field change from 2nd record');
    }
    
    public static testmethod void getForUpdateNull() {
        Test.StartTest();
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            final SObject result = dmlHandler.getForUpdate(null);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toUpdate.size(),'toUpdate collection size incorrect');
    }
    
    public static testmethod void getForUpdateNoId() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c();
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            dmlHandler.getForUpdate(myMock);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toUpdate.size(),'toUpdate collection size incorrect');
    }

     public static testmethod void getForUpsertHappyNone() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Name='Boone',RequiredField__c='Populated',MockExternalId__c='X1');
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        final SObject result = dmlHandler.getForUpsert(myMock,Trigger_Framework_Mock__c.fields.MockExternalId__c);
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toUpsert.size(),'toUpdate collection size incorrect');
        System.AssertNotEquals(null,result,'Result is guaranteed not to be null');
        System.AssertEquals(myMock,result,'expected NOT to find my record in toUpdate collection, but have it returned as the candidate');
    }
    
     public static testmethod void getForUpsertExistsHappy() {
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Name='Boone',RequiredField__c='Populated',MockExternalId__c='X1');
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        dmlHandler.putForUpsert(myMock,Trigger_Framework_Mock__c.fields.MockExternalId__c);
         
        Test.StartTest();
        final SObject result = dmlHandler.getForUpsert(myMock,Trigger_Framework_Mock__c.fields.MockExternalId__c);

        Test.StopTest();
        
        System.AssertEquals(1,dmlHandler.toUpsert.size(),'toUpdate collection size incorrect');
        System.AssertNotEquals(null,result,'Result is guaranteed not to be null');
        System.AssertEquals(myMock,result,'expected to find my record in toUpdate collection');
    }
    
     public static testmethod void getForUpsertChangedTwice() {
        final String ORIGINALVALUE=null;
        final String CHANGEDVALUE='ACME';
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c(Name=ORIGINALVALUE,RequiredField__c='Populated',MockExternalId__c='X1');
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        dmlHandler.putForUpsert(myMock,Trigger_Framework_Mock__c.fields.MockExternalId__c);
        final Trigger_Framework_Mock__c found = (Trigger_Framework_Mock__c)dmlHandler.getForUpsert(myMock,Trigger_Framework_Mock__c.fields.MockExternalId__c);
        final Trigger_Framework_Mock__c second = found.clone();
        second.name=CHANGEDVALUE;
         
        System.AssertEquals(ORIGINALVALUE,found.name,'Sanity check on original name value');
        dmlHandler.putForUpsert(second,Trigger_Framework_Mock__c.fields.MockExternalId__c);
         
        Test.StartTest();
        final Trigger_Framework_Mock__c result = (Trigger_Framework_Mock__c)dmlHandler.getForUpsert(second,Trigger_Framework_Mock__c.fields.MockExternalId__c);        
        Test.StopTest();
        
        System.AssertEquals(1,dmlHandler.toUpsert.size(),'toUpsert collection size incorrect');
        System.AssertEquals(second,result,'expected to find my record in toUpsert collection');
        System.AssertEquals(CHANGEDVALUE,second.name,'Expected to see field change from 2nd record');
    }
    
    public static testmethod void getForUpsertNull() {
        Test.StartTest();
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            final SObject result = dmlHandler.getForUpsert(null,Trigger_Framework_Mock__c.fields.MockExternalId__c);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toUpsert.size(),'toUpsert collection size incorrect');
    }
    
  
    public static testmethod void getForUpsertNoExternalId() {
        Test.StartTest();
        final Trigger_Framework_Mock__c myMock = new Trigger_Framework_Mock__c();
        
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        
        try {
            dmlHandler.getForUpsert(myMock,Trigger_Framework_Mock__c.fields.MockExternalId__c);
            System.Assert(false,'Expected exception not thrown');
        } catch(IllegalArgumentException ex) {
            System.Assert(true,'Caught expected exception');
        }
        Test.StopTest();
        
        System.AssertEquals(0,dmlHandler.toUpsert.size(),'toUpsert collection size incorrect');
    }

    /**
     * Ensure that INSERTS are committed to the database
     **/ 
    public static testmethod void applyInsertHappy() {
        final TriggerDMLHandler handler = new TriggerDMLHandler();
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated'));
            handler.addForInsert(myTestRecords[i]);
        }
        Test.StartTest();
        
        final List<Database.saveResult> results = handler.insertObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects INSERTED');
        for (Database.saveResult current : results) {
            System.Assert(current.isSuccess(),'Expected all rows to succeed');
        }

    } 
    
    /**
     * Ensure that failed INSERTS are logged
     * Ensure partial success semantics are followed
     **/ 
    public static testmethod void applyInsertErrorHandling() {
        final TriggerDMLHandler handler = new TriggerDMLHandler();
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated'));
            if (isEven(i)) {
                // add a value that is too long to force an error
                myTestRecords[i].RequiredField__c=''; 
            }
            handler.addForInsert(myTestRecords[i]);
        }
        Test.StartTest();
        
        System.Debug('TFMOCK DATA===> ' + handler.toInsert);
        final List<Database.saveResult> results = handler.insertObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects INSERTED');
        
        Integer n=0;
        for (Database.saveResult current : results) {
            final Boolean expectedSuccess = !isEven(n); // Even Rows should fail based on our test data
            System.Debug('n=' + n + ' Success? '+ current.isSuccess() + ' errors: ' + current.getErrors().size());
            System.AssertEquals(expectedSuccess,current.isSuccess(),'Row result (success/fail) not as expected');
            
            final SObject proposedRecord = handler.toInsert[n];
            System.AssertEquals(expectedSuccess,proposedRecord.getErrors().isEmpty(),'Expected Row errors incorrect');
            n++;
        }

    } 
    
    
     /**
     * Ensure that Platform Events are published to the Eventbus
     **/ 
    public static testmethod void publishHappy() {
        final TriggerDMLHandler handler = new TriggerDMLHandler();
        final List<TriggerMockPE__e> myTestRecords = new List<TriggerMockPE__e>();
          final TriggerMockPE__e  myMock = new TriggerMockPE__e(RequiredField__c='Populated');
      
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new TriggerMockPE__e(RequiredField__c='Populated'+i));
            handler.addForPublish(myTestRecords[i]);
        }
        
        Test.StartTest();
        
        final List<Database.saveResult> results = handler.publish();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all Platform Events Published');
        for (Database.saveResult current : results) {
            System.Assert(current.isSuccess(),'Expected all PEs to succeed');
        }

    } 
   
     /**
     * Test PE Publishing error handling
     **/ 
    public static testmethod void publishUnHappy() {
        final TriggerDMLHandler handler = new TriggerDMLHandler(new MockDMLExecutor());
        final List<TriggerMockPE__e> myTestRecords = new List<TriggerMockPE__e>();
        final TriggerMockPE__e  myMock = new TriggerMockPE__e(RequiredField__c='Populated');
      
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new TriggerMockPE__e(RequiredField__c='Populated'+i));
            handler.addForPublish(myTestRecords[i]);
        }
        
        Test.StartTest();
        
        final List<Database.saveResult> results = handler.publish();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all Platform Events Published');
        Integer n=0;
        for (Database.saveResult current : results) {
            final Boolean expectedSuccess = !isEven(n); // Even Rows should fail based on our test data
            System.Debug('n=' + n + ' Success? '+ current.isSuccess() + ' errors: ' + current.getErrors().size());
            System.AssertEquals(expectedSuccess,current.isSuccess(),'Row result (success/fail) not as expected');
            
            final SObject proposedRecord = handler.toPublish[n];
            System.AssertEquals(expectedSuccess,proposedRecord.getErrors().isEmpty(),'Expected Row errors incorrect');
            n++;
        }

    } 

    /**
     * Ensure that UPSERT are committed to the database
     **/ 
    public static testmethod void applyUpsertHappy() {
        final TriggerDMLHandler handler = new TriggerDMLHandler();
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated',MockExternalId__c=('X'+i)));
            handler.putForUpsert(myTestRecords[i],Trigger_Framework_Mock__c.fields.MockExternalId__c);
        }
        Test.StartTest();
        
        final List<Database.upsertResult> results = handler.upsertObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects UPSERTED');
        for (Database.upsertResult current : results) {
            System.Assert(current.isSuccess(),'Expected all rows to succeed');
        }

    } 
    /**
     * Ensure that UPSERT are committed to the database
     **/ 
    public static testmethod void applyUpsertHappy2() {
        final TriggerDMLHandler handler = new TriggerDMLHandler();
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated',MockExternalId__c=('X'+i)));
            handler.putForUpsert(myTestRecords[i],Trigger_Framework_Mock__c.fields.MockExternalId__c);
        }

        // Deep Clone the test records to make a separate copy we will upsert in advance
        List<Trigger_Framework_Mock__c> preloaded = myTestRecords.deepClone();
        upsert preloaded MockExternalId__c;
        
        Test.StartTest();
        
        
        final List<Database.upsertResult> results = handler.upsertObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects UPSERTED');
        for (Database.upsertResult current : results) {
            System.Assert(current.isSuccess(),'Expected all rows to succeed');
        }

    } 

    /**
     * Ensure that UPSERT with the Same key in a Single Batch will work
     **/ 
    public static testmethod void applyUpsertSameKey() {
        final TriggerDMLHandler handler = new TriggerDMLHandler();
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        // Test records have the unique externalid keys
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated',MockExternalId__c=('X'+i)));
            handler.putForUpsert(myTestRecords[i],Trigger_Framework_Mock__c.fields.MockExternalId__c);
        }
        
        // Now, force 2 to be duplicates so we can test error handling
        final String DUPKEY = 'X999';
        ((Trigger_Framework_Mock__c)handler.toUpsert.values()[0]).MockExternalId__c=DUPKEY;
        ((Trigger_Framework_Mock__c)handler.toUpsert.values()[1]).MockExternalId__c=DUPKEY;
        
        Test.StartTest();
        
        
        final List<Database.upsertResult> results = handler.upsertObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects UPSERTED');
        for (Integer i=0; i < results.size(); i++) {
            Database.upsertResult current=results[i];
            System.debug('i=' + i + ' : ' + current);
            if (i==0 || i==1) {
                System.Assert(!current.isSuccess(),'Expected a duplicate failure:' + current);
            } else {
                System.Assert(current.isSuccess(),'Expected all remaining rows to succeed: ' + current);
            }
        }

    } 
    
    /**
     * Ensure that failed UPSERTS are logged
     * Ensure partial success semantics are followed
     **/ 
    public static testmethod void applyUpsertErrorHandling() {
        final TriggerDMLHandler handler = new TriggerDMLHandler(new MockDMLExecutor());
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated',MockExternalId__c='ZZ'+i));
            handler.putForUpsert(myTestRecords[i],Trigger_Framework_Mock__c.fields.MockExternalId__c);
        }
        Test.StartTest();
        
        final List<Database.upsertResult> results = handler.upsertObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects INSERTED');
        
        Integer n=0;
        for (Database.upsertResult current : results) {
            final Boolean expectedSuccess = !isEven(n); // Even Rows should fail based on our test data
            System.Debug('n=' + n + ' Success? '+ current.isSuccess() + ' errors: ' + current.getErrors().size());
            System.AssertEquals(expectedSuccess,current.isSuccess(),'Row result (success/fail) not as expected');
            
            final SObject proposedRecord = handler.toUpsert.values()[n];
            System.AssertEquals(expectedSuccess,proposedRecord.getErrors().isEmpty(),'Expected Row errors incorrect');
            n++;
        }

    } 
    
    
    /**
     * Ensure that UPDATES are committed to the database
     **/ 
    public static testmethod void applyUpdateHappy() {
        final TriggerDMLHandler handler = new TriggerDMLHandler();
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated'));
            handler.addForInsert(myTestRecords[i]);
        }
        // We must insert these in order to be able to update them later
        // Deliberately not using the class under test to avoid double debugging work.
        insert myTestRecords;
        
        for (Trigger_Framework_Mock__c current : myTestRecords) {
            current.Name = 'Web';
            handler.putForUpdate(current);
        }
        
        Test.StartTest();
        
        final List<Database.saveResult> results = handler.updateObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects UPDATED');
        
        for (Database.saveResult current : results) {
            System.AssertEquals(true,current.isSuccess(),'Row result (success) not as expected');
            
            // Find the record in the map by Id
            final SObject proposedRecord = handler.toUpdate.get(current.getId());
            System.AssertEquals(true,proposedRecord.getErrors().isEmpty(),'Expected no Row errors');
        }

    } 
    /**
     * Ensure that failed UPDATES are logged
     * ???Ensure partial success semantics are followed???
     **/ 
    public static testmethod void applyUpdateErrorHandling() {
        final TriggerDMLHandler handler = new TriggerDMLHandler();
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated'));
            handler.addForInsert(myTestRecords[i]);
        }
        // We must insert these in order to be able to update them later
        // Deliberately not using the class under test to avoid double debugging work.
        insert myTestRecords;
        
        Integer i=0;
        for (Trigger_Framework_Mock__c current : myTestRecords) {
            current.Name = 'Web';
            if (isEven(i)) {
                current.RequiredField__c=''; // force an error by nullifying this field
            }
            handler.putForUpdate(current);
            i++;
        }
        
        Test.StartTest();
        
        final List<Database.saveResult> results = handler.updateObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects UPDATED');
        
        for (Database.saveResult current : results) {
            final Trigger_Framework_Mock__c proposedRecord = (Trigger_Framework_Mock__c) handler.toUpdate.get(current.getId()); // find the original record in the map by id
            final Boolean expectedSuccess = !(proposedRecord.RequiredField__c==''); // did we force the error, if not, we expect success
            System.Debug(' Success? '+ current.isSuccess() + ' errors: ' + current.getErrors().size());
            
            System.AssertEquals(expectedSuccess,current.isSuccess(),'Row result (success/fail) not as expected');           
            System.AssertEquals(expectedSuccess,proposedRecord.getErrors().isEmpty(),'Expected Row errors incorrect');
        }

    }    

    /**
     * Ensure that DELETES are committed to the database
     **/ 
    public static testmethod void applyDeleteHappy() {
        final TriggerDMLHandler handler = new TriggerDMLHandler();
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated'));
            handler.addForInsert(myTestRecords[i]);
        }
        // We must insert these in order to be able to Delete them later
        // Deliberately not using the class under test to avoid double debugging work.
        insert myTestRecords;
        
        for (Trigger_Framework_Mock__c current : myTestRecords) {
            handler.addForDelete(current);
        }
        
        Test.StartTest();
        
        final List<Database.DeleteResult> results = handler.deleteObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects UPDATED');
        
        for (Database.DeleteResult current : results) {
            System.AssertEquals(true,current.isSuccess(),'Row result (success) not as expected');
            
            // Find the record in the map by Id
            final SObject proposedRecord = handler.toDelete.get(current.getId());
            System.AssertEquals(true,proposedRecord.getErrors().isEmpty(),'Expected no Row errors');
        }

    } 
    /**
     * Ensure that failed DELETES are logged
     * Ensure partial success semantics are followed
     **/ 
    public static testmethod void applyDeleteErrorHandling() {
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated'));
        }
        
        // We must insert these in order to be able to Delete them later
        // Deliberately not using the class under test to avoid double debugging work.
        insert myTestRecords;
        
        // Mock the Database.delete() method to force fake errors on EVEN records
        final TriggerDMLHandler handler = new TriggerDMLHandler(new MockDMLExecutor());

        for (Trigger_Framework_Mock__c current : myTestRecords) {
            handler.addForDelete(current);
        }
        
        Test.StartTest();
        
        
        final List<Database.DeleteResult> results = handler.deleteObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects UPDATED');
        
        Integer n=0;
        for (Database.DeleteResult current : results) {
            final Boolean expectedSuccess = isOdd(n);
            System.AssertEquals(expectedSuccess,current.isSuccess(),'Row result (success) not as expected');
            
            // Find the record in the map by Id
            final SObject proposedRecord = handler.toDelete.get(current.getId());
            System.AssertEquals(expectedSuccess,proposedRecord.getErrors().isEmpty(),'Expected Row errors for failed rows/none for success: ' + expectedSuccess);
            n++;
        }

    }    
    /**
     * Ensure that UNDELETES are committed to the database
     **/ 
    public static testmethod void applyUndeleteHappy() {
        final TriggerDMLHandler handler = new TriggerDMLHandler();
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated'));
            handler.addForInsert(myTestRecords[i]);
        }
        // We must insert these in order to be able to Delete them later
        // Deliberately not using the class under test to avoid double debugging work.
        insert myTestRecords;
        
        delete myTestRecords;
        
        for (Trigger_Framework_Mock__c current : myTestRecords) {
            handler.addForUndelete(current);
        }
        
        Test.StartTest();
        
        final List<Database.UndeleteResult> results = handler.undeleteObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects UPDATED');
        
        for (Database.UndeleteResult current : results) {
            System.AssertEquals(true,current.isSuccess(),'Row result (success) not as expected');
            
            // Find the record in the map by Id
            final SObject proposedRecord = handler.toUndelete.get(current.getId());
            System.AssertEquals(true,proposedRecord.getErrors().isEmpty(),'Expected no Row errors');
        }

    } 
    /**
     * Ensure that failed UNDELETES are logged
     * Ensure partial success semantics are followed
     **/ 
    public static testmethod void applyUndeleteErrorHandling() {
        final TriggerDMLHandler handler = new TriggerDMLHandler(new MockDMLExecutor());
        final List<Trigger_Framework_Mock__c> myTestRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i=0; i < BATCHSIZE; i++) {
            myTestRecords.add(new Trigger_Framework_Mock__c(Name='Test'+i, RequiredField__c='Populated'));
            handler.addForInsert(myTestRecords[i]);
        }
        // We must insert these in order to be able to Delete them later
        // Deliberately not using the class under test to avoid double debugging work.
        insert myTestRecords;
        
        delete myTestRecords;
        
        for (Trigger_Framework_Mock__c current : myTestRecords) {
            handler.addForUndelete(current);
        }
        
        Test.StartTest();
        
        final List<Database.UndeleteResult> results = handler.undeleteObjects();
        
        Test.StopTest();
         
        System.AssertEquals(myTestRecords.size(),results.size(),'Results expected for all objects Undeleted');
        
        Integer n=0;
        for (Database.UndeleteResult current : results) {
            System.Debug('n='+ n + ' '+ JSON.serialize(current).toString());
            final Boolean expectedSuccess = isOdd(n);
            System.AssertEquals(expectedSuccess,current.isSuccess(),'Row result (success) not as expected');
            
            // Find the record in the map by Id
            final SObject proposedRecord = handler.toUndelete.get(current.getId());
            System.AssertEquals(expectedSuccess,proposedRecord.getErrors().isEmpty(),'Expected Row errors for failed rows/none for success: ' + expectedSuccess);
            n++;
        }

    } 
    
    /**
     * Ensure that the convenient apply works as expected when no input data for any
     **/ 
    public static testmethod void testApplyDMLEmpty() {
        final TriggerDMLHandler handler = new TriggerDMLHandler(new MockDMLExecutor());
        
        Test.StartTest();
        handler.applyDML();
        Test.StopTest();
        
        System.AssertEquals(handler.toInsert.size(),handler.toInsertResults.size(),'INSERT results must be same as input');
        System.AssertEquals(handler.toUpdate.size(),handler.toUpdateResults.size(),'UPDATE results must be same as input');
        System.AssertEquals(handler.toDelete.size(),handler.toDeleteResults.size(),'DELETE results must be same as input');
        System.AssertEquals(handler.toUndelete.size(),handler.toUndeleteResults.size(),'UNDELETE results must be same as input');
    }
    /**
     * Ensure that the convenient apply works as expected when Some input data
     **/ 
    public static testmethod void testApplyDMLSomeInserts() {
        final TriggerDMLHandler handler = new TriggerDMLHandler(new MockDMLExecutor());
        
        handler.addForInsert(new Trigger_Framework_Mock__c(Name='Test'));
        
        Test.StartTest();
        handler.applyDML();
        Test.StopTest();
        
        System.AssertEquals(handler.toInsert.size(),handler.toInsertResults.size(),'INSERT results must be same as input');
        System.AssertEquals(handler.toUpdate.size(),handler.toUpdateResults.size(),'UPDATE results must be same as input');
        System.AssertEquals(handler.toDelete.size(),handler.toDeleteResults.size(),'DELETE results must be same as input');
        System.AssertEquals(handler.toUndelete.size(),handler.toUndeleteResults.size(),'UNDELETE results must be same as input');
    }    
}