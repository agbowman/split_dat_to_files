CREATE PROGRAM ccl_get_program_info:dba
 DECLARE err_msg = vc WITH noconstant("")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE num = i4
 RECORD reply(
   1 qual[*]
     2 object_name = c30
     2 group = i2
     2 user_name = c12
     2 source_name = vc
     2 compile_dttm = c20
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "NL:"
  d.object_name, d.group, d.user_name,
  d.datestamp, d.timestamp, d.source_name
  FROM dprotect d
  WHERE d.object="P"
   AND expand(num,1,size(request->qual,5),cnvtupper(d.object_name),cnvtupper(request->qual[num].
    object_name))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].object_name = d.object_name, reply->qual[cnt].group = d.group, reply->qual[cnt].
   user_name = d.user_name,
   reply->qual[cnt].compile_dttm = format(cnvtdatetime(d.datestamp,d.timestamp),"@MEDIUMDATETIME"),
   reply->qual[cnt].source_name = d.source_name
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nullreport, expand = 0
 ;end select
 SET error_code = error(err_msg,0)
 IF (error_code != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "ccl_get_program_info"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Error Message"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
