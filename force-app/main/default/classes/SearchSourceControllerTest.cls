@IsTest
public class SearchSourceControllerTest {
	
    @IsTest
    static void testGetApexClasses() {
        SearchSourceController.searchSourceDAOService = new MockSearchSourceDAOServiceImpl();
        
        Test.startTest();
        List<ApexClass> aClasses = SearchSourceController.getApexClass('test string');
        Test.stopTest();
        
        System.assertEquals(1, aClasses.size(), 'List has at least one row.');
    }
    
    @IsTest
    static void testAutoSuggest() {
        Test.startTest();
        List<String> autoSuggests = SearchSourceController.getAutoSuggest('Manage');
        Test.stopTest();
        
        System.assert(autoSuggests.size() > 0, 'Should return at least one auto-suggest permission phrases.');
    }
    
    @IsTest
    static void testGetProfiles() {
        SearchSourceController.searchSourceDAOService = new MockSearchSourceDAOServiceImpl();
        
        Test.startTest();
        List<Profile> profiles = SearchSourceController.getProfiles('Testing');
        Test.stopTest();
        
        System.assertNotEquals(null, profiles, 'Should not return null.');
    }
    
    public class MockSearchSourceDAOServiceImpl implements SearchSourceDAOService {
        public List<ApexClass> getApexClasses(String searchString) {
            List<ApexClass> apexClasses = new List<ApexClass>();
            Id classId = TestUtility.getFakeId(ApexClass.SObjectType);
            ApexClass apex = (ApexClass) JSON.deserialize(
                '{"Id":"'+classId+'"}', 
                ApexClass.class);
            apexClasses.add(apex);
            return apexClasses;
        }
        
        public List<Profile> getAllProfiles() {
            List<Profile> profiles = new List<Profile>();
            Id profId = TestUtility.getFakeId(Profile.SObjectType);
            Profile prof = (Profile) JSON.deserialize(
                '{"Id":"'+profId+'", "Name":"TestProfile"}',
                Profile.class);
            profiles.add(prof);
            return profiles;
        }
        
        public List<PermissionSet> getAllPermissionSets() {
            List<PermissionSet> permSets = new List<PermissionSet>();
            Id permId = TestUtility.getFakeId(PermissionSet.SObjectType);
            PermissionSet permSet = (PermissionSet) JSON.deserialize(
                '{"Id":"'+permId+'"}, {"Name":"TestPermissionSet"}, {"Label":"Test PermissionSet"}', 
                PermissionSet.class);
            permSets.add(permSet);
            return permSets;
        }
        
        public String buildDbQuery(List<sObject> objs, String searchKey, String displayFieldName) {
            return 'SELECT Id, Name FROM SObject';
        }
        
        public List<SObject> findRecords(String searchKey, String dbQuery) {
            return new List<SObject>();
        }
    }
}