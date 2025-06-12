CREATE PROGRAM aps_get_reports_details:dba
 SET max_det_cnt = 00000
 SET det_cnt = 00000
 SET grp_cnt = 00000
 IF ((validate(reply->rpt_qual[1].catalog_cd,- (1))=- (1)))
  RECORD reply(
    1 rpt_qual[*]
      2 catalog_cd = f8
      2 description = vc
      2 mnemonic = vc
      2 active_ind = i2
      2 det_cnt = i4
      2 det_qual[*]
        3 task_assay_cd = f8
        3 task_assay_disp = vc
        3 task_assay_desc = vc
        3 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET reply->status_data.status = "F"
 ENDIF
 SELECT INTO "nl:"
  ptr.task_assay_cd, c.code_value, oc.catalog_cd,
  oc.description, oc.primary_mnemonic
  FROM code_value c,
   order_catalog oc,
   profile_task_r ptr
  PLAN (c
   WHERE c.code_set=5801
    AND c.cdf_meaning="APREPORT"
    AND c.active_ind=1)
   JOIN (oc
   WHERE c.code_value=oc.activity_subtype_cd
    AND parser(
    IF ((request->bshowinactives=0)) "oc.active_ind = 1"
    ELSE "1 = 1"
    ENDIF
    ))
   JOIN (ptr
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND parser(
    IF ((request->bshowinactives=0)) "ptr.active_ind = 1"
    ELSE "1 = 1"
    ENDIF
    ))
  ORDER BY oc.catalog_cd
  HEAD oc.catalog_cd
   det_cnt = 0, grp_cnt = (grp_cnt+ 1), stat = alterlist(reply->rpt_qual,grp_cnt),
   reply->rpt_qual[grp_cnt].catalog_cd = oc.catalog_cd, reply->rpt_qual[grp_cnt].description = oc
   .description, reply->rpt_qual[grp_cnt].mnemonic = oc.primary_mnemonic,
   reply->rpt_qual[grp_cnt].active_ind = oc.active_ind, reply->rpt_qual[grp_cnt].det_cnt = 0
  DETAIL
   det_cnt = (det_cnt+ 1), stat = alterlist(reply->rpt_qual[grp_cnt].det_qual,det_cnt), reply->
   rpt_qual[grp_cnt].det_cnt = det_cnt,
   reply->rpt_qual[grp_cnt].det_qual[det_cnt].task_assay_cd = ptr.task_assay_cd, reply->rpt_qual[
   grp_cnt].det_qual[det_cnt].active_ind = ptr.active_ind
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
