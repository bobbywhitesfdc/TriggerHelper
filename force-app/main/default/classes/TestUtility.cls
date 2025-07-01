/**
 Test Utility with object creation and permission related helper methods 
**/
@isTest
public with sharing class TestUtility {

    //Method for fetching single Profile based on the Name Field
    public static Profile getProfileOnExactName(String name){
        return [Select Id,name from Profile where Name = :name limit 1];
    }
    //Method for fetching Multiple List of Profiles based on the list of Names sent in input parameter
    public static List<Profile> getProfileOnExactName(List<String> names){
        return [Select Id,name from Profile where Name = :names order by Name];
    }

    //Method to fetch Groups and Queues on DeveloperName
    public static Group getPublicGroupOnDeveloperName(String developer_name){
        return [Select id,name,developerName from Group where developername = :developer_name limit 1];
    }
    //Method to fetch multiple Groups and Queues on List of Developer names
    public static List<Group> getPublicGroupOnDeveloperName(List<String> developer_names){
        return [Select id,name,developerName from Group where developername In :developer_names order by Name];
    }


    //Method accepts Permission set Group's DeveloperName and User Ids and assigns all the permission set groups mentioned to the users.
    public static List<PermissionSetAssignment> assignPermissionSetGroupsToUsers(List<String> psgNames, List<id> userIds, Boolean doInsert){
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        try{
            Map<String, Id> permissionSetGroupIds = new Map<String, Id>();
            for (PermissionSetGroup psg : [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN :psgNames]) {
                permissionSetGroupIds.put(psg.DeveloperName, psg.Id);
            }
            
            // Assign PermissionSetGroups to Users
            for (Id userId : userIds) {
                for (String groupName : psgNames) {
                    assignments.add(new PermissionSetAssignment(
                        PermissionSetGroupId = permissionSetGroupIds.get(groupName),
                        AssigneeId = userId
                    ));
                }
            }
            if(doInsert){
                insert assignments;
            }
        }catch (Exception e){
            system.debug('An Error Occured while adding PSG to Users: '+ e.getMessage());
            throw(e);
        }        
        return assignments;
    }
    //Method accpets Developer names of Groups/Queues and User Ids and Assigns users to all the Groups and Queues Mentioned.
    public Static List<GroupMember> assignGroupsandQueuesToUsers(List<String> developerNames,List<Id> userIds, Boolean doInsert){
        List<GroupMember> groupsAndQueues = new List<GroupMember>();
        Map<String, Id> groupIds = new Map<String, Id>();
        try{
            for (Group groups : [Select id,name,developerName from Group where developername IN :developerNames]) {
                groupIds.put(groups.DeveloperName, groups.Id);
            }
            // Assign Queues and Groups to Users
            for (Id userId : userIds) {
                for (String groupName : developerNames) {
                    groupsAndQueues.add(new GroupMember(
                        GroupId = groupIds.get(groupName),
                        UserOrGroupId = userId
                    ));
                }
            }
            if(doInsert){
                insert groupsAndQueues;
            }
        }catch(Exception e){
            system.debug('Exception in assingment of Users to Groups/Queues: '+ e.getMessage());
            throw(e);
        }
        return groupsAndQueues;
    }

    //Method to Avoid Error During Deployment for test classes which have user insertion and PSG assignment
    //Error Encountered : System.DmlException: Insert failed. First exception on row 0; first error: INVALID_CROSS_REFERENCE_KEY, You can only assign users to permission set groups that have the "Updated" status.: []
    public static void setPSGStatusAsUpdatedForTesting(){
        List<ID> uniquePSGID = new List<Id>();
        Set<String> uniquePermissionSetGroup = new Set<String>();
        
        //Fetch Metadata used for PSG assignment automation
        List< Permission_Set_Groups_Mapper__mdt> psgManagerMtd = [Select Id,
                                                                  Profile_API_Name__c,
                                                                  User_Persona__c ,
                                                                  Permission_Set_Groups__c 
                                                                  from Permission_Set_Groups_Mapper__mdt LIMIT 2
                                                                  ];
    //Process the unique PSG involved
        for(Permission_Set_Groups_Mapper__mdt psgMtd : psgManagerMtd)  {
                Set<String> setOfpermisionSetGrp = new Set<String>();
                if(!String.isBlank(psgMtd.Permission_Set_Groups__c)){
                    setOfpermisionSetGrp.addall(psgMtd.Permission_Set_Groups__c.split(';'));
                    uniquePermissionSetGroup.addAll(setOfpermisionSetGrp);
                }
            
        }
        //Filter the PSG where Status != Updated
        For(PermissionSetGroup psg: [SELECT Id, DeveloperName, status FROM PermissionSetGroup WHERE DeveloperName in :uniquePermissionSetGroup]){
            if(psg.status != 'Updated'){
                system.debug('PSG with Status not Updated: '+ psg);
                uniquePSGID.add(psg.id);
            }
        }
        //Update the PSG
        system.debug('Unique IDs :'+ uniquePSGID);
        if(uniquePSGID!= null && uniquePSGID.size()>0){
            Test.calculatePermissionSetGroup(uniquePSGID);
        }
    }


    //Insert Single account with Options provided
    public static Account insertTestAccount(Boolean doInsert, Map<String,Object> options) {
        if (options == null) { options = new Map<String,Object>(); }
        Account acct = new Account(Name = 'Test Account');
        buildObject(acct, options);

        if (doInsert) {
            insert acct;
        }
        return acct;
    }

    //Insert Multiple Accounts with a List of Options Provided
    public static List<Account> insertTestAccounts(Boolean doInsert, List<Map<String,Object>> optionsList) {
        List<Account> accountsToInsert = new List<Account>();
        Integer i=1;

        for (Map<String, Object> options : optionsList) {
            if (options == null) {options = new Map<String,Object>();}
            
            Account acct = new Account(Name = 'Test Account'+ i++);
            buildObject(acct, options);           
            accountsToInsert.add(acct);
        }

        if (doInsert) {
            insert accountsToInsert;
        }
        return accountsToInsert;
    }

    //Insert Multiple records with Options Provided
    public static List<SObject> insertTestSObjects(String objectName, Boolean doInsert, Map<String, Object> options, Integer count) {
        List<SObject> sObjectList = new List<SObject>();
        
        // Ensure options map is initialized
        if (options == null) {
            options = new Map<String, Object>();
        }
        
        // Get the SObject type from the object name
        SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        sObject prototypeSObject = insertObject(sObjectType,false,options);
        sObjectList.add(prototypeSObject);
        // Loop to create and insert SObjects
        for (Integer i = 1; i < count; i++) {
            
                SObject clonedSObject = prototypeSObject.clone(false, false, false, false);
                sObjectList.add(clonedSObject);
            }
            if (doInsert && sObjectList.size()>0) {
                insert sObjectList;
            }
                    
        return sObjectList;
    }

  //Responsible for Creating the sObject required for insertion with the right data from options provided.
  public static void buildObject(sObject obj, Map<String,Object> options){
    if(options != null){
            for(String option : options.keySet()){
                obj.put(option, options.get(option));
            }
        } 
  }
    
   static Integer startingIdSequenceNumber = 1;
    
   public static String generateFakeId(Schema.SObjectType sot)
   {
      String result = String.valueOf(startingIdSequenceNumber++);
      return sot.getDescribe().getKeyPrefix() + 
         '0'.repeat(12-result.length()) + result;
   }
    
    /**
     * Helper method to assign a Custom Permission by DeveloperName
    **/  
    public static void assignFeatureFlag(final Id userId, final String ffPermissionDevName) {
        DesignByContractUtil.assertNotEquals(null,userId,'userId is required');
        DesignByContractUtil.assertNotEquals(null,ffPermissionDevName,'ff name is required');
        
        final Id psId = getPSWithFeatureFlag(ffPermissionDevName);
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId=userId,PermissionSetId=psId);
       // System.RunAs(TestGlobalConstants.getRunningUser()) {
        User runningUser = new User(Id=UserInfo.getUserId());
        System.RunAs(runningUser){
            insert psa;
            System.Debug('PS assigned:' + psa);
        }        
    }
    
    /** 
     * Find a permissionSet that has the desired Feature Flag
     **/ 
    public static Id getPSWithFeatureFlag(final String ffPermissionDevName) {
        final List<SetupEntityAccess> setupEntities  = [
            SELECT ParentId FROM SetupEntityAccess 
            WHERE SetupEntityId IN (SELECT Id FROM CustomPermission WHERE DeveloperName = :ffPermissionDevName)];
        
        DesignByContractUtil.AssertNotEquals(true,setupEntities.isEmpty(),'No PermissionSet found containing:'+ffPermissionDevName);
        return setupEntities[0].ParentId; 
    }
    
    // method responsible for creation of sObject record based on the data provided
    public static sObject insertObject(SObjectType type, Boolean doInsert, Map<String,Object> options){
        sObject obj = type.newSObject();
        buildObject(obj, options);
        System.debug('Inside Insert Object-->  '  + obj);
        System.debug('Inside Insert Options-->  '  + options);
        if(doInsert) {
            insert obj;
        }
        
        return obj;
    } 
}