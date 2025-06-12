CREATE PROGRAM cermon_send_email:dba
 RECORD reply(
   1 successfulsend = i2
 )
 DECLARE numrecipients = i4 WITH public, noconstant(0)
 DECLARE i = i4 WITH public, noconstant(0)
 SET numrecipients = size(request->tolist,5)
 FOR (i = 1 TO numrecipients)
   CALL uar_send_mail(nullterm(request->tolist[i].recipient),nullterm(request->subject),nullterm(
     request->message),nullterm(request->sender),request->priority,
    "IPM.NOTE")
 ENDFOR
 SET reply->successfulsend = 1
END GO
