CREATE PROGRAM ccl_get_src_app:dba
 PROMPT
  "search pattern " = ""
  WITH srctbl
 RECORD app_reply(
   1 ret_count = f8
   1 ret[*]
     2 app_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT DISTINCT
  c.application_nbr, a.description
  FROM ccl_report_audit c,
   application a
  PLAN (c
   WHERE c.application_nbr > 0
    AND c.updt_dt_tm > cnvtdatetime((curdate - 7),0000))
   JOIN (a
   WHERE c.application_nbr=a.application_number
    AND cnvtupper(a.description)=patstring(cnvtupper( $SRCTBL)))
  ORDER BY a.description
  HEAD REPORT
   stat = alterlist(app_reply->ret,5), count = 0
  DETAIL
   count += 1, app_reply->ret[count].app_name = a.description
  FOOT REPORT
   stat = alterlist(app_reply->ret,count), app_reply->ret_count = count
  WITH nocounter, maxrec = 5
 ;end select
 DECLARE err_msg = vc
 IF (error(err_msg,0) > 0)
  SET app_reply->status_data.status = "F"
  SET app_reply->status_data.subeventstatus[1].operationname = "select statement"
  SET app_reply->status_data.subeventstatus[1].operationstatus = "F"
  SET app_reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
  GO TO exitscript
 ENDIF
#exitscript
 SET _memory_reply_string = cnvtrectojson(app_reply,2,1)
END GO
