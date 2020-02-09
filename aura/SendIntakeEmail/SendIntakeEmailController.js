/**
 * Created by abidap on 2/19/19.
 */
({
    doInit : function( component, event , helper ){
        var optionLst = [];
        optionLst.push({ key : 'Endo' , label : 'Endodontics' });
        optionLst.push({ key : 'Perio' , label : 'Periodontics' });
        optionLst.push({ key : 'Ortho' , label : 'Orthodontics' });
        optionLst.push({ key : 'Oral' , label : 'Oral Surgergy' });
        optionLst.push({ key : 'Pedo' , label : 'Pedodontics' });
        optionLst.push({ key : 'Anesth' , label : 'Dental Anesthesiology' });
        optionLst.push({ key : 'Prostho' , label : 'Prosthodontics' });
        optionLst.push({ key : ' ' , label : ' ' });
        component.set('v.intakeOptionLst',optionLst);
        helper.loadLeadData(component, event, helper);
        console.log('recordId =>',component.get('v.recordId'));
    },
    onsubmit : function( component , event , helper ){

        console.log('Checked =>',component.get('v.selectedOptionLst'));
        helper.initiateEmailInvocation( component , event , helper ); 

    },
    onChangeOfOption : function( component, event , helper ){
       console.log('event =>',event.getParam('checked'));
       console.log('event =>',JSON.stringify( event.getParams() ) );

    },
    onChangeOfEndo : function( component, event, helper ){
        var selectedOptionLst = component.get('v.selectedOptionLst');
        if(event.getParam('checked')){
           if($A.util.isUndefinedOrNull(component.get('v.selectedOptionLst'))){
                selectedOptionLst = [];
                selectedOptionLst.push('Endo');
            }else{
                selectedOptionLst.push('Endo');
            }

            component.set('v.selectedOptionLst',selectedOptionLst);
        }else{
            component.set('v.selectedOptionLst',helper.removeFromArray(selectedOptionLst,'Endo'));
        }

    },
    onChangeOfPerio : function( component, event, helper ){
        var selectedOptionLst = component.get('v.selectedOptionLst');
        if(event.getParam('checked')){
            if($A.util.isUndefinedOrNull(component.get('v.selectedOptionLst'))){
                selectedOptionLst = [];
                selectedOptionLst.push('Perio');
            }else{
                selectedOptionLst.push('Perio');
            }

            component.set('v.selectedOptionLst',selectedOptionLst);
        }else{
            component.set('v.selectedOptionLst',helper.removeFromArray(selectedOptionLst,'Perio'));
        }

    },
    onChangeOfOrtho : function( component, event, helper ){
         var selectedOptionLst = component.get('v.selectedOptionLst');
         if(event.getParam('checked')){
             if($A.util.isUndefinedOrNull(component.get('v.selectedOptionLst'))){
                 selectedOptionLst = [];
                 selectedOptionLst.push('Ortho');
             }else{
                 selectedOptionLst.push('Ortho');
             }

             component.set('v.selectedOptionLst',selectedOptionLst);
         }else{

             component.set('v.selectedOptionLst',helper.removeFromArray(selectedOptionLst,'Ortho'));
         }

    },
    onChangeOfOral : function( component, event, helper ){
       var selectedOptionLst = component.get('v.selectedOptionLst');
       if(event.getParam('checked')){
           if($A.util.isUndefinedOrNull(component.get('v.selectedOptionLst'))){
               selectedOptionLst = [];
               selectedOptionLst.push('Oral');
           }else{
               selectedOptionLst.push('Oral');
           }

           component.set('v.selectedOptionLst',selectedOptionLst);
       }else{
           component.set('v.selectedOptionLst',helper.removeFromArray(selectedOptionLst,'Oral'));
       }

    },
    onChangeOfPedo : function( component, event, helper ){
        var selectedOptionLst = component.get('v.selectedOptionLst');
        if(event.getParam('checked')){
            if($A.util.isUndefinedOrNull(component.get('v.selectedOptionLst'))){
                selectedOptionLst = [];
                selectedOptionLst.push('Pedo');
            }else{
                selectedOptionLst.push('Pedo');
            }

            component.set('v.selectedOptionLst',selectedOptionLst);
        }else{
            component.set('v.selectedOptionLst',helper.removeFromArray(selectedOptionLst,'Pedo'));
        }

    },
    onChangeOfAnesth : function( component, event, helper ){
        var selectedOptionLst = component.get('v.selectedOptionLst');
        if(event.getParam('checked')){
            if($A.util.isUndefinedOrNull(component.get('v.selectedOptionLst'))){
                selectedOptionLst = [];
                selectedOptionLst.push('Anesth');
            }else{
                selectedOptionLst.push('Anesth');
            }

            component.set('v.selectedOptionLst',selectedOptionLst);
        }else{
            component.set('v.selectedOptionLst',helper.removeFromArray(selectedOptionLst,'Anesth'));
        }

    },
    onChangeOfProstho : function( component, event, helper ){
        var selectedOptionLst = component.get('v.selectedOptionLst');
        if(event.getParam('checked')){
            if($A.util.isUndefinedOrNull(component.get('v.selectedOptionLst'))){
                selectedOptionLst = [];
                selectedOptionLst.push('Prostho');
            }else{
                selectedOptionLst.push('Prostho');
            }

            component.set('v.selectedOptionLst',selectedOptionLst);
        }else{
            component.set('v.selectedOptionLst',helper.removeFromArray(selectedOptionLst,'Prostho'));
        }

    },
    onChangeOfgpRec: function( component, event, helper ){
       var selectedOptionLst = component.get('v.selectedOptionLst');
       if(event.getParam('checked')){
           if($A.util.isUndefinedOrNull(component.get('v.selectedOptionLst'))){
               selectedOptionLst = [];
               selectedOptionLst.push('gpRec');
           }else{
               selectedOptionLst.push('gpRec');
           }

           component.set('v.selectedOptionLst',selectedOptionLst);
       }else{
           component.set('v.selectedOptionLst',helper.removeFromArray(selectedOptionLst,'gpRec'));
       }

    },
    onChangeOfAdvanceGP: function( component, event, helper ){
      var selectedOptionLst = component.get('v.selectedOptionLst');
      if(event.getParam('checked')){
          if($A.util.isUndefinedOrNull(component.get('v.selectedOptionLst'))){
              selectedOptionLst = [];
              selectedOptionLst.push('Advance');
          }else{
              selectedOptionLst.push('Advance');
          }

          component.set('v.selectedOptionLst',selectedOptionLst);
      }else{
          component.set('v.selectedOptionLst',helper.removeFromArray(selectedOptionLst,'Advance'));
      }

    }

})