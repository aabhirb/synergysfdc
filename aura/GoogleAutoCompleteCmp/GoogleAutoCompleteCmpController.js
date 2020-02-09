/**
 * Created by Sonal_Chaudhary on 9/22/2017.
 */
({
    keyPressController: function (component, event, helper) {

        var searchKey = component.get("v.searchKey");
        console.log('got the search key ',searchKey);
        if(searchKey.length > 5)
        {
            helper.openListbox(component, searchKey);
            helper.displayOptionsLocation(component, searchKey);
        }

    },

    selectOption: function (component, event, helper) {
        var selectedItem = event.currentTarget.dataset.record;
        console.log('Selected Address Item ==> '+selectedItem);

        var selectedPlaceId = event.currentTarget.dataset.value;
        console.log('checking ===> ',selectedPlaceId);
        //calling the details API.
        helper.displayPlaceDetails(component,selectedPlaceId);


        component.set("v.selectedOption", selectedItem);

        var searchLookup = component.find("searchLookup");
        $A.util.removeClass(searchLookup, 'slds-is-open');

        var iconDirection = component.find("iconDirection");
        $A.util.removeClass(iconDirection, 'slds-input-has-icon_left');
        $A.util.addClass(iconDirection, 'slds-input-has-icon_right');

        component.set("v.searchKey", selectedItem);


    },

    clear: function (component, event, helper) {
        helper.clearComponentConfig(component);
    }

})