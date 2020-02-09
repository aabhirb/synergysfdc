/**
 * Created by abhishekbidap on 9/1/19.
 */

({
    doInit : function ( component, event, helper ) {
        helper.retrieveData( component, event, helper );
    },
    handleEmailToggle : function( component, event, helper ) {
        helper.toggleData( component, event, helper, 'HasOptedOutOfEmail' );
    },
    handleCallToggle : function( component, event, helper ) {
        helper.toggleData( component, event, helper, 'DoNotCall' );
    }
});