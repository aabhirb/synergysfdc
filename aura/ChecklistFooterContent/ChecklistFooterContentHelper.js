({
	updateContactObj : function(component, event, helper) {
		//Update the value of the checkbox
        var value = component.get("v.wrapperObject").value;
        var action = component.get("c.updateCheckbox");
        action.setParams({
            "recordId" : component.get("v.recId"),
            "fieldApiName" : component.get("v.wrapperObject").fieldApiName,
            "checkboxValue" : !value
        });
        action.setCallback(this, function(response){
			var state = response.getState();
            if(state === "SUCCESS"){
                //Navigate to the record page
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recId"),
                    "slideDevName": "related"
                });
                
                navEvt.fire();
                
            } else if(state === "INCOMPLETE"){
                //do something
            }
		});
    	$A.enqueueAction(action);
	}
})