global without sharing class ChatGPTClass {
    
    @AuraEnabled
    global static string generateResponseFromGPT(String queryText){
        try {
            String content = generateResponse(queryText);
            return content;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    global static String generateResponse(String queryText){
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('callout:Chat_GPT/v1/chat/completions');
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization', 'Bearer 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');
        httpReq.setTimeout(60000); // Set timeout to 60 seconds (adjust as needed)

        String body = '{'+
		'    "model": "gpt-3.5-turbo",'+
		'    "messages": ['+
		'      {'+
		'        "role": "user",'+
		'        "content": "'+queryText+'"'+
		'      }'+
		'      '+
		'    ]'+
		'  }';

        httpReq.setBody(body);

        Http http = new Http();
        HttpResponse httpResponse = http.send(httpReq);
        String content = '';
        if (httpResponse.getStatusCode() == 200) {
            System.debug(httpResponse.getBody());
            ChatWrapper wrapper = (ChatWrapper)System.JSON.deserialize(httpResponse.getBody(), ChatWrapper.class);
            List<ChatGPTClass.Choices> choices = wrapper.choices;
            if (choices != null && choices.size() > 0) {
                ChatGPTClass.Choices choice = choices.get(0);
                if (choice.message != null) {
                content = choice.message.content;
                System.debug(content);  
                }
            }
        }else{
            System.debug('Error !!');
            System.debug(httpResponse.getBody());
        }
        return content;
    }

    global class ChatWrapper{
        public String id;
	    public Choices[] choices;	
    }
    global class Choices {
		public Integer index;	
		public Message message;
		public String finish_reason;	
	}
	global class Message {
		public String role;	
		public String content;	
	}
}
