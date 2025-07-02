/**
 * Factory who's sole purpose is to instantiate the TriggerHelpers
 * Read from CMT to determine the list and the order of execution
 * Filters by the Context (Production, various test contexts). 
 **/ 
public inherited sharing class TriggerHelperFactory {
    @testvisible // allow tests to manipulate this internal member
    private static String factoryContext='Production'; // Default context
    public static final String PILOT_FF = 'FF_TriggerHelperPilot';
    
    public static Boolean isUserInPilot() {
        return System.FeatureManagement.checkPermission(PILOT_FF);
    }
    
    /**
     * Returns an ordered list of ApexClass names for the helpers
     * 
     **/ 
    private static List<String> getEnabledHelperClassnames(final String objectTypename) {
        final List<String> helperClassNames = new List<String>();
        
        for (TriggerHelperConfig__mdt current : [select HelperClassName__c , ExecutionSequence__c, Enabled__c, IsPilotMode__c 
                                                   from TriggerHelperConfig__mdt
                                                  where Enabled__c=true
                                                    and SObjectType__c != null 
                                                    and SObjectType__r.QualifiedApiName=:objectTypename
                                                    and Context__c=:TriggerHelperFactory.factoryContext  // Filter by the context
                                                  order by ExecutionSequence__c asc]) {
                // Only include PilotMode helpers for those Users in the Pilot, include all GA Helpers for all people                                      
                if (current.IsPilotMode__c==false || (current.IsPilotMode__c==true && isUserInPilot())) {
                     helperClassNames.add(current.HelperClassName__c);                                            
                }                                     
         }
         // MDT Query is required to be split to avoid MALFORMED_QUERY: Disjunctions not supported
          for (TriggerHelperConfig__mdt current : [select HelperClassName__c , ExecutionSequence__c, Enabled__c, IsPilotMode__c 
                                                   from TriggerHelperConfig__mdt
                                                  where Enabled__c=true
                                                    and AlternateSObject__c != null 
                                                    and AlternateSObject__c = :objectTypename
                                                    and Context__c=:TriggerHelperFactory.factoryContext  // Filter by the context
                                                  order by ExecutionSequence__c asc]) {
                // Only include PilotMode helpers for those Users in the Pilot, include all GA Helpers for all people                                      
                if (current.IsPilotMode__c==false || (current.IsPilotMode__c==true && isUserInPilot())) {
                     helperClassNames.add(current.HelperClassName__c);                                            
                }                                     
         }
         if(FF_TriggerHelperPilot_Logging__c.getInstance().Enabled__c){
            Logger.debug('Running ' + helperClassNames + 'Trigger Helper(s) for User: ' + UserInfo.getUserName());
            Logger.saveLog();
         }
        
        return helperClassNames;
        
    }
    /**
     * Instantiate the configured helpers in sequence
     **/ 
    public static List<ITriggerHelper> getHelpers(final String objectTypename) {
        final List<ITriggerHelper> helpers = new List<ITriggerHelper>();
        for (String currentHelper : getEnabledHelperClassnames(objectTypename)) {
            try {
                // It's possible that the classname is invalid or that it doesn't implement ITriggerHelper
                final Type helperClass = Type.forName(currentHelper);
                
                if (helperClass==null) throw new IllegalArgumentException('Invalid classname:' + currentHelper);
                
                final ITriggerHelper helperInstance = (ITriggerHelper)helperClass.newInstance();
                helperInstance.setName(currentHelper);
                helpers.add(helperInstance);
            } catch (Exception ex) {
                LoggingUtility.logError(ex, true);
                throw ex;
            }
        }
        return helpers;
    }
}