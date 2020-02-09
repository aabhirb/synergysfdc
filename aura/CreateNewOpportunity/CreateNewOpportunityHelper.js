({
	getRecordTypeId : function(component, event, helper) {
		var action = component.get("c.getTraditionalRecordTypeId");
        // Create a callback
        action.setCallback(this, function(response){
			var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.recordtypeId", response.getReturnValue());
            } else if(state === "INCOMPLETE"){
                //do something
            }
		});
    	$A.enqueueAction(action);
	},
    
	getFieldsToShow : function(component, event, helper) {
		var action = component.get("c.getOpptFields");
        // Create a callback
        action.setCallback(this, function(response){
			var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.fields", response.getReturnValue());
            }
        });
		$A.enqueueAction(action);
	},    
   
})