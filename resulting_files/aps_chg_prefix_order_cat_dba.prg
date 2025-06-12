CREATE PROGRAM aps_chg_prefix_order_cat:dba
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
 SET count1 = 0
#start_of_script
 IF ((request->action="C"))
  SELECT INTO "nl:"
   ap.prefix_id
   FROM ap_prefix ap
   WHERE (ap.prefix_id=request->prefix_cd)
   DETAIL
    cur_updt_cnt = ap.updt_cnt
   WITH forupdate(ap)
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","AP_PREFIX")
   GO TO exit_script
  ENDIF
  IF ((request->updt_cnt != cur_updt_cnt))
   CALL handle_errors("LOCK","F","TABLE","AP_PREFIX")
   GO TO exit_script
  ENDIF
  SET cur_updt_cnt = (cur_updt_cnt+ 1)
  UPDATE  FROM ap_prefix ap
   SET ap.default_proc_catalog_cd = request->default_proc_catalog_cd, ap.updt_dt_tm = cnvtdatetime(
     curdate,curtime), ap.updt_cnt = cur_updt_cnt,
    ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
    updt_applctx
   WHERE (ap.prefix_id=request->prefix_cd)
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","AP_PREFIX")
   GO TO exit_script
  ENDIF
  SET reply->updt_cnt = cur_updt_cnt
 ENDIF
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
    request->rpt_add_qual[d.seq].reporting_sequence, prr.updt_dt_tm = cnvtdatetime(curdate,curtime),
    prr.updt_id = reqinfo->updt_id, prr.updt_task = reqinfo->updt_task, prr.updt_applctx = reqinfo->
    updt_applctx,
    prr.updt_cnt = 0
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
    prr.reporting_sequence = request->rpt_chg_qual[d.seq].reporting_sequence, prr.updt_dt_tm =
    cnvtdatetime(curdate,curtime), prr.updt_id = reqinfo->updt_id,
    prr.updt_task = reqinfo->updt_task, prr.updt_applctx = reqinfo->updt_applctx, prr.updt_cnt = (prr
    .updt_cnt+ 1)
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
 IF ((request->proc_del_cnt > 0))
  DELETE  FROM ap_prefix_auto_task apat,
    (dummyt d  WITH seq = value(request->proc_del_cnt))
   SET apat.seq = 1
   PLAN (d)
    JOIN (apat
    WHERE (request->prefix_cd=apat.prefix_id)
     AND (request->proc_del_qual[d.seq].catalog_cd=apat.catalog_cd))
   WITH nocounter
  ;end delete
  IF ((curqual != request->proc_del_cnt))
   CALL handle_errors("DELETE","F","TABLE","AP_PREFIX_AUTO_TASK")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->proc_add_cnt > 0))
  INSERT  FROM ap_prefix_auto_task apat,
    (dummyt d  WITH seq = value(request->proc_add_cnt))
   SET apat.prefix_id = request->prefix_cd, apat.catalog_cd = request->proc_add_qual[d.seq].
    catalog_cd, apat.specimen_ind = request->proc_add_qual[d.seq].per_spec_ind,
    apat.updt_dt_tm = cnvtdatetime(curdate,curtime), apat.updt_id = reqinfo->updt_id, apat.updt_task
     = reqinfo->updt_task,
    apat.updt_applctx = reqinfo->updt_applctx, apat.updt_cnt = 0
   PLAN (d)
    JOIN (apat)
   WITH nocounter
  ;end insert
  IF ((curqual != request->proc_add_cnt))
   CALL handle_errors("ADD","F","TABLE","AP_PREFIX_AUTO_TASK")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->proc_chg_cnt > 0))
  SELECT INTO "nl:"
   apat.catalog_cd
   FROM ap_prefix_auto_task apat,
    (dummyt d  WITH seq = value(request->proc_chg_cnt))
   PLAN (d)
    JOIN (apat
    WHERE (apat.prefix_id=request->prefix_cd)
     AND (apat.catalog_cd=request->proc_chg_qual[d.seq].catalog_cd))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), cur_updt_cnt2[count1] = apat.updt_cnt
   WITH nocounter, forupdate(apat)
  ;end select
  IF ((curqual != request->proc_chg_cnt))
   CALL handle_errors("SELECT","F","TABLE","AP_PREFIX_AUTO_TASK")
   GO TO exit_script
  ENDIF
  FOR (xx = 1 TO request->proc_chg_cnt)
    IF ((request->proc_chg_qual[xx].updt_cnt != cur_updt_cnt2[xx]))
     CALL handle_errors("LOCK","F","TABLE","AP_PREFIX_AUTO_TASK")
     GO TO exit_script
    ENDIF
  ENDFOR
  UPDATE  FROM ap_prefix_auto_task apat,
    (dummyt d  WITH seq = value(request->proc_add_cnt))
   SET apat.prefix_id = request->prefix_cd, apat.catalog_cd = request->proc_chg_qual[d.seq].
    catalog_cd, apat.specimen_ind = request->proc_chg_qual[d.seq].per_spec_ind,
    apat.updt_dt_tm = cnvtdatetime(curdate,curtime), apat.updt_id = reqinfo->updt_id, apat.updt_task
     = reqinfo->updt_task,
    apat.updt_applctx = reqinfo->updt_applctx, apat.updt_cnt = (apat.updt_cnt+ 1)
   PLAN (d)
    JOIN (apat
    WHERE (apat.prefix_id=request->prefix_cd)
     AND (apat.catalog_cd=request->proc_chg_qual[d.seq].catalog_cd))
   WITH nocounter
  ;end update
  IF ((curqual != request->proc_chg_cnt))
   CALL handle_errors("UPDATE","F","TABLE","AP_PREFIX_AUTO_TASK")
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
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
