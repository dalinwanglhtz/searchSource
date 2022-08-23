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
    public static List<Profile> getPermission(String keyWord) {
        String searchKey = getFieldName(keyWord);
        System.debug('SearchKey: '+searchKey);
        List<Profile> profiles = [SELECT Id, Name FROM Profile];
        List<Profile> foundProfiles = new List<Profile>();
        for(Profile prof : profiles) {
            try {
            	String dbQuery = 'SELECT '+searchKey+' FROM Profile WHERE Name = \''+prof.Name+'\'';
                System.debug('QUERY: '+dbQuery);
                sObject one = Database.query(dbQuery);
                Map<String, Object> fields = one.getPopulatedFieldsAsMap();
                if(fields.get(searchKey) == true) {
                    System.debug('Added');
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
        Map<String,String> fieldToAPIName = new Map<String,String>();
        
        for(String fieldName : fieldMap.keySet()) {
            fieldToAPIName.put(fieldMap.get(fieldName).getDescribe().getLabel(), fieldMap.get(fieldName).getDescribe().getName());
        }
        
        return fieldToAPIName.get(keyWord);
    }
    
    private static Map<String, Schema.SObjectField> getFieldMap(String objectType) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjSchema = schemaMap.get(objectType);
    	return sObjSchema.getDescribe().fields.getMap();
    }
}