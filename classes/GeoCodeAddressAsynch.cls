/**
 * Created by abidap on 3/24/19.
 */

public with sharing class GeoCodeAddressAsynch implements Queueable,Database.AllowsCallouts  {

    public String sobjectType;
    public List<Sobject> sobjectLst;
    public Boolean executeProspectMatchRefresh;

    //Added constructor for setting default values
    public GeoCodeAddressAsynch(){
        sobjectLst = new List<Sobject>();
        executeProspectMatchRefresh = false;
    }
    public void execute(QueueableContext context) {
        ApexLogger.Logger logger = ApexLogger.createLogger('GeoCodeAddressAsynch '+system.now());
        List<SObject> sobjectLstToUpdate = new List<SObject>();
        String address = '';
        logger.log('Input : sobjectType '+sobjectType);
        logger.log('Input : sobjectLst '+sobjectLst);
        //Ankita A: 6 Feb 2020: Creating a variable to capture an error
        Boolean isError = false;
        try{
            for(Sobject sobjectVar : sobjectLst){

                if(sobjectType == 'Contact'){
                    address = (String) ( sobjectVar.get('MailingStreet')+','+sobjectVar.get('MailingCity')+','+sobjectVar.get('MailingState')+','+sobjectVar.get('MailingPostalCode')+' '+'United States' ) ;
                }else if(sobjectType == 'Lead'){
                    address = (String) ( sobjectVar.get('Street')+','+sobjectVar.get('City')+','+sobjectVar.get('State')+','+sobjectVar.get('PostalCode')+' '+'United States' ) ;
                }

                address = address.replace('null',' ');
                address = address.replace('#',' ');
                address = address.replace(' ','+');
                address = address.replace('+,','');
                address = address.replace('++','+');
                address= address.replaceAll( '\\s+', '');


                String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json';
                String googleAPIKey =  'AIzaSyDkgPmvDndKaX-P7vsSrgtCOxrVAjwoEd0';//TODO encrypt this.
                String postData = '?address='+address+'&key='+googleAPIKey;
                System.debug(postData);
                Http h = new Http();

                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/json');
                req.setEndpoint(endpoint+postData);
                req.setMethod('GET');
                system.debug('REQUEST: '+req.getBody());
                logger.log('REQUEST: '+req.getBody());


                HttpResponse res ;

                String jsonResponse;
                if(Test.isRunningTest()){
                    jsonResponse = '{"results":[{"address_components":[{"long_name":"2000","short_name":"2000","types":["street_number"]},{"long_name":"WalnutAvenue","short_name":"WalnutAve","types":["route"]},{"long_name":"CentralDistrict","short_name":"CentralDistrict","types":["neighborhood","political"]},{"long_name":"Fremont","short_name":"Fremont","types":["locality","political"]},{"long_name":"AlamedaCounty","short_name":"AlamedaCounty","types":["administrative_area_level_2","political"]},{"long_name":"California","short_name":"CA","types":["administrative_area_level_1","political"]},{"long_name":"UnitedStates","short_name":"US","types":["country","political"]},{"long_name":"94538","short_name":"94538","types":["postal_code"]}],"formatted_address":"2000WalnutAve,Fremont,CA94538,USA","geometry":{"location":{"lat":37.5577221,"lng":-121.9718755},"location_type":"ROOFTOP","viewport":{"northeast":{"lat":37.5590710802915,"lng":-121.9705265197085},"southwest":{"lat":37.5563731197085,"lng":-121.9732244802915}}},"place_id":"ChIJs5m_bI3Aj4ARjhVfEB-KSqI","plus_code":{"compound_code":"H25H+36Fremont,California,UnitedStates","global_code":"849WH25H+36"},"types":["street_address"]}],"status":"OK"}';
                }else{
                    res = h.send(req);
                    jsonResponse = res.getBody();
                    system.debug('Body =>'+res.getBody());
                    logger.log('Response Body =>'+res.getBody());
                }

                Map<String,Object> respMap = (Map<String,Object>) JSON.deserializeUntyped( jsonResponse );

                List<Object> resultLst = (List<Object>) respMap.get('results');
                //Ankita A: 24 Jan 2020: Capture the status from the JSON response
                Object status = respMap.get('status');
                if(status != null && status.toString().equalsIgnoreCase('ok')){
                    logger.setStatus('SUCCESS');
                } else {
                    logger.setStatus('Error');
                    //Ankita A: 6 Feb: Set isError as true in case of exception
                    isError = true;
                }
                if( resultLst != null && resultLst.size() != 0) {
                    Object resultVar = resultLst[0];
                    Map <String, Object> geometryObj = (Map<String, Object>) ((Map<String, Object>) resultVar).get('geometry');
                    Decimal latVal = (Decimal) ((Map<String, Object>) geometryObj.get('location')).get('lat');
                    Decimal longVal = (Decimal) ((Map<String, Object>) geometryObj.get('location')).get('lng');
                    system.debug(' ' + latVal);
                    system.debug(' ' + longVal);

                    Schema.SObjectType t  = Schema.getGlobalDescribe().get(sobjectType);
                    SObject s = t.newSObject();
                    if(sobjectType == 'Contact'){
                        s.put('MailingLatitude',latVal);
                        s.put('MailingLongitude',longVal);
                        s.put('Id',sobjectVar.get('Id'));
                    }else if(sobjectType == 'Lead'){
                        s.put('Latitude',latVal);
                        s.put('Longitude',longVal);
                        s.put('Id',sobjectVar.get('Id'));
                    }

                    sobjectLstToUpdate.add(s);

                }
            }

            if(!sobjectLstToUpdate.isEmpty())
                update sobjectLstToUpdate;

            // If there is any change in contact , system will find all the matches which are not started yet ,
            // Delete them
            // Recalculate matches
            if( executeProspectMatchRefresh && sobjectType == 'Contact' ){

                List<Prospect_Match__c> matchLstToDelete = [ SELECT Id,Name from Prospect_Match__c
                                                                where
                                                                ( GP_Contact__c IN: sobjectLstToUpdate or SP_Contact__c IN: sobjectLstToUpdate )
                                                                    and
                                                                Match_Stage__c = 'No Action Yet'
                                                     ];

                if( matchLstToDelete != null && !matchLstToDelete.isEmpty() ){
                    delete matchLstToDelete;
                }

                for( SObject sobjectVar : sobjectLstToUpdate ){
                    Id recordtypeId = (Id) sobjectVar.get('RecordTypeId');
                    String operationType = ( recordtypeId == Utility.getsObjectRecordTypeId( Contact.SObjectType , 'Practice' ) ) ? 'GP Contact' : 'SP Contact';
                    CustomLeadConvertController.calculateProspectMatches( (Id) sobjectVar.get('Id') , operationType , null );
                }
            }
            
        } catch(Exception ex){
            //Ankita A: 6 Feb: Set isError as true in case of exception
            isError = true;
            logger.log('Error while Processing : '+ex.getStackTraceString()+'\n Message : '+ex.getMessage());
            logger.logException(ex);
        } finally {
            //Ankita A: 6 Feb 2020: If sObject list has any records or an error has occured, then capture the logs
            if(!sobjectLst.isEmpty() || isError){
                ApexLogger.commitLogs();
            }
            
        }

    }
}