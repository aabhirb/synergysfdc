/**
 * Created by abidap on 1/20/19.
 */
({
    createComponent : function( component , event , helper ){

        var modalBody;
        var recordTypeIdJS = component.get("v.pageReference").state.recordTypeId;
        var componentToCreateVar = 'c:SPCreateComponent';
        var headerLabelJS = '';
		debugger;
        if( recordTypeIdJS == '01246000000RxZMAA0' ){ // GP

            componentToCreateVar = 'c:GPCreateComponent';
            headerLabelJS        = 'New Practice Lead';
            
        }else if( recordTypeIdJS == '01246000000RxZNAA0' ){
            componentToCreateVar = 'c:SPCreateComponent';
            headerLabelJS        = 'New Provider Lead';
            
        }else if( recordTypeIdJS == '01246000000y62AAAQ'){ // SP
			
            componentToCreateVar = 'c:VCCreateComponent';
            headerLabelJS        = 'New Vendor Lead';
        }

        $A.createComponent(componentToCreateVar, {
            recordTypeIdAttr : recordTypeIdJS
        },
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       header: headerLabelJS,
                       body: modalBody,
                       showCloseButton: true,
                       cssClass: "customClass",
                       closeCallback: function() {
                          /* var pageReference = {
                                       type: 'standard__objectPage',
                                       attributes: {
                                           objectApiName: 'Lead',
                                           actionName: 'list'
                                       },
                                       state: {
                                           filterName: "RecentlyViewedLeads"
                                       }
                                   };

                            var navService = component.find("navService");
                            // Uses the pageReference definition in the init handler
                            var pageReference = pageReference;
                            event.preventDefault();
                            navService.navigate(pageReference);*/
                       }
                   })
               }
           });
    }
})