CREATE PROGRAM aps_get_exclude_axis:dba
 RECORD reply(
   1 qual[10]
     2 prefix_id = f8
     2 exclude_axis_qual[*]
       3 exclude_axis_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET exclude_axis_cnt = 0
 SELECT INTO "nl:"
  apda.prefix_id
  FROM ap_prefix_diag_axis apda
  WHERE 1=1
  ORDER BY apda.prefix_id
  HEAD REPORT
   cnt = 0
  HEAD apda.prefix_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alter(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].prefix_id = apda.prefix_id, exclude_axis_cnt = 0, stat = alterlist(reply->qual[
    cnt].exclude_axis_qual,5)
  DETAIL
   exclude_axis_cnt = (exclude_axis_cnt+ 1)
   IF (mod(exclude_axis_cnt,5)=1
    AND exclude_axis_cnt != 1)
    stat = alterlist(reply->qual[cnt].exclude_axis_qual,(exclude_axis_cnt+ 4))
   ENDIF
   reply->qual[cnt].exclude_axis_qual[exclude_axis_cnt].exclude_axis_cd = apda.exclude_axis_cd
  FOOT  apda.prefix_id
   stat = alterlist(reply->qual[cnt].exclude_axis_qual,exclude_axis_cnt)
  FOOT REPORT
   stat = alter(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX_DIAG_AXIS"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
