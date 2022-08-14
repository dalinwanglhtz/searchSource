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
}