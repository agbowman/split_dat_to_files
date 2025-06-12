CREATE PROGRAM aps_chg_db_ft_activity:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 ft_type_cd = f8
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cur_updt_cnt = 0
 SET count = 1
 SET term_updt_cnt[500] = 0
 SET cnt = 1
 IF ((request->ft_type_cd=0))
  SELECT INTO "nl:"
   next_seq_nbr = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    request->ft_type_cd = cnvtreal(next_seq_nbr)
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("NEXTVAL","F","SEQUENCE","REFERENCE_SEQ")
   GO TO end_of_script
  ENDIF
  INSERT  FROM code_value c
   SET c.code_set = 1317, c.code_value = request->ft_type_cd, c.display = request->short_desc,
    c.display_key = cnvtupper(cnvtalphanum(request->short_desc)), c.description = request->
    description, c.active_ind = request->active_ind,
    c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo
    ->updt_task,
    c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","CODE_VALUE, 1317")
   GO TO end_of_script
  ENDIF
  INSERT  FROM ap_ft_type ftt
   SET ftt.followup_tracking_type_cd = request->ft_type_cd, ftt.patient_notification_ind = request->
    patient_notification_ind, ftt.short_desc = request->short_desc,
    ftt.description = request->description, ftt.active_ind = request->active_ind, ftt
    .patient_notif_template_id = request->patient_notif_template_id,
    ftt.patient_first_overdue_ind = request->patient_first_overdue_ind, ftt.patient_first_template_id
     = request->patient_first_template_id, ftt.patient_final_overdue_ind = request->
    patient_final_overdue_ind,
    ftt.patient_final_template_id = request->patient_final_template_id, ftt.doctor_notification_ind
     = request->doctor_notification_ind, ftt.doctor_notif_template_id = request->
    doctor_notif_template_id,
    ftt.doctor_first_overdue_ind = request->doctor_first_overdue_ind, ftt.doctor_first_template_id =
    request->doctor_first_template_id, ftt.doctor_final_overdue_ind = request->
    doctor_final_overdue_ind,
    ftt.doctor_final_template_id = request->doctor_final_template_id, ftt.updt_cnt = 0, ftt
    .updt_dt_tm = cnvtdatetime(curdate,curtime),
    ftt.updt_id = reqinfo->updt_id, ftt.updt_task = reqinfo->updt_task, ftt.updt_applctx = reqinfo->
    updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","AP_FT_TYPE")
   GO TO end_of_script
  ENDIF
 ELSEIF ((request->ft_type_cd > 0))
  SELECT INTO "nl:"
   ftt.*
   FROM ap_ft_type ftt
   WHERE (request->ft_type_cd=ftt.followup_tracking_type_cd)
   DETAIL
    cur_updt_cnt = ftt.updt_cnt
   WITH forupdate(ftt)
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","AP_FT_TYPE")
   GO TO end_of_script
  ENDIF
  IF ((request->updt_cnt != cur_updt_cnt))
   CALL handle_errors("LOCK","F","TABLE","AP_FT_TYPE")
   GO TO end_of_script
  ENDIF
  SET cur_updt_cnt = (cur_updt_cnt+ 1)
  UPDATE  FROM ap_ft_type ftt
   SET ftt.patient_notification_ind = request->patient_notification_ind, ftt.short_desc = request->
    short_desc, ftt.description = request->description,
    ftt.active_ind = request->active_ind, ftt.patient_notif_template_id = request->
    patient_notif_template_id, ftt.patient_first_overdue_ind = request->patient_first_overdue_ind,
    ftt.patient_first_template_id = request->patient_first_template_id, ftt.patient_final_overdue_ind
     = request->patient_final_overdue_ind, ftt.patient_final_template_id = request->
    patient_final_template_id,
    ftt.doctor_notification_ind = request->doctor_notification_ind, ftt.doctor_notif_template_id =
    request->doctor_notif_template_id, ftt.doctor_first_overdue_ind = request->
    doctor_first_overdue_ind,
    ftt.doctor_first_template_id = request->doctor_first_template_id, ftt.doctor_final_overdue_ind =
    request->doctor_final_overdue_ind, ftt.doctor_final_template_id = request->
    doctor_final_template_id,
    ftt.updt_cnt = cur_updt_cnt, ftt.updt_dt_tm = cnvtdatetime(curdate,curtime), ftt.updt_id =
    reqinfo->updt_id,
    ftt.updt_task = reqinfo->updt_task, ftt.updt_applctx = reqinfo->updt_applctx
   WHERE (request->ft_type_cd=ftt.followup_tracking_type_cd)
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","AP_FT_TYPE")
   GO TO end_of_script
  ENDIF
  SELECT INTO "nl:"
   c.*
   FROM code_value c
   WHERE (request->ft_type_cd=c.code_value)
   DETAIL
    cur_updt_cnt = c.updt_cnt
   WITH forupdate(c)
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","CODE_VALUE, 1317")
   GO TO end_of_script
  ENDIF
  IF ((request->cs_updt_cnt != cur_updt_cnt))
   CALL handle_errors("LOCK","F","TABLE","CODE_VALUE, 1317")
   GO TO end_of_script
  ENDIF
  SET cur_updt_cnt = (cur_updt_cnt+ 1)
  UPDATE  FROM code_value c
   SET c.display = request->short_desc, c.display_key = cnvtupper(cnvtalphanum(request->short_desc)),
    c.description = request->description,
    c.active_ind = request->active_ind, c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id =
    reqinfo->updt_id,
    c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt =
    cur_updt_cnt
   WHERE (request->ft_type_cd=c.code_value)
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","CODE_VALUE, 1317")
   GO TO end_of_script
  ENDIF
 ENDIF
 IF ((request->term_add_cnt > 0))
  INSERT  FROM ap_ft_term_proc ft,
    (dummyt d  WITH seq = value(request->term_add_cnt))
   SET ft.followup_tracking_type_cd = request->ft_type_cd, ft.catalog_cd = request->term_add_qual[d
    .seq].catalog_cd, ft.auto_termination_ind = request->term_add_qual[d.seq].auto_term_ind,
    ft.auto_termination_reason_cd = request->term_add_qual[d.seq].auto_term_reason_cd, ft
    .look_back_days = request->term_add_qual[d.seq].look_back_days, ft.updt_dt_tm = cnvtdatetime(
     curdate,curtime),
    ft.updt_id = reqinfo->updt_id, ft.updt_task = reqinfo->updt_task, ft.updt_applctx = reqinfo->
    updt_applctx,
    ft.updt_cnt = 0
   PLAN (d)
    JOIN (ft)
   WITH nocounter
  ;end insert
  IF ((curqual != request->term_add_cnt))
   CALL handle_errors("INSERT","F","TABLE","AP_FT_TERM_PROC")
   GO TO end_of_script
  ENDIF
 ENDIF
 IF ((request->term_chg_cnt > 0))
  SELECT INTO "nl:"
   ft.*
   FROM ap_ft_term_proc ft,
    (dummyt d  WITH seq = value(request->term_chg_cnt))
   PLAN (d)
    JOIN (ft
    WHERE (request->ft_type_cd=ft.followup_tracking_type_cd)
     AND (request->term_chg_qual[d.seq].catalog_cd=ft.catalog_cd))
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1), term_updt_cnt[count] = ft.updt_cnt
   WITH forupdate(ft)
  ;end select
  IF (((curqual=0) OR ((count != request->term_chg_cnt))) )
   CALL handle_errors("SELECT","F","TABLE","AP_FT_TERM_PROC")
   GO TO end_of_script
  ENDIF
  FOR (cnt = 1 TO request->term_chg_cnt)
    IF ((term_updt_cnt[cnt] != request->term_chg_qual[cnt].updt_cnt))
     CALL handle_errors("LOCK","F","TABLE","AP_FT_TERM_PROC")
     GO TO end_of_script
    ENDIF
  ENDFOR
  UPDATE  FROM ap_ft_term_proc ft,
    (dummyt d  WITH seq = value(request->term_chg_cnt))
   SET ft.followup_tracking_type_cd = request->ft_type_cd, ft.catalog_cd = request->term_chg_qual[d
    .seq].catalog_cd, ft.auto_termination_ind = request->term_chg_qual[d.seq].auto_term_ind,
    ft.auto_termination_reason_cd = request->term_chg_qual[d.seq].auto_term_reason_cd, ft
    .look_back_days = request->term_chg_qual[d.seq].look_back_days, ft.updt_dt_tm = cnvtdatetime(
     curdate,curtime),
    ft.updt_id = reqinfo->updt_id, ft.updt_task = reqinfo->updt_task, ft.updt_applctx = reqinfo->
    updt_applctx,
    ft.updt_cnt = (term_updt_cnt[d.seq]+ 1)
   PLAN (d)
    JOIN (ft
    WHERE (request->ft_type_cd=ft.followup_tracking_type_cd)
     AND (request->term_chg_qual[d.seq].catalog_cd=ft.catalog_cd))
   WITH nocounter
  ;end update
  IF ((curqual != request->term_chg_cnt))
   CALL handle_errors("UPDATE","F","TABLE","AP_FT_TERM_PROC")
   GO TO end_of_script
  ENDIF
 ENDIF
 IF ((request->term_del_cnt > 0))
  DELETE  FROM ap_ft_term_proc ft,
    (dummyt d  WITH seq = value(request->term_del_cnt))
   SET ft.seq = 1
   PLAN (d)
    JOIN (ft
    WHERE (request->ft_type_cd=ft.followup_tracking_type_cd)
     AND (request->term_del_qual[d.seq].catalog_cd=ft.catalog_cd))
   WITH nocounter
  ;end delete
  IF ((curqual != request->term_del_cnt))
   CALL handle_errors("DELETE","F","TABLE","AP_FT_TERM_PROC")
   GO TO end_of_script
  ENDIF
 ENDIF
 IF ((request->rpt_add_cnt > 0))
  INSERT  FROM ap_ft_report_proc ft,
    (dummyt d  WITH seq = value(request->rpt_add_cnt))
   SET ft.followup_tracking_type_cd = request->ft_type_cd, ft.task_assay_cd = request->rpt_add_qual[d
    .seq].task_assay_cd, ft.updt_dt_tm = cnvtdatetime(curdate,curtime),
    ft.updt_id = reqinfo->updt_id, ft.updt_task = reqinfo->updt_task, ft.updt_applctx = reqinfo->
    updt_applctx,
    ft.updt_cnt = 0
   PLAN (d)
    JOIN (ft)
   WITH nocounter
  ;end insert
  IF ((curqual != request->rpt_add_cnt))
   CALL handle_errors("INSERT","F","TABLE","AP_FT_REPORT_PROC")
   GO TO end_of_script
  ENDIF
 ENDIF
 IF ((request->rpt_del_cnt > 0))
  DELETE  FROM ap_ft_report_proc ft,
    (dummyt d  WITH seq = value(request->rpt_del_cnt))
   SET ft.seq = 1
   PLAN (d)
    JOIN (ft
    WHERE (request->ft_type_cd=ft.followup_tracking_type_cd)
     AND (request->rpt_del_qual[d.seq].task_assay_cd=ft.task_assay_cd))
   WITH nocounter
  ;end delete
  IF ((curqual != request->rpt_del_cnt))
   CALL handle_errors("DELETE","F","TABLE","AP_FT_REPORT_PROC")
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
  COMMIT
  SET reply->ft_type_cd = request->ft_type_cd
  SET reply->status_data.status = "S"
 ELSE
  ROLLBACK
  SET reply->ft_type_cd = 0
 ENDIF
END GO
