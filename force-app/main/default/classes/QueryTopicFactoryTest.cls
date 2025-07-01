/**
* Unit test for QueryTopicFactory to construct QueryTopics from configuration
**/
@isTest(isParallel=true)
public class QueryTopicFactoryTest {
    public static testmethod void testGetTestTopics() {
        QueryTopicFactory.context='Unittest';
        
        Test.StartTest();
        final Map<String,TopicDefinition> topics = QueryTopicFactory.initializeTopics();
        Test.StopTest();
        
        System.AssertNotEquals(null,topics,'result must not be null');
        System.AssertNotEquals(0,topics.size(),'result must not be empty');
        
        final String TESTTOPIC='User';
        final TopicDefinition topic = topics.get(TESTTOPIC);
        System.AssertNotEquals(null,topic, TESTTOPIC + ' topic must be defined!');
        System.AssertEquals(TESTTOPIC,topic.name);
        System.AssertEquals(TopicDefinition.TopicType.DETAIL,topic.type,'Wrong type');
        System.Assert(!String.IsBlank(topic.queryTemplate),'Query must not be blank');
    }
    public static testmethod void testGetInvalidTestTopic() {
        QueryTopicFactory.context='Unittest';
        
        Test.StartTest();
        final Map<String,TopicDefinition> topics = QueryTopicFactory.initializeTopics();
        Test.StopTest();
        
        System.AssertNotEquals(null,topics,'result must not be null');
        System.AssertNotEquals(0,topics.size(),'result must not be empty');
        
        final String TESTTOPIC='ThisIsAnInvalidName';
        System.AssertEquals(null,topics.get(TESTTOPIC), TESTTOPIC + ' topic must be not defined!');
   }

}