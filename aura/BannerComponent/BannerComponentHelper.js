/**
 * Created by abhishekbidap on 9/1/19.
 */

({
    retrieveData : function( component, event, helper ){
        console.log('retrieveData');

        var childCmp = component.find('LightningUtil-BannerComponent');
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.getBannerFields");
        var recordId = component.get('v.recordId');


        action.setParams({
                            sobjectId  : recordId

                         });


        var dataPromise = childCmp.invokeServerAction( action , 'action' );

        dataPromise.then($A.getCallback(function (data) {
            console.log('data =>',data);
            component.set('v.instance',data);
        })).catch(function(error){

           console.log('Error =>',error);
           childCmp.fireToastEventAction( 'error' , ("Error while opening the related records !"+error) );

        });
    },
    toggleData : function( component, event, helper, fieldType ){

        var childCmp = component.find('LightningUtil-BannerComponent');
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.setBannerFields");
        var recordId = component.get('v.recordId');


        action.setParams({
                            sobjectId  : recordId,
                            fieldTypeStr : fieldType
                         });


        var dataPromise = childCmp.invokeServerAction( action , 'action' );

        dataPromise.then($A.getCallback(function (data) {
           helper.retrieveData( component, event, helper );
        })).catch(function(error){

           console.log('Error =>',error);
           childCmp.fireToastEventAction( 'error' , ("Error while opening the related records !"+error) );

        });
    }
});