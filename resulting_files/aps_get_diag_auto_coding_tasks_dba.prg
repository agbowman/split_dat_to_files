CREATE PROGRAM aps_get_diag_auto_coding_tasks:dba
 RECORD reply(
   1 rpt_qual[*]
     2 catalog_cd = f8
     2 description = vc
     2 mnemonic = vc
     2 det_cnt = i4
     2 det_qual[*]
       3 task_assay_cd = f8
       3 task_assay_disp = vc
       3 task_assay_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET max_det_cnt = 00000
 SET det_cnt = 00000
 SET grp_cnt = 00000
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  adac.*, oc.catalog_cd, oc.description,
  oc.primary_mnemonic, dta.task_assay_cd, dta.description
  FROM ap_diag_auto_code adac,
   order_catalog oc,
   discrete_task_assay dta
  PLAN (adac)
   JOIN (oc
   WHERE adac.catalog_cd=oc.catalog_cd
    AND oc.active_ind=1)
   JOIN (dta
   WHERE adac.task_assay_cd=dta.task_assay_cd)
  ORDER BY oc.primary_mnemonic, dta.description
  HEAD oc.catalog_cd
   det_cnt = 0, grp_cnt = (grp_cnt+ 1), stat = alterlist(reply->rpt_qual,grp_cnt),
   reply->rpt_qual[grp_cnt].catalog_cd = oc.catalog_cd, reply->rpt_qual[grp_cnt].description = oc
   .description, reply->rpt_qual[grp_cnt].mnemonic = oc.primary_mnemonic,
   reply->rpt_qual[grp_cnt].det_cnt = 0
  DETAIL
   det_cnt = (det_cnt+ 1), stat = alterlist(reply->rpt_qual[grp_cnt].det_qual,det_cnt), reply->
   rpt_qual[grp_cnt].det_cnt = det_cnt,
   reply->rpt_qual[grp_cnt].det_qual[det_cnt].task_assay_cd = dta.task_assay_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DISCRETE_TASK_ASSAY"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
