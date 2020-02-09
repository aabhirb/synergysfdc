({
    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        component.find("overlayLib").notifyClose();
    },
    
    handleConfirm : function(component, event, helper) {
        helper.updateContactObj(component, event, helper);
        
    }
})