/**
 * Created by abidap on 1/6/19.
 */

public with sharing class ProspectMatchViewExtension {
    public Id contactRecordId {get;set;}

    public ProspectMatchViewExtension(ApexPages.StandardController controller){
        contactRecordId = ApexPages.currentPage().getParameters().get('id');
    }
}