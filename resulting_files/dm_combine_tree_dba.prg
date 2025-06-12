CREATE PROGRAM dm_combine_tree:dba
 IF ( NOT (validate(cmb_tree)))
  FREE RECORD cmb_tree
  RECORD cmb_tree(
    1 valid_ind = i2
    1 final_enc_id = f8
    1 final_id = f8
    1 cmb[*]
      2 parent = vc
      2 cmb_id = f8
      2 from_id = f8
      2 to_id = f8
      2 encntr_id = f8
      2 updt_dt_tm = dq8
      2 updt_id = f8
      2 application_flag = i2
    1 cnt = i2
    1 err_tbl = vc
    1 err_msg = vc
  )
 ENDIF
 SET dm_debug_cmb = 0
 IF (validate(dm_debug,0) > 0)
  SET dm_debug_cmb = 1
 ENDIF
 FREE RECORD dct_work
 RECORD dct_work(
   1 dct_tbl = vc
   1 dct_pk = vc
   1 dct_from = vc
   1 dct_to = vc
   1 dct_parent_pk = vc
   1 dct_parent = vc
   1 err_msg = vc
 )
 DECLARE dct_from_id = f8
 SET dct_from_id = 0.0
 DECLARE dct_encntr_id = f8
 SET dct_encntr_id = 0.0
 DECLARE dct_cmb_id = f8
 SET dct_cmb_id = 0.0
 DECLARE dct_ecode = i2
 SET dct_ecode = 0
 DECLARE dcv_id = f8
 SET dcv_id = 0.0
 DECLARE dgc_id = f8
 SET dgc_id = 0.0
 DECLARE dgc_cmb_id = f8
 SET dgc_cmb_id = 0.0
 DECLARE dge_from_id = f8
 SET dge_from_id = 0.0
 DECLARE dge_cmb_id = f8
 SET dge_cmb_id = 0.0
 DECLARE dge_encntr_id = f8
 SET dge_encntr_id = 0.0
 DECLARE dct_chk_validity(dcv_id) = i2
 DECLARE dct_get_cmb_id(dgc_id,dgc_cmb_id) = f8
 DECLARE dct_get_encntr_move_id(dge_from_id,dge_encntr_id,dge_cmb_id) = null
 SET cmb_tree->cnt = 0
 SET stat = alterlist(cmb_tree->cmb,0)
 SET cmb_tree->valid_ind = 0
 SET cmb_tree->final_enc_id = 0.0
 SET cmb_tree->final_id = 0.0
 SET dct_work->dct_parent = cnvtupper(trim( $1))
 SET dct_from_id =  $2
 SET dct_encntr_id =  $3
 SET dct_cmb_id =  $4
 SET dct_file = build("dm_combine_tree_",cnvtint(dct_from_id),".txt")
 CASE (cnvtupper(dct_work->dct_parent))
  OF "PERSON":
   SET dct_work->dct_tbl = "PERSON_COMBINE"
   SET dct_work->dct_pk = "PERSON_COMBINE_ID"
   SET dct_work->dct_from = "FROM_PERSON_ID"
   SET dct_work->dct_to = "TO_PERSON_ID"
   SET dct_work->dct_parent_pk = "PERSON_ID"
  OF "ENCOUNTER":
   SET dct_work->dct_tbl = "ENCNTR_COMBINE"
   SET dct_work->dct_pk = "ENCNTR_COMBINE_ID"
   SET dct_work->dct_from = "FROM_ENCNTR_ID"
   SET dct_work->dct_to = "TO_ENCNTR_ID"
   SET dct_work->dct_parent_pk = "ENCNTR_ID"
  OF "PRSNL":
   SET dct_work->dct_tbl = "COMBINE"
   SET dct_work->dct_pk = "COMBINE_ID"
   SET dct_work->dct_from = "FROM_ID"
   SET dct_work->dct_to = "TO_ID"
   SET dct_work->dct_parent_pk = "PERSON_ID"
  OF "LOCATION":
   SET dct_work->dct_tbl = "COMBINE"
   SET dct_work->dct_pk = "COMBINE_ID"
   SET dct_work->dct_from = "FROM_ID"
   SET dct_work->dct_to = "TO_ID"
   SET dct_work->dct_parent_pk = "LOCATION_CD"
  OF "HEALTH_PLAN":
   SET dct_work->dct_tbl = "COMBINE"
   SET dct_work->dct_pk = "COMBINE_ID"
   SET dct_work->dct_from = "FROM_ID"
   SET dct_work->dct_to = "TO_ID"
   SET dct_work->dct_parent_pk = "HEALTH_PLAN_ID"
  OF "ORGANIZATION":
   SET dct_work->dct_tbl = "COMBINE"
   SET dct_work->dct_pk = "COMBINE_ID"
   SET dct_work->dct_from = "FROM_ID"
   SET dct_work->dct_to = "TO_ID"
   SET dct_work->dct_parent_pk = "ORGANIZATION_ID"
  ELSE
   SET cmb_tree->err_tbl = dct_work->dct_parent
   SET cmb_tree->err_msg = concat("The parent table ",dct_work->dct_parent," is invalid for combine."
    )
   GO TO dct_error
 ENDCASE
 IF (dm_debug_cmb=1)
  CALL echo(build("dct_work->dct_tbl =",dct_work->dct_tbl))
  CALL echo(build("dct_work->dct_pk =",dct_work->dct_pk))
 ENDIF
 IF ((dct_work->dct_parent="PERSON")
  AND dct_encntr_id > 0)
  CALL dct_get_encntr_move_id(dct_from_id,dct_encntr_id,dct_cmb_id)
 ELSE
  IF (dct_from_id > 0)
   SET cmb_tree->valid_ind = dct_chk_validity(dct_from_id)
  ENDIF
  IF (dm_debug_cmb=1)
   CALL echo(build("The from_id's valid_ind =",cmb_tree->valid_ind," on parent table =",dct_work->
     dct_parent))
  ENDIF
  SET cmb_tree->final_id = dct_get_cmb_id(dct_from_id,dct_cmb_id)
  IF ((dct_work->dct_parent="ENCOUNTER"))
   SET cmb_tree->final_enc_id = cmb_tree->final_id
  ENDIF
  IF ((cmb_tree->final_id=- (1)))
   SET cmb_tree->err_tbl = dct_work->dct_tbl
   SET cmb_tree->err_msg = build("A loop has been found on ",trim(dct_work->dct_tbl),
    " table for from_id ",dct_from_id,".  Can not continue due to illegal combine.")
   GO TO dct_error
  ENDIF
 ENDIF
