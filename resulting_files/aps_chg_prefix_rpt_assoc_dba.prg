CREATE PROGRAM aps_chg_prefix_rpt_assoc:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 updt_cnt = i4
 )
 SET reply->status_data.status = "F"
 SET reply->updt_cnt = request->updt_cnt
 SET cur_updt_cnt = 0
 SET x = 1
 SET error_cnt = 0
 SET cur_updt_cnt2[500] = 0
 SET cur_updt_cnt3[500] = 0
 SET count1 = 0
 SET count2 = 0
#start_of_script
 IF ((request->rpt_del_cnt > 0))
  DELETE  FROM prefix_report_r prr,
    (dummyt d  WITH seq = value(request->rpt_del_cnt))
   SET prr.seq = 1
   PLAN (d)
    JOIN (prr
    WHERE (request->prefix_cd=prr.prefix_id)
     AND (request->rpt_del_qual[d.seq].catalog_cd=prr.catalog_cd))
   WITH nocounter
  ;end delete
  IF ((curqual != request->rpt_del_cnt))
   CALL handle_errors("DELETE","F","TABLE","PREFIX_REPORT_R")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->rpt_add_cnt > 0))
  INSERT  FROM prefix_report_r prr,
    (dummyt d  WITH seq = value(request->rpt_add_cnt))
   SET prr.prefix_id = request->prefix_cd, prr.catalog_cd = request->rpt_add_qual[d.seq].catalog_cd,
    prr.primary_ind = request->rpt_add_qual[d.seq].primary_ind,
    prr.mult_allowed_ind = request->rpt_add_qual[d.seq].mult_allowed_ind, prr.reporting_sequence =
    request->rpt_add_qual[d.seq].reporting_sequence, prr.dflt_diagnostic_task_assay_cd = request->
    rpt_add_qual[d.seq].dflt_task_assay_cd,
    prr.report_type_cd = request->rpt_add_qual[d.seq].report_type_cd, prr.updt_dt_tm = cnvtdatetime(
     curdate,curtime), prr.updt_id = reqinfo->updt_id,
    prr.updt_task = reqinfo->updt_task, prr.updt_applctx = reqinfo->updt_applctx, prr.updt_cnt = 0
   PLAN (d)
    JOIN (prr)
   WITH nocounter
  ;end insert
  IF ((curqual != request->rpt_add_cnt))
   CALL handle_errors("ADD","F","TABLE","PREFIX_REPORT_R")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->rpt_chg_cnt > 0))
  SELECT INTO "nl:"
   prr.catalog_cd
   FROM prefix_report_r prr,
    (dummyt d  WITH seq = value(request->rpt_chg_cnt))
   PLAN (d)
    JOIN (prr
    WHERE (prr.prefix_id=request->prefix_cd)
     AND (prr.catalog_cd=request->rpt_chg_qual[d.seq].catalog_cd))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), cur_updt_cnt2[count1] = prr.updt_cnt
   WITH nocounter, forupdate(prr)
  ;end select
  IF ((count1 != request->rpt_chg_cnt))
   CALL handle_errors("SELECT","F","TABLE","PREFIX_REPORT_R")
   GO TO exit_script
  ENDIF
  FOR (xx = 1 TO request->rpt_chg_cnt)
    IF ((request->rpt_chg_qual[xx].updt_cnt != cur_updt_cnt2[xx]))
     CALL handle_errors("LOCK","F","TABLE","PREFIX_REPORT_R")
     GO TO exit_script
    ENDIF
  ENDFOR
  UPDATE  FROM prefix_report_r prr,
    (dummyt d  WITH seq = value(request->rpt_chg_cnt))
   SET prr.catalog_cd = request->rpt_chg_qual[d.seq].catalog_cd, prr.primary_ind = request->
    rpt_chg_qual[d.seq].primary_ind, prr.mult_allowed_ind = request->rpt_chg_qual[d.seq].
    mult_allowed_ind,
    prr.reporting_sequence = request->rpt_chg_qual[d.seq].reporting_sequence, prr
    .dflt_diagnostic_task_assay_cd = request->rpt_chg_qual[d.seq].dflt_task_assay_cd, prr
    .report_type_cd = request->rpt_chg_qual[d.seq].report_type_cd,
    prr.updt_dt_tm = cnvtdatetime(curdate,curtime), prr.updt_id = reqinfo->updt_id, prr.updt_task =
    reqinfo->updt_task,
    prr.updt_applctx = reqinfo->updt_applctx, prr.updt_cnt = (prr.updt_cnt+ 1)
   PLAN (d)
    JOIN (prr
    WHERE (prr.prefix_id=request->prefix_cd)
     AND (prr.catalog_cd=request->rpt_chg_qual[d.seq].catalog_cd))
   WITH nocounter
  ;end update
  IF ((curqual != request->rpt_chg_cnt))
   CALL handle_errors("UPDATE","F","TABLE","PREFIX_REPORT_R")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->auto_task_del_cnt > 0))
  DELETE  FROM ap_prefix_auto_task apat,
    (dummyt d  WITH seq = value(request->auto_task_del_cnt))
   SET apat.seq = 1
   PLAN (d)
    JOIN (apat
    WHERE (request->prefix_cd=apat.prefix_id)
     AND (request->auto_task_del_qual[d.seq].catalog_cd=apat.catalog_cd))
   WITH nocounter
  ;end delete
  IF ((curqual != request->auto_task_del_cnt))
   CALL handle_errors("DELETE","F","TABLE","AP_PREFIX_AUTO_TASK")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->auto_task_add_cnt > 0))
  INSERT  FROM ap_prefix_auto_task apat,
    (dummyt d  WITH seq = value(request->auto_task_add_cnt))
   SET apat.prefix_id = request->prefix_cd, apat.catalog_cd = request->auto_task_add_qual[d.seq].
    catalog_cd, apat.specimen_ind = request->auto_task_add_qual[d.seq].per_spec_ind,
    apat.updt_dt_tm = cnvtdatetime(curdate,curtime), apat.updt_id = reqinfo->updt_id, apat.updt_task
     = reqinfo->updt_task,
    apat.updt_applctx = reqinfo->updt_applctx, apat.updt_cnt = 0
   PLAN (d)
    JOIN (apat)
   WITH nocounter
  ;end insert
  IF ((curqual != request->auto_task_add_cnt))
   CALL handle_errors("ADD","F","TABLE","AP_PREFIX_AUTO_TASK")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->rpt_style_del_cnt > 0))
  DELETE  FROM prefix_rpt_font_info prfi,
    (dummyt d  WITH seq = value(request->rpt_style_del_cnt))
   SET prfi.seq = 1
   PLAN (d)
    JOIN (prfi
    WHERE (request->prefix_cd=prfi.prefix_id)
     AND (request->rpt_style_del_qual[d.seq].catalog_cd=prfi.catalog_cd)
     AND (request->rpt_style_del_qual[d.seq].task_assay_cd=prfi.task_assay_cd))
   WITH nocounter
  ;end delete
  IF ((curqual != request->rpt_style_del_cnt))
   CALL handle_errors("DELETE","F","TABLE","PREFIX_RPT_FONT_INFO")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->rpt_style_add_cnt > 0))
  INSERT  FROM prefix_rpt_font_info prfi,
    (dummyt d  WITH seq = value(request->rpt_style_add_cnt))
   SET prfi.prefix_id = request->prefix_cd, prfi.catalog_cd = request->rpt_style_add_qual[d.seq].
    catalog_cd, prfi.font_attribute_flag = request->rpt_style_add_qual[d.seq].font_attribute_flag,
    prfi.font_color = request->rpt_style_add_qual[d.seq].font_color, prfi.font_name = request->
    rpt_style_add_qual[d.seq].font_name, prfi.font_size = request->rpt_style_add_qual[d.seq].
    font_size,
    prfi.section_type_flag = request->rpt_style_add_qual[d.seq].section_type_flag, prfi.task_assay_cd
     = request->rpt_style_add_qual[d.seq].task_assay_cd, prfi.updt_dt_tm = cnvtdatetime(curdate,
     curtime),
    prfi.updt_id = reqinfo->updt_id, prfi.updt_task = reqinfo->updt_task, prfi.updt_applctx = reqinfo
    ->updt_applctx,
    prfi.updt_cnt = 0
   PLAN (d)
    JOIN (prfi)
   WITH nocounter
  ;end insert
  IF ((curqual != request->rpt_style_add_cnt))
   CALL handle_errors("ADD","F","TABLE","PREFIX_RPT_FONT_INFO")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->rpt_style_chg_cnt > 0))
  SELECT INTO "nl:"
   prfi.catalog_cd
   FROM prefix_rpt_font_info prfi,
    (dummyt d  WITH seq = value(request->rpt_style_chg_cnt))
   PLAN (d)
    JOIN (prfi
    WHERE (prfi.prefix_id=request->prefix_cd)
     AND (prfi.catalog_cd=request->rpt_style_chg_qual[d.seq].catalog_cd)
     AND (prfi.section_type_flag=request->rpt_style_chg_qual[d.seq].section_type_flag)
     AND (prfi.task_assay_cd=request->rpt_style_chg_qual[d.seq].task_assay_cd))
   HEAD REPORT
    count2 = 0
   DETAIL
    count2 = (count2+ 1),
    CALL echo(count2), cur_updt_cnt3[count2] = prfi.updt_cnt
   WITH nocounter, forupdate(prfi)
  ;end select
  IF ((count2 != request->rpt_style_chg_cnt))
   CALL handle_errors("SELECT","F","TABLE","PREFIX_RPT_FONT_INFO")
   GO TO exit_script
  ENDIF
  FOR (xx = 1 TO request->rpt_style_chg_cnt)
    IF ((request->rpt_style_chg_qual[xx].updt_cnt != cur_updt_cnt3[xx]))
     CALL handle_errors("LOCK","F","TABLE","PREFIX_RPT_FONT_INFO")
     GO TO exit_script
    ENDIF
  ENDFOR
  UPDATE  FROM prefix_rpt_font_info prfi,
    (dummyt d  WITH seq = value(request->rpt_style_chg_cnt))
   SET prfi.font_attribute_flag = request->rpt_style_chg_qual[d.seq].font_attribute_flag, prfi
    .font_color = request->rpt_style_chg_qual[d.seq].font_color, prfi.font_name = request->
    rpt_style_chg_qual[d.seq].font_name,
    prfi.font_size = request->rpt_style_chg_qual[d.seq].font_size, prfi.task_assay_cd = request->
    rpt_style_chg_qual[d.seq].task_assay_cd, prfi.updt_dt_tm = cnvtdatetime(curdate,curtime),
    prfi.updt_id = reqinfo->updt_id, prfi.updt_task = reqinfo->updt_task, prfi.updt_applctx = reqinfo
    ->updt_applctx,
    prfi.updt_cnt = (prfi.updt_cnt+ 1)
   PLAN (d)
    JOIN (prfi
    WHERE (prfi.prefix_id=request->prefix_cd)
     AND (prfi.catalog_cd=request->rpt_style_chg_qual[d.seq].catalog_cd)
     AND (prfi.section_type_flag=request->rpt_style_chg_qual[d.seq].section_type_flag)
     AND (prfi.task_assay_cd=request->rpt_style_chg_qual[d.seq].task_assay_cd))
   WITH nocounter
  ;end update
  IF ((curqual != request->rpt_style_chg_cnt))
   CALL handle_errors("UPDATE","F","TABLE","PREFIX_RPT_FONT_INFO")
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
END GO
