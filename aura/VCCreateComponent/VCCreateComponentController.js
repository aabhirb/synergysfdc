/**
 * Created by abidap on 2/2/19.
 */
({
    onChangeOfLeadSource : function( component , event , helper){
         console.log('in onChangeOfLeadSource', event.getParam('value'));

         var leadSourceValue = event.getParam('value');
          if(leadSourceValue == 'Other'){
              component.set('v.showOtherleadSource',true);
          }else{
              component.set('v.showOtherleadSource',false);
          }
    },
    onNextAction : function ( component , event , helper ){
        component.set('v.activeSection','company-information');
    },
    onCompanyNextAction : function( component , event , helper ){
        component.set('v.activeSection','additional-information');
    },
    handleComponentEvent : function( component , event , helper ){
        debugger;
        var address =  event.getParam("address");
        var lat =  event.getParam("lat");
        var long =  event.getParam("long");
        var addressTypeJS = event.getParam("addressType");
        console.log('Got the address Event ',address+' '+lat+' '+long);
        var addressList = address.split(",");
        var addressLstSaved = component.get('v.addressListCaptured');

        if($A.util.isUndefinedOrNull(addressLstSaved)){
                    addressLstSaved = [];
                }
        var homeAddressVar ;
        var entityAddressVar;

        if(addressTypeJS == 'Address'){
            homeAddressVar = new Object();
            homeAddressVar.addressType = 'Address';
            homeAddressVar.latVal  = lat;
            homeAddressVar.longVal = long;
        }

        if(addressList != undefined){
            var zipstateList;

            if(addressList[2])
                zipstateList = addressList[2].split(" ");

            if(addressList[0]){
                if(addressTypeJS == 'Address'){
                    homeAddressVar.street = addressList[0].toUpperCase();
                }
            }


            if(addressList[1]){
                if(addressTypeJS == 'Address'){
                    homeAddressVar.city = addressList[1].toUpperCase();
                }
            }


            if(zipstateList != undefined){

                if(zipstateList[1]){
                     if(addressTypeJS == 'Address'){
                         homeAddressVar.state = zipstateList[1].toUpperCase();
                    }
                }


                if(zipstateList[2]){
                   if(addressTypeJS == 'Address'){
                       homeAddressVar.zip = zipstateList[2].toUpperCase();
                   }
                }

            }

        }

        if(!$A.util.isUndefinedOrNull(homeAddressVar)){
            addressLstSaved.push(homeAddressVar);
        }

        console.log('addressLstSaved =>',JSON.stringify(addressLstSaved));
        if(!$A.util.isUndefinedOrNull(addressLstSaved))
            component.set('v.addressListCaptured',addressLstSaved);

    },handleError : function( component, event, helper ){
           var error = event.getParam("error");
           console.log('Main Error : ',JSON.stringify(error)); // main error message

    },
    handleSuccess : function( component, event , helper ){
       var record = event.getParam("response");
       var toastEvent = $A.get("e.force:showToast");
       toastEvent.setParams({
           type:'success',
           mode: 'sticky',
           message: 'This is a required message',
           messageTemplate: 'Record {0} created! See it {1}!',
           messageTemplateData: [
               {
                   url: '/' + record.id,
                   label: record.fields.FirstName.value + ' ' + record.fields.LastName.value
               },
               {
                   url: '/' + record.id,
                   label: 'HERE'
               }
           ]
       });
       toastEvent.fire();

       var childCmp = component.find('LightningUtil-VCCreateComponent');
       var action = component.get("c.updateAddressOnLead");
       action.setParams({ addressListJSON : JSON.stringify(component.get('v.addressListCaptured')) , leadId : record.id });

       var dataPromise = childCmp.invokeServerAction( action , 'action' );

       dataPromise.then($A.getCallback(function (data) {
          console.log('Proccessed update');

       })).catch(function(error){

          console.log('Error =>',error);
          childCmp.fireToastEventAction( 'error' , ("Error in Lead Conversion!"+error) );

       });

      component.find("overlayLibModal").notifyClose();

    }

})