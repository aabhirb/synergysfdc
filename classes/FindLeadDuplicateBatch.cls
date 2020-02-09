global class FindLeadDuplicateBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Set<Id> addedLeadIds; //Set to maintain the leads whose duplicate is already found
    
    //Constructor to initialize the Set
    global FindLeadDuplicateBatch(){
        addedLeadIds = new Set<Id>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Lead';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope){
        List<DuplicateRecordSet> drset = new List<DuplicateRecordSet>();
        Map<Id, List<DuplicateRecordItem>> mapLeadToItem = new Map<Id, List<DuplicateRecordItem>>();
        Map<Id, DuplicateRecordSet> mapLeadToDRSet = new Map<Id, DuplicateRecordSet>();
        Map<Id, String> mapLeadToDuplicateRules = new Map<Id, String>();

        for(Lead leadObj : scope){
            //If the lead is not added to set, then find the duplicates
            if(!addedLeadIds.contains(leadObj.Id)){
                addedLeadIds.add(leadObj.Id);
                System.debug('actual record' +leadObj);
                Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(new List<Lead>{leadObj});
                //As we are passing LeadList with only one record, the FindDuplicatesResult list size will be one if duplicates are found
                if(results.size() > 0){
                	Datacloud.FindDuplicatesResult findDupeResult = results[0];
                    List<Datacloud.DuplicateResult> duplicateResults = findDupeResult.getDuplicateResults();
                    if(duplicateResults.size() > 0){
                        Datacloud.DuplicateResult dupeResult = duplicateResults[0];
                        //Get the duplicate Rule name
                        String duplicateRule = dupeResult.getDuplicateRule();
                        List<DuplicateRecordItem> drItems = new List<DuplicateRecordItem>();
                        Boolean isDuplicateFound = false;
                        DuplicateRecordItem drItem;
                        for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                            for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                                System.debug('Duplicate Record: ' + matchRecord.getRecord());
    
                                //Set the Boolean as true if match record is found
                                isDuplicateFound = true;
                                //Create an object of DuplicateRecordItem and add it to the list
                                drItem = new DuplicateRecordItem(RecordId = matchRecord.getRecord().Id);
                                drItems.add(drItem);
                                //Add the duplicate lead to the set so that it's duplicate is not searched again
                                addedLeadIds.add(matchRecord.getRecord().Id);
                            }
                        }
                        
                        if(isDuplicateFound){
                            mapLeadToDuplicateRules.put(leadObj.Id, duplicateRule);
                            //Add the Lead object for which duplicates are searched for
                            drItem = new DuplicateRecordItem(RecordId = leadObj.Id);
                            drItems.add(drItem);
                            //Add the Duplicate record set and list of it's duplicate record items to a Map
                            mapLeadToItem.put(leadObj.Id, drItems);
                        }
                    }
            	}
        	}    
        }
                
        //Query the duplicate rule Id from DuplicateRule object
        List<DuplicateRule> duplicatesRules = [SELECT Id, DeveloperName FROM DuplicateRule WHERE DeveloperName IN: mapLeadToDuplicateRules.values()];
        Map<String, Id> mapRuleNameToId = new Map<String, Id>();
        for(DuplicateRule rule : duplicatesRules){
            mapRuleNameToId.put(rule.DeveloperName, rule.Id);
        }
        
        for(Id leadId : mapLeadToDuplicateRules.keySet()){
            //Create a Duplicate Record set object
            DuplicateRecordSet record = new DuplicateRecordSet(
                DuplicateRuleId = mapRuleNameToId.get(mapLeadToDuplicateRules.get(leadId))
            );
            mapLeadToDRSet.put(leadId, record);
        }     
        //Insert the DuplicateRecordSet records
        insert mapLeadToDRSet.values();
        
        List<DuplicateRecordItem> drItemLstToInsert = new List<DuplicateRecordItem>();
        //Update the DuplicateRecordSetId on DuplicateRecordItem object
        
        for(Id leadId : mapLeadToDRSet.keySet()){
            DuplicateRecordSet recordSetObj = mapLeadToDRSet.get(leadId);
            for(DuplicateRecordItem drItem : mapLeadToItem.get(leadId)){
                drItem.DuplicateRecordSetId = recordSetObj.Id;
                //Add to a list for insertion
                drItemLstToInsert.add(drItem);
            }
        }
        
        insert drItemLstToInsert;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    

}