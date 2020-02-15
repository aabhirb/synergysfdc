/**
 * Created by abidap on 1/3/19.
 */
({
    doInit : function( component , event , helper ){

        helper.getMatchesAction(component, event, helper );
        helper.getContactDetails(component, event, helper );
        var columnLst = component.get('v.columns');
        columnLst.forEach(function(element){
            if(element.label.includes('Name')){
                component.set('v.filterByAttr',element.label);
            }
        });
        helper.setOperatorType(component, event,helper);
    },
    handleRowSelection : function( component, event, helper){
        console.log('On row selection');
        helper.populateSelectedItems(component, event, helper);
    },
    handleCommonBtnClick : function ( component , event , helper ){

        helper.processNextAction( component , event , helper );
    },
    handleRowAction : function( component , event , helper ){
        console.log('in handleRowSelection');
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'show_details':
                helper.onShowDetails( component , event , helper );
                break;
            case 'nextactionGP':
                helper.onNextAction( component , event , helper , 'nextactionGP' );
                break;
            case 'nextactionSP':
                helper.onNextAction( component , event , helper , 'nextactionSP' );
                break;
            case 'viewMatch':
                helper.onShowDetails( component , event , helper  );
                break;
            case 'queueMatch':
                helper.enQueueMatch( component , event , helper  );
                break;
            //Name: Albina
            //Date: 2/8/2020
            //Description: added the fourth option 'prospect'   
            case 'prospect':           
                helper.enProspect(component, event, helper);
                break;


        }
    },
    handleRecalculateAction : function( component , event , helper ){
        helper.recalculateProspectMatches( component , event , helper );
    },
    onChangeOfPicklist : function( component, event, helper ){
        console.log('inside onChangeOfPicklist');
        helper.setOperatorType(component, event,helper);
    },
    onClickOfApply : function(component,event,helper){
        debugger;
        helper.filterResults(component,event.helper);
    },
    onClickOfClear : function(component,event,helper){
        component.set('v.filteredData',component.get('v.data'));
    },
    handleChange : function(component, event, helper){
        //alert(event.getParam('value'));
        //alert(event.getSource().get("v.name"));
        debugger;
        var eventSource = event.getSource().get("v.name");
        helper.processFilterCheckBoxes(component, event, helper, eventSource );


     }

})