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
        Map<String, Schema.SObjectField> fieldMap = getFieldMap('Profile');
		List<String> autoSuggests = new List<String>();
        
        for(String fieldName : fieldMap.keySet()) {
            String label = fieldMap.get(fieldName).getDescribe().getLabel();
            if(label.contains(searchKey)) {
                autoSuggests.add(label);
            }
        }

        return autoSuggests;
    }
    
    @AuraEnabled
    public static List<Profile> getProfiles(String keyWord) {
        String searchKey = getFieldName(keyWord, 'Profile');
        List<Profile> profiles = [SELECT Id, Name FROM Profile];
        List<Profile> foundProfiles = new List<Profile>();
        String dbQuery = buildDbQuery(profiles, searchKey, 'Name');
        
        try {
            List<Profile> profilesWithPermission = Database.query(dbQuery);
            for(Profile prof : profilesWithPermission) {
                Map<String, Object> fields = prof.getPopulatedFieldsAsMap();
                if(fields.get(searchKey) == true) {
                    foundProfiles.add(prof);
                }   
            }
        } catch (Exception ex) {
            System.debug('Error: '+ex.getMessage());
        }
        
        return foundProfiles;
    }
    
    @AuraEnabled
    public static List<PermissionSet> getPermissionSets(String keyWord) {
        String searchKey = getFieldName(keyWord, 'PermissionSet');
        List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet];
        List<PermissionSet> foundPermissionSets = new List<PermissionSet>();
        String dbQuery = buildDbQuery(permissionSets, searchKey, 'Label');
        
        try {
            List<PermissionSet> permissionSetsWithPermission = Database.query(dbQuery);
            for(PermissionSet ps : permissionSetsWithPermission) {
                Map<String, Object> fields = ps.getPopulatedFieldsAsMap();
                if(fields.get(searchKey) == true) {
                    foundPermissionSets.add(ps);
                }
            }
        } catch (Exception ex) {
            System.debug('Error: '+ex.getMessage());
        }
        
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
        
        return dbQuery;
    }
}