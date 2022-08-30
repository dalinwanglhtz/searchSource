public class SearchSourceController {
	@AuraEnabled
    public static List<ApexClass> getApexClass(String searchKey) {
        String queryString = '%'+searchKey+'%';
        List<ApexClass> aClasses = [
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
            	WHERE Name LIKE :queryString
        ];
        return aClasses;
    }
    
    @AuraEnabled
    public static List<String> getAutoSuggest(String searchKey) {
		Set<String> autoSuggests = new Set<String>();
        List<String> items = new List<String>{'Profile', 'PermissionSet'};
        for(String str: items) {
        	Map<String, Schema.SObjectField> fieldMap = getFieldMap(str);
            for(String fieldName : fieldMap.keySet()) {
                String label = fieldMap.get(fieldName).getDescribe().getLabel();
                if(label.contains(searchKey)) {
                    autoSuggests.add(label);
                }
            }            
        }

        return new List<String>(autoSuggests);
    }
    
    @AuraEnabled
    public static List<Profile> getProfiles(String keyWord) {
        String searchKey = getFieldName(keyWord, 'Profile');
        List<Profile> profiles = [SELECT Id, Name FROM Profile];
        String dbQuery = buildDbQuery(profiles, searchKey, 'Name');
        
        List<Profile> foundProfiles = findRecords(searchKey, dbQuery);
        
        return foundProfiles;
    }
    
    @AuraEnabled
    public static List<PermissionSet> getPermissionSets(String keyWord) {
        String searchKey = getFieldName(keyWord, 'PermissionSet');
        List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet];
        String dbQuery = buildDbQuery(permissionSets, searchKey, 'Label');
        
        List<PermissionSet> foundPermissionSets = findRecords(searchKey, dbQuery);
        
        return foundPermissionSets;
    }
    
    private static String getFieldName(String keyWord, String objType) {
        Map<String, Schema.SObjectField> fieldMap = getFieldMap(objType);
        String foundFieldName = null;
        
        for(String fieldName : fieldMap.keySet()) {
            if(keyWord.equalsIgnoreCase(fieldMap.get(fieldName).getDescribe().getLabel())) {
                foundFieldName = fieldMap.get(fieldName).getDescribe().getName();
                break;
            }
        }
        
        return foundFieldName;
    }
    
    private static Map<String, Schema.SObjectField> getFieldMap(String objectType) {
        Schema.SObjectType sObjSchema = Schema.getGlobalDescribe().get(objectType);
    	return sObjSchema.getDescribe().fields.getMap();
    }
    
    private static String buildDbQuery(List<sObject> objs, String searchKey, String displayFieldName) {
        Iterator<sObject> iter = objs.iterator();
        String dbQuery = 'SELECT '+searchKey+', '+displayFieldName+' FROM '+objs.getSObjectType()+' WHERE ';
        while(iter.hasNext()) {
			dbQuery += 'Name = \''+iter.next().get('Name')+'\'';
            if(iter.hasNext()) {
                dbQuery += ' OR ';
            }
        }
        dbQuery += ' ORDER BY '+displayFieldName+' DESC';
        
        return dbQuery;
    }
    
    private static List<SObject> findRecords(String searchKey, String dbQuery) {
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
            System.debug('Error: '+ex.getMessage());
        }
        
        return records;
    }
}