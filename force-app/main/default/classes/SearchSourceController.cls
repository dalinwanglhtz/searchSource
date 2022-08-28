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
        String searchKey = getFieldName(keyWord);
        List<Profile> profiles = [SELECT Id, Name FROM Profile];
        List<Profile> foundProfiles = new List<Profile>();
        String dbQuery = buildDbQuery(profiles, searchKey);
        
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
    
    private static String getFieldName(String keyWord) {
        Map<String, Schema.SObjectField> fieldMap = getFieldMap('Profile');
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
    
    private static String buildDbQuery(List<sObject> objs, String searchKey) {
        Iterator<sObject> iter = objs.iterator();
        String dbQuery = 'SELECT '+searchKey+', Name FROM '+objs.getSObjectType()+' WHERE ';
        while(iter.hasNext()) {
			dbQuery += 'Name = \''+iter.next().get('Name')+'\'';
            if(iter.hasNext()) {
                dbQuery += ' OR ';
            }
        }
        
        return dbQuery;
    }
}