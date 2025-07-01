/**
 * QueryTopicFactory manages the retrieval of Topic definitions which are stored in CMT records
 * At runtime in Production, it fetches all of the Topics at once and the consumer caches them
 * for performance.
 * 
 * NOTE:  The combination of Context + Topic must be unique! This is not enforced in the data model
 * */ 
public class QueryTopicFactory {
    /**
     * Default the context to Production, but allow UnitTests to override it
     **/ 
    @testvisible
    private static String context='Production';
    
    /**
     * For efficiency, return a map that contains all of the topics
     * and is indexed by name.
     * 
     * Note:  Naming convention - Detail='<SObjectName>'    Related='Related<SObjectName>'
     * Note:  Because contexts overlap on names, cannot rely on DeveloperName because it's globally unique
     **/ 
    public static Map<String,TopicDefinition> initializeTopics() {
        // Query the CMT filtering by Context (Production, various test contexts) to return all of the defined topics
        final List<TriggerLookupTopic__mdt> topicConfigs = TriggerLookupTopic__mdt.getAll().values();
        /*    final List<TriggerLookupTopic__mdt> topicConfigs = [select id, topic__c, TopicType__c, QueryTemplate__c, Context__c, KeyFieldname__c 
                                          from TriggerLookupTopic__mdt 
                                          where Context__c= :context]; */
        final Map<String,TopicDefinition> results = new Map<String,TopicDefinition>();
        for (TriggerLookupTopic__mdt current : topicConfigs) {
            if(current.Context__c == context){
                TopicDefinition def = new TopicDefinition(current);
                results.put(def.name,def);
            }
        }
        return results;
    }
}