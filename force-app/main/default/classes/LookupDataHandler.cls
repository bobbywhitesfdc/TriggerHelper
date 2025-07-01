/**
 * Reboot of the LookupDataHandler concept with an abstraction layer
 * to decouple from any org level field metadata
 * Two basic kinds of Queries need to be supported:
 * 
 * 1) Detail Queries -->  These expect a single record to be returned
 *    from Case.OwnerId ---> Query User for that owner's info
 *    from Case.AccountId --> Query the related account's info
 *    from Case.ContactId --> Query the related Contact's info
 *    from Case.ParentId --> Query for the Parent Case
 * 
 * Rule:  The supplied Id is a foreign key value which will match the Primary Key of this record
 * Queries will all be in the form:   select id, <other interesting fields> From <targetObject> Where Id in :keySet
 * 
 * 2) Related Records --> These expect 0 to n records to be returned
 *    from Case.Id --> Query for the Case Milestones --> return a collection of MileStones
 * .  from Case.Id --> Query for the Case Comments --> return an ordered collection of Case Comments
 * .  from Case.AccountId --> Query for Assets available on the associated Account --> return a collection of Assets
 * 
 * Rule:  The supplied Id is a foreign key in the target table
 * Queries will be in the form:    select Id, <foreignKeyField>, <other interesting fields> From <targetObject> where <foreignKeyField> in :keySet
 * Ex:  select Id, CaseId, <interesting fields> From CaseMileStones Where CaseId in :keySet  Order By CaseId, Id
 **/ 
