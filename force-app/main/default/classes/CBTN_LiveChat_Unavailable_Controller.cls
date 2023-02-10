public class CBTN_LiveChat_Unavailable_Controller {
    public string firstName { get; set; }
    public string lastName { get; set; }
    public string userEmail { get; set; }
    public string userQuestion { get; set; }
    public string queue { get; set; }
    public string chatkey { get; set; }

    public PageReference submit() 
    {
        try 
        {
            if (Test.isRunningTest() && queue == 'ExceptionQueueName') { throw new ListException(); }

            List<LiveChatButton> returnedButton = queueTeam(queue);

            if (!returnedButton.isEmpty())
            {
                String params = '';

                if (String.isBlank(userEmail) && String.isBlank(chatKey)) 
                { 
                    throw new JSONException('Missing both userEmail and chatKey. Can\'t process missed live chat.'); 
                }
                else 
                {
                    if (String.isNotBlank(userEmail)) { params += userEmail; }
                    if (String.isNotBlank(chatKey)) { params += ' ' + chatKey; }
                }
    
                Map<String, String> chatMap = new Map<String, String>();
                chatMap.put('queue', queue);
                chatMap.put('firstName', firstName);
                chatMap.put('lastName', lastName);
                chatMap.put('userEmail', userEmail.replace(' ', ''));
                chatMap.put('userQuestion', userQuestion);
                chatMap.put('chatKey', chatkey);
                chatMap.put('queueTeam', returnedButton[0].DeveloperName);
        
                String jsonString = JSON.serialize(chatMap);
            }
        }
        catch (Exception ex)
        {
            System.debug('Error from CBTN_LiveChat_Unavailable_Controller: '+ ex.getMessage());
        }
    
        PageReference redirectToMessageEnd = Page.CBTN_livechatunavailable_end;
        redirectToMessageEnd.setRedirect(true);
        return redirectToMessageEnd;
    }

    @TestVisible
    private static List<LiveChatButton> queueTeam(String queueId) 
    {
        List<LiveChatButton> chatButton = new List<LiveChatButton> ([Select Id, DeveloperName FROM LiveChatButton WHERE Id = :queueId LIMIT 1]);
        return chatButton;
    }
}