CREATE PROGRAM dm_code_value_group:dba
 CALL echo("start dm_code_value_group")
 DECLARE dcvg_err_msg = c132
 DECLARE dcvg_err_ind = i2
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 IF ((dmrequest->delete_ind=0))
  SET reply->status_data.status = "F"
  SET ret_p_code_value = 0.00
  SET ret_c_code_value = 0.00
  IF ((validate(cs_reply->cs_fail,- (99)) != - (99)))
   SET dcvg_err_ind = error(dcvg_err_msg,1)
  ENDIF
  SELECT INTO "nl:"
   a.code_value
   FROM code_value a
   WHERE (((a.cki=dmrequest->p_cki)) OR ((a.cki=dmrequest->c_cki)))
    AND a.code_set IN (dmrequest->code_set, dmrequest->child_code_set)
   DETAIL
    IF ((a.cki=dmrequest->p_cki))
     ret_p_code_value = a.code_value
    ENDIF
    IF ((a.cki=dmrequest->c_cki))
     ret_c_code_value = a.code_value
    ENDIF
   WITH nocounter
  ;end select
  IF ((validate(cs_reply->cs_fail,- (99)) != - (99)))
   SET dcvg_err_ind = error(dcvg_err_msg,0)
   IF (dcvg_err_ind > 0)
    SET reply->status_data.status = "F"
    SET cs_reply->cs_fail = 1
    SET cs_reply->cs_fail_msg = "ERROR from finding Parent or child code value from code_value table"
    GO TO exit_program
   ENDIF
  ENDIF
  IF (ret_p_code_value > 0
   AND ret_c_code_value > 0)
   SET upd_id = 0
   SET upd_task = 0
   SET upd_applctx = 0
   SET upd_cnt = - (1)
   SELECT INTO "nl:"
    FROM code_value_group cvg
    WHERE cvg.parent_code_value=ret_p_code_value
     AND cvg.child_code_value=ret_c_code_value
    DETAIL
     upd_id = cvg.updt_id, upd_task = cvg.updt_task, upd_applctx = cvg.updt_applctx,
     upd_cnt = cvg.updt_cnt
    WITH nocounter
   ;end select
   IF ((validate(cs_reply->cs_fail,- (99)) != - (99)))
    SET dcvg_err_ind = error(dcvg_err_msg,0)
    IF (dcvg_err_ind > 0)
     SET reply->status_data.status = "F"
     SET cs_reply->cs_fail = 1
     SET cs_reply->cs_fail_msg =
     "ERROR from finding child code value group from code_value_group table"
     GO TO exit_program
    ENDIF
   ENDIF
   IF (curqual > 0)
    UPDATE  FROM code_value_group cvg
     SET cvg.collation_seq = dmrequest->collation_seq, cvg.updt_dt_tm = cnvtdatetime(curdate,curtime3
       ), cvg.updt_applctx = reqinfo->updt_applctx,
      cvg.updt_id = reqinfo->updt_id, cvg.updt_cnt = (cvg.updt_cnt+ 1), cvg.updt_task = reqinfo->
      updt_task,
      cvg.code_set = dmrequest->child_code_set
     WHERE cvg.parent_code_value=ret_p_code_value
      AND cvg.child_code_value=ret_c_code_value
     WITH nocounter
    ;end update
    IF ((validate(cs_reply->cs_fail,- (99)) != - (99)))
     SET dcvg_err_ind = error(dcvg_err_msg,0)
     IF (dcvg_err_ind > 0)
      SET reply->status_data.status = "F"
      SET cs_reply->cs_fail = 1
      SET cs_reply->cs_fail_msg = "ERROR from updating code_value_group table"
      GO TO exit_program
     ENDIF
    ENDIF
   ELSE
    INSERT  FROM code_value_group cvg
     SET cvg.parent_code_value = ret_p_code_value, cvg.child_code_value = ret_c_code_value, cvg
      .collation_seq = dmrequest->collation_seq,
      cvg.code_set = dmrequest->child_code_set, cvg.updt_applctx = reqinfo->updt_applctx, cvg
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cvg.updt_id = reqinfo->updt_id, cvg.updt_cnt = 0, cvg.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF ((validate(cs_reply->cs_fail,- (99)) != - (99)))
     SET dcvg_err_ind = error(dcvg_err_msg,0)
     IF (dcvg_err_ind > 0)
      SET reply->status_data.status = "F"
      SET cs_reply->cs_fail = 1
      SET cs_reply->cs_fail_msg = "ERROR from updating code_value_group table"
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   IF (curqual=0)
    SET reply->status_data.status = "F"
    IF ((validate(cs_reply->cs_fail,- (99)) != - (99)))
     SET cs_reply->cs_fail = 1
     SET cs_reply->cs_fail_msg = "Table code_value_group could not be inserted/updated"
    ENDIF
   ELSE
    COMMIT
    SET reply->status_data.status = "S"
   ENDIF
  ELSEIF (((ret_p_code_value=0) OR (ret_c_code_value=0)) )
   SET reply->status_data.status = "F"
   IF ((validate(cs_reply->cs_fail,- (99)) != - (99)))
    SET cs_reply->cs_fail = 1
    SET cs_reply->cs_fail_msg = "Can not find Parent or child code value from code_value table"
    CALL echo(build("inc cs_fail=",cs_reply->cs_fail))
   ENDIF
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_program
END GO
