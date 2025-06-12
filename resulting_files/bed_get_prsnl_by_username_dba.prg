CREATE PROGRAM bed_get_prsnl_by_username:dba
 FREE SET reply
 RECORD reply(
   1 usernames[*]
     2 username = vc
     2 personnel[*]
       3 person_id = f8
       3 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ucnt = 0
 SET ucnt = size(request->usernames,5)
 FOR (u = 1 TO ucnt)
   SET stat = alterlist(reply->usernames,ucnt)
   SET reply->usernames[u].username = request->usernames[u].username
   SET pcnt = 0
   SET alterlist_pcnt = 0
   SET stat = alterlist(reply->usernames[u].personnel,10)
   SELECT INTO "NL:"
    FROM prsnl p
    WHERE (p.username=request->usernames[u].username)
    DETAIL
     pcnt = (pcnt+ 1), alterlist_pcnt = (alterlist_pcnt+ 1)
     IF (alterlist_pcnt > 10)
      stat = alterlist(reply->usernames[u].personnel,(pcnt+ 10)), alterlist_pcnt = 1
     ENDIF
     reply->usernames[u].personnel[pcnt].person_id = p.person_id, reply->usernames[u].personnel[pcnt]
     .name_full_formatted = p.name_full_formatted
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->usernames[u].personnel,pcnt)
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
