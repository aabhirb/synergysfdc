/**
* @author abhishekbidap
* @date 9/6/19
*
* @description : .
*/
global with sharing class DailyEmailScheduler implements Schedulable
{
    static Set<String> opptyStageToExclude = new Set<String> {
                                                                'Closed Won',
                                                                'Treatment Scheduled',
                                                                'Tx Day Schedule',
                                                                'Meeting Completed',
                                                                'Closed Lost'

                                                              };
    static Map<String,String> ownerToEmailMap = new Map <String,String> {
                                                                            'Darius Somekhian' => 'dariussomekhian@gmail.com',
                                                                            'Alijeh Kee' => 'alijeh@synergyspecialists.com',
                                                                            'Danika Lin' => 'Danika@synergyspecialists.com',
                                                                            'Lauren Fradella' => 'Lauren@synergyspecialists.com',
                                                                            'Malia Otken' => 'malia@synergyspecialists.com',
                                                                            'Cynthia Capitin' => 'cynthia@synergyspecialists.com'
                                                                        };

    global void execute(SchedulableContext SC) {

        List<Opportunity> openOpptyLst = queryOpenOpportunities();
        Map<String,List<Opportunity>> ownerWiseOpptyMap = new Map<String,List<Opportunity>> ();

        if( !openOpptyLst.isEmpty() ) {

            for( Opportunity opptyVar : openOpptyLst ) {

                if( ownerWiseOpptyMap.containsKey( opptyVar.Owner__c ) ) {
                    ownerWiseOpptyMap.get( opptyVar.Owner__c ).add( opptyVar );
                } else {
                    ownerWiseOpptyMap.put( opptyVar.Owner__c , new List <Opportunity>{ opptyVar } );
                }
            }
        }

        if( !ownerWiseOpptyMap.keySet().isEmpty() ) {
            List<Messaging.SingleEmailMessage> messageLst = new List<Messaging.SingleEmailMessage>();

            for( String ownerStr : ownerWiseOpptyMap.keySet() ) {

                if( String.isNotBlank( ownerStr ) && ownerToEmailMap.containsKey(ownerStr) ) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses( new List<String> { ownerToEmailMap.get(ownerStr) } );
                    mail.setSubject( ownerStr + ' : Your Daily Digest for Open Opportunities' );
                    String htmlBody = '<html>';
                    htmlBody += '<body>';
                    htmlBody += '<p>';
                    htmlBody += 'Following are the open opportunities assigned to you , please review and complete it asap';
                    htmlBody += '</p>';
                    htmlBody += '<table style="border:1px solid black;border-collapse:collapse;">';
                    htmlBody += '<tr>';
                    htmlBody += '<th style="border:1px solid red;">Sno</th>';
                    htmlBody += '<th style="border:1px solid red;">Opportunity </th>';
                    htmlBody += '<th style="border:1px solid red;">Stage </th>';
                    htmlBody += '<th style="border:1px solid red;">Description </th>';
                    htmlBody += '</tr>';

                    Integer ind = 1;

                    for( Opportunity opptyVar : ownerWiseOpptyMap.get(ownerStr) ) {
                        htmlBody += '<tr>';
                        htmlBody += '<td style="border:1px solid red;">'+ (ind++) +'</td>';
                        htmlBody += '<td style="border:1px solid red;"> <a href="https://ascendorthodontics.lightning.force.com/"'+opptyVar.Id+'>'+ opptyVar.Name +'</a> </td>';
                        htmlBody += '<td style="border:1px solid red;">'+opptyVar.StageName+'</td>';
                        htmlBody += '<td style="border:1px solid red;">'+( String.isNotBlank(opptyVar.Description) ? opptyVar.Description : '' )+'</td>';
                        htmlBody += '</tr>';
                    }

                    htmlBody += '</table>';
                    htmlBody += '</body>';
                    htmlBody += '</html>';

                    mail.setHtmlBody(htmlBody);

                    messageLst.add(mail);
                }
            }

            if( !messageLst.isEmpty() ){
                Messaging.sendEmail( messageLst );
            }
        }
    }

    public static List<Opportunity> queryOpenOpportunities(){

        return [
                    SELECT Id,Name,Owner__c,StageName,Description
                            FROM
                            Opportunity
                            WHERE
                            StageName NOT IN: opptyStageToExclude and
                            Owner__c <> null
                 ];
    }



}