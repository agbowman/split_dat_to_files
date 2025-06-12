CREATE PROGRAM aps_get_diag_dflt_proc:dba
 RECORD reply(
   1 default_diag_proc = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  prr.catalog_cd
  FROM prefix_report_r prr
  WHERE (prr.catalog_cd=request->catalog_cd)
   AND (prr.prefix_id=request->prefix_id)
  DETAIL
   reply->default_diag_proc = prr.dflt_diagnostic_task_assay_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PREFIX_REPORT_R"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
