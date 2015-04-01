trigger CopyMessageToCaseComment on EmailMessage (after insert) {

    List<CaseComment> newCaseComments = new List<CaseComment>();
    CaseComment cc;
    String tempBody;
    
    for(EmailMessage em : Trigger.new) {
        cc = new CaseComment();
        cc.ParentId = em.ParentId;
        cc.CommentBody = 'Date Received: ' + Date.valueOf(em.MessageDate.addhours(-1));
        cc.CommentBody += '\nEmail subject:: ' + em.Subject;
        cc.CommentBody += '\nFrom:: ' + em.FromAddress;
        tempBody = em.TextBody;
        if(tempBody.length() > 4000) {
            cc.CommentBody += '\nEmail body: ' + tempBody.subString(0, 3800);
        }
        else {
            cc.CommentBody += '\nEmail body: ' + tempBody;
        }
        newCaseComments.add(cc);
    }
    
    if(newCaseComments.size() > 0) {
        insert newCaseComments;
    }
}