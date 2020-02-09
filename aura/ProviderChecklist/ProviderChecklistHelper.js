({
	putCheckboxWrapper : function(component, event, helper) {
		var action = component.get("c.getCheckboxWrapper");
        action.setParams({
            recId : component.get("v.recordId")
        });
        // Create a callback
        action.setCallback(this, function(response){
			var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.checkboxWrapper", response.getReturnValue());
            } else if(state === "INCOMPLETE"){
                //do something
            }
		});
    	$A.enqueueAction(action);
	},
    
    showModal : function(component, event, helper){
        var wrapper = JSON.parse(JSON.stringify(event.getSource().get('v.value')));
        //parse the article object
        var modalBody;
        var modalFooter;
        $A.createComponents([
            ["c:ChecklistModalContent",{"wrapperObject": wrapper, "recId" : component.get("v.recordId")}],
        	["c:ChecklistFooterContent",{"wrapperObject": wrapper,"recId" : component.get("v.recordId")}]
        ],function(components, status) {
                if (status === "SUCCESS") {
                    modalBody = components[0];
            		modalFooter = components[1];
                    component.find("overlayLib").showCustomModal({
                        header: "Confirmation",
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: true,
                        cssClass: "mymodal"
                    })
                }
            });
    }
})