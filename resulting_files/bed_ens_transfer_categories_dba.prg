CREATE PROGRAM bed_ens_transfer_categories:dba
 FREE SET reply
 RECORD reply(
   1 transfer_categories[*]
     2 id = f8
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
 SET ccnt = size(request->transfer_categories,5)
 SET stat = alterlist(reply->transfer_categories,ccnt)
 FOR (c = 1 TO ccnt)
   IF ((request->transfer_categories[c].action_flag=1))
    SET trans_id = 0.0
    SELECT INTO "nl:"
     w = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      trans_id = cnvtreal(w)
     WITH nocounter
    ;end select
    INSERT  FROM dcp_cf_trans_cat c
     SET c.dcp_cf_trans_cat_id = trans_id, c.cf_category_name = request->transfer_categories[c].name,
      c.cf_transfer_type_cd = request->transfer_categories[c].transfer_type_code_value,
      c.active_ind = request->transfer_categories[c].active_ind, c.updt_applctx = reqinfo->
      updt_applctx, c.updt_id = reqinfo->updt_id,
      c.updt_task = reqinfo->updt_task, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime),
      c.beg_effective_dt_tm =
      IF ((request->transfer_categories[c].active_ind=0)) cnvtdatetime("31-DEC-2100")
      ELSE cnvtdatetime(curdate,curtime)
      ENDIF
      , c.end_effective_dt_tm =
      IF ((request->transfer_categories[c].active_ind=0)) cnvtdatetime(curdate,curtime)
      ELSE cnvtdatetime("31-DEC-2100")
      ENDIF
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "F"
     SET error_msg = concat("Error inserting dcp_cf_trans_cat")
     GO TO exit_script
    ENDIF
    SET reply->transfer_categories[c].id = trans_id
   ELSEIF ((request->transfer_categories[c].action_flag=2))
    UPDATE  FROM dcp_cf_trans_cat c
     SET c.cf_category_name = request->transfer_categories[c].name, c.cf_transfer_type_cd = request->
      transfer_categories[c].transfer_type_code_value, c.active_ind = request->transfer_categories[c]
      .active_ind,
      c.updt_applctx = reqinfo->updt_applctx, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
      updt_task,
      c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.beg_effective_dt_tm =
      IF ((request->transfer_categories[c].active_ind=0)) cnvtdatetime("31-DEC-2100")
      ELSE cnvtdatetime(curdate,curtime)
      ENDIF
      ,
      c.end_effective_dt_tm =
      IF ((request->transfer_categories[c].active_ind=0)) cnvtdatetime(curdate,curtime)
      ELSE cnvtdatetime("31-DEC-2100")
      ENDIF
     WHERE (c.dcp_cf_trans_cat_id=request->transfer_categories[c].id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "F"
     SET error_msg = concat("Error updating dcp_cf_trans_cat")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->transfer_categories[c].action_flag=3))
    IF ((request->transfer_categories[c].move_to_category_id > 0))
     SET seq_found = 0
     SET next_seq = 0
     SELECT INTO "nl:"
      FROM dcp_cf_trans_cat_reltn d
      WHERE (d.dcp_cf_trans_cat_id=request->transfer_categories[c].move_to_category_id)
       AND d.active_ind=1
      ORDER BY d.reltn_sequence
      DETAIL
       seq_found = 1, next_seq = d.reltn_sequence
      WITH nocounter
     ;end select
    ENDIF
    UPDATE  FROM dcp_cf_trans_cat c
     SET c.active_ind = 0, c.updt_applctx = reqinfo->updt_applctx, c.updt_id = reqinfo->updt_id,
      c.updt_task = reqinfo->updt_task, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime),
      c.beg_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.end_effective_dt_tm = cnvtdatetime(
       curdate,curtime)
     WHERE (c.dcp_cf_trans_cat_id=request->transfer_categories[c].id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "F"
     SET error_msg = concat("Error inactivating dcp_cf_trans_cat")
     GO TO exit_script
    ENDIF
    RECORD temp(
      1 ids[*]
        2 dcp_cf_trans_event_cd_r_id = f8
    )
    SET tcnt = 0
    SELECT INTO "nl:"
     FROM dcp_cf_trans_cat_reltn d1,
      dcp_cf_trans_event_cd_r d2
     PLAN (d1
      WHERE (d1.dcp_cf_trans_cat_id=request->transfer_categories[c].id)
       AND d1.active_ind=1)
      JOIN (d2
      WHERE d2.dcp_cf_trans_event_cd_r_id=d1.dcp_cf_trans_event_cd_r_id
       AND d2.active_ind=1)
     DETAIL
      tcnt = (tcnt+ 1), stat = alterlist(temp->ids,tcnt), temp->ids[tcnt].dcp_cf_trans_event_cd_r_id
       = d2.dcp_cf_trans_event_cd_r_id
     WITH nocounter
    ;end select
    FOR (t = 1 TO tcnt)
      IF ((request->transfer_categories[c].move_to_category_id=0))
       SET row_cnt = 0
       SELECT INTO "nl:"
        FROM dcp_cf_trans_cat_reltn d
        WHERE (d.dcp_cf_trans_event_cd_r_id=temp->ids[t].dcp_cf_trans_event_cd_r_id)
         AND (d.dcp_cf_trans_cat_id != request->transfer_categories[c].id)
         AND d.active_ind=1
        DETAIL
         row_cnt = (row_cnt+ 1)
        WITH nocounter
       ;end select
       IF (row_cnt=0)
        UPDATE  FROM dcp_cf_trans_event_cd_r d
         SET d.active_ind = 0, d.beg_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d
          .end_effective_dt_tm = cnvtdatetime(curdate,curtime),
          d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo
          ->updt_task,
          d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime)
         WHERE (d.dcp_cf_trans_event_cd_r_id=temp->ids[t].dcp_cf_trans_event_cd_r_id)
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET error_flag = "F"
         SET error_msg = concat("Error updating dcp_cf_trans_event_cd_r")
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      UPDATE  FROM dcp_cf_trans_cat_reltn d
       SET d.active_ind = 0, d.beg_effective_dt_tm = cnvtdatetime("31-DEC-2100"), d
        .end_effective_dt_tm = cnvtdatetime(curdate,curtime),
        d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->
        updt_task,
        d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime)
       WHERE (d.dcp_cf_trans_event_cd_r_id=temp->ids[t].dcp_cf_trans_event_cd_r_id)
        AND (d.dcp_cf_trans_cat_id=request->transfer_categories[c].id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "F"
       SET error_msg = concat("Error updating dcp_cf_trans_cat_reltn")
       GO TO exit_script
      ENDIF
      IF ((request->transfer_categories[c].move_to_category_id > 0))
       SET trans_id = 0.0
       SET trans_active_ind = 0
       SELECT INTO "nl:"
        FROM dcp_cf_trans_cat_reltn d
        WHERE (d.dcp_cf_trans_cat_id=request->transfer_categories[c].move_to_category_id)
         AND (d.dcp_cf_trans_event_cd_r_id=temp->ids[t].dcp_cf_trans_event_cd_r_id)
        DETAIL
         trans_id = d.dcp_cf_trans_cat_reltn_id, trans_active_ind = d.active_ind
        WITH nocounter
       ;end select
       IF (trans_id > 0.0)
        IF (trans_active_ind=0)
         UPDATE  FROM dcp_cf_trans_cat_reltn d
          SET d.active_ind = 1, d.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), d
           .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
           d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->updt_id, d.updt_task =
           reqinfo->updt_task,
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
       ELSE
        IF (seq_found=1)
         SET next_seq = (next_seq+ 1)
        ELSE
         SET seq_found = 1
        ENDIF
        INSERT  FROM dcp_cf_trans_cat_reltn d
         SET d.dcp_cf_trans_cat_reltn_id = seq(carenet_seq,nextval), d.dcp_cf_trans_cat_id = request
          ->transfer_categories[c].move_to_category_id, d.dcp_cf_trans_event_cd_r_id = temp->ids[t].
          dcp_cf_trans_event_cd_r_id,
          d.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), d.end_effective_dt_tm = cnvtdatetime
          ("31-DEC-2100"), d.active_ind = 1,
          d.reltn_sequence = next_seq, d.updt_applctx = reqinfo->updt_applctx, d.updt_id = reqinfo->
          updt_id,
          d.updt_task = reqinfo->updt_task, d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,
           curtime)
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "F"
         SET error_msg = concat("Error inserting dcp_cf_trans_cat_reltn for add mode")
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = build2(">> PROGRAM NAME: BED_ENS_TRANSFER_CATEGORIES  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
