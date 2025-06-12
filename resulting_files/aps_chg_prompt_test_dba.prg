CREATE PROGRAM aps_chg_prompt_test:dba
 RECORD temp(
   1 qual[1]
     2 long_text_id = f8
     2 updt_cnt = i4
     2 add_ind = i2
 )
#script
 SET failed = "F"
 IF ((validate(reply->case_id,- (1))=- (1)))
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
 ENDIF
 SET x = 0
 SET text_count = 0
 SET nbr_items = 0
 SET prompt_cnt = cnvtint(size(request->prompt_qual,5))
 SET add_cnt = 0
 SET chg_cnt = 0
 SET del_cnt = 0
 FOR (x = 1 TO prompt_cnt)
   SET add_cnt = cnvtint(size(request->prompt_qual[x].add_qual,5))
   SET chg_cnt = cnvtint(size(request->prompt_qual[x].chg_qual,5))
   SET del_cnt = cnvtint(size(request->prompt_qual[x].del_qual,5))
   IF (add_cnt > 0)
    SET stat = alter(temp->qual,add_cnt)
    SET text_count = 0
    FOR (xa = 1 TO add_cnt)
      IF ((request->prompt_qual[x].add_qual[xa].text=""))
       SET temp->qual[xa].long_text_id = 0.0
      ELSE
       SELECT INTO "nl:"
        seq_nbr = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         temp->qual[xa].long_text_id = seq_nbr, text_count = (text_count+ 1)
        WITH format, counter
       ;end select
       IF (curqual=0)
        GO TO lt_seq_failed
       ENDIF
      ENDIF
    ENDFOR
    IF (text_count > 0)
     INSERT  FROM long_text lt,
       (dummyt d  WITH seq = value(add_cnt))
      SET lt.long_text_id = temp->qual[d.seq].long_text_id, lt.parent_entity_name = "AP_PROMPT_TEST",
       lt.parent_entity_id = request->case_id,
       lt.long_text = request->prompt_qual[x].add_qual[d.seq].text, lt.active_ind = 1, lt
       .active_status_cd = reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx
      PLAN (d
       WHERE (temp->qual[d.seq].long_text_id != 0.0))
       JOIN (lt)
      WITH nocounter
     ;end insert
     IF (curqual != text_count)
      GO TO lt_ins_failed
     ENDIF
    ENDIF
    INSERT  FROM ap_prompt_test apt,
      (dummyt d  WITH seq = value(add_cnt))
     SET apt.accession_id = request->case_id, apt.task_assay_cd = request->prompt_qual[x].add_qual[d
      .seq].task_assay_cd, apt.long_text_id = temp->qual[d.seq].long_text_id,
      apt.active_ind = 1, apt.updt_dt_tm = cnvtdatetime(curdate,curtime3), apt.updt_id = reqinfo->
      updt_id,
      apt.updt_task = reqinfo->updt_task, apt.updt_applctx = reqinfo->updt_applctx, apt.updt_cnt = 0
     PLAN (d)
      JOIN (apt)
     WITH nocounter
    ;end insert
    IF (curqual != add_cnt)
     GO TO apt_ins_failed
    ENDIF
   ENDIF
   IF (chg_cnt > 0)
    SET stat = alter(temp->qual,chg_cnt)
    SET text_count = 0
    FOR (xa = 1 TO chg_cnt)
      IF ((request->prompt_qual[x].chg_qual[xa].long_text_id=0.0))
       SELECT INTO "nl:"
        seq_nbr = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         temp->qual[xa].long_text_id = seq_nbr, temp->qual[xa].add_ind = 1, text_count = (text_count
         + 1)
        WITH format, counter
       ;end select
       IF (curqual=0)
        GO TO lt_seq_failed
       ENDIF
      ELSE
       SET temp->qual[xa].add_ind = 0
      ENDIF
    ENDFOR
    IF (text_count > 0)
     INSERT  FROM long_text lt,
       (dummyt d  WITH seq = value(chg_cnt))
      SET lt.long_text_id = temp->qual[d.seq].long_text_id, lt.parent_entity_name = "AP_PROMPT_TEST",
       lt.parent_entity_id = request->case_id,
       lt.long_text = request->prompt_qual[x].chg_qual[d.seq].text, lt.active_ind = 1, lt
       .active_status_cd = reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx
      PLAN (d
       WHERE (temp->qual[d.seq].add_ind=1))
       JOIN (lt)
      WITH nocounter
     ;end insert
     IF (curqual != text_count)
      GO TO lt_ins_failed
     ENDIF
     SELECT INTO "nl:"
      apt.accession_id
      FROM ap_prompt_test apt,
       (dummyt d  WITH seq = value(chg_cnt))
      PLAN (d
       WHERE (temp->qual[d.seq].add_ind=1))
       JOIN (apt
       WHERE (request->case_id=apt.accession_id)
        AND (request->prompt_qual[x].chg_qual[d.seq].task_assay_cd=apt.task_assay_cd))
      HEAD REPORT
       nbr_items = 0
      DETAIL
       temp->qual[d.seq].updt_cnt = apt.updt_cnt, nbr_items = (nbr_items+ 1)
      WITH nocounter, forupdate(apt)
     ;end select
     IF (nbr_items != text_count)
      GO TO apt_select_failed
     ENDIF
     FOR (xc = 1 TO chg_cnt)
       IF ((temp->qual[xc].add_ind=1)
        AND (request->prompt_qual[x].chg_qual[xc].updt_cnt != temp->qual[xc].updt_cnt))
        GO TO apt_lock_failed
       ENDIF
     ENDFOR
     UPDATE  FROM ap_prompt_test apt,
       (dummyt d  WITH seq = value(chg_cnt))
      SET apt.long_text_id = temp->qual[d.seq].long_text_id, apt.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), apt.updt_id = reqinfo->updt_id,
       apt.updt_task = reqinfo->updt_task, apt.updt_applctx = reqinfo->updt_applctx, apt.updt_cnt = (
       apt.updt_cnt+ 1)
      PLAN (d
       WHERE (temp->qual[d.seq].add_ind=1))
       JOIN (apt
       WHERE (request->case_id=apt.accession_id)
        AND (request->prompt_qual[x].chg_qual[d.seq].task_assay_cd=apt.task_assay_cd))
      WITH nocounter
     ;end update
     IF (curqual != text_count)
      GO TO apt_upd_failed
     ENDIF
    ENDIF
    IF (((chg_cnt - text_count) > 0))
     SELECT INTO "nl:"
      lt.long_text_id
      FROM long_text lt,
       (dummyt d  WITH seq = value(chg_cnt))
      PLAN (d
       WHERE (temp->qual[d.seq].add_ind=0))
       JOIN (lt
       WHERE (lt.long_text_id=request->prompt_qual[x].chg_qual[d.seq].long_text_id))
      HEAD REPORT
       nbr_items = 0
      DETAIL
       temp->qual[d.seq].updt_cnt = lt.updt_cnt, nbr_items = (nbr_items+ 1)
      WITH nocounter, forupdate(lt)
     ;end select
     IF ((nbr_items != (chg_cnt - text_count)))
      GO TO lt_select_failed
     ENDIF
     FOR (xc = 1 TO chg_cnt)
       IF ((temp->qual[xc].add_ind=0)
        AND (request->prompt_qual[x].chg_qual[xc].lt_updt_cnt != temp->qual[xc].updt_cnt))
        GO TO lt_lock_failed
       ENDIF
     ENDFOR
     UPDATE  FROM long_text lt,
       (dummyt d  WITH seq = value(chg_cnt))
      SET lt.long_text = request->prompt_qual[x].chg_qual[d.seq].text, lt.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), lt.updt_id = reqinfo->updt_id,
       lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1)
      PLAN (d
       WHERE (temp->qual[d.seq].add_ind=0))
       JOIN (lt
       WHERE (lt.long_text_id=request->prompt_qual[x].chg_qual[d.seq].long_text_id))
      WITH nocounter
     ;end update
     IF ((curqual != (chg_cnt - text_count)))
      GO TO lt_upd_failed
     ENDIF
    ENDIF
   ENDIF
   IF (del_cnt > 0)
    SET stat = alter(temp->qual,del_cnt)
    SELECT INTO "nl:"
     apt.task_assay_cd
     FROM ap_prompt_test apt,
      (dummyt d  WITH seq = value(del_cnt))
     PLAN (d)
      JOIN (apt
      WHERE (request->case_id=apt.accession_id)
       AND (request->prompt_qual[x].del_qual[d.seq].task_assay_cd=apt.task_assay_cd))
     HEAD REPORT
      nbr_items = 0
     DETAIL
      temp->qual[d.seq].updt_cnt = apt.updt_cnt, nbr_items = (nbr_items+ 1)
     WITH nocounter, forupdate(apt)
    ;end select
    IF (nbr_items != del_cnt)
     GO TO atp_select_failed
    ENDIF
    FOR (xd = 1 TO del_cnt)
      IF ((request->prompt_qual[x].del_qual[xd].updt_cnt != temp->qual[xd].updt_cnt))
       GO TO atp_lock_failed
      ENDIF
    ENDFOR
    UPDATE  FROM ap_prompt_test apt,
      (dummyt d  WITH seq = value(del_cnt))
     SET apt.long_text_id = 0.0, apt.updt_dt_tm = cnvtdatetime(curdate,curtime3), apt.updt_id =
      reqinfo->updt_id,
      apt.updt_task = reqinfo->updt_task, apt.updt_applctx = reqinfo->updt_applctx, apt.updt_cnt = (
      apt.updt_cnt+ 1)
     PLAN (d)
      JOIN (apt
      WHERE (request->case_id=apt.accession_id)
       AND (request->prompt_qual[x].del_qual[d.seq].task_assay_cd=apt.task_assay_cd))
     WITH nocounter
    ;end update
    IF (curqual != del_cnt)
     GO TO apt_upd_failed
    ENDIF
    DELETE  FROM long_text lt,
      (dummyt d  WITH seq = value(del_cnt))
     SET lt.seq = 1
     PLAN (d)
      JOIN (lt
      WHERE (request->prompt_qual[x].del_qual[d.seq].long_text_id=lt.long_text_id))
     WITH nocounter
    ;end delete
    IF (curqual != del_cnt)
     GO TO lt_del_failed
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#lt_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT_SEQ"
 SET failed = "T"
 GO TO exit_script
#lt_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#lt_select_failed
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#lt_lock_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#lt_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#lt_del_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#apt_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PROMPT_TEST"
 SET failed = "T"
 GO TO exit_script
#apt_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PROMPT_TEST"
 SET failed = "T"
 GO TO exit_script
#atp_select_failed
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PROMPT_TEST"
 SET failed = "T"
 GO TO exit_script
#atp_lock_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PROMPT_TEST"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
