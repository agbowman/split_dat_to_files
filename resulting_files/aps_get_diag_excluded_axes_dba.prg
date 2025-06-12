CREATE PROGRAM aps_get_diag_excluded_axes:dba
 RECORD reply(
   1 axes_qual[5]
     2 exclude_axis_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET x = 0
 SELECT INTO "nl:"
  apda.exclude_axis_cd
  FROM ap_prefix_diag_axis apda
  WHERE (request->prefix_cd=apda.prefix_id)
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (mod(x,5)=1
    AND x != 1)
    stat = alter(reply->axes_qual,(x+ 4))
   ENDIF
   reply->axes_qual[x].exclude_axis_cd = apda.exclude_axis_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "Z"
  SET reply->status_data.subeventstatus.targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus.targetobjectvalue = "AP_PREFIX_DIAG_AXIS"
 ELSE
  SET stat = alter(reply->axes_qual,x)
 ENDIF
#exit_script
 IF (x=0)
  SET reply->status_data.status = "Z"
  SET stat = alter(reply->axes_qual,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
