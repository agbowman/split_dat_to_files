CREATE PROGRAM aps_add_db_sys_corr_params:dba
 RECORD temp(
   1 add_cnt = i2
   1 chg_cnt = i2
   1 sys_corr_qual[*]
     2 add_ind = i2
     2 chg_ind = i2
     2 study_id = f8
     2 study_sequence = i4
     2 sys_corr_id = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 DECLARE x = i2
 DECLARE y = i2
 DECLARE error_cnt = i2
 DECLARE param_cnt = i2 WITH private, noconstant(0)
 DECLARE max_param_cnt = i2
 DECLARE detail_cnt = i2 WITH private, noconstant(0)
 DECLARE max_detail_cnt = i2
 DECLARE updt_cnt_err = i2
 DECLARE sys_corr_cnt = i2
 SET error_cnt = 0
 SET max_param_cnt = 0
 SET max_detail_cnt = 0
 SET sys_corr_cnt = cnvtint(size(request->sys_corr_qual,5))
 SET stat = alterlist(temp->sys_corr_qual,sys_corr_cnt)
 FOR (x = 1 TO sys_corr_cnt)
   IF ((request->sys_corr_qual[x].sys_corr_id=0.0))
    SET temp->sys_corr_qual[x].add_ind = 1
    SET temp->sys_corr_qual[x].study_id = request->sys_corr_qual[x].study_id
    SET temp->add_cnt = (temp->add_cnt+ 1)
    SELECT INTO "nl:"
     seq_nbr = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      temp->sys_corr_qual[x].sys_corr_id = seq_nbr
     WITH format, counter
    ;end select
    IF (curqual=0)
     CALL handle_errors("NEXTVAL","F","SEQ","PATHNET")
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     apsc.study_id
     FROM ap_sys_corr apsc
     PLAN (apsc
      WHERE (temp->sys_corr_qual[x].study_id=apsc.study_id))
     HEAD REPORT
      temp->sys_corr_qual[x].study_sequence = 0
     DETAIL
      temp->sys_corr_qual[x].study_sequence = (temp->sys_corr_qual[x].study_sequence+ 1)
     WITH nocounter
    ;end select
    FOR (y = 1 TO x)
      IF ((temp->sys_corr_qual[y].study_id=temp->sys_corr_qual[x].study_id))
       SET temp->sys_corr_qual[x].study_sequence = (temp->sys_corr_qual[x].study_sequence+ 1)
      ENDIF
    ENDFOR
   ELSE
    SET temp->sys_corr_qual[x].chg_ind = 1
    SET temp->chg_cnt = (temp->chg_cnt+ 1)
   ENDIF
   SET param_cnt = cnvtint(size(request->sys_corr_qual[x].param_qual,5))
   IF (param_cnt > max_param_cnt)
    SET max_param_cnt = param_cnt
   ENDIF
   FOR (y = 1 TO param_cnt)
    SET detail_cnt = cnvtint(size(request->sys_corr_qual[x].param_qual[y].detail_qual,5))
    IF (detail_cnt > max_detail_cnt)
     SET max_detail_cnt = detail_cnt
    ENDIF
   ENDFOR
 ENDFOR
 IF ((temp->chg_cnt > 0))
  SELECT INTO "nl:"
   apsc.sys_corr_id
   FROM ap_sys_corr apsc,
    (dummyt d  WITH seq = value(sys_corr_cnt))
   PLAN (d
    WHERE (temp->sys_corr_qual[d.seq].chg_ind=1))
    JOIN (apsc
    WHERE (request->sys_corr_qual[d.seq].sys_corr_id=apsc.sys_corr_id))
   HEAD REPORT
    updt_cnt_err = 0
   DETAIL
    IF ((request->sys_corr_qual[d.seq].updt_cnt=apsc.updt_cnt))
     temp->sys_corr_qual[d.seq].sys_corr_id = request->sys_corr_qual[d.seq].sys_corr_id
    ELSE
     updt_cnt_err = 1
    ENDIF
   WITH nocounter, forupdate(apsc)
  ;end select
  IF (curqual=0)
   CALL handle_errors("LOCK","F","TABLE","AP_SYS_CORR")
   GO TO exit_script
  ENDIF
  IF (updt_cnt_err=1)
   CALL handle_errors("UPDT_CNT","F","TABLE","AP_SYS_CORR")
   GO TO exit_script
  ENDIF
  UPDATE  FROM ap_sys_corr apsc,
    (dummyt d  WITH seq = value(sys_corr_cnt))
   SET apsc.study_id = request->sys_corr_qual[d.seq].study_id, apsc.case_percentage = request->
    sys_corr_qual[d.seq].case_percentage, apsc.active_ind = request->sys_corr_qual[d.seq].active_ind,
    apsc.execute_on_rescreen_ind = request->sys_corr_qual[d.seq].execute_on_rescreen_ind, apsc
    .lookback_case_type_cd = request->sys_corr_qual[d.seq].lookback_case_type_cd, apsc
    .lookback_months = request->sys_corr_qual[d.seq].lookback_months,
    apsc.lookback_all_cases_ind = request->sys_corr_qual[d.seq].lookback_all_cases_ind, apsc
    .notify_user_online_ind = request->sys_corr_qual[d.seq].notify_user_online_ind, apsc
    .assign_to_group_ind = request->sys_corr_qual[d.seq].assign_to_group_ind,
    apsc.assign_to_group_id = request->sys_corr_qual[d.seq].assign_to_group_id, apsc
    .assign_to_prsnl_id = request->sys_corr_qual[d.seq].assign_to_prsnl_id, apsc
    .assign_to_verifying_ind = request->sys_corr_qual[d.seq].assign_to_verifying_ind,
    apsc.updt_dt_tm = cnvtdatetime(curdate,curtime), apsc.updt_id = reqinfo->updt_id, apsc.updt_task
     = reqinfo->updt_task,
    apsc.updt_applctx = reqinfo->updt_applctx, apsc.updt_cnt = (apsc.updt_cnt+ 1)
   PLAN (d
    WHERE (temp->sys_corr_qual[d.seq].chg_ind=1)
     AND (temp->sys_corr_qual[d.seq].sys_corr_id != 0.0))
    JOIN (apsc
    WHERE (apsc.sys_corr_id=temp->sys_corr_qual[d.seq].sys_corr_id))
   WITH nocounter
  ;end update
  IF ((curqual != temp->chg_cnt))
   CALL handle_errors("UPDATE","F","TABLE","AP_SYS_CORR")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((temp->add_cnt > 0))
  INSERT  FROM ap_sys_corr apsc,
    (dummyt d  WITH seq = value(sys_corr_cnt))
   SET apsc.sys_corr_id = temp->sys_corr_qual[d.seq].sys_corr_id, apsc.study_id = temp->
    sys_corr_qual[d.seq].study_id, apsc.study_sequence = temp->sys_corr_qual[d.seq].study_sequence,
    apsc.case_percentage = request->sys_corr_qual[d.seq].case_percentage, apsc.active_ind = request->
    sys_corr_qual[d.seq].active_ind, apsc.execute_on_rescreen_ind = request->sys_corr_qual[d.seq].
    execute_on_rescreen_ind,
    apsc.lookback_case_type_cd = request->sys_corr_qual[d.seq].lookback_case_type_cd, apsc
    .lookback_months = request->sys_corr_qual[d.seq].lookback_months, apsc.lookback_all_cases_ind =
    request->sys_corr_qual[d.seq].lookback_all_cases_ind,
    apsc.notify_user_online_ind = request->sys_corr_qual[d.seq].notify_user_online_ind, apsc
    .assign_to_group_ind = request->sys_corr_qual[d.seq].assign_to_group_ind, apsc.assign_to_group_id
     = request->sys_corr_qual[d.seq].assign_to_group_id,
    apsc.assign_to_prsnl_id = request->sys_corr_qual[d.seq].assign_to_prsnl_id, apsc
    .assign_to_verifying_ind = request->sys_corr_qual[d.seq].assign_to_verifying_ind, apsc.updt_dt_tm
     = cnvtdatetime(curdate,curtime),
    apsc.updt_id = reqinfo->updt_id, apsc.updt_task = reqinfo->updt_task, apsc.updt_applctx = reqinfo
    ->updt_applctx,
    apsc.updt_cnt = 0
   PLAN (d
    WHERE (temp->sys_corr_qual[d.seq].add_ind=1)
     AND (temp->sys_corr_qual[d.seq].sys_corr_id != 0.0))
    JOIN (apsc
    WHERE 1=1)
   WITH nocounter
  ;end insert
  IF ((curqual != temp->add_cnt))
   CALL handle_errors("INSERT","F","TABLE","AP_SYS_CORR")
   GO TO exit_script
  ENDIF
  INSERT  FROM ap_sys_corr_counts apscc,
    (dummyt d  WITH seq = value(sys_corr_cnt))
   SET apscc.sys_corr_id = temp->sys_corr_qual[d.seq].sys_corr_id, apscc.total_cases = 0, apscc
    .qualified_cases = 0,
    apscc.updt_dt_tm = cnvtdatetime(curdate,curtime), apscc.updt_id = reqinfo->updt_id, apscc
    .updt_task = reqinfo->updt_task,
    apscc.updt_applctx = reqinfo->updt_applctx, apscc.updt_cnt = 0
   PLAN (d
    WHERE (temp->sys_corr_qual[d.seq].add_ind=1)
     AND (temp->sys_corr_qual[d.seq].sys_corr_id != 0.0))
    JOIN (apscc
    WHERE 1=1)
   WITH nocounter
  ;end insert
  IF ((curqual != temp->add_cnt))
   CALL handle_errors("INSERT","F","TABLE","AP_SYS_CORR_COUNTS")
   GO TO exit_script
  ENDIF
 ENDIF
 DELETE  FROM ap_sys_corr_detail ascd,
   (dummyt d  WITH seq = value(sys_corr_cnt))
  SET ascd.sys_corr_id = temp->sys_corr_qual[d.seq].sys_corr_id
  PLAN (d
   WHERE (temp->sys_corr_qual[d.seq].sys_corr_id != 0.0)
    AND (request->sys_corr_qual[d.seq].updt_trigger_details_ind=1))
   JOIN (ascd
   WHERE (ascd.sys_corr_id=temp->sys_corr_qual[d.seq].sys_corr_id)
    AND ascd.lookback_ind=0)
  WITH nocounter
 ;end delete
 DELETE  FROM ap_sys_corr_detail ascd,
   (dummyt d  WITH seq = value(sys_corr_cnt))
  SET ascd.sys_corr_id = temp->sys_corr_qual[d.seq].sys_corr_id
  PLAN (d
   WHERE (temp->sys_corr_qual[d.seq].sys_corr_id != 0.0)
    AND (request->sys_corr_qual[d.seq].updt_lookback_details_ind=1))
   JOIN (ascd
   WHERE (ascd.sys_corr_id=temp->sys_corr_qual[d.seq].sys_corr_id)
    AND ascd.lookback_ind=1)
  WITH nocounter
 ;end delete
 IF (max_param_cnt > 0)
  INSERT  FROM ap_sys_corr_detail ascd,
    (dummyt d  WITH seq = value(sys_corr_cnt)),
    (dummyt d2  WITH seq = value(max_param_cnt)),
    (dummyt d3  WITH seq = value(max_detail_cnt))
   SET ascd.sys_corr_detail_id = seq(pathnet_seq,nextval), ascd.sys_corr_id = temp->sys_corr_qual[d
    .seq].sys_corr_id, ascd.param_name = request->sys_corr_qual[d.seq].param_qual[d2.seq].param_name,
    ascd.param_sequence = request->sys_corr_qual[d.seq].param_qual[d2.seq].param_sequence, ascd
    .lookback_ind = request->sys_corr_qual[d.seq].param_qual[d2.seq].lookback_ind, ascd
    .parent_entity_name = request->sys_corr_qual[d.seq].param_qual[d2.seq].detail_qual[d3.seq].
    parent_entity_name,
    ascd.parent_entity_id = request->sys_corr_qual[d.seq].param_qual[d2.seq].detail_qual[d3.seq].
    parent_entity_id, ascd.updt_dt_tm = cnvtdatetime(curdate,curtime), ascd.updt_id = reqinfo->
    updt_id,
    ascd.updt_task = reqinfo->updt_task, ascd.updt_applctx = reqinfo->updt_applctx, ascd.updt_cnt = 0
   PLAN (d
    WHERE (temp->sys_corr_qual[d.seq].sys_corr_id != 0.0))
    JOIN (d2
    WHERE d2.seq <= cnvtint(size(request->sys_corr_qual[d.seq].param_qual,5)))
    JOIN (d3
    WHERE d3.seq <= cnvtint(size(request->sys_corr_qual[d.seq].param_qual[d2.seq].detail_qual,5)))
    JOIN (ascd
    WHERE 1=1)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","AP_SYS_CORR_DETAIL")
  ENDIF
 ENDIF
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 GO TO end_of_program
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#end_of_program
END GO
