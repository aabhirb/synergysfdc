/**
 * Created by abidap on 1/20/19.
 */
({
    doInit : function (component , event , helper) {
        helper.loadDefaultLead( component , event , helper );
    },
    onNextAction : function ( component , event , helper ){
        component.set('v.activeSection','personal-information');
    },
    onChangeOfLeadSource : function( component , event , helper){
         console.log('in onChangeOfLeadSource', event.getParam('value'));

         var leadSourceValue = event.getParam('value');
          if(leadSourceValue == 'Other'){
              component.set('v.showOtherleadSource',true);
          }else{
              component.set('v.showOtherleadSource',false);
          }
    },
    onChangeOfDualSpecialty : function( component , event , helper ){
       var dualSpecialty = event.getParam('checked');
       console.log('dualSpecialty =>',dualSpecialty);
       if(dualSpecialty){
           component.set('v.showDualSpecialtySelectList',true);
       }else{
           component.set('v.showDualSpecialtySelectList',false);
       }
    },
    onChangeOfLanguageSpoken : function ( component , event , helper ){
         var languageValue = event.getParam('value');
          if(languageValue == 'Other'){
              component.set('v.showOtherlanguage',true);
          }else{
              component.set('v.showOtherlanguage',false);
          }
    },
    handleComponentEvent : function( component , event , helper ){
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
        var nonCompeteAddressVar;

        debugger;
        if(addressTypeJS == 'Practice Address'){
            component.find('practice-address').set('v.value',address);
            var practiseAddress = new Object();
            practiseAddress.addressType = 'Practice Address';
            practiseAddress.fullAddress = address;
            addressLstSaved.push(practiseAddress);
        }else if(addressTypeJS == 'Home Address'){
            homeAddressVar = new Object();
            homeAddressVar.addressType = 'Home Address';
            homeAddressVar.latVal  = lat;
            homeAddressVar.longVal = long;
        }else if(addressTypeJS == 'Entity Address'){
            entityAddressVar = new Object();
            homeAddressVar.addressType = 'Entity Address';
        }else if(addressTypeJS == 'Non Compete Address'){
            nonCompeteAddressVar = new Object();
            nonCompeteAddressVar.addressType = 'Non Compete Address';
            nonCompeteAddressVar.fullAddress = address;
            addressLstSaved.push(practiseAddress);
        }

        if(addressList != undefined){
            var zipstateList;

            if(addressList[2])
                zipstateList = addressList[2].split(" ");

            if(addressList[0]){
                if(addressTypeJS == 'Home Address'){
                    homeAddressVar.street = addressList[0].toUpperCase();

                }else if(addressTypeJS == 'Entity Address'){

                    entityAddressVar.street = addressList[0].toUpperCase();
                }
            }


            if(addressList[1]){
                if(addressTypeJS == 'Home Address'){

                    homeAddressVar.city = addressList[1].toUpperCase();
                }else if(addressTypeJS == 'Entity Address'){
                    entityAddressVar.city = addressList[1].toUpperCase();
                }
            }


            if(zipstateList != undefined){

                if(zipstateList[1]){
                     if(addressTypeJS == 'Home Address'){
                        homeAddressVar.state = zipstateList[1].toUpperCase();
                    }else if(addressTypeJS == 'Entity Address'){
                        entityAddressVar.state = zipstateList[1].toUpperCase();
                    }
                }


                if(zipstateList[2]){
                   if(addressTypeJS == 'Home Address'){
                       homeAddressVar.zip = zipstateList[2].toUpperCase();
                   }else if(addressTypeJS == 'Entity Address'){
                       entityAddressVar.zip = zipstateList[2].toUpperCase();
                   }
                }

            }

            if(!$A.util.isUndefinedOrNull(homeAddressVar)){
                addressLstSaved.push(homeAddressVar);
            }else if(!$A.util.isUndefinedOrNull(entityAddressVar)){
                addressLstSaved.push(entityAddressVar);
            }

            console.log('addressLstSaved =>',JSON.stringify(addressLstSaved));
            if(!$A.util.isUndefinedOrNull(addressLstSaved))
                component.set('v.addressListCaptured',addressLstSaved);

            if(!$A.util.isUndefinedOrNull(homeAddressVar)){
                component.set('v.homeAddressCaptured',homeAddressVar);
            }
        }

    },
    onNextActionOfPersonalSection : function( component , event , helper ){
        component.set('v.activeSection','entity-information');
    },
    onChangeOfEntitySelection : function( component , event , helper ){
       var entitySelection = event.getParam('checked');
       console.log('entitySelection =>',entitySelection);
       if(entitySelection){
           component.set('v.showEntitySelection',true);
       }else{
           component.set('v.showEntitySelection',false);
       }
    },onChangeOfPracticeSelection : function( component , event , helper ){
        var practiceSelection = event.getParam('checked');
        console.log('practiceSelection =>',practiceSelection);
        if(practiceSelection){
            component.set('v.showPracticeSelection',true);
        }else{
            component.set('v.showPracticeSelection',false);
        }
     },
     onChangeOfNonCompeteSelection : function( component , event , helper ){
          var NonCompeteSelection = event.getParam('checked');
          console.log('NonCompeteSelection =>',NonCompeteSelection);
          if(NonCompeteSelection){
              component.set('v.showNonCompeteSelection',true);
          }else{
              component.set('v.showNonCompeteSelection',false);
          }
     },
     onChangeOfResidentSelection : function( component , event , helper ){
         var residentSelection = event.getParam('checked');
         console.log('residentSelection =>',residentSelection);
         if(residentSelection){
             component.set('v.showResidentSelection',true);
         }else{
             component.set('v.showResidentSelection',false);
         }
     },
     onChangeOfSuspensionSelection : function ( component , event , helper ){
         var suspensionSelection = event.getParam('checked');
          console.log('suspensionSelection =>',suspensionSelection);
          if(suspensionSelection){
              component.set('v.showSuspensionSelection',true);
          }else{
              component.set('v.showSuspensionSelection',false);
          }
     },
     onNextActionOfProfessionalSection : function ( component , event , helper ){
         component.set('v.activeSection','surgery-information');
     },onChangeOfTravelingEquipment  : function ( component , event , helper ){
         var travelingEquipmentSelection = event.getParam('checked');
          console.log('travelingEquipmentSelection =>',travelingEquipmentSelection);
          if(travelingEquipmentSelection){
              component.set('v.travelingEquipmentSelection',true);
          }else{
              component.set('v.travelingEquipmentSelection',false);
          }
     },onChangeOfAssistance : function( component , event , helper ){
          var assistanceSelection = event.getParam('checked');
          console.log('assistanceSelection =>',assistanceSelection);
          if(assistanceSelection){
               component.set('v.assistanceSelection',true);
          }else{
               component.set('v.assistanceSelection',false);
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
         debugger;

        var childCmp = component.find('LightningUtil-SPCreateComponent');
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
     handleOnSubmit : function(component, event, helper) {
         event.preventDefault();
         var fields = event.getParam("fields");
         //fields["Name"] = 'testest lkdlkdkld lkd';
         component.find("recordViewForm").submit(fields);
     },
     onNextActionOfSurgerySection : function( component , event , helper ){
         component.set('v.activeSection','group-information');
     },
      onNextActionOfAdvancedGPSection : function( component , event , helper ){
           component.set('v.activeSection','group-information');
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
    onSubmit : function( component , event , helper ){
        debugger;
        component.set('v.isButtonClicked',true);
        /*
         { key : 'mobilePhone'   , label : 'Mobile Phone' , section : 'General Information' } ,
                                           { key : 'leadSource'   , label : 'Lead Source' , section : 'General Information' } ,
                                           { key : 'company'       , label : 'Practice Information / Company' , section : 'Practice Information' } ,
                                           { key : 'leadCreditBy'  , label : 'Lead Created By' , section : 'Interview Information' } ,
                                           { key : 'leadEnteredBy' , label : 'Lead Entered By' , section : 'Interview Information' } ,
                                           { key : 'specialtyPrimary' , label : 'Specialty - Primary' , section : 'General Information' },
                                           { key : 'distanceToTravel' , label : 'Distance SP willing to travel (miles)' , section : 'Contact Information' }
                                           */

        var fieldLstToValidate = [
                                   { key : 'firstName'     , label : 'First Name' , section : 'General Information' } ,
                                   { key : 'lastName'      , label : 'Last Name'  , section : 'General Information' } ,
                                   { key : 'email'         , label : 'Email'  , section : 'General Information' }

                                 ];

        for(var ind = 0 ; ind < fieldLstToValidate.length ; ind++){
            if(!$A.util.isUndefinedOrNull( (fieldLstToValidate[ind]).key )){ 

                console.log('1 =>',$A.util.isUndefinedOrNull( component.find( fieldLstToValidate[ind].key ).get("v.value") ));
                console.log('2 =>',component.find( fieldLstToValidate[ind].key ).get("v.value") == '' );
                console.log('3 =>',$A.util.isUndefinedOrNull( component.get('v.homeAddressCaptured') ));
                // || $A.util.isUndefinedOrNull( component.get('v.homeAddressCaptured')
                if( $A.util.isUndefinedOrNull( component.find( fieldLstToValidate[ind].key ).get("v.value") ) || component.find( fieldLstToValidate[ind].key ).get("v.value") == '' ){
                    console.log('Error =>',("Required Fields Missing !! Please fill "+fieldLstToValidate[ind].label+" in "+fieldLstToValidate[ind].section+" section."));

                    //if( !$A.util.isUndefinedOrNull( component.get('v.homeAddressCaptured') )){
                         component.set('v.errorMessage',("Required Fields Missing !! Please fill "+fieldLstToValidate[ind].label+" in "+fieldLstToValidate[ind].section+" section."));
                         component.set('v.isButtonClicked',false);
                    /*}else{
                        component.set('v.errorMessage',("Required Fields Missing !! Please fill  Address in Contact Information section."));
                        component.set('v.isButtonClicked',false);
                    }*/
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
        component.set('v.errorMessage','');
        component.find("recordViewForm").submit();
    },
    onSpecialistSelection : function ( component , event , helper ){
           var languageValue = event.getParam('value');
            if(languageValue.includes('Advanced')){
                component.set('v.showGPType',true);
            }else{
                component.set('v.showGPType',false);
            }
    },
    onChangeOfSynergyCE : function( component, event , helper ){
        var isSynergyCE = event.getParam('checked');
        if(isSynergyCE){
              component.set('v.isSynergyCE',true);
        }else{
              component.set('v.isSynergyCE',false);
        }
    },
    onChangeOfSynergyFormulary : function( component, event , helper ){
        var isSynergyFormulary = event.getParam('checked');
        if(isSynergyFormulary){
              component.set('v.isSynergyFormulary',true);
        }else{
              component.set('v.isSynergyFormulary',false);
        }
    }

})