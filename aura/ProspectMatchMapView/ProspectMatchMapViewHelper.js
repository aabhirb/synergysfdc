/**
 * Created by abidap on 1/3/19.
 */
({
    getMatchesAction : function( component , event , helper ){
        var childCmp = component.find('LightningUtil-ProspectMatchMapView');
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.getProspectMatches");
        var recordId = component.get('v.recordId'); //'0060x000007R4LQAA0'; //
        action.setParams({ opportunityId : recordId });

        //childCmp.fireToastEventAction( 'success' , "Successfully Converted Lead !" );
        var dataPromise = childCmp.invokeServerAction( action , 'action' );

        dataPromise.then($A.getCallback(function (data) {
           console.log('Got results ',JSON.stringify(data));

           helper.processResults( component , event , data );
           //childCmp.fireToastEventAction( 'success' , "Successfully Converted Lead !" );

        })).catch(function(error){

           console.log('Error =>',error);
           childCmp.fireToastEventAction( 'error' , ("Error in Lead Conversion!"+error) );

        });
    },
    getContactDetails : function( component , event , helper ){
        var childCmp = component.find('LightningUtil-ProspectMatchMapView');
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.getContactDetails");
        var recordId = component.get('v.recordId');
        action.setParams({ contactId : recordId });

        //childCmp.fireToastEventAction( 'success' , "Successfully Converted Lead !" );
        var dataPromise = childCmp.invokeServerAction( action , 'action' );

        dataPromise.then($A.getCallback(function (data) {
           console.log('Got results ',JSON.stringify(data));

           if(!$A.util.isUndefinedOrNull( data )){

              console.log('data.RecordType.Name =>',data.RecordType.Name);
              console.log('data.RecordType.Name =>',data.Contact_Status__c);

              if( data.RecordType.Name == 'Provider' && data.Contact_status__c == 'Contract Signed' ){
                  component.set('v.isSPEligibleForMatch',true);
              }
           }

        })).catch(function(error){

           console.log('Error =>',error);
           childCmp.fireToastEventAction( 'error' , ("Error in Lead Conversion!"+error) );

        });
    },
    processResults : function( component , event , result ){
        if(!$A.util.isUndefinedOrNull(result) && result.length != 0){
            console.log('result =>',result);
            var markerArray = [];
            result.forEach(function(element){
                markerArray.push(element.wrapper);
            });
            if(!$A.util.isUndefinedOrNull(markerArray))
                component.set('v.mapMarkers',markerArray);

            component.set('v.wrapperLst',result);
            var objectLst = [];
            var processTypeVal = (result[0].contactType == 'GP') ? 'SP' : 'GP';
            //,  disabled: { fieldName: 'isActive'}
            var actions = [
                             { label: 'Start Match/Opt-in', name: 'nextaction'+processTypeVal  },
                			 { label: 'View Match', name: 'viewMatch'},
                			 { label: 'Queue Match', name: 'queueMatch' }
                          ];


            component.set('v.processTypeAttr',processTypeVal);
            if( result[0].contactType == 'SP' ){
                component.set('v.columns', [
                                        { label: processTypeVal + ' Name' , fieldName: 'nameURL', type: 'url' , typeAttributes: { label: { fieldName: 'name' } , target : '_blank' } , "cellAttributes": { "class": { "fieldName": "showClass" } } },
                    					{ label: processTypeVal + ' Practice Name' , fieldName: 'practiceName', type: 'text', "cellAttributes": { "class": { "fieldName": "showClass" } } },
                                        { label: processTypeVal + ' Type' , fieldName: 'type', type: 'text' , "cellAttributes": { "class": { "fieldName": "showClass" } }},
                                        { label: processTypeVal + ' Specialty' , fieldName: 'specialty', type: 'text' , "cellAttributes": { "class": { "fieldName": "showClass" } }},
                                        /*{ label: processTypeVal + ' Address', fieldName: 'addressURL', type: 'url' , typeAttributes: { label: { fieldName: 'address' } } , "cellAttributes": { "class": { "fieldName": "showClass" } }},*/
                                        { label: processTypeVal + ' Approximate Distance' , fieldName: 'distance', type: 'decimal' , "cellAttributes": { "class": { "fieldName": "showClass" } } },
                                        { label: 'Match Stage', fieldName: 'matchStage', type: 'text' , "cellAttributes": { "class": { "fieldName": "showClass" } }},
                                        { type: 'action', typeAttributes: { rowActions: actions } , fieldId : 'matchId' , "cellAttributes": { "class": { "fieldName": "showClass" } }}
                                    ]);
            }else{

                // Practice Flow
                component.set('v.isPracticeFlow',true);
                component.set('v.columns', [
                                                        { label: processTypeVal + ' Name' , fieldName: 'nameURL', type: 'url' , typeAttributes: { label: { fieldName: 'name' } , target : '_blank' } , "cellAttributes": { "class": { "fieldName": "showClass" } }},
                                                        { label: processTypeVal + ' Status' , fieldName: 'status', type: 'text' , "cellAttributes": { "class": { "fieldName": "showClass" } }},
                                                        { label: processTypeVal + ' Type' , fieldName: 'type', type: 'text' , "cellAttributes": { "class": { "fieldName": "showClass" } }},
                                                        { label: processTypeVal + ' Specialty' , fieldName: 'specialty', type: 'text' , "cellAttributes": { "class": { "fieldName": "showClass" } }},
                                                        /*{ label: processTypeVal + ' Address', fieldName: 'addressURL', type: 'url' , typeAttributes: { label: { fieldName: 'address' } } , "cellAttributes": { "class": { "fieldName": "showClass" } }},*/
                                                        { label: processTypeVal + ' Approximate Distance' , fieldName: 'distance', type: 'decimal' , "cellAttributes": { "class": { "fieldName": "showClass" } }},
                                                        { label: 'Match Stage', fieldName: 'matchStage', type: 'text' , "cellAttributes": { "class": { "fieldName": "showClass" } }},
                                                        { type: 'action', typeAttributes: { rowActions: actions } , fieldId : 'matchId', "cellAttributes": { "class": { "fieldName": "showClass" } }}
                                                    ]);

            }

            //{ label: 'Next Stage', fieldName: 'nextmatchStage', type: 'text' },

            result.forEach(function(element){

                    console.log('stage =>',element.matchStageString);
                var formattedAddress = element.contactAddress.replace(' ','+');
                if( result[0].contactType == 'SP' ){

                    if('Contact' != element.contactStatus  ){


                        objectLst.push({
                                            name                : element.contactNameString  ,
                                            nameURL             : 'https://ascendorthodontics.lightning.force.com/'+element.sobjectIdToNavigate,
                                            address             : element.contactAddress ,
                                            addressURL          : ( 'https://www.google.com/maps/place/'+formattedAddress ),
                                            distance            : ($A.util.isUndefinedOrNull(element.approximateDistance)) ? null : parseFloat(element.approximateDistance).toFixed(2),
                                            matchStage          : element.matchStageString,
                                            matchId             : element.prospectMatchId,
                                            type                : element.objectType,
                                            specialty           : element.specialtyType,
                                            showClass           : (element.isQueued) ?  'fillColorQueued' : 'IgnoreFillColor',
                                            isActive            : true,
											practiceName        : element.practiceName
                                        });
                    }
                }else{
					if( ( 'Contact' != element.contactStatus  ) ){


                    objectLst.push({
                                        name            : element.contactNameString,
                                        nameURL         : 'https://ascendorthodontics.lightning.force.com/'+element.sobjectIdToNavigate,
                                        address			: element.contactAddress ,
                                        addressURL      : ( 'https://www.google.com/maps/place/'+formattedAddress ),
                                        distance        : ($A.util.isUndefinedOrNull(element.approximateDistance)) ? null : parseFloat(element.approximateDistance).toFixed(2),
                                        matchStage      : element.matchStageString,
                                        matchId         : element.prospectMatchId,
                                        type            : element.objectType,
                                        specialty       : element.specialtyType,
                                        status          : element.contactStatus,
                                        showClass       : ( (element.isQueued) ? 'fillColorQueued' :
                                                            ( ( !$A.util.isUndefinedOrNull(element.noOfDaysSPAvailable)
                                                                    && element.noOfDaysSPAvailable == '0 - Not Available' ) ||
                                                                ( !$A.util.isUndefinedOrNull(element.matchStageString) &&  element.matchStageString.includes('Denied')  ) ? 'fillColor' : 'IgnoreFillColor') ),
                                        isActive        : true
                                    });
                    }

                }
                //nextmatchStage  : element.nextMatchStageString,
            });

            component.set('v.data',objectLst);
			component.set('v.filteredData',objectLst);

        }
    },
    populateSelectedItems : function( component , event , helper ){
        var selectedRows = event.getParam('selectedRows');
        var selectedIdLst = [];
        console.log('Selected Rows : ',selectedRows);
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            selectedIdLst.push(selectedRows[i].matchId);
        }

        component.set('v.selectedMatchIdList',selectedIdLst);
    },
    processNextAction : function( component , event , helper ){
        var childCmp = component.find('LightningUtil-ProspectMatchMapView');

        if($A.util.isUndefinedOrNull( component.get('v.selectedMatchIdList')) || component.get('v.selectedMatchIdList').length == 0 ){
            childCmp.fireToastEventAction( 'warning' , ("Please select any items before processing") );
        }else{
            helper.takeNextAction(component , event , helper , component.get('v.selectedMatchIdList') );
        }
    },
    takeNextAction : function ( component , event , helper , dataToUpdate , actionTypeJS ){
        var childCmp = component.find('LightningUtil-ProspectMatchMapView');
        var action   = component.get("c.startMatchProcess");
        action.setParams({
                            prospectMatchIdLst : dataToUpdate ,
                            actionType         : actionTypeJS
                         });

        var dataPromise = childCmp.invokeServerAction( action , 'action' );

        dataPromise.then($A.getCallback(function (data) {
           console.log('Got results ',JSON.stringify(data));

           if(data){
                childCmp.fireToastEventAction( 'success' , "Match process initiated successfully" );
                window.location.reload();
           }


        })).catch(function(error){

           console.log('Error =>',error);
           childCmp.fireToastEventAction( 'error' , ("Error during Update :"+error) );

        });

    },
    onNextAction : function( component , event , helper , actionType ){
        debugger;
        var childCmp = component.find('LightningUtil-ProspectMatchMapView');
        var row = event.getParam('row');
        console.log('ID : ',row.matchId);
        var idLstVar = [];
        var isMatchedBlocked = false;
        console.log('isSPEligibleForMatch ==> ',component.get('v.isSPEligibleForMatch'));
        console.log('processTypeAttr ==> ',component.get('v.processTypeAttr'));

        var wrapperLst = component.get('v.data');

        for( var ind = 0; ind < wrapperLst.length; ind++ ){
            if( wrapperLst[ind].matchId == row.matchId ){

                if(wrapperLst[ind].type == 'Lead'){
                    childCmp.fireToastEventAction( 'error' , "Match Process can be initiated only on Contact." );
                    isMatchedBlocked = true;
                    break;
                }

                if( wrapperLst[ind].matchStageString != undefined && wrapperLst[ind].matchStageString != 'No Action Yet' ){

                    childCmp.fireToastEventAction( 'error' , "Match Process already initiated for this, You can not start Match twice. "+wrapperLst[ind].matchStageString );
                    isMatchedBlocked = true;
                    break;
                }
            }
        }

        if( !isMatchedBlocked ){
            idLstVar.push(row.matchId);
            helper.takeNextAction(component,event,helper,idLstVar,actionType);
        }

    },
    onShowDetails : function( component , event , helper ){
         var row = event.getParam('row');
         console.log('ID : ',row.matchId);

         /*var childCmp = component.find('LightningUtil-ProspectMatchMapView');
         childCmp.navigateToRecord( row.matchId , 'Prospect_Match__c' );*/
        window.open('https://ascendorthodontics.lightning.force.com/'+row.matchId, '_blank');
    },
    recalculateProspectMatches : function( component , event , helper ){

        var childCmp = component.find('LightningUtil-ProspectMatchMapView');


        if($A.util.isUndefinedOrNull(component.get('v.realculateMilesInteger'))){
            childCmp.fireToastEventAction( 'error' , "Please Enter The recalculation radius in the text box to recalculate." );
            return;
        }

        var action   = component.get("c.recalculateProspectMatches");
        action.setParams({ sobjectId : component.get('v.recordId') , mileRadius : component.get('v.realculateMilesInteger') });

        var dataPromise = childCmp.invokeServerAction( action , 'action' );

        dataPromise.then($A.getCallback(function (data) {
           console.log('Got results ',JSON.stringify(data));

           if(data){
                childCmp.fireToastEventAction( 'success' , "Recalculated successfully" );
                window.location.reload();
           }


        })).catch(function(error){

           console.log('Error =>',error);
           childCmp.fireToastEventAction( 'error' , ("Error during Recalculation :"+error) );

        });

    },
    setOperatorType : function( component, event, helper){
        console.log('inside setOperatorType');
        // check the selection and define the operator type
        var filterType = component.get('v.filterByAttr');
        var operatorLst = [];
        var RHSSelectionLst = [];
        console.log('filterType =>',filterType);
        if(filterType){
            if( filterType.toUpperCase().includes('NAME' ) ){
                operatorLst.push('Like');
                operatorLst.push('Not Like');
                component.set('v.isTextSelection',true);
            }else if( filterType.toUpperCase().includes('TYPE') ){
                operatorLst.push('Equals');
                operatorLst.push('Not Equals');
                component.set('v.isTextSelection',false);
                RHSSelectionLst.push('Contact');
                RHSSelectionLst.push('Lead');
            }else if( filterType.toUpperCase().includes('SPECIALTY') ){
                operatorLst.push('Equals');
                operatorLst.push('Not Equals');
                component.set('v.isTextSelection',false);
                RHSSelectionLst.push('Perio');
                RHSSelectionLst.push('Ortho');
                RHSSelectionLst.push('Oral');
                RHSSelectionLst.push('Prostho');
                RHSSelectionLst.push('Endo');

            }else if( filterType.toUpperCase().includes('APPROXIMATE') ){
                operatorLst.push('Greater Than');
                operatorLst.push('Less Than');
                component.set('v.isTextSelection',true);
            }else if( filterType.toUpperCase().includes('MATCH STAGE') ){
                operatorLst.push('Equals');
                operatorLst.push('Not Equals');
                component.set('v.isTextSelection',false);

                RHSSelectionLst.push('Match Approved');
                RHSSelectionLst.push('No Action Yet');
                RHSSelectionLst.push('Match Email Sent to SP');
                RHSSelectionLst.push('Match Email Sent to GP');

            }
        }

        if(!$A.util.isUndefinedOrNull(operatorLst))
        component.set('v.operatorLst',operatorLst);

        if(!$A.util.isUndefinedOrNull(RHSSelectionLst))
                component.set('v.RHSSelectionLst',RHSSelectionLst);

        console.log('list =>',component.get('v.operatorLst'));
    },
    filterResults : function(component,event,helper){

        if( !$A.util.isUndefinedOrNull(component.get('v.filterValue')) && !$A.util.isUndefinedOrNull(component.get('v.data')) ){
            var dataLst         = component.get('v.data');
            var filterByValue     = component.get('v.filterByAttr');
            var filterValue   = component.get('v.filterValue');
            var isTextSelection = component.get('v.isTextSelection');
            var operatorSelected = component.get('v.operatorSelected');

            var filteredDataLst = [];

            dataLst.forEach(function(element){

               console.log('element.matchStage =>',element.matchStage);
               console.log('filterByValue.includes =>',filterByValue.includes('Stage'));
               console.log('operatorSelected =>',operatorSelected);

               if( filterByValue.includes('Name') ){
                   if(element.name.toLowerCase().includes(filterValue.toLowerCase()) && operatorSelected == 'Like'){
                       filteredDataLst.push(element);
                   }else if(!element.name.toLowerCase().includes(filterValue.toLowerCase()) && operatorSelected == 'Not Like'){
                       filteredDataLst.push(element);
                   }
               }else if( filterByValue.includes('Stage') ){
                   if(element.matchStage == filterValue && operatorSelected == 'Equals'){
                        filteredDataLst.push(element);
                   }else if(element.matchStage != filterValue && operatorSelected == 'Not Equals'){
                        filteredDataLst.push(element);
                   }
               }else if( filterByValue.includes('Type') ){
                   if(element.type == filterValue && operatorSelected == 'Equals'){
                        filteredDataLst.push(element);
                   }else if(element.type != filterValue && operatorSelected == 'Not Equals'){
                        filteredDataLst.push(element);
                   }
               }else if( filterByValue.includes('Specialty') ){
                   if(element.specialty.includes(filterValue) && operatorSelected == 'Equals'){
                       filteredDataLst.push(element);
                   }else if(!element.specialty.includes(filterValue) && operatorSelected == 'Not Equals'){
                      filteredDataLst.push(element);
                   }
               }else if( filterByValue.includes('Distance') ){
                   if(element.distance >= filterValue && operatorSelected == 'Greater Than'){
                       filteredDataLst.push(element);
                   }else if( element.distance <= filterValue && operatorSelected == 'Less Than'){
                      filteredDataLst.push(element);
                   }
               }

            });

            component.set('v.filteredData',filteredDataLst);

        }
    },
    enQueueMatch : function( component, event, helper ){
          var row = event.getParam('row');
          console.log('ID : ',row.matchId);
          var childCmp = component.find('LightningUtil-ProspectMatchMapView');
          var action   = component.get("c.enQueueMatch");
          action.setParams({
                              prospectMatchId : row.matchId
                           });

          var dataPromise = childCmp.invokeServerAction( action , 'action' );

          dataPromise.then($A.getCallback(function (data) {
             console.log('Got results ',JSON.stringify(data));

             if(data){
                childCmp.fireToastEventAction( 'success' , "Prospect Match Queued successfully" );
                $A.get('e.force:refreshView').fire();
             }else{
                 childCmp.fireToastEventAction( 'error' , "Error while queueing the record, Please contact admin." );
                $A.get('e.force:refreshView').fire();
             }

          })).catch(function(error){

             console.log('Error =>',error);
             childCmp.fireToastEventAction( 'error' , ("Error during Update :"+error) );

          });
    },
    processFilterCheckBoxes : function(component, event, helper  ){

        var filterDataLst = component.get('v.data');
        //var filterValue   = component.get('v.filterValue');
        var updatedFilterLst = [];

        filterDataLst.forEach(function( element ){

             console.log('****');
             console.log('Type : ',element.specialty);
             console.log('Specialty : ',component.get('v.specialtyCheckBoxValue'));
             console.log('****');
            //helper.isPresent( element.specialty , (component.get('v.specialtyCheckBoxValue'))
             if( (component.get('v.typeCheckBoxValue')).includes( element.type ) && 
                	( !component.get('v.isPracticeFlow') || (component.get('v.statusCheckBoxValue')).includes( element.status ) )
                    && (component.get('v.specialtyCheckBoxValue')).includes( element.specialty.replace(';','').trim() )
                    && (component.get('v.stageCheckBoxValue')).includes( element.matchStage ) ){
                updatedFilterLst.push(element);
            }
        });
        /*if( filterType == 'type-checkbox' ){

            filterDataLst.forEach(function( element ){
                if( filterValue.includes( element.type )  ){
                    updatedFilterLst.push(element);
                }
            });

        }else if( filterType == 'sp-status-checkbox' ){
            console.log('filterValue =>',filterValue);
             filterDataLst.forEach(function( element ){
                if( filterValue.includes( element.status )  ){
                    updatedFilterLst.push(element);
                }
            });
        }else if( filterType == 'specialty-checkbox' ){

             console.log('filterValue =>',filterValue);
             filterDataLst.forEach(function( element ){
                            console.log('element.specialty =>',element.specialty);
                            var isPresent = helper.isPresent( element.specialty , filterValue );
                            if( isPresent ){
                                updatedFilterLst.push(element);
                            }
                        });

        }*/

        component.set('v.filteredData',updatedFilterLst);
    },
    isPresent : function( specialty , optionSelected ){

        if(Array.isArray(optionSelected)){
            optionSelected.forEach(function(element){
                        debugger;
                        if(!$A.util.isUndefinedOrNull(specialty) && !$A.util.isUndefinedOrNull(element) ){
                            specialty = specialty.replace(';','').trim();
                            element = element.replace(';','').trim();
                            if(specialty.includes(element)){
                                return true;
                            }
                        }

                    });
        }else{
            return (optionSelected.includes(specialty));
        }


        return false;
    }
})