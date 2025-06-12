CREATE PROGRAM aps_chg_cyto_user_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 join_table = c8
     2 prsnl_id = f8
 )
#script
 SET reply->status_data.status = "F"
 SET error_cnt = 0
 SET x = 1
 SET y = 1
 SET z = 1
 SET proficiency_add_cnt = request->proficiency_add_cnt
 SET proficiency_updt_cnt = request->proficiency_updt_cnt
 SET limits_cnt = request->limits_cnt
 SET security_cnt = request->security_cnt
 SET pe_updt_cnt = 0
 SET csl_updt_cnt = 0
 SET css_updt_cnt = 0
#proficiency_add
 IF (proficiency_add_cnt > 0)
  INSERT  FROM proficiency_event pe,
    (dummyt d  WITH seq = value(request->proficiency_add_cnt))
   SET pe.prsnl_id = request->proficiency_add_qual[d.seq].prsnl_id, pe.proficiency_type_cd = request
    ->proficiency_add_qual[d.seq].proficiency_type_cd, pe.sequence = 0,
    pe.comments = request->proficiency_add_qual[d.seq].comments, pe.active_ind = 1, pe.result_flag =
    request->proficiency_add_qual[d.seq].result_flag,
    pe.reviewer_id = request->proficiency_add_qual[d.seq].reviewer_id, pe.reviewed_dt_tm =
    cnvtdatetime(request->proficiency_add_qual[d.seq].reviewed_dt_tm), pe.administered_dt_tm =
    cnvtdatetime(request->proficiency_add_qual[d.seq].administered_dt_tm),
    pe.notification_dt_tm = cnvtdatetime(request->proficiency_add_qual[d.seq].notification_dt_tm), pe
    .updt_cnt = 0, pe.updt_dt_tm = cnvtdatetime(curdate,curtime),
    pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (pe)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("insert","f","table","proficiency_event")
   SET reply->exception_data[d.seq].join_table = "proficiency"
   SET reply->exception_data[d.seq].prsnl_id = request->proficiency_add_qual[d.seq].prsnl_id
  ELSE
   COMMIT
  ENDIF
 ENDIF
