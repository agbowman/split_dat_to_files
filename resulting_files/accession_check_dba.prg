CREATE PROGRAM accession_check:dba
 DECLARE accession_id = f8 WITH public, noconstant(0.0)
 DECLARE accession_dup_id = f8 WITH public, noconstant(0.0)
 SET accession_updt_cnt = 0
 SET accession_assignment_ind = 0
 IF ((accession_chk->check_disp_ind != 2))
  SELECT INTO "nl:"
   a.accession_id, a.accession, a.accession_nbr_check
   FROM accession a
   PLAN (a
    WHERE (a.accession_nbr_check=accession_chk->accession_nbr_check))
   DETAIL
    accession_dup_id = a.accession_id, accession_updt_cnt = a.updt_cnt, accession_assignment_ind = a
    .assignment_ind
   WITH nocounter
  ;end select
 ENDIF
 IF ((accession_chk->check_disp_ind IN (1, 2))
  AND accession_dup_id=0)
  SELECT INTO "nl:"
   a.accession_id, a.accession, a.accession_nbr_check
   FROM accession a
   PLAN (a
    WHERE (a.accession=accession_chk->accession))
   DETAIL
    accession_dup_id = a.accession_id, accession_updt_cnt = a.updt_cnt, accession_assignment_ind = a
    .assignment_ind
   WITH nocounter
  ;end select
 ENDIF
 IF ((accession_chk->action_ind=1))
  IF (accession_dup_id=0)
   SELECT INTO "nl:"
    FROM dba_tables dt
    WHERE dt.table_name="ACCESSION0001DRR"
     AND dt.status="VALID"
    WITH nocounter
   ;end select
   IF (curqual=1)
    SELECT INTO "nl:"
     adr.accession_id, adr.accession, adr.accession_nbr_check
     FROM accession0001drr adr
     PLAN (adr
      WHERE (adr.accession_nbr_check=accession_chk->accession_nbr_check))
     DETAIL
      accession_dup_id = adr.accession_id, accession_updt_cnt = adr.updt_cnt,
      accession_assignment_ind = adr.assignment_ind
     WITH nocounter
    ;end select
    IF (accession_dup_id > 0)
     SET accession_status = acc_duplicate
     SET accession_meaning = "Accession exists on the shadow accession table"
    ELSE
     SET accession_status = acc_success
     SET accession_meaning = "Accession does not exist on the shadow accession table"
    ENDIF
   ENDIF
   GO TO exit_script
  ENDIF
  IF (accession_dup_id > 0)
   SET accession_status = acc_duplicate
   IF (accession_assignment_ind=1)
    SET accession_meaning = "Accession exists on the accession table (Pre-Assigned)"
   ELSE
    SET accession_meaning = "Accession exists on the accession table"
   ENDIF
  ELSE
   SET accession_status = acc_success
   SET accession_meaning = "Accession does not exist on the accession table"
  ENDIF
  GO TO exit_script
 ENDIF
 IF (accession_dup_id > 0)
  IF (accession_assignment_ind=0
   AND (accession_chk->action_ind=0))
   SET accession_status = acc_duplicate
   SET accession_meaning = "Accession exists on the accession table"
   GO TO exit_script
  ENDIF
  IF (accession_assignment_ind=1
   AND (accession_chk->action_ind=0))
   SET accession_status = acc_duplicate
   SET accession_id = accession_dup_id
   SET accession_meaning = "Accession exists on the accession table (Pre-Assigned)"
   GO TO exit_script
  ENDIF
  SET accession_status = acc_modify
  SET accession_id = accession_dup_id
  IF ((accession_chk->action_ind=2)
   AND (accession_chk->accession_updt_cnt != accession_updt_cnt))
   SET accession_meaning = "Update count conflict"
   GO TO exit_script
  ENDIF
  IF ((accession_chk->accession_id > 0))
   SELECT INTO "nl:"
    a.accession_id
    FROM accession a
    PLAN (a
     WHERE (a.accession_id=accession_chk->accession_id))
    WITH nocounter, forupdate(a)
   ;end select
   IF (curqual > 0)
    UPDATE  FROM accession a
     SET a.accession = accession_chk->accession, a.accession_nbr_check = trim(accession_chk->
       accession_nbr_check), a.site_prefix_cd = accession_chk->site_prefix_cd,
      a.accession_year = accession_chk->accession_year, a.accession_day = accession_chk->
      accession_day, a.accession_format_cd = accession_chk->accession_format_cd,
      a.alpha_prefix = accession_chk->alpha_prefix, a.accession_sequence_nbr = accession_chk->
      accession_seq_nbr, a.accession_class_cd = accession_chk->accession_class_cd,
      a.accession_pool_id = accession_chk->accession_pool_id, a.preactive_ind = accession_chk->
      preactive_ind, a.assignment_ind = accession_chk->assignment_ind,
      a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->
      updt_task,
      a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a.updt_cnt+ 1)
     PLAN (a
      WHERE a.accession_id=accession_dup_id
       AND a.updt_cnt=accession_updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual > 0)
     SET accession_updt_cnt += 1
     SET accession_status = acc_success
     SET accession_meaning = "Accession modified on the accession table"
    ENDIF
   ENDIF
  ELSE
   SET accession_status = acc_success
   SET accession_meaning = "Accession exists on the table but was not updated"
  ENDIF
  IF (accession_status != acc_success)
   SET accession_meaning = "Update failed on the Accession table"
  ENDIF
 ELSE
  SET accession_id = 0.0
  SELECT INTO "nl:"
   nextsequence = seq(accession_seq,nextval)
   FROM dual
   DETAIL
    accession_id = nextsequence
   WITH format, counter
  ;end select
  IF (accession_id=0)
   SET accession_status = acc_sequence_id
   SET accession_meaning = "Unable to get the next accession sequence number"
   GO TO exit_script
  ENDIF
  INSERT  FROM accession a
   SET a.accession_id = accession_id, a.accession = accession_chk->accession, a.accession_nbr_check
     = trim(accession_chk->accession_nbr_check),
    a.site_prefix_cd = accession_chk->site_prefix_cd, a.accession_year = accession_chk->
    accession_year, a.accession_day = accession_chk->accession_day,
    a.accession_format_cd = accession_chk->accession_format_cd, a.alpha_prefix = accession_chk->
    alpha_prefix, a.accession_sequence_nbr = accession_chk->accession_seq_nbr,
    a.accession_class_cd = accession_chk->accession_class_cd, a.accession_pool_id = accession_chk->
    accession_pool_id, a.preactive_ind = accession_chk->preactive_ind,
    a.assignment_ind = accession_chk->assignment_ind, a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id
     = reqinfo->updt_id,
    a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
   WITH nocounter
  ;end insert
  SET accession_updt_cnt = 0
  IF (curqual=0)
   SET accession_status = acc_insert
   SET accession_meaning = "Accession not inserted on the accession table"
  ELSE
   SET accession_status = acc_success
   SET accession_meaning = "Accession inserted on the accession table"
  ENDIF
 ENDIF
#exit_script
END GO
