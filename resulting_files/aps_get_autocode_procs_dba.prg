CREATE PROGRAM aps_get_autocode_procs:dba
 RECORD reply(
   1 qual[*]
     2 catalog_cd = f8
     2 task_assay_cd = f8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET x = 0
 SELECT INTO "nl:"
  adac.catalog_cd, adac.task_assay_cd
  FROM ap_diag_auto_code adac
  HEAD REPORT
   x = 0, stat = alterlist(reply->qual,10)
  DETAIL
   x = (x+ 1)
   IF (mod(x,10)=1
    AND x != 1)
    stat = alterlist(reply->qual,(x+ 9))
   ENDIF
   reply->qual[x].catalog_cd = adac.catalog_cd, reply->qual[x].task_assay_cd = adac.task_assay_cd,
   reply->qual[x].updt_cnt = adac.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->qual,x)
  WITH nocounter
 ;end select
 IF (x=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_DIAG_AUTO_CODE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
