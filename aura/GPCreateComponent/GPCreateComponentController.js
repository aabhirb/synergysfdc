/**
 * Created by abidap on 1/21/19.
 */
({
    onChangeOfLeadSource : function( component , event , helper ){
          console.log('in onChangeOfLeadSource', event.getParam('value'));

         var leadSourceValue = event.getParam('value');
          if(leadSourceValue == 'Other'){
              component.set('v.showOtherleadSource',true);
          }else{
              component.set('v.showOtherleadSource',false);
          }
    },
    onChangeOfNeedOM : function( component , event , helper ){
        console.log('in onChangeOfLeadSource', event.getParam('checked'));

         var isOMNeeded = event.getParam('checked');
          if(isOMNeeded){
              component.set('v.isOMNeeded',true);
          }else{
              component.set('v.isOMNeeded',false);
          }
    },
    onNextAction : function( component , event , helper ){
        component.set('v.activeSection' , 'practice-information' );
    },
    onChangeOfLanguageSpoken : function ( component , event , helper ){
         var languageValue = event.getParam('value');
          if(languageValue.includes('Other')){
              component.set('v.showOtherlanguage',true);
          }else{
              component.set('v.showOtherlanguage',false);
          }
    },
    onSpecialistSelection : function ( component , event , helper ){
           var languageValue = event.getParam('value');
            if(languageValue.includes('Advanced')){
                component.set('v.showGPType',true);
            }else{
                component.set('v.showGPType',false);
            }
     },
    onNextActionOfPracticeInformation : function( component , event , helper ){
        component.set('v.activeSection' , 'additional-information' );
    },
    onNextActionOfAdditionalInformation : function( component , event , helper ){
      component.set('v.activeSection' , 'specialty-information' );
    },
    onNextActionOfSpecialtyInformation : function( component , event , helper ){
        component.set('v.activeSection' , 'group-information' );
    },
    onNextActionOfGroupSelection : function( component , event , helper ){
        component.set('v.activeSection' , 'interview-information' );
    },
    onChangeOfGroupSelection : function( component , event , helper ){

        var isGroupNeeded = event.getParam('checked');
        if(isGroupNeeded){
              component.set('v.isGroupAffiliated',true);
        }else{
              component.set('v.isGroupAffiliated',false);
        }
    },
    handleError : function( component, event, helper ){
       var error = event.getParam("error");
       console.log('Main Error : ',JSON.stringify(error)); // main error message

    },
    handleSuccess : function( component, event , helper ){
       var record = event.getParam("response");
       var toastEvent = $A.get("e.force:showToast");
       toastEvent.setParams({
           type:'success',
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

       var childCmp = component.find('LightningUtil-GPCreateComponent');
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

    },
    handleComponentEvent : function( component , event , helper ){
        debugger;
        var address =  event.getParam("address");
        var lat =  event.getParam("lat");
        var long =  event.getParam("long");
        var addressTypeJS = event.getParam("addressType");
        console.log('Got the address Event ',address+' '+lat+' '+long);
        var addressList = address.split(",");
        component.set('v.selectedHomeAddress',address);
        var addressLstSaved = component.get('v.addressListCaptured');

        if($A.util.isUndefinedOrNull(addressLstSaved)){
                    addressLstSaved = [];
                }
        var homeAddressVar ;
        var entityAddressVar;

        if(addressTypeJS == 'Practice Address'){
            homeAddressVar = new Object();
            homeAddressVar.addressType = 'Home Address';
            homeAddressVar.latVal  = lat;
            homeAddressVar.longVal = long;
        }

        if(addressList != undefined){
            var zipstateList;

            if(addressList[2])
                zipstateList = addressList[2].split(" ");

            if(addressList[0]){
                if(addressTypeJS == 'Practice Address'){
                    homeAddressVar.street = addressList[0].toUpperCase();
                }
            }


            if(addressList[1]){
                if(addressTypeJS == 'Practice Address'){
                    homeAddressVar.city = addressList[1].toUpperCase();
                }
            }


            if(zipstateList != undefined){

                if(zipstateList[1]){
                     if(addressTypeJS == 'Practice Address'){
                         homeAddressVar.state = zipstateList[1].toUpperCase();
                    }
                }


                if(zipstateList[2]){
                   if(addressTypeJS == 'Practice Address'){
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

    },
    onSubmit : function( component , event , helper ){
        debugger;
        component.set('v.isButtonClicked',true);
        //{ key : 'mobilePhone'   , label : 'Mobile Phone' , section : 'General Information' } ,
        /*
        { key : 'specialties-id', label : 'Type of Specialists GP want' , section : 'Specialty Information' } ,
       { key : 'leadCreditBy'  , label : 'Lead Created By' , section : 'Interview Information' } ,
       { key : 'leadEnteredBy' , label : 'Lead Entered By' , section : 'Interview Information' }
        */
        var fieldLstToValidate = [
                                   { key : 'firstName'     , label : 'First Name' , section : 'General Information' } ,
                                   { key : 'lastName'      , label : 'Last Name'  , section : 'General Information' } ,
                                   { key : 'email'         , label : 'Email'  , section : 'General Information' } ,
                                   { key : 'company'       , label : 'Practice Information / Company' , section : 'Practice Information' } , 
						           { key : 'leadsource'    , label : 'LeadSource' , section : 'Practice Information' } 
                                 ];

        for(var ind = 0 ; ind < fieldLstToValidate.length ; ind++){
            if(!$A.util.isUndefinedOrNull( (fieldLstToValidate[ind]).key )){
            
                if( $A.util.isUndefinedOrNull( component.find( fieldLstToValidate[ind].key ).get("v.value") ) || component.find( fieldLstToValidate[ind].key ).get("v.value") == '' || $A.util.isUndefinedOrNull( component.get('v.addressListCaptured') ) ){
                    console.log('Error =>',("Required Fields Missing !! Please fill "+fieldLstToValidate[ind].label+" in "+fieldLstToValidate[ind].section+" section."));

                    if( !$A.util.isUndefinedOrNull( component.get('v.addressListCaptured') )){
                         component.set('v.errorMessage',("Required Fields Missing !! Please fill "+fieldLstToValidate[ind].label+" in "+fieldLstToValidate[ind].section+" section."));
                         component.set('v.isButtonClicked',false);
                    }else{
                        component.set('v.errorMessage',("Required Fields Missing !! Please fill Practice Address in Practice Information section."));
                        component.set('v.isButtonClicked',false);
                    }
                    //$A.util.removeClass( component.find('errorDiv') , 'slds-hide');
                    document.getElementById('errorDiv').style.display = 'block';

                    var scrollOptions = {
                                left: 0,
                                top: 0,
                                behavior: 'smooth'
                            }
                    window.scrollTo(scrollOptions);


                    return;
                }
            }
        }

        document.getElementById('errorDiv').style.display = 'none';
        component.find("recordViewForm").submit();
    }
})