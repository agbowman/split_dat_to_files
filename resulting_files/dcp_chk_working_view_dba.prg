CREATE PROGRAM dcp_chk_working_view:dba
 RECORD reply(
   1 dup_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->dup_ind = 0
 SELECT INTO "nl:"
  FROM working_view wv
  WHERE (wv.position_cd=request->position_cd)
   AND (wv.location_cd=request->location_cd)
   AND (wv.display_name=request->display_name)
  DETAIL
   IF ((((request->future_version_flag=0)
    AND wv.version_num > 0) OR ((request->future_version_flag=1)
    AND wv.version_num=0)) )
    reply->dup_ind = 1
   ENDIF
 ;end select
 SET reply->status_data.status = "S"
END GO