public without sharing virtual class LookupDataHandler {
    // behind the scenes these data structures manage the data to be queried and the results
    // Topic = SObjectType.name for default topics.  Otherwise it describes the configured Query
    final Map<String,Set<Id>> theKeysByTopic = new Map<String,Set<Id>>();
    final Map<String,Set<String>> theKeysByExternalIdTopic = new Map<String,Set<String>>();
    final Map<String,Map<Id,SObject>> theDetailData= new Map<String,Map<Id,SObject>>();
    final Map<String,Map<String,SObject>> theExternalIdData= new Map<String,Map<String,SObject>>();
    final Map<String,Map<Id,List<SObject>>> theRelatedListData= new Map<String,Map<Id,List<SObject>>>();
    
    private Map<String,TopicDefinition> topicDefsLocal=null;
    private final Map<String,TopicDefinition> topicDefs { get { 
        if (topicDefsLocal==null) {
            topicDefsLocal=QueryTopicFactory.initializeTopics();
            }
        return topicDefsLocal;  
    }} 


    /**
     *  Request Item Detail Using the Default Topic for this SObjectType
     **/ 
    public void requestItemDetail(final Id key) {
        DesignByContractUtil.assertNotEquals(null,key, 'key must not be null');
        final Set<Id> keySet = getKeySetForTopic(getDefaultTopic(key));
        
        keySet.add(key);        
    }
    
    /**
    * for Unit tests to verify that a key has been requested
    **/
    @TestVisible
    private Boolean isRequestedItemDetail(final Id key) {
        if (key==null) {
            return false;
        } else {
            final Set<Id> keySet = getKeySetForTopic(getDefaultTopic(key));        
            return keySet == null ? false : keySet.contains(key);        
            
        }
    }
    
    /**
     * for Unit tests to verify the list of keys that have been requested for this type
     **/
    public Set<Id> getRequestedItemDetailKeys(final SObjectType keyType) {
        DesignByContractUtil.assertNotEquals(null,keyType, 'keyType must not be null');
        return getKeySetForTopic(keyType.getDescribe().name);        
    }
    
    /**
     * Default Topic is the DeveloperName of the SObjectType
     **/ 
    @TestVisible
    private String getDefaultTopic(final Id key) {
        return key.getSObjectType().getDescribe().name;
    }
    
    /**
     *  Request RelatedList Using the Named Topic
     **/
    public void requestRelatedList(final String topic, final Id key) {
        System.Debug('requestRelatedList('+topic+','+key+')');
        DesignByContractUtil.assertNotEquals(null,key, 'key must not be null');
        DesignByContractUtil.assertNotEquals(null,topic,'topic is required');
        final Set<Id> keySet = getKeySetForTopic(topic);
        
        keySet.add(key);        
    }
    
    
    /**
     * for Unit tests to verify the list of keys that have been requested for this type
     **/ 
    public Set<Id> getRequestedRelatedListKeys(final String topic) {
        DesignByContractUtil.assertNotEquals(null,topic, 'Topic must not be null');
        return getKeySetForTopic(topic);        
    } 
    
    /**
     * for Unit tests to verify the list of keys that have been requested for this type
     **/
    @TestVisible
    private Set<String> getRequestedExternalIdKeys(final String topic) {
        DesignByContractUtil.assertNotEquals(null,topic, 'Topic must not be null');
        return getKeySetForExternalIdTopic(topic);        
    }    

    
    /**
     * Get the specific keySet for this object type
     * Initializes on first use
     **/
    @TestVisible
    private Set<Id> getKeySetForTopic(final String topic) {
        Set<Id> keySet = theKeysByTopic.get(topic);
        
        if (keySet == null) {  // Initialize the keyset for this type on first use
            keySet = new Set<Id>();  
            theKeysByTopic.put(topic,keySet);
        }
        return keySet;
    }

     /**
     *  Request by ExternalIdList Using the Named Topic
     **/
    public void requestExternalId(final String topic, final String key) {
        DesignByContractUtil.assertNotEquals(null,key, 'key must not be null');
        DesignByContractUtil.assertNotEquals(null,topic,'topic is required');
        final Set<String> keySet = (Set<String>) getKeySetForExternalIdTopic(topic);
        
        keySet.add(key);        
    } 
     /**
     *  Request by ExternalIdList Using the Named Topic
     **/
    public Boolean isRequestedExternalId(final String topic, final String key) {
        DesignByContractUtil.assertNotEquals(null,key, 'key must not be null');
        DesignByContractUtil.assertNotEquals(null,topic,'topic is required');
        final Set<String> keySet = (Set<String>) getKeySetForExternalIdTopic(topic);
        return keySet.contains(key);
    } 

    /**
     * Get the specific keySet for this ExternalIdTopic
     * Initializes on first use
     **/
    @TestVisible
    private Set<String> getKeySetForExternalIdTopic(final String topic) {
        Set<String> keySet = theKeysByExternalIdTopic.get(topic);
        
        if (keySet == null) {  // Initialize the keyset for this type on first use
            keySet = new Set<String>();  
            theKeysByExternalIdTopic.put(topic,keySet);
        }
        return keySet;
    }
    
    
    /**
     * Get the specific DataSet for this topic (Sobjecttype.name )
     * Initializes on first use
     **/ 
    public Map<Id,SObject> getDataSetForDetailTopic(final String topic) {
        Map<Id,SObject> theTypedDataSet= theDetailData.get(topic);
        
        if (theTypedDataSet==null) {
            final TopicDefinition topicDef = topicDefs.get(topic);
            if (topicDef==null) {
                throw new QueryTopicException(composeErrorMsg(topic,TOPICNOTFOUND)); 
            }
            
            DesignByContractUtil.assertEquals(TopicDefinition.TopicType.DETAIL,topicDef.type, 'Topic must be defined as a DETAIL topic type'); 
            theTypedDataSet = executeDetailQuery(topic,getKeySetForTopic(topic));                
            theDetailData.put(topic,theTypedDataSet);
        }
        
        return theTypedDataSet;
    }
    /**
     * Get the specific DataSet for this ExternalId topic
     * Initializes on first use
     **/ 
    public Map<String,SObject> getDataSetForExternalIdTopic(final String topic) {
        Map<String,SObject> theTypedDataSet= theExternalIdData.get(topic);
        
        if (theTypedDataSet==null) {
            final TopicDefinition topicDef = topicDefs.get(topic);
            if (topicDef==null) {
                throw new QueryTopicException(composeErrorMsg(topic,TOPICNOTFOUND)); 
            }
            
            DesignByContractUtil.assertEquals(TopicDefinition.TopicType.EXTERNALID,topicDef.type, 'Topic must be defined as a EXTERNAL topic type'); 
            theTypedDataSet =  executeExternalIdQuery(topic,getKeySetForExternalIdTopic(topic));   
            theExternalIdData.put(topic,theTypedDataSet);
        }
        
        return theTypedDataSet;
    }
  //getDataSetForRelatedListTopic
    /**
     * Get the specific DataSet for this ExternalId topic
     * Initializes on first use
     **/ 
    public Map<Id,List<SObject>> getDataSetForRelatedListTopic(final String topic) {
        Map<Id,List<SObject>> theTypedDataSet= theRelatedListData.get(topic);
        
        if (theTypedDataSet==null) {
            final TopicDefinition topicDef = topicDefs.get(topic);
            if (topicDef==null) {
                throw new QueryTopicException(composeErrorMsg(topic,TOPICNOTFOUND)); 
            }
            
            DesignByContractUtil.assertEquals(TopicDefinition.TopicType.RELATED,topicDef.type, 'Topic must be defined as a RELATED topic type'); 
            theTypedDataSet =  executeRelatedListQuery(topic,getKeySetForTopic(topic));                
            theRelatedListData.put(topic,theTypedDataSet);
        }
        
        return theTypedDataSet;
    }
  
    
    public static final String MALFORMEDSOQL = 'Malformed Topic SOQL definition';
    public static final String TOPICNOTFOUND = 'Topic definition not found';
    
    private String composeErrorMsg(final String topic, final String msg) {
        return 'Topic: ' + topic + ' ' + msg;
    }
    
    /**
     * Compose and execute the query
     **/
    private Map<Id,SObject> executeDetailQuery(final String topic, final Set<Id> keySet) {
        DesignByContractUtil.assertNotEquals(null, topic, 'Topic for lookup query must not be null!');
        DesignByContractUtil.assertNotEquals(null, keySet, 'KeySet for lookup query must not be null!');
        DesignByContractUtil.assertNotEquals(0, keySet.size(),'KeySet for lookup query must not be empty!');
        
        // Bind the query using Dynamic SOQL from templates
        final Map<String,Object> bindParams = new Map<String, Object>{'keySet' => keySet};
            
        // Results Map is IMPLICITLY keyed by the Id (PrimaryKey) of the object
        try {
           final Map<Id,SObject> resultsMap = new Map<Id,SObject>(Database.queryWithBinds(composeQueryString(topic), bindParams, AccessLevel.SYSTEM_MODE));        
           return resultsMap;                
        } catch (System.QueryException qex) {
           System.Debug(qex.getMessage());
           throw new QueryTopicException(composeErrorMsg(topic,MALFORMEDSOQL),qex); 
        }
    }
    
    /**
     * Compose and execute the RelatedList query, group the results by the KeyFieldname
     **/
    private Map<Id,List<SObject>> executeRelatedListQuery(final String topic, final Set<Id> keySet) {
        DesignByContractUtil.assertNotEquals(null, topic, 'Topic for lookup query must not be null!');
        DesignByContractUtil.assertNotEquals(null, keySet, 'KeySet for lookup query must not be null!');
        DesignByContractUtil.assertNotEquals(0, keySet.size(),'KeySet for lookup query must not be empty!');
        
        final TopicDefinition topicConfig = topicDefs.get(topic);
        
        // Bind the query using Dynamic SOQL from templates
        final Map<String,Object> bindParams = new Map<String, Object>{'keySet' => keySet};
        
        // Results must be grouped by the KeyFieldName (sparse list as there's no guarantee we will get results)
        final Map<Id,List<SObject>> resultsMap = new Map<Id,List<SObject>>();
        
        try {
            final List<SObject> results = Database.queryWithBinds(composeQueryString(topic), bindParams, AccessLevel.SYSTEM_MODE);        
            for (SObject current : results) {
                Id keyValue = (Id) current.get(topicConfig.keyFieldname);
                List<SObject> resultList = resultsMap.get(keyValue);
                if (resultList==null) {
                    resultList = new List<SObject>();
                    resultsMap.put(keyValue,resultList);
                }
                resultList.add(current);
            }
        } catch (System.QueryException qex) {
            System.Debug(qex.getMessage());
            throw new QueryTopicException(composeErrorMsg(topic,MALFORMEDSOQL),qex); 
        }      

        return resultsMap;
    }
    
    /**
     * Compose and execute the ExternalId query, group the results by the KeyFieldname
     * NOTE:  The key is of type STRING and therefore the map must be keyed by String (e.g. the ExternalId)
     **/
    private Map<String,SObject> executeExternalIdQuery(final String topic, final Set<String> keySet) {
        DesignByContractUtil.assertNotEquals(null, topic, 'Topic for lookup query must not be null!');
        DesignByContractUtil.assertNotEquals(null, keySet, 'KeySet for lookup query must not be null!');
        DesignByContractUtil.assertNotEquals(0, keySet.size(),'KeySet for lookup query must not be empty!');
        
        final TopicDefinition topicConfig = topicDefs.get(topic);
        DesignByContractUtil.assertEquals(TopicDefinition.TopicType.EXTERNALID, topicConfig.type,'Topic must be of type EXTERNALID');
        
        
        // Bind the query using Dynamic SOQL from templates
        final Map<String,Object> bindParams = new Map<String, Object>{'keySet' => keySet};
        
        // Results -- Expecting 1 row per ExternalId (unique)
        final Map<String,SObject> resultsMap = new Map<String,SObject>();
        
        try {
            final List<SObject> results = Database.queryWithBinds(composeQueryString(topic), bindParams, AccessLevel.SYSTEM_MODE);        
            for (SObject current : results) {
                String keyValue = (String) current.get(topicConfig.keyFieldname);
                resultsMap.put(keyValue,current);
            }
        } catch (System.QueryException qex) {
            System.Debug(qex.getMessage());
            throw new QueryTopicException(composeErrorMsg(topic,MALFORMEDSOQL),qex); 
        }
        
        return resultsMap;
    }
    
    
    private String composeQueryString(final String topic) {
        TopicDefinition topicConfig = topicDefs.get(topic);
        return topicConfig.queryTemplate;
    }
    
    /**
     * Retrieve the data for the default topic (SObjectType.name)
     **/ 
    public SObject getItemDetail(final Id key) {
       DesignByContractUtil.AssertNotEquals(null,key,'key may not be null');
       final Set<Id> keySet = getKeySetForTopic(getDefaultTopic(key));
       DesignByContractUtil.Assert(keySet != null && keySet.contains(key),'key must have been requested in advance using requestItemDetail('+key+')');
       final Map<Id,SObject> results = getDataSetForDetailTopic(getDefaultTopic(key));
       return results.get(key); 
    }
    
    /**
     * Retrieve the data for the ExternalID topic (SObjectType.name)
     **/ 
    public SObject getExternalId(final String topicName, final String key) {
       DesignByContractUtil.AssertNotEquals(null,key,'key may not be null');
       final Set<String> keySet = getKeySetForExternalIdTopic(topicName);
       DesignByContractUtil.Assert(keySet != null && keySet.contains(key),'key must have been requested in advance using requestExternalId('+ topicName + ','+key+')');
       final Map<String,SObject> results = getDataSetForExternalIdTopic(topicName);
       return results.get(key); 
    }

    /**
     * Retrieve the data for the RelatedList topic
     **/ 
    public List<SObject> getRelatedList(final String topicName, final Id key) {
       System.Debug('getRelatedList('+topicName+','+key+')');
       DesignByContractUtil.AssertNotEquals(null,key,'key may not be null');
       final Set<Id> keySet = getKeySetForTopic(topicName);
       DesignByContractUtil.Assert(keySet != null && keySet.contains(key),'key must have been requested in advance using requestRelatedList('+ topicName + ','+key+')');
       final Map<Id,List<SObject>> results = getDataSetForRelatedListTopic(topicName);
       // Sparse resultset, ensure that we always return a list, even if empty/missing
       return results.containsKey(key)? results.get(key) : new List<SObject>(); 
    }

}