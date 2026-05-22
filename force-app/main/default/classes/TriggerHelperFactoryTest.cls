/**
 * Unit test for TriggerHelperFactory
 * Negative pilot-mode tests run as a Standard User — sysadmin profile receives
 * FF_TriggerHelperPilot via 2GP auto-grant and cannot assert checkPermission == false.
 **/
@isTest(isParallel=false)
public class TriggerHelperFactoryTest {
    
    private static final string SOBJECTNAME = 'Trigger_Framework_Mock__c';
    @TestSetup
    static void setup() {
        System.RunAs(getRunningUser()) {
            FF_TriggerHelperPilot_Logging__c settings = FF_TriggerHelperPilot_Logging__c.getOrgDefaults();
            settings.Enabled__c = true;
            upsert settings;

            String emailDomain = UserInfo.getUserEmail().substringAfter('@');
            Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            insert new User(
                Alias = 'pilottst',
                Email = 'pilottest@' + emailDomain,
                EmailEncodingKey = 'UTF-8',
                LastName = 'PilotTest',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = standardProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'pilottest.' + UserInfo.getOrganizationId() + '@' + emailDomain
            );
        }
    }

    private static User getRunningUser() {
        return new User(Id=UserInfo.getUserId());
    }
    private static User getStandardTestUser() {
        return [SELECT Id FROM User WHERE UserName LIKE 'pilottest.%' LIMIT 1];
    }
    private static Boolean hasPilotFF() {
        return System.FeatureManagement.checkPermission(TriggerHelperFactory.PILOT_FF);
    }
    
    private static TriggerHelperConfig__mdt getCMTFromHelperName(final String objectTypename, final String helperName) {
        TriggerHelperConfig__mdt current = [select HelperClassName__c , ExecutionSequence__c, Enabled__c, IsPilotMode__c 
                                                   from TriggerHelperConfig__mdt
                                                  where Enabled__c=true
                                                    and SObjectType__r.QualifiedApiName=:objectTypename
                                                    and HelperClassName__c=:helperName
                                                    and Context__c=:TriggerHelperFactory.factoryContext  // Filter by the context
                                                  order by ExecutionSequence__c asc];
       return current;
    }
    
    public static testmethod void testIsUserInPilot() {
       System.AssertEquals(hasPilotFF(),TriggerHelperFactory.isUserInPilot(),'Must report same pilot status');
    }
    
    /**
     * Must return all active Helpers for this object including those in PilotMode
     **/ 
    public static testMethod void userInPilot() {
        final User testUser = getRunningUser();       
        TriggerHelperFactory.factoryContext='TestHappyPath'; // Test mode
        // Assign the Pilot Feature Flag
        TestUtility.assignFeatureFlag(testUser.Id,TriggerHelperFactory.PILOT_FF);

        
        System.runAs(testUser) {
            System.AssertEquals(true,hasPilotFF(),'Must have Pilot FF for this test');
            
            // Get All enabled helpers regardless of PilotMode
            List<TriggerHelperConfig__mdt> expectedHelpers = [select HelperClassName__c , ExecutionSequence__c, Enabled__c, IsPilotMode__c 
                                                   from TriggerHelperConfig__mdt
                                                  where Enabled__c=true
                                                    and SObjectType__r.QualifiedApiName=:SOBJECTNAME
                                                    and Context__c=:TriggerHelperFactory.factoryContext  // Filter by the context
                                                  order by ExecutionSequence__c asc];
            
            System.Assert(!expectedHelpers.isEmpty(),'Invalid test setup, no helpers defined for:' + SOBJECTNAME);            

            Test.StartTest();
            final List<ITriggerHelper> results = TriggerHelperFactory.getHelpers(SOBJECTNAME);
            Test.StopTest();
            
            System.AssertEquals(expectedHelpers.size(),results.size(),'Must return all expected pilot enabled helpers');
            
        }        
        
    }
    
