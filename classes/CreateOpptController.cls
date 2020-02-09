public class CreateOpptController {

    //Get the recordtype Id of Opportunity object
    @AuraEnabled
    public static Id getTraditionalRecordTypeId(){
        Schema.RecordTypeInfo rtByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Traditional');
        return rtByName.getRecordTypeId();
    }
    
    //This method will get the API names of the field which will be used for creation of Opportunity
    @AuraEnabled
    public static List<String> getOpptFields(){
        List<String> fields = new List<String>();
        List<Schema.FieldSetMember> fieldSetMembers = Schema.SObjectType.Opportunity.fieldSets.New_Oppt_Fields.getFields();
        for(Schema.FieldSetMember fieldSetMember: fieldSetMembers){
            fields.add(fieldSetMember.getFieldPath());
        }
        return fields;    
    }
}