CREATE PROGRAM bed_ens_result_copy_link_evts:dba
 FREE SET reply
 RECORD reply(
   1 relationships[*]
     2 dcp_cf_trans_event_cd_r_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET rcnt = size(request->relationships,5)
 SET stat = alterlist(reply->relationships,rcnt)
 IF ((request->action_flag=1))
  FOR (r = 1 TO rcnt)
    SET event_id = 0.0
    SET reltn_active_ind = 0
    SELECT INTO "nl:"
     FROM dcp_cf_trans_event_cd_r d
     WHERE (d.source_event_cd=request->relationships[r].source_event_code_value)
      AND (d.target_event_cd=request->relationships[r].target_event_code_value)
      AND (d.cf_transfer_type_cd=request->transfer_type_code_value)
      AND (d.association_identifier_cd=request->relationships[r].assoc_ident_code_value)
     DETAIL
      event_id = d.dcp_cf_trans_event_cd_r_id, reltn_active_ind = d.active_ind
     WITH nocounter
    ;end select
    IF (event_id > 0.0)
     IF (reltn_active_ind=0)
      UPDATE  FROM dcp_cf_trans_event_cd_r d
       SET d.active_ind = 1, d.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), d
        .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
        updt_task,
        d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime)
       WHERE d.dcp_cf_trans_event_cd_r_id=event_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "F"
       SET error_msg = concat("Error updating dcp_cf_trans_event_cd_r for add mode")
       GO TO exit_script
      ENDIF
     ENDIF
    ELSE
     SELECT INTO "nl:"
      w = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       event_id = cnvtreal(w)
      WITH nocounter
     ;end select
     INSERT  FROM dcp_cf_trans_event_cd_r d
      SET d.dcp_cf_trans_event_cd_r_id = event_id, d.source_event_cd = request->relationships[r].
       source_event_code_value, d.target_event_cd = request->relationships[r].target_event_code_value,
       d.cf_transfer_type_cd = request->transfer_type_code_value, d.association_identifier_cd =
       request->relationships[r].assoc_ident_code_value, d.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime),
       d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d.active_ind = 1, d.updt_applctx =
       reqinfo->updt_applctx,
       d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_cnt = 0,
       d.updt_dt_tm = cnvtdatetime(curdate,curtime)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "F"
      SET error_msg = concat("Error inserting dcp_cf_trans_event_cd_r for add mode")
      GO TO exit_script
     ENDIF
    ENDIF
    SET reply->relationships[r].dcp_cf_trans_event_cd_r_id = event_id
    SET trans_id = 0.0
    SET trans_active_ind = 0
    SET trans_reltn_seq = 0
    SELECT INTO "nl:"
     FROM dcp_cf_trans_cat_reltn d
     WHERE (d.dcp_cf_trans_cat_id=request->transfer_category_id)
      AND d.dcp_cf_trans_event_cd_r_id=event_id
     DETAIL
      trans_id = d.dcp_cf_trans_cat_reltn_id, trans_active_ind = d.active_ind, trans_reltn_seq =
      request->relationships[r].reltn_sequence
     WITH nocounter
    ;end select
    IF (trans_id > 0.0)
     IF (trans_active_ind=0)
      UPDATE  FROM dcp_cf_trans_cat_reltn d
       SET d.active_ind = 1, d.reltn_sequence = request->relationships[r].reltn_sequence, d
        .beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
        d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d.updt_applctx = reqinfo->updt_applctx,
        d.updt_id = reqinfo->updt_id,
        d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(
         curdate,curtime)
       WHERE d.dcp_cf_trans_cat_reltn_id=trans_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "F"
       SET error_msg = concat("Error updating dcp_cf_trans_cat_reltn for add mode")
       GO TO exit_script
      ENDIF
     ELSE
      IF ((trans_reltn_seq != request->relationships[r].reltn_sequence))
       UPDATE  FROM dcp_cf_trans_cat_reltn d
        SET d.reltn_sequence = request->relationships[r].reltn_sequence, d.beg_effective_dt_tm =
         cnvtdatetime(curdate,curtime), d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo
         ->updt_task,
         d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime)
        WHERE d.dcp_cf_trans_cat_reltn_id=trans_id
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "F"
        SET error_msg = concat("Error updating dcp_cf_trans_cat_reltn for add mode")
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ELSE
     INSERT  FROM dcp_cf_trans_cat_reltn d
      SET d.dcp_cf_trans_cat_reltn_id = seq(carenet_seq,nextval), d.dcp_cf_trans_cat_id = request->
       transfer_category_id, d.dcp_cf_trans_event_cd_r_id = event_id,
       d.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), d.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100"), d.active_ind = 1,
       d.reltn_sequence = request->relationships[r].reltn_sequence, d.updt_applctx = reqinfo->
       updt_applctx, d.updt_id = reqinfo->updt_id,
       d.updt_task = reqinfo->updt_task, d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "F"
      SET error_msg = concat("Error inserting dcp_cf_trans_cat_reltn for add mode")
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ELSEIF ((request->action_flag=2))
  FOR (r = 1 TO rcnt)
   UPDATE  FROM dcp_cf_trans_cat_reltn d
    SET d.reltn_sequence = request->relationships[r].reltn_sequence, d.updt_applctx = reqinfo->
     updt_applctx, d.updt_id = reqinfo->updt_id,
     d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(
      curdate,curtime)
    WHERE (d.dcp_cf_trans_event_cd_r_id=request->relationships[r].dcp_cf_trans_event_cd_r_id)
     AND (d.dcp_cf_trans_cat_id=request->transfer_category_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "F"
    SET error_msg = concat("Error updating dcp_cf_trans_cat_reltn for update mode")
    GO TO exit_script
   ENDIF
  ENDFOR
 ELSEIF ((request->action_flag=3))
  FOR (r = 1 TO rcnt)
    SET row_cnt = 0
    SELECT INTO "nl:"
     FROM dcp_cf_trans_cat_reltn d
     WHERE (d.dcp_cf_trans_event_cd_r_id=request->relationships[r].dcp_cf_trans_event_cd_r_id)
      AND (d.dcp_cf_trans_cat_id != request->transfer_category_id)
      AND d.active_ind=1
     DETAIL
      row_cnt = (row_cnt+ 1)
     WITH nocounter
    ;end select
    IF (row_cnt=0)
     UPDATE  FROM dcp_cf_trans_event_cd_r d
      SET d.active_ind = 0, d.beg_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d
       .end_effective_dt_tm = cnvtdatetime(curdate,curtime),
       d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
       updt_task,
       d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime)
      WHERE (d.dcp_cf_trans_event_cd_r_id=request->relationships[r].dcp_cf_trans_event_cd_r_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "F"
      SET error_msg = concat("Error updating dcp_cf_trans_event_cd_r for remove mode")
      GO TO exit_script
     ENDIF
    ENDIF
    UPDATE  FROM dcp_cf_trans_cat_reltn d
     SET d.active_ind = 0, d.beg_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d.end_effective_dt_tm
       = cnvtdatetime(curdate,curtime),
      d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
      updt_task,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime)
     WHERE (d.dcp_cf_trans_event_cd_r_id=request->relationships[r].dcp_cf_trans_event_cd_r_id)
      AND (d.dcp_cf_trans_cat_id=request->transfer_category_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "F"
     SET error_msg = concat("Error updating dcp_cf_trans_cat_reltn for remove mode")
     GO TO exit_script
    ENDIF
  ENDFOR
 ELSEIF ((request->action_flag=4))
  RECORD temp(
    1 ids[*]
      2 dcp_cf_trans_event_cd_r_id = f8
  )
  SET tcnt = 0
  SELECT INTO "nl:"
   FROM dcp_cf_trans_cat_reltn d1,
    dcp_cf_trans_event_cd_r d2
   PLAN (d1
    WHERE (d1.dcp_cf_trans_cat_id=request->transfer_category_id)
     AND d1.active_ind=1)
    JOIN (d2
    WHERE d2.dcp_cf_trans_event_cd_r_id=d1.dcp_cf_trans_event_cd_r_id
     AND (d2.cf_transfer_type_cd=request->transfer_type_code_value)
     AND d2.active_ind=1)
   DETAIL
    tcnt = (tcnt+ 1), stat = alterlist(temp->ids,tcnt), temp->ids[tcnt].dcp_cf_trans_event_cd_r_id =
    d2.dcp_cf_trans_event_cd_r_id
   WITH nocounter
  ;end select
  FOR (t = 1 TO tcnt)
    SET row_cnt = 0
    SELECT INTO "nl:"
     FROM dcp_cf_trans_cat_reltn d
     WHERE (d.dcp_cf_trans_event_cd_r_id=temp->ids[t].dcp_cf_trans_event_cd_r_id)
      AND (d.dcp_cf_trans_cat_id != request->transfer_category_id)
      AND d.active_ind=1
     DETAIL
      row_cnt = (row_cnt+ 1)
     WITH nocounter
    ;end select
    IF (row_cnt=0)
     UPDATE  FROM dcp_cf_trans_event_cd_r d
      SET d.active_ind = 0, d.beg_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d
       .end_effective_dt_tm = cnvtdatetime(curdate,curtime),
       d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
       updt_task,
       d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime)
      WHERE (d.dcp_cf_trans_event_cd_r_id=temp->ids[t].dcp_cf_trans_event_cd_r_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "F"
      SET error_msg = concat("Error updating dcp_cf_trans_event_cd_r for copy mode")
      GO TO exit_script
     ENDIF
    ENDIF
    UPDATE  FROM dcp_cf_trans_cat_reltn d
     SET d.active_ind = 0, d.beg_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d.end_effective_dt_tm
       = cnvtdatetime(curdate,curtime),
      d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
      updt_task,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime)
     WHERE (d.dcp_cf_trans_event_cd_r_id=temp->ids[t].dcp_cf_trans_event_cd_r_id)
      AND (d.dcp_cf_trans_cat_id=request->transfer_category_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "F"
     SET error_msg = concat("Error updating dcp_cf_trans_cat_reltn for copy mode")
     GO TO exit_script
    ENDIF
  ENDFOR
  FOR (r = 1 TO rcnt)
    SET event_id = 0.0
    SET reltn_active_ind = 0
    SELECT INTO "nl:"
     FROM dcp_cf_trans_event_cd_r d
     WHERE (d.source_event_cd=request->relationships[r].source_event_code_value)
      AND (d.target_event_cd=request->relationships[r].target_event_code_value)
      AND (d.cf_transfer_type_cd=request->transfer_type_code_value)
      AND (d.association_identifier_cd=request->relationships[r].assoc_ident_code_value)
     DETAIL
      event_id = d.dcp_cf_trans_event_cd_r_id, reltn_active_ind = d.active_ind
     WITH nocounter
    ;end select
    IF (event_id > 0.0)
     IF (reltn_active_ind=0)
      UPDATE  FROM dcp_cf_trans_event_cd_r d
       SET d.active_ind = 1, d.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), d
        .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
        updt_task,
        d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime)
       WHERE d.dcp_cf_trans_event_cd_r_id=event_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "F"
       SET error_msg = concat("Error updating dcp_cf_trans_event_cd_r for copy mode")
       GO TO exit_script
      ENDIF
     ENDIF
    ELSE
     SELECT INTO "nl:"
      w = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       event_id = cnvtreal(w)
      WITH nocounter
     ;end select
     INSERT  FROM dcp_cf_trans_event_cd_r d
      SET d.dcp_cf_trans_event_cd_r_id = event_id, d.source_event_cd = request->relationships[r].
       source_event_code_value, d.target_event_cd = request->relationships[r].target_event_code_value,
       d.cf_transfer_type_cd = request->transfer_type_code_value, d.association_identifier_cd =
       request->relationships[r].assoc_ident_code_value, d.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime),
       d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d.active_ind = 1, d.updt_applctx =
       reqinfo->updt_applctx,
       d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_cnt = 0,
       d.updt_dt_tm = cnvtdatetime(curdate,curtime)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "F"
      SET error_msg = concat("Error inserting dcp_cf_trans_event_cd_r for copy mode")
      GO TO exit_script
     ENDIF
    ENDIF
    SET reply->relationships[r].dcp_cf_trans_event_cd_r_id = event_id
    SET trans_id = 0.0
    SET trans_active_ind = 0
    SET trans_reltn_seq = 0
    SELECT INTO "nl:"
     FROM dcp_cf_trans_cat_reltn d
     WHERE (d.dcp_cf_trans_cat_id=request->transfer_category_id)
      AND d.dcp_cf_trans_event_cd_r_id=event_id
     DETAIL
      trans_id = d.dcp_cf_trans_cat_reltn_id, trans_active_ind = d.active_ind, trans_reltn_seq = d
      .reltn_sequence
     WITH nocounter
    ;end select
    IF (trans_id > 0.0)
     IF (trans_active_ind=0)
      UPDATE  FROM dcp_cf_trans_cat_reltn d
       SET d.active_ind = 1, d.reltn_sequence = request->relationships[r].reltn_sequence, d
        .beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
        d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d.updt_applctx = reqinfo->updt_applctx,
        d.updt_id = reqinfo->updt_id,
        d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(
         curdate,curtime)
       WHERE d.dcp_cf_trans_cat_reltn_id=trans_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "F"
       SET error_msg = concat("Error updating dcp_cf_trans_cat_reltn for add mode")
       GO TO exit_script
      ENDIF
     ELSE
      IF ((trans_reltn_seq != request->relationships[r].reltn_sequence))
       UPDATE  FROM dcp_cf_trans_cat_reltn d
        SET d.reltn_sequence = request->relationships[r].reltn_sequence, d.beg_effective_dt_tm =
         cnvtdatetime(curdate,curtime), d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo
         ->updt_task,
         d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime)
        WHERE d.dcp_cf_trans_cat_reltn_id=trans_id
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "F"
        SET error_msg = concat("Error updating dcp_cf_trans_cat_reltn for add mode")
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ELSE
     INSERT  FROM dcp_cf_trans_cat_reltn d
      SET d.dcp_cf_trans_cat_reltn_id = seq(carenet_seq,nextval), d.dcp_cf_trans_cat_id = request->
       transfer_category_id, d.dcp_cf_trans_event_cd_r_id = event_id,
       d.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), d.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100"), d.active_ind = 1,
       d.reltn_sequence = request->relationships[r].reltn_sequence, d.updt_applctx = reqinfo->
       updt_applctx, d.updt_id = reqinfo->updt_id,
       d.updt_task = reqinfo->updt_task, d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "F"
      SET error_msg = concat("Error inserting dcp_cf_trans_cat_reltn for copy mode")
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = build2(">> PROGRAM NAME: BED_ENS_RESULT_COPY_LINK_EVTS  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
