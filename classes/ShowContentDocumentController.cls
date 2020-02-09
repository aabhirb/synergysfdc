public class ShowContentDocumentController {

    public String contentUrl {get;set;}
    public String password {get;set;}
    
    public ShowContentDocumentController(){
        contentUrl = ApexPages.currentPage().getParameters().get('contentUrl');
    } 
    
    public PageReference urlRedirection() {
        PageReference page;
        //Fetch the password from custom setting
        Misc_Configuration__c configObject = Misc_Configuration__c.getOrgDefaults();

        //If the custom setting record exists and the password matches the universal password
        if(String.isNotBlank(contentUrl) && configObject != null && String.isNotBlank(configObject.Universal_Password__c)
           && configObject.Universal_Password__c.equals(password)){
            page = new PageReference(contentUrl);
        } else {
            List<Site> siteObjLst = [SELECT id from Site WHERE MasterLabel = 'Show Content Document'];
            if(siteObjLst.size() > 0){
                SiteDetail siteDetailObj = [SELECT id, SecureUrl from SiteDetail where DurableId =: siteObjLst[0].Id];
                page = new PageReference(siteDetailObj.SecureUrl);
                page.getParameters().put('contentUrl', contentUrl);
            }
            
            
        }
        page.setRedirect(true);
        return page;
    }
    
    
}