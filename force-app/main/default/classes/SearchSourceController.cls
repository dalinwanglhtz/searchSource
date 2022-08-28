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
        Iterator<Profile> iter = profiles.iterator();
        String dbQuery = 'SELECT '+searchKey+', Name FROM Profile WHERE ';
        while(iter.hasNext()) {
            Profile prof = iter.next();
			dbQuery += 'Name = \''+prof.Name+'\'';
            if(iter.hasNext()) {
                dbQuery += ' OR ';
            }
        }
        
        try {
            List<sObject> profilesWithPermission = Database.query(dbQuery);
            for(sObject prof : profilesWithPermission) {
                Map<String, Object> fields = prof.getPopulatedFieldsAsMap();
                if(fields.get(searchKey) == true) {
                    foundProfiles.add((Profile) prof);
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
}