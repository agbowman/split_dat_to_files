CREATE PROGRAM ccl_get_user:dba
 PROMPT
  "search pattern " = ""
  WITH srctbl
 RECORD user_reply(
   1 ret_count = f8
   1 ret[*]
     2 user_name = vc
     2 id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT DISTINCT
  p.username, c.updt_id
  FROM prsnl p,
   ccl_report_audit c
  PLAN (p
   WHERE cnvtupper(p.username)=patstring(cnvtupper( $SRCTBL)))
   JOIN (c
   WHERE p.person_id=c.updt_id)
  ORDER BY p.username
  HEAD REPORT
   stat = alterlist(user_reply->ret,5), count = 0
  DETAIL
   count += 1, user_reply->ret[count].user_name = p.username, user_reply->ret[count].id = p.person_id
  FOOT REPORT
   stat = alterlist(user_reply->ret,count), user_reply->ret_count = count
  WITH nocounter, maxrec = 5
 ;end select
 DECLARE err_msg = vc
 IF (error(err_msg,0) > 0)
  SET user_reply->status_data.status = "F"
  SET user_reply->status_data.subeventstatus[1].operationname = "select statement"
  SET user_reply->status_data.subeventstatus[1].operationstatus = "F"
  SET user_reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
  GO TO exitscript
 ENDIF
#exitscript
 SET _memory_reply_string = cnvtrectojson(user_reply,2,1)
END GO
