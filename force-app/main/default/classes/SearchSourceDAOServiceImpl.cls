public class SearchSourceDAOServiceImpl implements SearchSourceDAOService {

    public List<ApexClass> getApexClasses(String searchString) {
        return [
            SELECT ApiVersion, 
            	Body, 
            	BodyCrc, 
            	CreatedById, 
            	CreatedDate, 
            	Id, 
            	IsValid, 
            	LastModifiedById, 
            	LastModifiedDate, 
            	LengthWithoutComments, 
            	Name, 
            	NamespacePrefix, 
            	Status, SystemModstamp 
            	FROM ApexClass
            	WHERE Name LIKE :searchString
        ];
    }
    
    public List<Profile> getAllProfiles() {
        return [SELECT Id, Name FROM Profile];
    }
    
    public List<PermissionSet> getAllPermissionSets() {
        // Exclude permission sets owned by profiles
        // https://help.salesforce.com/s/articleView?id=000339288&type=1
        return [
            SELECT Id, Name, Label 
            FROM PermissionSet 
			WHERE IsOwnedByProfile = false
        ];
    }
}