    /**
     * Must exclude Helpers in PilotMode
     **/ 
    public static testMethod void userNotInPilot() {
        final User testUser = getStandardTestUser();
        TriggerHelperFactory.factoryContext='TestHappyPath'; // Test mode
        System.runAs(testUser) {
            System.AssertEquals(false,hasPilotFF(),'Must not have Pilot FF for this test');
            
            
            // Get All enabled helpers except those in PilotMode
            List<TriggerHelperConfig__mdt> expectedHelpers = [select HelperClassName__c , ExecutionSequence__c, Enabled__c, IsPilotMode__c 
                                                   from TriggerHelperConfig__mdt
                                                  where Enabled__c=true
                                                    and IsPilotMode__c=false
                                                    and SObjectType__r.QualifiedApiName=:SOBJECTNAME
                                                    and Context__c=:TriggerHelperFactory.factoryContext  // Filter by the context
                                                  order by ExecutionSequence__c asc];
            
            System.Assert(!expectedHelpers.isEmpty(),'Invalid test setup, no helpers defined for:' + SOBJECTNAME);            

            Test.StartTest();
            final List<ITriggerHelper> results = TriggerHelperFactory.getHelpers(SOBJECTNAME);
            Test.StopTest();

            System.AssertEquals(expectedHelpers.size(),results.size(),'Must exclude PilotMode helpers');
            
            for(ITriggerHelper current : results) {
                System.AssertNotEquals(null,current,'Result entry must not be null');
                TriggerHelperConfig__mdt cmt = getCMTFromHelperName(SOBJECTNAME,current.getName());
                System.AssertNotEquals(true,cmt.IsPilotMode__c,'Pilot helpers must not be returned');
            }
            
        }        
    }
    
    /**
     * Validates the Production configuration for the Trigger_Framework_Mock__c Object
     * That the helpers that are enabled can be instantiated
     **/ 
    public static testmethod void validateResultsForTriggerFrameworkMock() {
        TriggerHelperFactory.factoryContext='TestHappyPath'; // Unit Test mode
        try {
            final List<ITriggerHelper> results = TriggerHelperFactory.getHelpers('Trigger_Framework_Mock__c');
            System.AssertNotEquals(null,results,'Result cannot be null');
            System.Assert(!results.isEmpty(),'Must have a configured helper!');
            for(ITriggerHelper current : results) {
                System.AssertNotEquals(null,current,'Result entry must not be null');
                System.debug('Helper:' + current.getName());
                System.AssertNotEquals(null,current.getName(),'Name must be initialized');
            }     
        } catch (System.TypeException tex) {
            System.Assert(false,'Configuration issue -- Trigger_Framework_Mock__c Helpers must be upgraded to ITriggerHelper interface: ' + tex.getMessage());
        }
    }
    
    /**
    * Validates the Error Handling for bad Classname
    **/ 
    public static testmethod void validateErrorHandlingBadClass() {
        TriggerHelperFactory.factoryContext='FactoryTest1';
        try {
           final List<ITriggerHelper> results = TriggerHelperFactory.getHelpers('Trigger_Framework_Mock__c');
           System.Assert(false,'Must not reach this line');
        } catch (IllegalArgumentException ex) {
            System.Assert(true,'Expected exception caught');
        }
    }
    
     /**
     * Validates the Error Handling for Class not implementing ITriggerHelper
     **/ 
    public static testmethod void validateErrorHandlingNotITriggerHelper() {
        TriggerHelperFactory.factoryContext='FactoryTest2';
        try {
           final List<ITriggerHelper> results = TriggerHelperFactory.getHelpers('Trigger_Framework_Mock__c');
           System.Assert(false,'Must not reach this line');
        } catch (System.TypeException ex) {
            System.Assert(true,'Expected exception caught');
        }
    }

    /**
     * Must log debug messages
     **/ 
    public static testMethod void userInPilotAndDebugModeOn() {
        final User testUser = getStandardTestUser();
        TriggerHelperFactory.factoryContext='TestHappyPath'; // Test mode
        System.runAs(testUser) {
            System.AssertEquals(false,hasPilotFF(),'Must not have Pilot FF for this test');
            
            
            // Get All enabled helpers except those in PilotMode
            List<TriggerHelperConfig__mdt> expectedHelpers = [select HelperClassName__c , ExecutionSequence__c, Enabled__c, IsPilotMode__c 
                                                   from TriggerHelperConfig__mdt
                                                  where Enabled__c=true
                                                    and IsPilotMode__c=false
                                                    and SObjectType__r.QualifiedApiName=:SOBJECTNAME
                                                    and Context__c=:TriggerHelperFactory.factoryContext  // Filter by the context
                                                  order by ExecutionSequence__c asc];
            
            System.Assert(!expectedHelpers.isEmpty(),'Invalid test setup, no helpers defined for:' + SOBJECTNAME);            

            Test.StartTest();
            final List<ITriggerHelper> results = TriggerHelperFactory.getHelpers(SOBJECTNAME);
            Test.StopTest();

            System.AssertEquals(expectedHelpers.size(),results.size(),'Must exclude PilotMode helpers');
            
            for(ITriggerHelper current : results) {
                System.AssertNotEquals(null,current,'Result entry must not be null');
                TriggerHelperConfig__mdt cmt = getCMTFromHelperName(SOBJECTNAME,current.getName());
                System.AssertNotEquals(true,cmt.IsPilotMode__c,'Pilot helpers must not be returned');
            }
            
        }    
         // Ensure that the debug is logged
         Test.getEventbus().deliver();
        
         List<LogEntry__c> logs = [select id from LogEntry__c WHERE LoggingLevel__c = 'DEBUG' limit 100];
         System.AssertNotEquals(0,logs.size(),'Expected to see 1 or more debug messages logged');  
        
    }

