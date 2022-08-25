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
        for(Profile prof : profiles) {
            try {
            	String dbQuery = 'SELECT '+searchKey+' FROM Profile WHERE Name = \''+prof.Name+'\'';
                sObject one = Database.query(dbQuery);
                Map<String, Object> fields = one.getPopulatedFieldsAsMap();
                if(fields.get(searchKey) == true) {
                    foundProfiles.add(prof);
                }
            } catch (Exception ex) {
                System.debug('Error: '+ex.getMessage());
                continue;
            }
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