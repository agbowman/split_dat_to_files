CREATE PROGRAM ccl_get_category:dba
 RECORD reply(
   1 qual[*]
     2 category = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET failed = "F"
 SET errmsg = fillstring(255," ")
 SELECT DISTINCT INTO "nl:"
  d.data_model_section
  FROM dm_data_model_section d
  WHERE trim(d.data_model_section) != null
  ORDER BY d.data_model_section
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].category = d.data_model_section,
   CALL echo(reply->qual[cnt].category)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,cnt)
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET failed = "F"
 ELSE
  SET errcode = error(errmsg,1)
  IF (errcode=284)
   SET failed = "F"
   SET stat = alterlist(reply->qual,1)
   SET reply->qual[1].category = "<ADMIN DATA UNAVAILABLE>"
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.subeventstatus[1].operationname = "get"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "dtable"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL parser("rdb rollback go")
END GO