    /**
     * Must log debug messages
     **/ 
    public static testMethod void userInPilotAndDebugModeOff() {
        FF_TriggerHelperPilot_Logging__c settings = FF_TriggerHelperPilot_Logging__c.getOrgDefaults();
        settings.Enabled__c = false;
        upsert settings;
        TriggerHelperFactory.factoryContext='TestHappyPath'; // Test mode
        final User testUser = getStandardTestUser();

        System.runAs(testUser) {
            System.AssertEquals(false,hasPilotFF(),'Must not have Pilot FF for this test');
            // Get All enabled helpers except those in PilotMode
            List<TriggerHelperConfig__mdt> expectedHelpers = [select HelperClassName__c , ExecutionSequence__c, Enabled__c, IsPilotMode__c 
                                                   from TriggerHelperConfig__mdt
                                                  where Enabled__c=true
                                                    and IsPilotMode__c=false                                    
                                                    and SObjectType__r.QualifiedApiName=:SOBJECTNAME
                                                    and Context__c=:TriggerHelperFactory.factoryContext  // Filter by the context
                                                  order by ExecutionSequence__c asc];
            
            System.Assert(!expectedHelpers.isEmpty(),'Invalid test setup, no helpers defined for:' + SOBJECTNAME);            

            Test.StartTest();
            final List<ITriggerHelper> results = TriggerHelperFactory.getHelpers(SOBJECTNAME);
            Test.StopTest();

            System.AssertEquals(expectedHelpers.size(),results.size(),'Must exclude PilotMode helpers');
            
            for(ITriggerHelper current : results) {
                System.AssertNotEquals(null,current,'Result entry must not be null');
                TriggerHelperConfig__mdt cmt = getCMTFromHelperName(SOBJECTNAME,current.getName());
                System.AssertNotEquals(true,cmt.IsPilotMode__c,'Pilot helpers must not be returned');
            }
            
        } 

        // Ensure that the debug is not logged
        Test.getEventbus().deliver();
    
        List<LogEntry__c> logs = [select id from LogEntry__c WHERE LoggingLevel__c = 'DEBUG' limit 100];
        System.AssertEquals(0,logs.size(),'Expected not to see any debug messages logged'); 
        
    }

     /**
    * Validates the alternate SObject field usage
    **/ 
    public static testmethod void validateAlternateSObjectUsage() {
        TriggerHelperFactory.factoryContext='TestAlternateSObject';
        final String objectTypename='Case';
        // Get All enabled helpers regardless of PilotMode
        List<TriggerHelperConfig__mdt> expectedHelpers = [select HelperClassName__c , ExecutionSequence__c, Enabled__c, IsPilotMode__c 
                                                            from TriggerHelperConfig__mdt
                                                           where Enabled__c=true
                                                            and AlternateSObject__c=:objectTypename
                                                            and Context__c=:TriggerHelperFactory.factoryContext  // Filter by the context
                                                        order by ExecutionSequence__c asc];

        System.Assert(!expectedHelpers.isEmpty(),'Invalid test setup, no helpers defined for:' + objectTypename);            

        Test.StartTest();
        final List<ITriggerHelper> results = TriggerHelperFactory.getHelpers(objectTypename);
        Test.StopTest();        
        System.AssertEquals(expectedHelpers.size(),results.size(),'Must return all expected pilot enabled helpers');    
    }

    /**
    * Validates the alternate SObject values
    **/ 
    public static testmethod void validateAlternateSObjectNames() {
        List<TriggerHelperConfig__mdt> expectedHelpers = [select AlternateSObject__c
                                                            from TriggerHelperConfig__mdt
                                                          where AlternateSObject__c != null];

        Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();
        for(TriggerHelperConfig__mdt thc:expectedHelpers){
            system.assertEquals(true, sObjectMap.ContainsKey(thc.AlternateSObject__c));
        }
    }


}