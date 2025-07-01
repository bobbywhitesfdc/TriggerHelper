/**
* Defines the kind of QueryType:  DETAIL, RELATED, EXTERNALID
**/
public class TopicDefinition {    
    /**
    * Define the kinds of Topics
    **/
    public enum TopicType { DETAIL, RELATED, EXTERNALID }
    
    public final String name;
    public final String queryTemplate;
    public final TopicType type;
    public final String keyFieldname;
    
    public TopicDefinition(TriggerLookupTopic__mdt mdt) {
        name = mdt.topic__c;
        type = (mdt.TopicType__c=='Detail') ? TopicType.DETAIL : ((mdt.TopicType__c == 'RelatedList') ? TopicType.RELATED : TopicType.EXTERNALID);            
        queryTemplate=mdt.QueryTemplate__c;
        keyFieldname=mdt.KeyFieldname__c;
    }
}