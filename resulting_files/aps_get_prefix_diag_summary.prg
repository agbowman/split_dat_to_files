CREATE PROGRAM aps_get_prefix_diag_summary
 RECORD reply(
   1 diag_summary_prefix_id = f8
   1 prefix_id = f8
   1 task_assay_cd = f8
   1 required_ind = i2
   1 comment_ind = i2
   1 comment_length = i2
   1 site_cd = f8
   1 prefix_cd = f8
   1 alpha_resp_qual = i2
   1 alpha_resp[*]
     2 task_assay_cd = f8
     2 task_assay_desc = c50
     2 reference_range_factor_id = f8
     2 nomenclature_id = f8
     2 short_string = c60
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
  FROM ap_prefix_diag_smry apds,
   ap_prefix ap
  PLAN (ap
   WHERE (ap.accession_format_cd=request->accn_format_cd)
    AND (ap.site_cd=request->site_cd))
   JOIN (apds
   WHERE apds.prefix_id=outerjoin(ap.prefix_id))
  DETAIL
   reply->diag_summary_prefix_id = apds.prefix_diag_smry_id, reply->prefix_id = ap.prefix_id, reply->
   task_assay_cd = apds.task_assay_cd,
   reply->required_ind = apds.required_ind, reply->comment_ind = apds.comment_ind, reply->
   comment_length = apds.comment_length_qty,
   reply->site_cd = ap.site_cd, reply->prefix_cd = ap.accession_format_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX"
  GO TO exit_script
 ELSEIF ((reply->task_assay_cd=0))
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX_DIAG_SMRY"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 EXECUTE afc_get_alpha_response  WITH replace("REQUEST","REPLY"), replace("REPLY","REPLY")
#exit_script
END GO
