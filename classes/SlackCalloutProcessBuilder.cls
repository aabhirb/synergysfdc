public class SlackCalloutProcessBuilder {
    //Calling From Process builder
    private static final String slackURL = System.Label.Slack_API;
    
    public class Oppty {
        @InvocableVariable(label='Lead Name')
        public String leadName;
        @InvocableVariable(label='URL')
        public String url;
        @InvocableVariable(label='Lead Type')
        public String type;        
    }
     
    @InvocableMethod(label='Post to Slack')
    public static void postToSlack(List<Oppty> oppties) {
        Oppty o = oppties[0]; // If bulk, only post first to avoid overloading Slack channel
        Map<String,Object> msg = new Map<String,Object>();
        msg.put('text', 'New '+o.type+' Lead, '+o.leadName+' ,is added, Please process the intake and follow up on the next process. \n' + o.url );
        msg.put('mrkdwn', true);
        String body = JSON.serialize(msg);
        //https://hooks.slack.com/services/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
        System.enqueueJob(new QueueableSlackCall(slackURL, 'POST', body));
    }
     
    public class QueueableSlackCall implements System.Queueable, Database.AllowsCallouts {
         
        private final String url;
        private final String method;
        private final String body;
         
        public QueueableSlackCall(String url, String method, String body) {
            this.url = url;
            this.method = method;
            this.body = body;
        }
         
        public void execute(System.QueueableContext ctx) {
        
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(method);
            req.setBody(body);
            Http http = new Http();
            if(!Test.isRunningTest()){
            HttpResponse res = http.send(req);
            }
           
        }
 
    }

    public class MultipleSlackCall implements System.Queueable, Database.AllowsCallouts {
        private final String url;
        private final String method;
        private final List<String> lstBody;
         
        public MultipleSlackCall(String url, String method, List<String> lstBody) {
            this.url = url;
            this.method = method;
            this.lstBody = lstBody;
        }
         
        public void execute(System.QueueableContext ctx) {
            for(String body : lstBody){
                HttpRequest req = new HttpRequest();
                req.setEndpoint(url);
                req.setMethod(method);
                req.setBody(body);
                Http http = new Http();
                if(!Test.isRunningTest()){
                    HttpResponse res = http.send(req);
                }
            }
        }
    }
    
}