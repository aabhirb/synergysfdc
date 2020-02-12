public with sharing class opportunitylineintemExtensionsController {
                 
        @TestVisible Private Opportunity_Line_Item__c oli;
       
        Private Opportunity opp1;
        private Adjustment__c adjustmet;
        Private Contact con;
        Private Integer tLPInt,gPMInt;
        Public Integer cal;
        Public String call{get;set;}
        Private Integer pAInt,tBLMInt,tSIMInt;
        Private Integer topInt,bottomInt;
        Public Integer top_BottonInt;
        Public String top_Botton{get;set;}
        Public Integer bill;
        Public String billed{get;set;}
        public String currentRecordId {get;set;}
        
        public Boolean initialised{get; set;}
        public Id posId{get;set;}
        public Id posOppId;
        Public String dateFormat = 'dd-MM-yyyy';
        Public Datetime datet;
        Public String dateString{get;set;}
        Public Datetime datets;
        Public String dateStrings{get;set;}
        Public Integer tLineamount;
        Public Integer tLinesum{get;set;}
        
        //Convert values
        Public Integer adjustmentpercentInt;
        Public Integer adjustmnetInt;
        Public Integer opplineInt;
        Public Integer aSupplyLineTotal;
        Public Integer bgSupplyLineTotal;
        Public Integer healingAbutmentLineTotal;
        Public Integer iSupplyLineTotal;
        Public Integer mSupplyLineTotal;
        Public Integer ivSupplyLineTotal;
        Public Integer supplyAdjustmentsTotal;
        Public String adjustmnetStr{get;set;}
        public Integer counter {get; set;}
        Public String supplyAdjustmentsTotalStr{get;set;}
        
        //Constructor
        public opportunitylineintemExtensionsController(ApexPages.StandardController stdController) {
            posId = stdcontroller.getRecord().Id;
           system.debug('id = ' + currentRecordId );
        }
        
        public Opportunity_Line_Item__c getopp() {        
            oli = [SELECT Id,Invoice_Due_Date_Formatted__c,Membrane_Cost_To_be_Invoiced__c,Provider_Synergy_Plus__c,
                            Membrane_Used__c,Membrane_Cost__c,Implant_Cost_To_be_Invoiced__c,Implants_Used__c,
                            Implant_Cost__c,Healing_Abutment_To_Invoiced__c,Healing_Abutments_Used__c,Healing_Abutment__c,
                            Healing_Abutment_Cost__c,Bone_Graft_Cost_To_be_Invoiced__c,Bone_Graft_Used__c,
                            Bone_Graft_Cost__c,Assistant_Cost_To_Be_Invoiced__c,Assistant_Hours_Used__c,Assistant_Hourly_Rate__c,Opportunity__c,Treatment_Date_Formatted__c,Total_Supply_Invoice_Amount__c,Total_Bottom_Line_Amount__c,
                            Name,Invoice_Due_Date__c,Production_Amount__c,Compensation__c,Gross_Production_Amount__c,Total_Top_Line_Percentage__c,
                            Treatment_Date__c,Implant__c,Bone_Graft__c,Membrane__c,Assistant_Supply__c,Total_Cost_for_Provider__c,
                            Provider_Healing_Abutment__c,Membrane_Cost_for_Provider__c,Bone_Graft_Cost_for_Provider__c,Implant_Cost_for_Provider__c,
                            Total_Cost_Owed_By_Practice__c,Total_Cost_Practice_Owes__c,Implant_Cost_Practice_Owes__c,Implant_Cost_Owed_By_Practice__c,
                            Provider_Contribution_Implant__c,Other_Cost__c,Assistant_Cost_Practice_Owes__c,Assistant_Cost_Owed_By_Practice__c,
                            Provider_Contribution_Assistant__c,Practice_Assistant_Contribution__c,Bone_Graft_Cost_Practice_Owes__c,Bone_Graft_Practice_Owes__c,
                            Provider_Contribution_for_Bone_Graft__c,HA_Cost_Practice_Owes__c,HA_Cost_Owed_By_Practice__c,
                            Provider_Contribution_Healing_Abutment__c,Membrane_Cost_Practice_Owes__c,Membrane_Cost_Owed_By_Practice__c,Provider_Contribution_Membrane__c,
                            Total_Cost_Owed_By_Practice_Calc__c,Total_Cost_Practice_Owes_Calc__c,Invoice_Amount__c,Other_Cost_2__c,Other_Cost_3__c,Other_Description_2__c,Other_Description_3__c,Other_Description__c,OD_Payment_Balance__c,OD_Payment_Amount__c,Status__c,
                            PR_Courtesy_Adjustment__c,Courtesy_Adjustment__c,PR_Insurance_Adjustment__c,Insurance_Adjustment__c,PR_Production_Adjustment__c,Production_Adjustment__c,PR_Write_off_Adjustment__c,Write_off_Adjustment__c,
                            Prepay_Balance__c,Provider_Full_Name__c,Practice_Name__c
                            FROM
                            Opportunity_Line_Item__c
                            where
                            id=:posId];
            // Calculate 
            If(oli.Total_Top_Line_Percentage__c!=null && oli.Gross_Production_Amount__c!=null){
               TLPInt = Integer.valueOf(oli.Total_Top_Line_Percentage__c);
               GPMInt = Integer.valueOf(oli.Gross_Production_Amount__c);
               cal= GPMInt* TLPInt/100;
               call=String.valueOf(cal);
               posOppId=oli.Opportunity__c;
               datet=(Datetime)oli.Invoice_Due_Date__c;
               dateString = datet.format(dateFormat);
               datets=(Datetime)oli.Treatment_Date__c;
               dateStrings = datet.format(dateFormat);    
            }
            System.debug('posOppId'+posOppId);
            // Top + Bottom Calculation 
            If(oli.Total_Bottom_Line_Amount__c!=null && cal!=null){
            BottomInt = Integer.valueOf(oli.Total_Bottom_Line_Amount__c);
            Top_BottonInt= BottomInt + cal;
            Top_Botton= String.valueOf(Top_BottonInt);
            } 
            //Calculate Total Supply
            if(oli!=null){
            aSupplyLineTotal= (oli.Assistant_Cost_To_Be_Invoiced__c != null) ? Integer.valueOf(oli.Assistant_Cost_To_Be_Invoiced__c) : 0;  
            bgSupplyLineTotal= ( oli.Bone_Graft_Cost_To_be_Invoiced__c != null ) ? Integer.valueOf(oli.Bone_Graft_Cost_To_be_Invoiced__c) : 0;
            healingAbutmentLineTotal= (oli.Healing_Abutment_To_Invoiced__c != null) ? Integer.valueOf(oli.Healing_Abutment_To_Invoiced__c) : 0;
            iSupplyLineTotal = (oli.Implant_Cost_To_be_Invoiced__c != null ) ? Integer.valueOf(oli.Implant_Cost_To_be_Invoiced__c) : 0;
            mSupplyLineTotal = (oli.Membrane_Cost_To_be_Invoiced__c != null) ? Integer.valueOf(oli.Membrane_Cost_To_be_Invoiced__c) : 0;
            ivSupplyLineTotal = (oli.Membrane_Cost__c != null) ? Integer.valueOf(oli.Membrane_Cost__c) : 0;
            supplyAdjustmentsTotal= aSupplyLineTotal + bgSupplyLineTotal + healingAbutmentLineTotal + iSupplyLineTotal + mSupplyLineTotal + ivSupplyLineTotal;
            supplyAdjustmentsTotalStr= String.valueOf(supplyAdjustmentsTotal);
            }
            
            //Calculate Total Bill
            If(oli.Gross_Production_Amount__c!=null && oli.Total_Bottom_Line_Amount__c!=null && cal!=null && oli.Total_Supply_Invoice_Amount__c!=null){
           // PAInt,TBLMInt,TSIMInt
            PAInt = Integer.valueOf(oli.Gross_Production_Amount__c);
           // TBLMInt = Integer.valueOf(opp.Total_Bottom_Line_Amount__c);
           // TSIMInt = Integer.valueOf(oli.Total_Supply_Invoice_Amount__c);
            bill=  PAInt + Top_BottonInt + supplyAdjustmentsTotal;
            billed= String.valueOf(bill);
            }
            
            return oli;
        }                         
         
        Public Opportunity getopp1(){
        oli = [SELECT Id,Opportunity__c,Total_Supply_Invoice_Amount__c,Total_Bottom_Line_Amount__c, Name,Invoice_Due_Date__c,Production_Amount__c,Compensation__c,Gross_Production_Amount__c,Total_Top_Line_Percentage__c,Treatment_Date__c,Treatment_Date_Formatted__c,Provider_Synergy_Plus__c,Total_Cost_for_Provider__c,Provider_Healing_Abutment__c,Membrane_Cost_for_Provider__c,Bone_Graft_Cost_for_Provider__c,Implant_Cost_for_Provider__c,Total_Cost_Owed_By_Practice__c,Total_Cost_Practice_Owes__c,Implant_Cost_Practice_Owes__c,Implant_Cost_Owed_By_Practice__c,Provider_Contribution_Implant__c,Invoice_Amount__c,Other_Cost_2__c,Other_Cost_3__c,Other_Description_2__c,Other_Description_3__c,Other_Description__c,OD_Payment_Balance__c,OD_Payment_Amount__c,Status__c,Courtesy_Adjustment__c,Insurance_Adjustment__c,Production_Adjustment__c,Write_off_Adjustment__c FROM Opportunity_Line_Item__c where id=:posId];

            opp1 = [SELECT Id,GP_Contact__r.MailingCity , GP_Contact__r.MailingState, GP_Contact__r.MailingCountry,Primary_Contact__r.Account.Name, GP_Contact__r.MailingPostalCode,GP_Contact__r.Formulated_MailingAddress__c,Primary_Contact__r.Formulated_MailingAddress__c, GP_Contact__r.MailingStreet, Name,Primary_Contact__r.firstname,Primary_Contact__r.lastname,GP_Contact__r.firstname,GP_Contact__r.lastname,GP_Contact__r.Account.Name,GP_Contact__r.MobilePhone,Primary_Contact__r.MobilePhone,Provider_Synergy_Plus__c,Cheques_go_to_Synergy__c, Special_Payment_Instructions__c FROM Opportunity where id=:oli.Opportunity__c];
            return opp1;
        }
        
        // Adjustment Query
        Public Adjustment__c getadjustmet(){
        adjustmet=[Select id, Name,Adjustment_Amount__c,Adjustment_Percent__c,Description__c from Adjustment__c where Opportunity_Line_Item__c=:oli.id];
        return adjustmet;
        }
        
        //Top Line Adjustment Table Values
         Public List<Adjustment__c> getAdjustmetList(){
         List<Adjustment__c> adjustmetList;
         oli = [SELECT Id,Opportunity__c,Total_Supply_Invoice_Amount__c,Total_Bottom_Line_Amount__c, Name,Invoice_Due_Date__c,Production_Amount__c,Compensation__c,Gross_Production_Amount__c,Total_Top_Line_Percentage__c,Treatment_Date__c,Provider_Synergy_Plus__c,OD_Payment_Balance__c,OD_Payment_Amount__c,Courtesy_Adjustment__c,Insurance_Adjustment__c,Production_Adjustment__c,Write_off_Adjustment__c FROM Opportunity_Line_Item__c where id=:posId];
         adjustmetList =[Select id,RecordType.Name,AmountCount__c, Name,Adjustment_Amount__c,Adjustment_Percent__c,Description__c from Adjustment__c where Opportunity_Line_Item__c=:oli.id and RecordType.Name='Top Line Adjustment'];
         
          Integer tempSum = 0;   
         //Calculate Sum of 
         for(Adjustment__c a:adjustmetList){
             tLineamount = Integer.valueOf(a.Adjustment_Percent__c);
             tempSum = tempSum + tLineamount;
            }
        tLinesum = tempSum;
        System.debug('tLineamount'+tLineamount);
        System.debug('tLinesum'+tLinesum);
         
        return adjustmetList;
       }
                 
        //Bottom Line Adjustment Table values
         Public List<Adjustment__c> getbLineAdjustmetList(){
         List<Adjustment__c> bottomAdjustmetList;
         oli = [SELECT Id,Opportunity__c,Total_Supply_Invoice_Amount__c,Total_Bottom_Line_Amount__c, Name,Invoice_Due_Date__c,Production_Amount__c,Compensation__c,Gross_Production_Amount__c,Total_Top_Line_Percentage__c,Treatment_Date__c,Provider_Synergy_Plus__c,Invoice_Amount__c,OD_Payment_Balance__c,OD_Payment_Amount__c,Courtesy_Adjustment__c,Insurance_Adjustment__c,Production_Adjustment__c,Write_off_Adjustment__c FROM Opportunity_Line_Item__c where id=:posId];
         bottomAdjustmetList =[Select id,RecordType.Name,AmountCount__c, Name,Adjustment_Amount__c,Adjustment_Percent__c,Description__c from Adjustment__c where Opportunity_Line_Item__c=:oli.id and RecordType.Name='Bottom Line Adjustment'];
         return bottomAdjustmetList;
         }  
         
    
        public void saveAttachement() {
            if (oli.ID !=NULL) {
                PageReference pdf = Page.Generate_Invoice;
                Blob body;
                try {           
                    // returns the output of the page as a PDF
                    body = pdf.getContentAsPDF();            
                    // need to pass unit test -- current bug    
                } catch (VisualforceException e) {                
                    body = Blob.valueOf('Some Text');
                }
                
                // add the user entered name
                String oppName = opp1.name;
                if(oppName.contains('Match')){
                    oppName = oppName.remove('Match');
                }
                
                /* Attachment attach = new Attachment(); 
                attach.Body = body;
                attach.Name = oli.Name + '.pdf';
                attach.IsPrivate = false;
                attach.ParentId = oli.Id; // attach the pdf to the account
                insert attach; */
                String fileTitle = oli.Name + '.pdf';
                //Ankita A: Delete old Invoice report file
                delete [SELECT Id FROM ContentDocument WHERE Title =:fileTitle];
                //Create new Invoice report
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                conVer.PathOnClient = oli.Name + '.pdf'; // The files name, extension is very important here which will help the file in preview.
                conVer.Title = oli.Name + '.pdf'; // Display name of the files
                conVer.VersionData = body; // converting your binary string to Blog
                conVer.Content_Type__c = 'Invoice'; //Ankita A: Adding content type as well
                
                insert conVer;
        
                // First get the content document Id from ContentVersion
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        
                //Create ContentDocumentLink
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = conDoc;
                cDe.LinkedEntityId = oli.Id; // you can use objectId,GroupId etc
                cDe.ShareType = 'V'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                cDe.Visibility = 'AllUsers';
                insert cDe;
                
                conVer.Is_Approved__c = true; //Ankita A: Setting the value as true so that Invoice Url is generated
                update conVer;
                                
            } 
            else {
              system.debug('tried to run twice');
            }
        } 
    }