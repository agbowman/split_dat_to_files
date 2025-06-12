CREATE PROGRAM ccl_get_obj:dba
 PROMPT
  "search pattern " = ""
  WITH srctbl
 RECORD obj_reply(
   1 ret_count = f8
   1 ret[*]
     2 obj_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "NL:"
  dp.object_name, dp.group, dp.app_major_version,
  dp.app_minor_version, dp.datestamp
  FROM dprotect dp
  WHERE dp.object="P"
   AND dp.object_name=patstring(cnvtupper( $SRCTBL))
  HEAD REPORT
   stat = alterlist(obj_reply->ret,5), count = 0
  DETAIL
   count += 1, obj_reply->ret[count].obj_name = dp.object_name
  FOOT REPORT
   stat = alterlist(obj_reply->ret,count), obj_reply->ret_count = count
  WITH nocounter, maxrec = 5
 ;end select
 DECLARE err_msg = vc
 IF (error(err_msg,0) > 0)
  SET obj_reply->status_data.status = "F"
  SET obj_reply->status_data.subeventstatus[1].operationname = "select statement"
  SET obj_reply->status_data.subeventstatus[1].operationstatus = "F"
  SET obj_reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
  GO TO exitscript
 ENDIF
#exitscript
 SET _memory_reply_string = cnvtrectojson(obj_reply,2,1)
END GO
