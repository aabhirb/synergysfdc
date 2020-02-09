/**
 * Created by abidap on 4/27/19.
 */

public without sharing class ConfirmInvoiceController {

    public String opportunityLineItemId {get;set;}
    public Opportunity_Line_Item__c opportunityLineItemRequested {get; set;}

    /*

    {
        if( opportunityLineItemRequested == null ){
            opportunityLineItemRequested = [
                    SELECT Id,Name,Invoice_Due_Date__c,Opportunity__r.GP_Contact__r.Name,Total_Supply_Invoice_Amount__c,
                            Total_Bottom_Line_Amount__c,Treatment_Date_Formatted__c,Invoice_Due_Date_Formatted__c,Total_Invoice_Amount__c
                    from
                            Opportunity_Line_Item__c
                    where
                            Id =: opportunityLineItemId Limit 1
            ];
        }

        return opportunityLineItemRequested;
    }

     */

    public ConfirmInvoiceController(){

        parseURLParameters();

        if(String.isNotBlank(opportunityLineItemId)){

                opportunityLineItemRequested = [
                                                    SELECT Id,Name,Invoice_Due_Date__c,Opportunity__r.GP_Contact__r.Name,Total_Supply_Invoice_Amount__c,Invoice_Amount__c,
                                                        Total_Bottom_Line_Amount__c,Treatment_Date_Formatted__c,Invoice_Due_Date_Formatted__c,Total_Invoice_Amount__c,Opportunity__r.Primary_Contact__r.Name,
                                                        Invoice_PDF_URL__c, Production_Report_PDF_URL__c
                                                        from
                                                        Opportunity_Line_Item__c
                                                        where
                                                        Id =: opportunityLineItemId Limit 1
                                                ];


        }
    }

    private void parseURLParameters(){
        if(ApexPages.currentPage().getParameters() != null ){
            opportunityLineItemId      = ApexPages.currentPage().getParameters().get('oliId');
        }
    }

    @RemoteAction
    public static String onclickOfAction( String oliId ){
       if(String.isNotBlank(oliId)){
           Opportunity_Line_Item__c oliVar = new Opportunity_Line_Item__c();
           oliVar.Id = oliId;
           oliVar.Status__c = 'Invoice Sent to Practice';
           try{

               update oliVar;

               return 'SUCCESS';
           }catch( Exception ex){
                return 'Error : Please contact Synergy with more details.'+ex.getMessage();
           }
       }

        return 'Error:'+'Values not Passed !!';
    }
}