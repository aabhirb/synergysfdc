({
    displayOptionsLocation: function (component, searchKey) {
        console.log('calling google api');
        var action = component.get("c.getAddressAutoComplete");
        action.setParams({
            "input": searchKey,
            "types": '(regions)'
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('got success for the results');
                var options = JSON.parse(response.getReturnValue());
                var predictions = options.predictions;
                var addresses = [];
                if (predictions.length > 0) {
                    for (var i = 0; i < predictions.length; i++) {
                        addresses.push(
                            {
                                value: predictions[i].place_id,
                                label: predictions[i].description
                            });
                    }
                    console.log(addresses);
                    console.log('address selected',addresses);
                    component.set("v.filteredOptions", addresses);
                } else{
                    console.log('got zero results');
                }
            }
        });
        $A.enqueueAction(action);
    },
    displayPlaceDetails: function (component, searchKey,selectedItem) {
            console.log('calling google place details api');
            var action = component.get("c.getAddressDetails");
            action.setParams({
                "PlaceId": searchKey,
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('got placedetails for the results :');
                    var options = JSON.parse(response.getReturnValue());
                    console.log('Full address details ',options.result);
                    console.log('place details ',options.result.formatted_address);
                    //Fire a component event after setting the address
                            var addresscompEvent = $A.get("e.c:GoogleAutoCompleteCmpEvent");
                            console.log('street Number ==>',options.result.address_components[0].types[0]);
                            var validstNumber = '';
                            if(options.result.address_components[0].types[0]=='street_number')
                            {
                                validstNumber =true;
                            } else{
                                validstNumber =false;
                                component.set("v.searchKey",options.result.formatted_address);
                                var inputCheck = component.find("inputCmp");
                                $A.util.addClass(inputCheck, 'slds-has-error');
                                component.set("v.valstreet",true);
                            }

                            var isRequiredCounty  = false;
                            var isNYState         = false;
                            var isCountyBlockedJS = false;
                            if(!$A.util.isUndefinedOrNull(options.result.address_components)){
                                options.result.address_components.forEach(element => {
                                    if(element){
                                        if(element.types && element.types[0] &&  element.types[0] == 'administrative_area_level_2'){
                                            if(element.long_name && ( element.long_name.includes('Suffolk') || element.long_name.includes('Nassau') ) ){
                                                console.log('County is Nassau or Suffolk ');
                                                isRequiredCounty = true;
                                            }
                                        }

                                        if(element.types && element.types[0] &&  element.types[0] == 'administrative_area_level_1'){
                                            if(element.short_name && element.short_name == 'NY' ){
                                                console.log('State is NY ');
                                                isNYState = true;

                                            }
                                        }
                                    }
                                });
                            }

                            if(isNYState && isRequiredCounty){
                                console.log('*******OK TO BLOCK*******');
                                isCountyBlockedJS = true;
                            }

                            addresscompEvent.setParams({"address" : options.result.formatted_address,"lat" : options.result.geometry.location.lat,"long": options.result.geometry.location.lng,"validstreet": validstNumber, "isCountyBlocked" : isCountyBlockedJS ,"addressType" : component.get('v.searchlabel') });
                            //addresscompEvent.setParams({"address" : component.get("v.selectedOption"),"lat" : options.result.geometry.location.lat,"long": options.result.geometry.location.lng});
                            addresscompEvent.fire();
                            console.log('Fired the selected Address component level event ',options.result.geometry.location.lat);

                }
            });
            $A.enqueueAction(action);
        },
    openListbox: function (component, searchKey) {
        var searchLookup = component.find("searchLookup");

        if (typeof searchKey === 'undefined' || searchKey.length < 5)
        {
            $A.util.addClass(searchLookup, 'slds-combobox-lookup');
            $A.util.removeClass(searchLookup, 'slds-is-open');
            return;
        }

        $A.util.addClass(searchLookup, 'slds-is-open');
        $A.util.removeClass(searchLookup, 'slds-combobox-lookup');
    },

    clearComponentConfig: function (component) {
        var searchLookup = component.find("searchLookup");
        $A.util.addClass(searchLookup, 'slds-combobox-lookup');

        component.set("v.selectedOption", null);
        component.set("v.searchKey", null);

        var iconDirection = component.find("iconDirection");
        $A.util.removeClass(iconDirection, 'slds-input-has-icon_right');
        $A.util.addClass(iconDirection, 'slds-input-has-icon_left');
    },

})