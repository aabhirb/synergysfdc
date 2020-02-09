/**
 * Created by abidap on 12/27/18.
 */
({
    convertLeadAction : function( component , event, helper ){

        var childCmp = component.find('LightningUtil-CustomLeadConvertComp');
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.convertLead");
        action.setParams({ leadId : component.get('v.recordId')});
        console.log('Parent action =>',action);
        //childCmp.fireToastEventAction( 'success' , "Successfully Converted Lead !" );
        var dataPromise = childCmp.invokeServerAction( action , 'action' );

        dataPromise.then($A.getCallback(function (data) {
           console.log('Got results ',data);
           helper.processResults( component , event , data );

        })).catch(function(error){
            debugger;
           console.log('Error =>',error);

           component.set('v.errorMessage',error);
            $A.util.addClass(component.find('loadingDiv'),'slds-hide');
           childCmp.fireToastEventAction( 'error' , ("Error in Lead Conversion!"+error) );
            component.find("overlayLibModal").notifyClose();
        });
    },
    processResults : function( component , event , result ){
        var childCmp = component.find('LightningUtil-CustomLeadConvertComp');
        if(!$A.util.isUndefinedOrNull(result)){
            if($A.util.isUndefinedOrNull(result.validationErrorString)){
                component.set('v.accountAttr',result.accountObject);
                component.set('v.opportunityAttr',result.opportunityObject);
                component.set('v.leadAttr',result.leadObject);
                component.set('v.contactAttr',result.contactObject);
                childCmp.fireToastEventAction( 'success' , "Successfully Converted Lead !" );
            }else{
                component.set('v.errorMessage',result.validationErrorString);
                childCmp.fireToastEventAction( 'error' , component.get('v.errorMessage') );
                component.find("overlayLibModal").notifyClose();
            }

        }
        $A.util.addClass(component.find('loadingDiv'),'slds-hide');
    },
    redirectToRecordURL : function( component, event, helper ){
        debugger;
        var sobjectName = event.currentTarget.getAttribute('data-sobj');
        var recordId  = event.currentTarget.getAttribute('data-attri');
        
        var childCmp = component.find('LightningUtil-CustomLeadConvertComp');
        childCmp.navigateToRecord( recordId , sobjectName );
    }
})