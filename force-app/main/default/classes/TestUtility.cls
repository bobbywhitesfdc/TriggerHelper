/**
 * Test Utility with permission related helper methods
 * and common utilities used by Tests
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
 
    
   static Integer startingIdSequenceNumber = 1;
    
   public static String generateFakeId(Schema.SObjectType sot)
   {
      String result = String.valueOf(startingIdSequenceNumber++);
      return sot.getDescribe().getKeyPrefix() + 
         '0'.repeat(12-result.length()) + result;
   }
    
    public static Id getPSWithFeatureFlag(final String ffPermissionDevName) {
        final List<SetupEntityAccess> setupEntities = [
            SELECT ParentId FROM SetupEntityAccess
            WHERE SetupEntityId IN (SELECT Id FROM CustomPermission WHERE DeveloperName = :ffPermissionDevName)];
        DesignByContractUtil.AssertNotEquals(true, setupEntities.isEmpty(), 'No PermissionSet found containing:' + ffPermissionDevName);
        return setupEntities[0].ParentId;
    }

    /**
      This test method creates a new temporary PermissionSet
      with which to assign the Feature Flag (Custom Permission)
      It's a test-only duration and will be rolled back when the unit
      test finishes executing
    **/
    public static void assignFeatureFlag(final Id userId, final String ffPermissionDevName) {
        DesignByContractUtil.assertNotEquals(null, userId, 'userId is required');
        DesignByContractUtil.assertNotEquals(null, ffPermissionDevName, 'ff name is required');

        // Must create a fresh PS + SetupEntityAccess; querying an existing PS does not
        // trigger permission recalc inside System.runAs (Salesforce platform behavior).
        System.runAs(new User(Id = UserInfo.getUserId())) {
            PermissionSet ps = new PermissionSet(
                Name = 'TestFF_' + ffPermissionDevName,
                Label = 'Test FF ' + ffPermissionDevName
            );
            insert ps;
            insert new List<SObject>{
                new SetupEntityAccess(
                    ParentId = ps.Id,
                    SetupEntityId = [SELECT Id FROM CustomPermission WHERE DeveloperName = :ffPermissionDevName LIMIT 1].Id
                ),
                new PermissionSetAssignment(
                    AssigneeId = userId,
                    PermissionSetId = ps.Id
                )
            };
        }
    }

}