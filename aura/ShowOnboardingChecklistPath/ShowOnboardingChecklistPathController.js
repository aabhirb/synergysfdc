({
    handleSelect : function (component, event, helper) {
        //set the stepName to component attribute
        var stepName = event.getParam("detail").value;
        component.set("v.stepName", stepName);
        //Enable the update button
        component.set("v.isDisabled", false);
    },

    updatePicklistValue : function(component, event, helper){
        var action = component.get("c.updateOnboardingChecklist");
        action.setParams({ 
            recordId : component.get("v.recordId"),
            picklistValue : component.get("v.stepName")
        });

        // Create a callback that is executed after the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Updated the Onboarding Checklist"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    
})