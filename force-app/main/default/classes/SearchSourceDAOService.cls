public interface SearchSourceDAOService {
	List<ApexClass> getApexClasses(String searchString);
    List<Profile> getAllProfiles();
    List<PermissionSet> getAllPermissionSets();
}