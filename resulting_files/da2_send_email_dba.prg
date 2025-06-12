CREATE PROGRAM da2_send_email:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE numrecipients = i4 WITH public, noconstant(0)
 DECLARE i = i4 WITH public, noconstant(0)
 SET numrecipients = size(request->tolist,5)
 FOR (i = 1 TO numrecipients)
   CALL uar_send_mail(nullterm(request->tolist[i].recipient),nullterm(request->subject),nullterm(
     request->message),nullterm(request->sender),request->priority,
    "IPM.NOTE")
 ENDFOR
 SET reply->status_data.status = "S"
END GO