#proficiency_updt
 IF (proficiency_updt_cnt > 0)
  FOR (x = x TO proficiency_updt_cnt)
    SELECT INTO "nl:"
     pe.*
     FROM proficiency_event pe
     WHERE (request->proficiency_updt_qual[x].prsnl_id=pe.prsnl_id)
      AND (request->proficiency_updt_qual[x].proficiency_type_cd=pe.proficiency_type_cd)
      AND (request->proficiency_updt_qual[x].sequence=pe.sequence)
     DETAIL
      pe_updt_cnt = pe.updt_cnt
     WITH nocounter, forupdate(pe)
    ;end select
    IF (curqual=0)
     CALL handle_errors("LOCK","F","table","proficiency_event")
     SET reply->exception_data[x].join_table = "proficiency"
     SET reply->exception_data[x].prsnl_id = request->proficiency_updt_qual[x].prsnl_id
     SET x = (x+ 1)
     GO TO proficiency_updt
    ENDIF
    IF ((pe_updt_cnt != request->proficiency_updt_qual[x].updt_cnt))
     CALL handle_errors("COUNTER SYNC","F","table","proficiency_event")
     SET reply->exception_data[x].join_table = "proficiency"
     SET reply->exception_data[x].prsnl_id = request->proficiency_updt_qual[x].prsnl_id
     SET x = (x+ 1)
     GO TO proficiency_updt
    ENDIF
    UPDATE  FROM proficiency_event pe
     SET pe.active_ind = 0, pe.updt_cnt = (pe_updt_cnt+ 1), pe.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
      updt_applctx
     WHERE (request->proficiency_updt_qual[x].prsnl_id=pe.prsnl_id)
      AND (request->proficiency_updt_qual[x].proficiency_type_cd=pe.proficiency_type_cd)
      AND (request->proficiency_updt_qual[x].sequence=pe.sequence)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL handle_errors("update","f","table","proficiency_event")
     SET reply->exception_data[x].join_table = "proficiency"
     SET reply->exception_data[x].prsnl_id = request->proficiency_updt_qual[x].prsnl_id
     SET x = (x+ 1)
     GO TO proficiency_updt
    ENDIF
    INSERT  FROM proficiency_event pe
     SET pe.prsnl_id = request->proficiency_updt_qual[x].prsnl_id, pe.proficiency_type_cd = request->
      proficiency_updt_qual[x].proficiency_type_cd, pe.sequence = (request->proficiency_updt_qual[x].
      sequence+ 1),
      pe.comments = request->proficiency_updt_qual[x].comments, pe.result_flag = request->
      proficiency_updt_qual[x].result_flag, pe.reviewer_id = request->proficiency_updt_qual[x].
      reviewer_id,
      pe.reviewed_dt_tm = cnvtdatetime(request->proficiency_updt_qual[x].reviewed_dt_tm), pe
      .administered_dt_tm = cnvtdatetime(request->proficiency_updt_qual[x].administered_dt_tm), pe
      .notification_dt_tm = cnvtdatetime(request->proficiency_updt_qual[x].notification_dt_tm),
      pe.active_ind = 1, pe.updt_cnt = 0, pe.updt_dt_tm = cnvtdatetime(curdate,curtime),
      pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL handle_errors("insert","f","table","proficiency_event")
     SET reply->exception_data[x].join_table = "proficiency"
     SET reply->exception_data[x].prsnl_id = request->proficiency_updt_qual[x].prsnl_id
     SET x = (x+ 1)
     GO TO proficiency_updt
    ELSE
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
#limits
 IF (limits_cnt > 0
  AND y <= limits_cnt)
  FOR (y = y TO limits_cnt)
    SELECT INTO "nl:"
     csl.*
     FROM cyto_screening_limits csl
     WHERE (request->limits_qual[y].prsnl_id=csl.prsnl_id)
      AND (request->limits_qual[y].sequence=csl.sequence)
     DETAIL
      csl_updt_cnt = csl.updt_cnt
     WITH nocounter, forupdate(csl)
    ;end select
    IF (curqual=0)
     CALL handle_errors("LOCK","F","table","cyto_screening_limits")
     SET reply->exception_data[y].join_table = "limits"
     SET reply->exception_data[y].prsnl_id = request->limits_qual[y].prsnl_id
     SET y = (y+ 1)
     GO TO limits
    ENDIF
    IF ((csl_updt_cnt != request->limits_qual[y].updt_cnt))
     CALL handle_errors("COUNTER SYNC","F","table","cyto_screening_limits")
     SET reply->exception_data[y].join_table = "limits"
     SET reply->exception_data[y].prsnl_id = request->limits_qual[y].prsnl_id
     SET y = (y+ 1)
     GO TO limits
    ENDIF
    UPDATE  FROM cyto_screening_limits csl
     SET csl.active_ind = 0, csl.updt_cnt = (csl_updt_cnt+ 1), csl.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      csl.updt_id = reqinfo->updt_id, csl.updt_task = reqinfo->updt_task, csl.updt_applctx = reqinfo
      ->updt_applctx
     WHERE (request->limits_qual[y].prsnl_id=csl.prsnl_id)
      AND (request->limits_qual[y].sequence=csl.sequence)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL handle_errors("update","f","table","cyto_screening_limits")
     SET reply->exception_data[y].join_table = "limits"
     SET reply->exception_data[y].prsnl_id = request->limits_qual[y].prsnl_id
     SET y = (y+ 1)
     GO TO limits
    ENDIF
    INSERT  FROM cyto_screening_limits csl
     SET csl.prsnl_id = request->limits_qual[y].prsnl_id, csl.sequence = (request->limits_qual[y].
      sequence+ 1), csl.slide_limit = request->limits_qual[y].slide_limit,
      csl.screening_hours = request->limits_qual[y].screening_hours, csl.comments = request->
      limits_qual[y].comment, csl.reviewed_dt_tm = cnvtdatetime(request->limits_qual[y].reviewed_dttm
       ),
      csl.reviewer_id = request->limits_qual[y].reviewer_id, csl.active_ind = 1, csl.updt_cnt = 0,
      csl.updt_dt_tm = cnvtdatetime(curdate,curtime), csl.updt_id = reqinfo->updt_id, csl.updt_task
       = reqinfo->updt_task,
      csl.updt_applctx = reqinfo->updt_applctx, csl.requeue_flag = request->limits_qual[y].
      requeue_flag
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL handle_errors("insert","f","table","cyto_screening_limits")
     SET reply->exception_data[y].join_table = "limits"
     SET reply->exception_data[y].prsnl_id = request->limits_qual[y].prsnl_id
     SET y = (y+ 1)
     GO TO limits
    ELSE
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
#security
 IF (security_cnt > 0)
  FOR (z = z TO security_cnt)
    SELECT INTO "nl:"
     css.*
     FROM cyto_screening_security css
     WHERE (request->security_qual[z].prsnl_id=css.prsnl_id)
      AND (request->security_qual[z].sequence=css.sequence)
     DETAIL
      css_updt_cnt = css.updt_cnt
     WITH nocounter, forupdate(css)
    ;end select
    IF (curqual=0)
     CALL handle_errors("LOCK","F","table","cyto_screening_security")
     SET reply->exception_data[z].join_table = "security"
     SET reply->exception_data[z].prsnl_id = request->security_qual[z].prsnl_id
     SET z = (z+ 1)
     GO TO security
    ENDIF
    IF ((css_updt_cnt != request->security_qual[z].updt_cnt))
     CALL handle_errors("COUNTER SYNC","F","table","cyto_screening_security")
     SET reply->exception_data[z].join_table = "security"
     SET reply->exception_data[z].prsnl_id = request->security_qual[z].prsnl_id
     SET z = (z+ 1)
     GO TO security
    ENDIF
    UPDATE  FROM cyto_screening_security css
     SET css.active_ind = 0, css.updt_cnt = (css_updt_cnt+ 1), css.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      css.updt_id = reqinfo->updt_id, css.updt_task = reqinfo->updt_task, css.updt_applctx = reqinfo
      ->updt_applctx
     WHERE (request->security_qual[z].prsnl_id=css.prsnl_id)
      AND (request->security_qual[z].sequence=css.sequence)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL handle_errors("update","f","table","cyto_screening_security")
     SET reply->exception_data[z].join_table = "security"
     SET reply->exception_data[z].prsnl_id = request->security_qual[z].prsnl_id
     SET z = (z+ 1)
     GO TO security
    ENDIF
    INSERT  FROM cyto_screening_security css
     SET css.prsnl_id = request->security_qual[z].prsnl_id, css.sequence = (request->security_qual[z]
      .sequence+ 1), css.normal_percentage = request->security_qual[z].norm_percentage,
      css.normal_requeue_flag = request->security_qual[z].norm_rq_flag, css
      .normal_service_resource_cd = request->security_qual[z].norm_srvc_rsrce_cd, css
      .normal_requeue_rank = request->security_qual[z].norm_rq_rank,
      css.abnormal_percentage = request->security_qual[z].abnorm_percentage, css
      .abnormal_requeue_flag = request->security_qual[z].abnorm_rq_flag, css
      .abnormal_service_resource_cd = request->security_qual[z].abnorm_srvc_rsrce_cd,
      css.abnormal_requeue_rank = request->security_qual[z].abnorm_rq_rank, css.atypical_percentage
       = request->security_qual[z].atyp_percentage, css.atypical_requeue_flag = request->
      security_qual[z].atyp_rq_flag,
      css.atypical_service_resource_cd = request->security_qual[z].atyp_srvc_rsrce_cd, css
      .atypical_requeue_rank = request->security_qual[z].atyp_rq_rank, css.chr_percentage = request->
      security_qual[z].chr_percentage,
      css.chr_requeue_flag = request->security_qual[z].chr_rq_flag, css.chr_service_resource_cd =
      request->security_qual[z].chr_srvc_rsrce_cd, css.chr_requeue_rank = request->security_qual[z].
      chr_rq_rank,
      css.unsat_percentage = request->security_qual[z].unsat_percentage, css.unsat_requeue_flag =
      request->security_qual[z].unsat_rq_flag, css.unsat_service_resource_cd = request->
      security_qual[z].unsat_srvc_rsrce_cd,
      css.verify_level = request->security_qual[z].verify_level, css.comments = request->
      security_qual[z].comment, css.reviewed_dt_tm = cnvtdatetime(request->security_qual[z].
       reviewed_dttm),
      css.reviewer_id = request->security_qual[z].reviewer_id, css.active_ind = 1, css.updt_cnt = 0,
      css.updt_dt_tm = cnvtdatetime(curdate,curtime), css.updt_id = reqinfo->updt_id, css.updt_task
       = reqinfo->updt_task,
      css.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL handle_errors("insert","f","table","cyto_screening_security")
     SET reply->exception_data[z].join_table = "security"
     SET reply->exception_data[z].prsnl_id = request->security_qual[z].prsnl_id
     SET z = (z+ 1)
     GO TO security
    ELSE
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (error_cnt > 0)
  IF ((error_cnt=(((limits_cnt+ security_cnt)+ proficiency_add_cnt)+ proficiency_updt_cnt)))
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
    SET stat = alter(reply->exception_data,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#end_of_reports
END GO
