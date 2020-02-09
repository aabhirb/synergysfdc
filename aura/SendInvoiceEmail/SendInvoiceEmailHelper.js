/**
 * Created by abhishek on 2019-09-19.
 */

({
    sendEmail : function (component, event, helper) {
        this.validateMandatoryDocuments(component, event, helper);
    },
    validateMandatoryDocuments : function (component, event, helper) {
        var childCmp = component.find('LightningUtil-SendInvoiceEmail');
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.generateEmailContent");
        action.setParams({ invoiceId : component.get('v.recordId')});
        var dataPromise = childCmp.invokeServerAction( action , 'action' );

        dataPromise.then($A.getCallback(function (data) {
            var response = JSON.parse(data);
            if(response.status === 'SUCCESS'){
                var actionAPI = component.find("quickActionAPI");
                                
                var args = {actionName: "Opportunity_Line_Item__c.Email",
                               targetFields:{
                                   ToAddress: {value: response.toAddress},
                                   HtmlBody: {value: response.emailContent, insertType: "cursor"},
                                   Subject: {value: response.subject, insertType: "cursor"}
                               }
                           };

                actionAPI.setActionFieldValues(args).then(function(result){
                    
                }).catch(function(e){
                    console.log(JSON.stringify(e));
                    console.error(e.errors);
                });
                //Refresh the Invoice fields
                $A.get('e.force:refreshView').fire();
				childCmp.fireToastEventAction( 'success' , 'Email content populated' );
				//Refresh the record page                
            } else {
                childCmp.fireToastEventAction( 'warning' , response.status);                
            }

            component.find("overlayLibModal").notifyClose();

        })).catch(function(error){
            console.log('Error =>',error);
            childCmp.fireToastEventAction( 'error' , (error) );
            component.find("overlayLibModal").notifyClose();
        });
    }

});