#dct_error
 IF (dct_ecode != 0)
  SET cmb_tree->err_tbl = " "
  SET cmb_tree->err_msg = dct_work->err_msg
 ENDIF
 IF (size(cmb_tree->err_msg,1) > 0)
  SELECT INTO value(dct_file)
   d.*
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    col 0, "Error occured in dm_combine_tree...", row + 1,
    col 0, "ERROR_TABLE :", col 20,
    cmb_tree->err_tbl, row + 1, col 0,
    "ERROR_MESSAGE :", col 20, cmb_tree->err_msg,
    row + 1
   WITH nocounter
  ;end select
 ELSEIF ((cmb_tree->cnt=0))
  SELECT INTO value(dct_file)
   d.*
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    IF ((cmb_tree->valid_ind=1))
     col 0, "The from id ", col + 0,
     dct_from_id, col + 1, "is active on parent table ",
     col + 0, dct_work->dct_parent, row + 1
    ENDIF
    col 0, "No combine history found for from id", col + 0,
    dct_from_id, col + 0, ", encntr_id",
    col + 0, dct_encntr_id, col + 0,
    ", combine_id", col + 0, dct_cmb_id,
    col + 1, "on parent table ", col + 0,
    dct_work->dct_parent, row + 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO value(dct_file)
   d.*
   FROM (dummyt d  WITH seq = value(cmb_tree->cnt))
   HEAD REPORT
    IF ((cmb_tree->valid_ind=1))
     col 0, "The from id ", col + 0,
     dct_from_id, col + 1, "is active on parent table ",
     col + 0, dct_work->dct_parent, row + 1,
     row + 1
    ENDIF
    col 0, "PARENT_TABLE", col 20,
    "COMBINE_ID", col 35, "FROM_ID",
    col 50, "TO_ID", col 65,
    "ENCNTR_ID", col 80, "UPDT_DT_TM",
    col 100, "UPDT_ID", col 110,
    "APPLICATION_FLAG", row + 1
   DETAIL
    col 0, cmb_tree->cmb[d.seq].parent, col 15,
    cmb_tree->cmb[d.seq].cmb_id, col 30, cmb_tree->cmb[d.seq].from_id,
    col 45, cmb_tree->cmb[d.seq].to_id, col 60,
    cmb_tree->cmb[d.seq].encntr_id, col 78, cmb_tree->cmb[d.seq].updt_dt_tm";;q",
    col 95, cmb_tree->cmb[d.seq].updt_id, col 108,
    cmb_tree->cmb[d.seq].application_flag, row + 1
   FOOT REPORT
    row + 0
   WITH nocounter, maxcol = 200
  ;end select
 ENDIF
 IF (validate(dr_call_script,"ZZ")="ZZ")
  FREE DEFINE rtl
  FREE SET file_loc
  SET logical file_loc value(dct_file)
  DEFINE rtl "file_loc"
  SELECT
   r.line
   FROM rtlt r
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE dct_chk_validity(dcv_id)
  SELECT INTO "nl:"
   FROM (value(dct_work->dct_parent) c)
   WHERE parser(build("c.",dct_work->dct_parent_pk," = ",dcv_id))
    AND c.active_ind=1
   WITH nocounter
  ;end select
  IF (curqual)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE dct_get_cmb_id(dgc_id,dgc_cmb_id)
   SET dgc_loop = 1
   SET dgc_temp_id = 0.0
   SET dgc_flag = 0
   SELECT
    IF (dgc_cmb_id > 0)INTO "nl:"
     FROM (value(dct_work->dct_tbl) c)
     WHERE parser(build("c.",dct_work->dct_pk," = ",dgc_cmb_id))
      AND c.active_ind=1
    ELSEIF (dgc_cmb_id=0
     AND (dct_work->dct_parent="PERSON"))INTO "nl:"
     FROM person_combine c
     WHERE c.from_person_id=dgc_id
      AND c.encntr_id=0
      AND c.active_ind=1
     ORDER BY c.updt_dt_tm DESC
    ELSE INTO "nl:"
     FROM (value(dct_work->dct_tbl) c)
     WHERE parser(build("c.",dct_work->dct_from," = ",dgc_id))
      AND c.active_ind=1
     ORDER BY c.updt_dt_tm DESC
    ENDIF
    DETAIL
     cmb_tree->cnt += 1, stat = alterlist(cmb_tree->cmb,cmb_tree->cnt), cmb_tree->cmb[cmb_tree->cnt].
     parent = trim(dct_work->dct_parent),
     cmb_tree->cmb[cmb_tree->cnt].cmb_id = parser(build("c.",dct_work->dct_pk)), cmb_tree->cmb[
     cmb_tree->cnt].from_id = parser(build("c.",dct_work->dct_from)), cmb_tree->cmb[cmb_tree->cnt].
     to_id = parser(build("c.",dct_work->dct_to)),
     cmb_tree->cmb[cmb_tree->cnt].encntr_id = 0.0, cmb_tree->cmb[cmb_tree->cnt].updt_dt_tm = c
     .updt_dt_tm, cmb_tree->cmb[cmb_tree->cnt].updt_id = c.updt_id,
     cmb_tree->cmb[cmb_tree->cnt].application_flag = c.application_flag, dgc_id = cmb_tree->cmb[
     cmb_tree->cnt].to_id
    WITH nocounter, maxread(c,1)
   ;end select
   IF (curqual=0)
    SET dgc_loop = 0
   ENDIF
   WHILE (dgc_loop)
    SELECT
     IF ((dct_work->dct_parent="PERSON"))INTO "nl:"
      FROM person_combine c
      WHERE c.from_person_id=dgc_id
       AND c.encntr_id=0
       AND active_ind=1
      ORDER BY c.updt_dt_tm DESC
     ELSE INTO "nl:"
      FROM (value(dct_work->dct_tbl) c)
      WHERE parser(build("c.",dct_work->dct_from," = ",dgc_id))
       AND c.active_ind=1
      ORDER BY c.updt_dt_tm DESC
     ENDIF
     DETAIL
      dgc_temp_id = parser(build("c.",dct_work->dct_to))
      FOR (dgc_idx = 1 TO cmb_tree->cnt)
        IF ((dgc_temp_id=cmb_tree->cmb[dgc_idx].from_id))
         dgc_loop = 0, dgc_idx = cmb_tree->cnt, dgc_flag = 1
        ENDIF
      ENDFOR
      IF (dgc_loop)
       cmb_tree->cnt += 1, stat = alterlist(cmb_tree->cmb,cmb_tree->cnt), cmb_tree->cmb[cmb_tree->cnt
       ].parent = dct_work->dct_parent,
       cmb_tree->cmb[cmb_tree->cnt].cmb_id = parser(build("c.",dct_work->dct_pk)), cmb_tree->cmb[
       cmb_tree->cnt].from_id = parser(build("c.",dct_work->dct_from)), cmb_tree->cmb[cmb_tree->cnt].
       to_id = parser(build("c.",dct_work->dct_to)),
       cmb_tree->cmb[cmb_tree->cnt].encntr_id = 0.0, cmb_tree->cmb[cmb_tree->cnt].updt_dt_tm = c
       .updt_dt_tm, cmb_tree->cmb[cmb_tree->cnt].updt_id = c.updt_id,
       cmb_tree->cmb[cmb_tree->cnt].application_flag = c.application_flag, dgc_id = cmb_tree->cmb[
       cmb_tree->cnt].to_id
      ENDIF
     WITH nocounter, maxread(c,1)
    ;end select
    IF (curqual=0)
     SET dgc_loop = 0
    ENDIF
   ENDWHILE
   IF ((cmb_tree->cnt > 0)
    AND dgc_flag=0)
    RETURN(cmb_tree->cmb[cmb_tree->cnt].to_id)
   ELSEIF ((cmb_tree->cnt > 0)
    AND dgc_flag=1)
    RETURN(- (1))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dct_get_encntr_move_id(dge_id,dge_encntr_id,dge_cmb_id)
   SET dge_loop1 = 1
   SET dge_loop2 = 1
   SET dge_loop3 = 1
   SET dge_person_valid = 0
   SET dge_encntr_valid = 0
   SET cmb_tree->final_id = dge_id
   SET cmb_tree->final_enc_id = dge_encntr_id
   SET dge_enc_move_cnt = 0
   SELECT
    IF (dge_cmb_id > 0.0)INTO "nl:"
     FROM person_combine pc
     WHERE pc.person_combine_id=dge_cmb_id
      AND pc.active_ind=1
    ELSE INTO "nl:"
     FROM person_combine pc
     WHERE pc.from_person_id=dge_id
      AND pc.encntr_id=dge_encntr_id
      AND pc.active_ind=1
     ORDER BY pc.updt_dt_tm
    ENDIF
    DETAIL
     cmb_tree->cnt += 1, stat = alterlist(cmb_tree->cmb,cmb_tree->cnt), cmb_tree->cmb[cmb_tree->cnt].
     parent = "PERSON",
     cmb_tree->cmb[cmb_tree->cnt].cmb_id = pc.person_combine_id, cmb_tree->cmb[cmb_tree->cnt].from_id
      = pc.from_person_id, cmb_tree->cmb[cmb_tree->cnt].to_id = pc.to_person_id,
     cmb_tree->cmb[cmb_tree->cnt].encntr_id = pc.encntr_id, cmb_tree->cmb[cmb_tree->cnt].updt_dt_tm
      = pc.updt_dt_tm, cmb_tree->cmb[cmb_tree->cnt].updt_id = pc.updt_id,
     cmb_tree->cmb[cmb_tree->cnt].application_flag = pc.application_flag, dge_id = cmb_tree->cmb[
     cmb_tree->cnt].to_id, dge_encntr_id = cmb_tree->cmb[cmb_tree->cnt].encntr_id,
     dge_cmb_id = cmb_tree->cmb[cmb_tree->cnt].cmb_id, cmb_tree->final_id = cmb_tree->cmb[cmb_tree->
     cnt].to_id, cmb_tree->final_enc_id = cmb_tree->cmb[cmb_tree->cnt].encntr_id
    WITH nocounter, maxread(pc,1)
   ;end select
   IF (curqual=0)
    SET dge_loop2 = 0
   ENDIF
   IF (dm_debug_cmb=1)
    CALL echo("After first combine...")
    CALL echorecord(cmb_tree)
    CALL echo(build("dge_id =",dge_id))
    CALL echo(build("dge_cmb_id =",dge_cmb_id))
    CALL echo(build("dge_encntr_id =",dge_encntr_id))
   ENDIF
   WHILE (dge_loop1)
     WHILE (dge_loop2)
       SET dge_enc_move_cnt = 0
       SELECT INTO "nl:"
        FROM person_combine pc
        WHERE pc.from_person_id=dge_id
         AND pc.encntr_id=dge_encntr_id
         AND pc.person_combine_id > dge_cmb_id
         AND pc.active_ind=1
        ORDER BY pc.updt_dt_tm
        DETAIL
         dge_enc_move_cnt += 1, cmb_tree->cnt += 1, stat = alterlist(cmb_tree->cmb,cmb_tree->cnt),
         cmb_tree->cmb[cmb_tree->cnt].parent = "PERSON", cmb_tree->cmb[cmb_tree->cnt].cmb_id = pc
         .person_combine_id, cmb_tree->cmb[cmb_tree->cnt].from_id = pc.from_person_id,
         cmb_tree->cmb[cmb_tree->cnt].to_id = pc.to_person_id, cmb_tree->cmb[cmb_tree->cnt].encntr_id
          = pc.encntr_id, cmb_tree->cmb[cmb_tree->cnt].updt_dt_tm = pc.updt_dt_tm,
         cmb_tree->cmb[cmb_tree->cnt].updt_id = pc.updt_id, cmb_tree->cmb[cmb_tree->cnt].
         application_flag = pc.application_flag, dge_id = cmb_tree->cmb[cmb_tree->cnt].to_id,
         dge_encntr_id = cmb_tree->cmb[cmb_tree->cnt].encntr_id, dge_cmb_id = cmb_tree->cmb[cmb_tree
         ->cnt].cmb_id, cmb_tree->final_id = cmb_tree->cmb[cmb_tree->cnt].to_id,
         cmb_tree->final_enc_id = cmb_tree->cmb[cmb_tree->cnt].encntr_id
        WITH nocounter, maxread(pc,1)
       ;end select
       IF (dm_debug_cmb=1)
        CALL echo(build("After ",cmb_tree->cnt," combine..."))
        CALL echorecord(cmb_tree)
        CALL echo(build("dge_id =",dge_id))
        CALL echo(build("dge_cmb_id =",dge_cmb_id))
        CALL echo(build("dge_encntr_id =",dge_encntr_id))
       ENDIF
       IF (dge_enc_move_cnt=0)
        SET dge_loop2 = 0
       ENDIF
     ENDWHILE
     SELECT INTO "nl:"
      FROM encntr_combine ec
      WHERE ec.from_encntr_id=dge_encntr_id
       AND ec.active_ind=1
      ORDER BY ec.updt_dt_tm DESC
      DETAIL
       FOR (dge_idx = 1 TO cmb_tree->cnt)
         IF ((ec.to_encntr_id=cmb_tree->cmb[dge_idx].from_id)
          AND (cmb_tree->cmb[dge_idx].parent="ENCOUNTER"))
          dge_loop1 = 0, dge_idx = cmb_tree->cnt
         ENDIF
       ENDFOR
       IF (dge_loop1)
        cmb_tree->cnt += 1, stat = alterlist(cmb_tree->cmb,cmb_tree->cnt), cmb_tree->cmb[cmb_tree->
        cnt].parent = "ENCOUNTER",
        cmb_tree->cmb[cmb_tree->cnt].cmb_id = ec.encntr_combine_id, cmb_tree->cmb[cmb_tree->cnt].
        from_id = ec.from_encntr_id, cmb_tree->cmb[cmb_tree->cnt].to_id = ec.to_encntr_id,
        cmb_tree->cmb[cmb_tree->cnt].encntr_id = 0.0, cmb_tree->cmb[cmb_tree->cnt].updt_dt_tm = ec
        .updt_dt_tm, cmb_tree->cmb[cmb_tree->cnt].updt_id = ec.updt_id,
        cmb_tree->cmb[cmb_tree->cnt].application_flag = ec.application_flag, dge_encntr_id = cmb_tree
        ->cmb[cmb_tree->cnt].to_id, cmb_tree->final_enc_id = cmb_tree->cmb[cmb_tree->cnt].to_id,
        dge_loop2 = 1
       ENDIF
      WITH nocounter, maxread(ec,1)
     ;end select
     IF (dm_debug_cmb=1)
      CALL echo("***************")
      CALL echo(build("curqual =",curqual))
      CALL echo(build("dge_enc_move_cnt =",dge_enc_move_cnt))
      CALL echo("***************")
     ENDIF
     IF (curqual=0
      AND dge_enc_move_cnt=0)
      SET dge_loop1 = 0
     ENDIF
   ENDWHILE
   WHILE (dge_loop3)
     SET dge_person_valid = dct_chk_validity(dge_id)
     IF ( NOT (dge_person_valid))
      SELECT INTO "nl:"
       FROM person_combine pc
       WHERE pc.from_person_id=dge_id
        AND pc.encntr_id=0
        AND pc.person_combine_id > dge_cmb_id
        AND pc.active_ind=1
       ORDER BY pc.updt_dt_tm DESC
       DETAIL
        FOR (dge_idx = 1 TO cmb_tree->cnt)
          IF ((pc.to_person_id=cmb_tree->cmb[dge_idx].from_id)
           AND (cmb_tree->cmb[dge_idx].parent="PERSON")
           AND (cmb_tree->cmb[dge_idx].encntr_id=0))
           dge_loop3 = 0, dge_idx = cmb_tree->cnt
          ENDIF
        ENDFOR
        IF (dge_loop3)
         cmb_tree->cnt += 1, stat = alterlist(cmb_tree->cmb,cmb_tree->cnt), cmb_tree->cmb[cmb_tree->
         cnt].parent = "PERSON",
         cmb_tree->cmb[cmb_tree->cnt].cmb_id = pc.person_combine_id, cmb_tree->cmb[cmb_tree->cnt].
         from_id = dge_id, cmb_tree->cmb[cmb_tree->cnt].to_id = pc.to_person_id,
         cmb_tree->cmb[dge_idx].encntr_id = 0, cmb_tree->cmb[dge_idx].updt_dt_tm = pc.updt_dt_tm,
         cmb_tree->cmb[dge_idx].updt_id = pc.updt_id,
         dge_id = cmb_tree->cmb[cmb_tree->cnt].to_id, dge_cmb_id = pc.person_combine_id, cmb_tree->
         final_id = cmb_tree->cmb[cmb_tree->cnt].to_id
        ENDIF
       WITH nocounter, maxread(c,1)
      ;end select
     ELSE
      SET dge_loop3 = 0
     ENDIF
     IF (curqual=0)
      SET dge_loop3 = 0
     ENDIF
   ENDWHILE
 END ;Subroutine
#exit_script
END GO
