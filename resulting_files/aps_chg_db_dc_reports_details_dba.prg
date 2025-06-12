CREATE PROGRAM aps_chg_db_dc_reports_details:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cur_updt_cnt = 0
 SET count = 1
 SET term_updt_cnt[500] = 0
 SET cnt = 1
 IF ((request->study_id=0))
  SELECT INTO "nl:"
   next_seq_nbr = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    request->study_id = cnvtreal(next_seq_nbr)
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("NEXTVAL","F","SEQUENCE","REFERENCE_SEQ")
   GO TO end_of_script
  ENDIF
  INSERT  FROM ap_dc_study ads
   SET ads.description = request->description, ads.across_case_ind = request->across_case_ind, ads
    .active_ind = request->active_ind,
    ads.slide_counts_prompt_ind = request->slide_counts_prompt_ind, ads.include_cytotechs_ind =
    request->include_cytotechs_ind, ads.default_to_group_ind = request->default_to_group_ind,
    ads.updt_cnt = 0, ads.updt_dt_tm = cnvtdatetime(curdate,curtime), ads.updt_id = reqinfo->updt_id,
    ads.updt_task = reqinfo->updt_task, ads.updt_applctx = reqinfo->updt_applctx, ads
    .service_resource_cd = request->service_resource_cd
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","AP_DC_STUDY")
   GO TO end_of_script
  ENDIF
 ELSEIF ((request->study_id > 0))
  SELECT INTO "nl:"
   ads.*
   FROM ap_dc_study ads
   WHERE (request->study_id=ads.study_id)
   DETAIL
    cur_updt_cnt = ads.updt_cnt
   WITH forupdate(ads)
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","AP_DC_STUDY")
   GO TO end_of_script
  ENDIF
  IF ((request->updt_cnt != cur_updt_cnt))
   CALL handle_errors("LOCK","F","TABLE","AP_DC_STUDY")
   GO TO end_of_script
  ENDIF
  SET cur_updt_cnt = (cur_updt_cnt+ 1)
  UPDATE  FROM ap_dc_study ads
   SET ads.description = request->description, ads.across_case_ind = request->across_case_ind, ads
    .active_ind = request->active_ind,
    ads.slide_counts_prompt_ind = request->slide_counts_prompt_ind, ads.include_cytotechs_ind =
    request->include_cytotechs_ind, ads.default_to_group_ind = request->default_to_group_ind,
    ads.updt_cnt = cur_updt_cnt, ads.updt_dt_tm = cnvtdatetime(curdate,curtime), ads.updt_id =
    reqinfo->updt_id,
    ads.updt_task = reqinfo->updt_task, ads.updt_applctx = reqinfo->updt_applctx, ads
    .service_resource_cd = request->service_resource_cd
   WHERE (request->study_id=ads.study_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","AP_DC_STUDY")
   GO TO end_of_script
  ENDIF
  IF ((request->active_ind=0))
   UPDATE  FROM ap_sys_corr apsc
    SET apsc.active_ind = 0, apsc.updt_cnt = (apsc.updt_cnt+ 1), apsc.updt_dt_tm = cnvtdatetime(
      curdate,curtime),
     apsc.updt_id = reqinfo->updt_id, apsc.updt_task = reqinfo->updt_task, apsc.updt_applctx =
     reqinfo->updt_applctx
    WHERE (request->study_id=apsc.study_id)
    WITH nocounter
   ;end update
  ENDIF
 ENDIF
 IF ((request->overwrite="Y"))
  DELETE  FROM ap_dc_study_rpt_proc adsrp
   WHERE (request->study_id=adsrp.study_id)
   WITH nocounter
  ;end delete
 ENDIF
 IF ((request->detail_add_cnt > 0))
  INSERT  FROM ap_dc_study_rpt_proc adsrp,
    (dummyt d  WITH seq = value(request->detail_add_cnt))
   SET adsrp.study_id = request->study_id, adsrp.task_assay_cd = request->detail_add_qual[d.seq].
    task_assay_cd, adsrp.updt_dt_tm = cnvtdatetime(curdate,curtime),
    adsrp.updt_id = reqinfo->updt_id, adsrp.updt_task = reqinfo->updt_task, adsrp.updt_applctx =
    reqinfo->updt_applctx,
    adsrp.updt_cnt = 0
   PLAN (d)
    JOIN (adsrp)
   WITH nocounter
  ;end insert
  IF ((curqual != request->detail_add_cnt))
   CALL handle_errors("INSERT","F","TABLE","AP_DC_STUDY_RPT_PROC")
   GO TO end_of_script
  ENDIF
 ENDIF
 IF ((request->detail_del_cnt > 0))
  DELETE  FROM ap_dc_study_rpt_proc adsrp,
    (dummyt d  WITH seq = value(request->detail_del_cnt))
   SET adsrp.seq = 1
   PLAN (d)
    JOIN (adsrp
    WHERE (request->study_id=adsrp.study_id)
     AND (request->detail_del_qual[d.seq].task_assay_cd=adsrp.task_assay_cd))
   WITH nocounter
  ;end delete
  IF ((curqual != request->detail_del_cnt))
   CALL handle_errors("DELETE","F","TABLE","AP_DC_STUDY_RPT_PROC")
   GO TO end_of_script
  ENDIF
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = op_name
   SET reply->status_data.subeventstatus[1].operationstatus = op_status
   SET reply->status_data.subeventstatus[1].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[1].targetobjectvalue = tar_value
 END ;Subroutine
#end_of_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
