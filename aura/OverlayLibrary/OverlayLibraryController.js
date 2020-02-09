({
	init : function(component, event, helper) {
        var modalBody;
        var modalFooter;
        $A.createComponent("c:CreateNewOpportunity", {}, function(content, status){
            if (status === "SUCCESS") {
                modalBody = content;
                component.find('overlayLib').showCustomModal({
                    header: "New Traditional Opportunity",
                    body: modalBody,
                    showCloseButton: true,
                    cssClass: "my-modal,my-custom-class,my-other-class",
                    closeCallback: function() {
                        
                    }
                });
            }
        });
    }
                    
})