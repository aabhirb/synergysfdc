({
	doInit : function(component, event, helper) {
		
		var action = component.get("c.MarkFinancialDisclosure");
        action.setParams({
            "OpptyId": component.get("v.recordId")
        });
      
        action.setCallback(this, function(response) {
             var state = response.getState();
            if(state === "SUCCESS") {
                console.log('Resp =>',response.getReturnValue());
                if(response.getReturnValue() == 'DONE' ) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Financial Disclosure already sent to practice !",
                        "type":'warning'
                    });
                    toastEvent.fire();	
                    $A.get("e.force:closeQuickAction").fire();
                    
                    setTimeout(function(){ location.reload(); }, 3000);
                }else if(response.getReturnValue() == 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Financial Disclosure sent to practice succesfully.",
                        "type":'success'
                    });
                    toastEvent.fire();	
                    $A.get("e.force:closeQuickAction").fire();
                    
                    setTimeout(function(){ location.reload(); }, 3000);
                }
            

            } else {
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.error(message);
            }
        });
        // Invoke the service
        $A.enqueueAction(action);
	}
})