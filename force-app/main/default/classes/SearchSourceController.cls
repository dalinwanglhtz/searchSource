public class SearchSourceController {
    
    public static SearchSourceDAOService searchSourceDAOService {
        get {
            if(searchSourceDAOService == null) {
                searchSourceDAOService = new SearchSourceDAOServiceImpl();
            }
            return searchSourceDAOService;
        }
        set {
            searchSourceDAOService = value;
        }
    }
    
	@AuraEnabled
    public static List<ApexClass> getApexClass(String searchKey) {
        String queryString = '%'+searchKey+'%';
        List<ApexClass> aClasses = searchSourceDAOService.getApexClasses(queryString);
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
        String searchKey = getFieldApiName(keyWord, 'Profile');
        List<Profile> profiles = searchSourceDAOService.getAllProfiles();
        String dbQuery = searchSourceDAOService.buildDbQuery(profiles, searchKey, 'Name');
        List<Profile> foundProfiles = searchSourceDAOService.findRecords(searchKey, dbQuery);
        return foundProfiles;
    }
    
    @AuraEnabled
    public static List<PermissionSet> getPermissionSets(String keyWord) {
        String searchKey = getFieldApiName(keyWord, 'PermissionSet');
        List<PermissionSet> permissionSets = searchSourceDAOService.getAllPermissionSets();
        String dbQuery = searchSourceDAOService.buildDbQuery(permissionSets, searchKey, 'Label');
        List<PermissionSet> foundPermissionSets = searchSourceDAOService.findRecords(searchKey, dbQuery);
        return foundPermissionSets;
    }
    
    private static String getFieldApiName(String keyWord, String objType) {
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
}