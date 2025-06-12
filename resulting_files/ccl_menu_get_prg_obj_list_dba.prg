CREATE PROGRAM ccl_menu_get_prg_obj_list:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cnt_qual = i2
   1 qual[*]
     2 object_name = c30
     2 ccl_group = i4
 )
 SET reply->status_data.status = "F"
 CALL echo(concat("request->object_name in prg: ",build(request->object_name)))
 SELECT INTO "nl:"
  FROM dprotect d
  WHERE d.object="P"
   AND d.object_name=patstring(request->object_name)
  ORDER BY d.object_name, d.group
  HEAD REPORT
   stat = alterlist(reply->qual,10), cnt = 0
  DETAIL
   cnt += 1, reply->cnt_qual = cnt
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].object_name = d.object_name, reply->qual[cnt].ccl_group = d.group
  FOOT REPORT
   stat = alterlist(reply->qual,cnt), reply->cnt_qual = cnt,
   CALL echo(concat("reply->cnt_qual: ",build(reply->cnt_qual)))
  WITH nocounter
 ;end select
 CALL echo(concat("curqual: ",build(curqual)))
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "Retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DPROTECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Can not find the object name starts with ",trim(request->object_name)," in dprotect table.")
 ENDIF
#exitscript
 CALL echorecord(request)
 CALL echorecord(reply)
END GO
