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
    
    public String buildDbQuery(List<sObject> objs, String searchKey, String displayFieldName) {
        Iterator<sObject> iter = objs.iterator();
        String dbQuery = 'SELECT '+searchKey+', '+displayFieldName+' FROM '+objs.getSObjectType()+' WHERE Name IN (';
        while(iter.hasNext()) {
			dbQuery += '\''+iter.next().get('Name')+'\'';
            if(iter.hasNext()) {
                dbQuery += ', ';
            }
        }
        dbQuery += ') ORDER BY '+displayFieldName+' DESC';
        
        return dbQuery;
    }
    
    public List<SObject> findRecords(String searchKey, String dbQuery) {
        List<SObject> records = new List<SObject>();
        try {
            List<SObject> dbResults = Database.query(dbQuery);
            for(SObject obj : dbResults) {
                Map<String, Object> fields = obj.getPopulatedFieldsAsMap();
                if(fields.get(searchKey) == true) {
                    records.add(obj);
                }   
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error getting results, detail: '+ex.getMessage());
        }
        
        return records;
    }
}