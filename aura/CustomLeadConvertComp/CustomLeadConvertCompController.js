/**
 * Created by abidap on 12/27/18.
 */
({
    doInit : function( component, event, helper ){
        console.log('in doInit');
        helper.convertLeadAction( component, event , helper );
    },
    onclickOfRecord : function( component, event, helper){ 
        helper.redirectToRecordURL(component,event,helper);
    }
})