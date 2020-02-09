/**
 * Created by abidap on 12/27/18.
 */
({
    makeServerInvocation : function( component, event, helper ){
        return new Promise(function(resolve, reject){

            // get the action with all params set and controller methods specified
            var args   = event.getParam("arguments");
            var action = args.actionParam;

            // set callback
            action.setCallback(this, function(response) {
                var state = response.getState();
                   console.log('Response', response);
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }else if (state === "INCOMPLETE") {
                    //console.log('Response', response);
                }else if (state === "ERROR") {
                   console.log('Response', response );
                    var responseMessage = '';
                    if( !$A.util.isUndefinedOrNull(response.getError())
                       	&& !$A.util.isUndefinedOrNull(response.getError()[0])
                        &&
                       ( !$A.util.isUndefinedOrNull(response.getError()[0].pageErrors[0].statusCode)
                       		 ||
                         !$A.util.isUndefinedOrNull(response.getError()[0].pageErrors[0].message) ) ){
                       responseMessage = response.getError()[0].pageErrors[0].statusCode + ' ' +response.getError()[0].pageErrors[0].message;
                    }else if( response.getError()[0].message ){
                       responseMessage = response.getError()[0].message;
                    }else{
                        responseMessage = 'Error : Unexpected Error while converting the lead, Contact System Admin.'
                    }

                    reject(responseMessage);
                }
            });

            $A.enqueueAction(action);
        });
    },
    fireToastAction : function( component , event , helper){
        var args       = event.getParam("arguments");
        var typeStr    = args.type;
        var messageStr = args.Message;
        debugger;
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                                           "title": typeStr,
                                           "message": messageStr,
                                           "type":typeStr
                                       });
                   toastEvent.fire();
        }else{
            alert(messageStr);
        }

    },
    navigateToRecord : function( component , event , helper){

         var params = event.getParam('arguments');
         if (params) {
             var recordToNavigateStr  = params.recordToNavigateAttr;
             var sobjectToNavigateStr = params.sobjectToNavigate;
             var navService = component.find("navService");
             console.log('recordToNavigateStr    =>',recordToNavigateStr);
             console.log('sobjectToNavigateStr   =>',(sobjectToNavigateStr));

             var pageReference = {
                                   type: 'standard__recordPage',
                                   attributes: {
                                       objectApiName: sobjectToNavigateStr,
                                       recordId: recordToNavigateStr,
                                       actionName:'view'
                                   },
                                   state : {
                                               retURL : '/lightning/page/chatter'
                                           }
                               };

            // component.set("v.pageReference", pageReference);
             //console.log('PR => ',component.get("v.pageReference"));

            // var pageReference = component.get("v.pageReference");
             event.preventDefault();
             navService.navigate(pageReference); //,true
         }

    }
})