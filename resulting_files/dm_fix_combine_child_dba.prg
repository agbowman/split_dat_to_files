CREATE PROGRAM dm_fix_combine_child:dba
 PROMPT
  "Enter in quotes the table name (eg. 'CODING') : ",
  "Enter in quotes the attribute name referenced to PERSON (eg. 'PERSON_ID') or 'NONE'    : " =
  "none",
  "Enter in quotes the attribute name referenced to ENCOUNTER (eg. 'ENCNTR_ID') or 'NONE' : " =
  "none"
 EXECUTE dm_temp_check
 SET child_table = cnvtupper( $1)
 SET p_fk_name = cnvtupper( $2)
 SET e_fk_name = cnvtupper( $3)
 SET pk_col_name = fillstring(30," ")
 SET log_fname = "dm_fix_combine_child_log.dat"
 IF (p_fk_name != "NONE")
  SELECT INTO "nl:"
   a.column_name
   FROM dm_user_cons_columns a
   WHERE a.table_name=child_table
    AND a.constraint_type="P"
    AND a.position=1
   DETAIL
    pk_col_name = a.column_name
   WITH nocounter
  ;end select
  IF (pk_col_name=" ")
   CALL echo(
    "*****************************************************************************************")
   CALL echo(concat("                  Could not process ",trim(child_table)," table."))
   CALL echo("                         Primary key was not found .")
   CALL echo(
    "*****************************************************************************************")
   GO TO end_script
  ENDIF
  SELECT INTO "nl:"
   FROM dm_user_cons_columns a
   WHERE a.table_name=child_table
    AND a.r_constraint_name="XPKPERSON"
    AND a.column_name=p_fk_name
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo(
    "*****************************************************************************************")
   CALL echo(concat("                  Could not process ",trim(child_table)," table."))
   CALL echo("                     Attribute name referenced to PERSON was not found.")
   CALL echo(
    "*****************************************************************************************")
   GO TO end_script
  ENDIF
 ENDIF
 IF (e_fk_name != "NONE")
  SELECT INTO "nl:"
   a.column_name
   FROM dm_user_cons_columns a
   WHERE a.table_name=child_table
    AND a.constraint_type="P"
    AND a.position=1
   DETAIL
    pk_col_name = a.column_name
   WITH nocounter
  ;end select
  IF (pk_col_name=" ")
   CALL echo(
    "*****************************************************************************************")
   CALL echo(concat("                    Could not process ",child_table," table."))
   CALL echo("                           Primary key was not found.")
   CALL echo(
    "*****************************************************************************************")
   GO TO end_script
  ENDIF
  SELECT INTO "nl:"
   FROM dm_user_cons_columns a
   WHERE a.table_name=child_table
    AND a.r_constraint_name="XPKENCOUNTER"
    AND a.column_name=e_fk_name
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo(
    "*****************************************************************************************")
   CALL echo(concat("                    Could not process ",child_table," table."))
   CALL echo("                   Attribute name referenced to ENCOUNTER was not found.")
   CALL echo(
    "*****************************************************************************************")
   GO TO end_script
  ENDIF
 ENDIF
 RECORD qual(
   1 enc_move[*]
     2 old_person_id = f8
     2 new_person_id = f8
     2 encntr_id = f8
     2 pk_id = f8
     2 upt_ind = i2
   1 per_cmb[*]
     2 old_id = f8
     2 new_id = f8
     2 pk_id = f8
     2 combine_id = f8
   1 enc_cmb[*]
     2 old_id = f8
     2 new_id = f8
     2 pk_id = f8
     2 combine_id = f8
   1 enc_move_cnt = i4
   1 per_cmb_cnt = i4
   1 enc_cmb_cnt = i4
 )
 SET qual->enc_move_cnt = 0
 SET qual->per_cmb_cnt = 0
 SET qual->enc_cmb_cnt = 0
 SET p_buf[20] = fillstring(132," ")
 IF (p_fk_name != "NONE"
  AND e_fk_name != "NONE")
  SET p_buf[1] = "select into 'nl:'"
  SET p_buf[2] = concat("  from ",trim(child_table)," c")
  SET p_buf[3] = " where exists (select 'x' from person_combine p where p.from_person_id != 0"
  SET p_buf[4] = concat("                 and  p.from_person_id = c.",trim(p_fk_name))
  SET p_buf[5] = concat("                 and  p.encntr_id      = c.",trim(e_fk_name),")")
  SET p_buf[6] = "detail"
  SET p_buf[7] = "  qual->enc_move_cnt = qual->enc_move_cnt + 1"
  SET p_buf[8] = "  stat = alterlist(qual->enc_move, qual->enc_move_cnt)"
  SET p_buf[9] = concat("  qual->enc_move[qual->enc_move_cnt]->old_person_id = c.",trim(p_fk_name))
  SET p_buf[10] = concat("  qual->enc_move[qual->enc_move_cnt]->encntr_id = c.",trim(e_fk_name))
  SET p_buf[11] = concat("  qual->enc_move[qual->enc_move_cnt]->pk_id = c.",trim(pk_col_name))
  SET p_buf[12] = "with nocounter go"
  FOR (b_cnt = 1 TO 12)
   CALL parser(p_buf[b_cnt])
   SET p_buf[b_cnt] = fillstring(132," ")
  ENDFOR
  IF ((qual->enc_move_cnt > 0))
   SELECT INTO "nl:"
    FROM encounter e,
     (dummyt d  WITH seq = value(qual->enc_move_cnt))
    PLAN (d)
     JOIN (e
     WHERE (e.encntr_id=qual->enc_move[d.seq].encntr_id)
      AND (e.person_id != qual->enc_move[d.seq].old_person_id))
    DETAIL
     qual->enc_move[d.seq].new_person_id = e.person_id, qual->enc_move[d.seq].upt_ind = 1
    WITH nocounter
   ;end select
   FOR (x = 1 TO qual->enc_move_cnt)
     IF ((qual->enc_move[x].upt_ind=1))
      SET p_buf[1] = concat("update into ",trim(child_table)," c")
      SET p_buf[2] = concat("   set c.",trim(p_fk_name)," = ",build(qual->enc_move[x].new_person_id),
       ",")
      SET p_buf[3] =
      "       c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = c.updt_cnt + 1,"
      SET p_buf[4] = "       c.updt_task = 88888"
      SET p_buf[5] = concat("where  c.",trim(pk_col_name)," = ",build(qual->enc_move[x].pk_id))
      SET p_buf[6] = concat("  and  c.",trim(p_fk_name)," = ",build(qual->enc_move[x].old_person_id))
      SET p_buf[7] = concat("  and  c.",trim(e_fk_name)," = ",build(qual->enc_move[x].encntr_id))
      SET p_buf[8] = "with nocounter go"
      FOR (b_cnt = 1 TO 8)
       CALL parser(p_buf[b_cnt])
       SET p_buf[b_cnt] = fillstring(132," ")
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
 ELSEIF (p_fk_name="NONE"
  AND e_fk_name="NONE")
  CALL echo(
   "*****************************************************************************************")
  CALL echo("                     Please retry entering one or both attribute name.")
  CALL echo(
   "*****************************************************************************************")
  GO TO end_script
 ENDIF
 IF (p_fk_name != "NONE")
  SET p_buf[1] = "select into 'nl:'"
  SET p_buf[2] = concat("from   ",trim(child_table)," c, person_combine pc")
  SET p_buf[3] = concat("where  c.",trim(p_fk_name)," = pc.from_person_id")
  SET p_buf[4] = "and  pc.from_person_id != 0 and pc.encntr_id = 0 and pc.active_ind = 1"
  SET p_buf[5] = "order by pc.updt_dt_tm"
  SET p_buf[6] = "detail"
  SET p_buf[7] = "  qual->per_cmb_cnt = qual->per_cmb_cnt + 1"
  SET p_buf[8] = "  stat = alterlist(qual->per_cmb, qual->per_cmb_cnt)"
  SET p_buf[9] = "  qual->per_cmb[qual->per_cmb_cnt]->old_id = pc.from_person_id"
  SET p_buf[10] = "  qual->per_cmb[qual->per_cmb_cnt]->new_id = pc.to_person_id"
  SET p_buf[11] = concat("  qual->per_cmb[qual->per_cmb_cnt]->pk_id = c.",trim(pk_col_name))
  SET p_buf[12] = "  qual->per_cmb[qual->per_cmb_cnt]->combine_id = pc.person_combine_id"
  SET p_buf[13] = "with nocounter go"
  FOR (b_cnt = 1 TO 13)
   CALL parser(p_buf[b_cnt])
   SET p_buf[b_cnt] = fillstring(132," ")
  ENDFOR
  CALL echo("----")
  CALL echo(concat("Total person_cmb = ",build(qual->per_cmb_cnt)))
  CALL echo("----")
 ENDIF
 IF (e_fk_name != "NONE")
  SET p_buf[1] = "select into 'nl:'"
  SET p_buf[2] = concat("from ",trim(child_table)," c, encntr_combine pc")
  SET p_buf[3] = concat("where c.",trim(e_fk_name)," = pc.from_encntr_id ")
  SET p_buf[4] = "and pc.from_encntr_id != 0 and pc.active_ind = 1"
  SET p_buf[5] = "order by pc.updt_dt_tm"
  SET p_buf[6] = "detail"
  SET p_buf[7] = "  qual->enc_cmb_cnt = qual->enc_cmb_cnt + 1"
  SET p_buf[8] = "  stat = alterlist(qual->enc_cmb, qual->enc_cmb_cnt)"
  SET p_buf[9] = "  qual->enc_cmb[qual->enc_cmb_cnt]->old_id = pc.from_encntr_id"
  SET p_buf[10] = "  qual->enc_cmb[qual->enc_cmb_cnt]->new_id = pc.to_encntr_id"
  SET p_buf[11] = concat("  qual->enc_cmb[qual->enc_cmb_cnt]->pk_id = c.",trim(pk_col_name))
  SET p_buf[12] = "  qual->enc_cmb[qual->enc_cmb_cnt]->combine_id = pc.encntr_combine_id"
  SET p_buf[13] = "with nocounter go"
  FOR (b_cnt = 1 TO 13)
   CALL parser(p_buf[b_cnt])
   SET p_buf[b_cnt] = fillstring(132," ")
  ENDFOR
  CALL echo("----")
  CALL echo(concat("Total enc_cmb = ",build(qual->enc_cmb_cnt)))
  CALL echo("----")
 ENDIF
 IF ((((qual->per_cmb_cnt > 0)) OR ((qual->enc_cmb_cnt > 0))) )
  SELECT INTO dm_fix_combine_child_log
   d.seq
   FROM dummyt d
   DETAIL
    col 0, child_table, " TABLE COMBINE FIX LOG"
   WITH nocounter, format = variable, noformfeed,
    maxrow = 1, maxcol = 130, noheading
  ;end select
  SET dm_active_cd = 0
  SET upt = 0
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE"
   DETAIL
    dm_active_cd = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=327
    AND c.cdf_meaning="UPT"
   DETAIL
    upt = c.code_value
   WITH nocounter
  ;end select
  IF ((qual->per_cmb_cnt > 0))
   SELECT INTO dm_fix_combine_child_log
    d.seq
    FROM dummyt d
    DETAIL
     row + 1, col 0, "Old Person_id  New Person_id  Primary key ID  Status/Error",
     row + 1, col 0, "-------------  -------------  --------------  ------------"
    WITH nocounter, format = variable, noformfeed,
     maxrow = 4, maxcol = 130, noheading,
     append
   ;end select
   FOR (ichange = 1 TO qual->per_cmb_cnt)
     SET id_buffer = 0
     SET id_buffer = qual->per_cmb[ichange].new_id
     CALL get_valid_pid(id_buffer)
     SET p_buf[1] = concat("update into ",trim(child_table)," c")
     SET p_buf[2] = concat("   set c.",trim(p_fk_name)," = qual->per_cmb[iChange]->new_id,")
     SET p_buf[3] =
     "       c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = c.updt_cnt + 1,"
     SET p_buf[4] = "       c.updt_task = 88888"
     SET p_buf[5] = concat("where  c.",trim(pk_col_name),"= qual->per_cmb[iChange]->pk_id")
     SET p_buf[6] = concat("  and  c.",trim(p_fk_name)," = qual->per_cmb[iChange]->old_id")
     SET p_buf[7] = "with nocounter go"
     FOR (b_cnt = 1 TO 7)
      CALL parser(p_buf[b_cnt])
      SET p_buf[b_cnt] = fillstring(132," ")
     ENDFOR
     INSERT  FROM person_combine_det
      SET attribute_name = p_fk_name, combine_action_cd = upt, person_combine_id = qual->per_cmb[
       ichange].combine_id,
       entity_id = qual->per_cmb[ichange].pk_id, entity_name = child_table, person_combine_det_id =
       seq(person_combine_seq,nextval),
       updt_cnt = 0, updt_dt_tm = cnvtdatetime(sysdate), updt_id = 88888,
       updt_task = 88888, updt_applctx = 88888, active_ind = 1,
       active_status_cd = dm_active_cd, active_status_dt_tm = cnvtdatetime(sysdate),
       active_status_prsnl_id = 88888
      WITH nocounter
     ;end insert
     SET ecode = 0
     SET emsg = fillstring(132," ")
     SET ecode = error(emsg,1)
     SET dm_old_id = qual->per_cmb[ichange].old_id
     SET dm_new_id = qual->per_cmb[ichange].new_id
     SET dm_pk_id = qual->per_cmb[ichange].pk_id
     SET dm_cmb_id = qual->per_cmb[ichange].combine_id
     SELECT INTO dm_fix_combine_child_log
      d.seq, error1 = substring(1,70,emsg), error2 = substring(71,61,emsg)
      FROM dummyt d
      DETAIL
       col 1, dm_old_id"###########;r", col + 4,
       dm_new_id"###########;r", col + 4, dm_pk_id"############;r"
       IF (ecode=0)
        col + 3, "Corrected"
       ELSE
        col + 3, error1, row + 1,
        col 60, error2
       ENDIF
      WITH nocounter, format = variable, noformfeed,
       maxrow = 2, maxcol = 130, noheading,
       append
     ;end select
   ENDFOR
  ENDIF
  IF ((qual->enc_cmb_cnt > 0))
   SELECT INTO dm_fix_combine_child_log
    d.seq
    FROM dummyt d
    DETAIL
     row + 1, col 0, "Old Encntr_id  New Encntr_id  Primary key ID  Status/Error",
     row + 1, col 0, "-------------  -------------  --------------  ------------"
    WITH nocounter, format = variable, noformfeed,
     maxrow = 4, maxcol = 130, noheading,
     append
   ;end select
   FOR (ichange = 1 TO qual->enc_cmb_cnt)
     SET id_buffer = 0
     SET id_buffer = qual->enc_cmb[ichange].new_id
     CALL get_valid_eid(id_buffer)
     SET p_buf[1] = concat("update into ",trim(child_table)," c")
     SET p_buf[2] = concat("   set c.",trim(e_fk_name)," = qual->enc_cmb[iChange]->new_id,")
     SET p_buf[3] =
     "       c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = c.updt_cnt + 1,"
     SET p_buf[4] = "       c.updt_task = 88888"
     SET p_buf[5] = concat("where  c.",trim(pk_col_name),"= qual->enc_cmb[iChange]->pk_id")
     SET p_buf[6] = concat("  and  c.",trim(e_fk_name)," = qual->enc_cmb[iChange]->old_id")
     SET p_buf[7] = "with nocounter go"
     FOR (b_cnt = 1 TO 7)
      CALL parser(p_buf[b_cnt])
      SET p_buf[b_cnt] = fillstring(132," ")
     ENDFOR
     INSERT  FROM encntr_combine_det
      SET attribute_name = e_fk_name, combine_action_cd = upt, encntr_combine_id = qual->enc_cmb[
       ichange].combine_id,
       entity_id = qual->enc_cmb[ichange].pk_id, entity_name = child_table, encntr_combine_det_id =
       seq(encounter_combine_seq,nextval),
       updt_cnt = 0, updt_dt_tm = cnvtdatetime(sysdate), updt_id = 88888,
       updt_task = 88888, updt_applctx = 88888, active_ind = 1,
       active_status_cd = dm_active_cd, active_status_dt_tm = cnvtdatetime(sysdate),
       active_status_prsnl_id = 88888
      WITH nocounter
     ;end insert
     SET ecode = 0
     SET emsg = fillstring(132," ")
     SET ecode = error(emsg,1)
     SET dm_old_id = qual->enc_cmb[ichange].old_id
     SET dm_new_id = qual->enc_cmb[ichange].new_id
     SET dm_pk_id = qual->enc_cmb[ichange].pk_id
     SET dm_cmb_id = qual->enc_cmb[ichange].combine_id
     SELECT INTO dm_fix_combine_child_log
      d.seq, error1 = substring(1,70,emsg), error2 = substring(71,61,emsg)
      FROM dummyt d
      DETAIL
       col 1, dm_old_id"###########;r", col + 4,
       dm_new_id"###########;r", col + 4, dm_pk_id"############;r"
       IF (ecode=0)
        col + 3, "Corrected"
       ELSE
        col + 3, error1, row + 1,
        col 60, error2
       ENDIF
      WITH nocounter, format = variable, noformfeed,
       maxrow = 2, maxcol = 130, noheading,
       append
     ;end select
   ENDFOR
  ENDIF
  CALL echo("********************************************************************")
  CALL echo(" Please view the changes in ccluserdir:dm_fix_combine_child_log.dat")
  CALL echo("             Then do 'commit go' to make them permanent!")
  CALL echo("********************************************************************")
 ELSE
  CALL echo(
   "*****************************************************************************************")
  CALL echo(
   " If no errors were scrolling by on the screen, this means the combine records are clean.")
  CALL echo("              No changes have been made, and no log file has been generated.")
  CALL echo(
   "*****************************************************************************************")
 ENDIF
 SUBROUTINE get_valid_pid(old_pid)
   SET new_id = old_pid
   SET new_cmb_id = qual->per_cmb[ichange].combine_id
   SET new_flag = 0
   WHILE (new_flag=0)
    SET new_flag = 1
    SELECT INTO "nl:"
     p.to_person_id
     FROM person_combine p
     WHERE p.from_person_id=new_id
      AND p.encntr_id=0
      AND p.active_ind=1
     DETAIL
      new_id = p.to_person_id, new_cmb_id = p.person_combine_id, new_flag = 0
     WITH nocounter
    ;end select
   ENDWHILE
   SET qual->per_cmb[ichange].new_id = new_id
   SET qual->per_cmb[ichange].combine_id = new_cmb_id
 END ;Subroutine
 SUBROUTINE get_valid_eid(old_eid)
   SET new_id = old_eid
   SET new_cmb_id = qual->enc_cmb[ichange].combine_id
   SET new_flag = 0
   WHILE (new_flag=0)
    SET new_flag = 1
    SELECT INTO "nl:"
     e.to_encntr_id
     FROM encntr_combine e
     WHERE e.from_encntr_id=new_id
      AND e.active_ind=1
     DETAIL
      new_id = e.to_encntr_id, new_cmb_id = e.encntr_combine_id, new_flag = 0
     WITH nocounter
    ;end select
   ENDWHILE
   SET qual->enc_cmb[ichange].new_id = new_id
   SET qual->enc_cmb[ichange].combine_id = new_cmb_id
 END ;Subroutine
#end_script
END GO
