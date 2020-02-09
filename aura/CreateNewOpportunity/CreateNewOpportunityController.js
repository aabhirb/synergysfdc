({
    doInit : function(component, event, helper){
        helper.getRecordTypeId(component, event, helper);
        helper.getFieldsToShow(component, event, helper);
    },
    
	 
    handleError : function( component, event, helper ){
         var error = event.getParam("error");
         console.log('Main Error : ',JSON.stringify(error)); // main error message

     },
    
    handleSuccess: function(component, event, helper) {
        var opptRecord = event.getParams().response;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": opptRecord.id,
            "slideDevName": "related"
        });
        
        navEvt.fire();
    }  
    
});