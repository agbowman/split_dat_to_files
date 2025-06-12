CREATE PROGRAM aps_get_db_dc_reports_details:dba
 RECORD reply(
   1 study_id = f8
   1 description = vc
   1 across_case_ind = i2
   1 active_ind = i2
   1 slide_counts_prompt_ind = i2
   1 include_cytotechs_ind = i2
   1 default_to_group_ind = i2
   1 triggers_exist_ind = i2
   1 updt_cnt = i4
   1 detail_qual[*]
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 updt_cnt = i4
   1 service_resource_cd = f8
   1 service_resource_disp = c40
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
 SET failed = "F"
 SET x = 0
 SET err_cnt = 0
 SELECT INTO "nl:"
  ads.study_id, join_sys_corr = decode(apsc.seq,"Y","N")
  FROM ap_dc_study ads,
   ap_sys_corr apsc,
   (dummyt d  WITH seq = 1)
  PLAN (ads
   WHERE (ads.study_id=request->study_id))
   JOIN (d)
   JOIN (apsc
   WHERE apsc.study_id=ads.study_id)
  ORDER BY ads.study_id
  HEAD REPORT
   null_var = 0
  DETAIL
   reply->study_id = ads.study_id, reply->description = ads.description, reply->across_case_ind = ads
   .across_case_ind,
   reply->active_ind = ads.active_ind, reply->slide_counts_prompt_ind = ads.slide_counts_prompt_ind,
   reply->include_cytotechs_ind = ads.include_cytotechs_ind,
   reply->default_to_group_ind = ads.default_to_group_ind, reply->updt_cnt = ads.updt_cnt
   IF (join_sys_corr="Y")
    reply->triggers_exist_ind = 1
   ENDIF
   reply->service_resource_cd = ads.service_resource_cd
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "AP_DC_STUDY"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  adsrp.task_assay_cd
  FROM ap_dc_study_rpt_proc adsrp
  WHERE (reply->study_id=adsrp.study_id)
   AND (reply->study_id > 0)
  ORDER BY adsrp.study_id
  HEAD REPORT
   y = 0
  DETAIL
   y = (y+ 1), stat = alterlist(reply->detail_qual,y), reply->detail_qual[y].task_assay_cd = adsrp
   .task_assay_cd,
   reply->detail_qual[y].updt_cnt = adsrp.updt_cnt
  WITH nocounter
 ;end select
#exit_script
 IF (failed="F")
  IF ((reply->study_id=0))
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
