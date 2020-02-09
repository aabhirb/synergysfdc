/**
 * Created by abidap on 1/20/19.
 */
({
    loadDefaultLead : function ( component , event , helper ){
        var containerLead = component.get('v.containerLead');
        containerLead['RecordTypeId'] = component.get('v.recordTypeIdAttr');
    }
})