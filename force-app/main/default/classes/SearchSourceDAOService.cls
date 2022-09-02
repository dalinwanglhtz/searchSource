public interface SearchSourceDAOService {
	List<ApexClass> getApexClasses(String searchString);
    List<Profile> getAllProfiles();
    List<PermissionSet> getAllPermissionSets();
    String buildDbQuery(List<sObject> objs, String searchKey, String displayFieldName);
    List<SObject> findRecords(String searchKey, String dbQuery);
}