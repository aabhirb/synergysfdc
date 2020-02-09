/**
 * Created by abidap on 2/19/19.
 */
({
    removeFromArray : function ( arrayVar , elementToSearch ){
          var newArrayVar = [] ;
          for( var ind = 0; ind < arrayVar.length ; ind ++ ){
              if( arrayVar [ind] != elementToSearch ){
                  newArrayVar.push( arrayVar [ind] );
              }
          }

          return newArrayVar;
    },
    initiateEmailInvocation : function( component, event , helper ){
        debugger;
        var childCmp = component.find('LightningUtil-SendIntakeEmail');
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.initiateEmailInvocation");
        var selectedEle ;
        if(component.get('v.selectedOptionLst')){
            selectedEle     = [];
            selectedEle     = component.get('v.selectedOptionLst');
        }else{
            selectedEle     = [];
            selectedEle.push('null');
        }


        var recordId = component.get('v.recordId');
        action.setParams({
                           recordIdString : recordId ,
                           specialtiesSelected : selectedEle.toString()
                          });


        //childCmp.fireToastEventAction( 'success' , "Successfully Converted Lead !" );
        var dataPromise = childCmp.invokeServerAction( action , 'action' );

        dataPromise.then($A.getCallback(function (data) {

           if( $A.util.isUndefinedOrNull(data) ){
               childCmp.fireToastEventAction( 'warning' , "Seems Intake Email is already sent, Intake Email sent can be sent only if Lead is in status \' Initial \' " );
           }else{
             childCmp.fireToastEventAction( 'success' , "Intake Email sent" );
             $A.get('e.force:refreshView').fire();
           }

           component.find("overlayLibModal").notifyClose();

        })).catch(function(error){

           console.log('Error =>',error);
           childCmp.fireToastEventAction( 'error' , ("Error in Lead Conversion!"+error) );

        });

    },
    loadLeadData : function ( component , event , helper ){

        console.log('inside loadLeadData');
        var childCmp = component.find('LightningUtil-SendIntakeEmail');
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.loadLeadData");


        var recordId = component.get('v.recordId');
        action.setParams({
                           leadId : recordId
                          });


        //childCmp.fireToastEventAction( 'success' , "Successfully Converted Lead !" );
        var dataPromise = childCmp.invokeServerAction( action , 'action' );

        dataPromise.then($A.getCallback(function (data) {

           if( !$A.util.isUndefinedOrNull(data) ){
               console.log(' Data RName => ',data.RecordType.Name);
              component.set('v.recordType', data.RecordType.Name);
           }
        })).catch(function(error){

           console.log('Error =>',error);
           childCmp.fireToastEventAction( 'error' , ("Error in Lead Conversion!"+error) );

        });
    }
})