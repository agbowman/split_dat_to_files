CREATE PROGRAM cps_mrg_nomen_dups:dba
 FREE SET hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[*]
     2 dup_knt = i4
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 principle_type_cd = f8
     2 source_string = vc
 )
 SET dvar = 0
 SET loop_knt = 0
 SET true = 1
 SET false = 0
 SET continue = true
 FREE SET err_log
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 SET msg_knt = 0
 SET err_log->msg_qual = msg_knt
 SET err_level = 0
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET err_status = fillstring(7," ")
 SET log_file = "CPS_MRG_NOMEN_DUPS.LOG"
 FREE SET constr
 RECORD constr(
   1 qual_knt = i4
   1 qual[*]
     2 table_name = vc
     2 constraint_name = vc
 )
 SET constr->qual_knt = 0
 SET disable_line = fillstring(42," ")
 SET tdup_knt = 0
 SET tqual_knt = 0
 SET max_nbr = 1000
 SUBROUTINE error_logging(lvar)
  SET err_log->msg_qual = msg_knt
  SELECT INTO value(log_file)
   out_string = substring(1,132,err_log->msg[d.seq].err_msg)
   FROM (dummyt d  WITH seq = value(err_log->msg_qual))
   PLAN (d
    WHERE d.seq > 0)
   DETAIL
    row + 1, col 0, out_string
   WITH nocounter, append, format = variable,
    noformfeed, maxrow = value((msg_knt+ 1)), maxcol = 150
  ;end select
 END ;Subroutine
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_MRG_NOMEN_DUPS BEGIN : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET errcode = error(errmsg,1)
 SET errcode = 0
 SELECT INTO "nl:"
  count(n.primary_nomen_id)
  FROM nomen_dup_hold n
  WITH nocounter, maxqual(n,1)
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 0
  AND substring(1,9,errmsg) != "%CCL-E-18")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   ERROR > Unexpected error ",
   "when looking for Nomen_Dup_Hold table")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = errmsg
  SET err_level = 2
  GO TO exit_script
 ELSEIF (errcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO > Will create the ","Nomen_Dup_Hold table")
  CALL parser("drop table nomen_dup_hold go")
  CALL parser("rdb DROP TABLE nomen_dup_hold CASCADE CONSTRAINTS go")
  SET create_line = concat("rdb CREATE TABLE nomen_dup_hold ",
   "(delete_nomen_id NUMBER NOT NULL,primary_nomen_id NUMBER NOT NULL,",
   "mnemonic VARCHAR2(25) NULL,short_string VARCHAR2(60) NULL,",
   "updt_cnt INTEGER NULL,updt_dt_tm DATE NULL,updt_id NUMBER NULL,",
   "updt_task NUMBER NULL,updt_applctx NUMBER NULL) TABLESPACE d_nomen go")
  CALL parser(create_line)
  SET create_un_ind = concat("rdb CREATE UNIQUE INDEX XPKnomen_dup_hold ON ",
   "nomen_dup_hold (delete_nomen_id,primary_nomen_id) TABLESPACE i_nomen go")
  CALL parser(create_un_ind)
  SET create_ind = concat("rdb CREATE INDEX XIF37nomen_dup_hold ON ",
   "nomen_dup_hold (primary_nomen_id) go")
  CALL parser(create_ind)
  SET alter_table = concat("rdb ALTER TABLE nomen_dup_hold ADD (CONSTRAINT ",
   "XPKnomen_dup_hold PRIMARY KEY (delete_nomen_id, primary_nomen_id) ",
   "USING INDEX TABLESPACE i_nomen) go")
  CALL parser(alter_table)
  SET add_constr = concat("rdb ALTER TABLE nomen_dup_hold ADD (CONSTRAINT ",
   "R_37 FOREIGN KEY (primary_nomen_id) REFERENCES nomenclature) go")
  CALL parser(add_constr)
  CALL parser("oragen3 'NOMEN_DUP_HOLD' go")
  SET errcode = error(errmsg,1)
  SET errcode = 0
  SELECT INTO "nl:"
   count(n.primary_nomen_id)
   FROM nomen_dup_hold n
   WITH nocounter, maxqual(n,1)
  ;end select
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,9,errmsg) != "%CCL-E-18")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   ERROR > Failed to create",
    "the Nomen_Dup_Hold table")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   INFO > Include ",
    "CER_INSTALL:CPS_MAK_NOMEN_DUP_HOLD.CCL and run this process again")
   SET err_level = 2
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  uc.constraint_name
  FROM user_constraints uc
  PLAN (uc
   WHERE uc.r_constraint_name="XPKNOMENCLATURE"
    AND uc.status="ENABLED")
  HEAD REPORT
   knt = 0, stat = alterlist(constr->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(constr->qual,(knt+ 9))
   ENDIF
   constr->qual[knt].table_name = uc.table_name, constr->qual[knt].constraint_name = uc
   .constraint_name
  FOOT REPORT
   constr->qual_knt = knt, stat = alterlist(constr->qual,knt)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   ERROR > Getting constraints ","to disable")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = errmsg
  SET err_level = 2
  GO TO exit_script
 ENDIF
 IF ((constr->qual_knt > 0))
  FOR (i = 1 TO constr->qual_knt)
    CALL parser(trim(concat("rdb ALTER TABLE ",trim(constr->qual[i].table_name),
       " DISABLE CONSTRAINT ",trim(constr->qual[i].constraint_name)," GO")))
    SET errcode = error(errmsg,1)
    IF (errcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("   ERROR > Failed to ","disable constraint ",trim(
       constr->qual[i].constraint_name)," on table ",trim(constr->qual[i].table_name))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = errmsg
     SET err_level = 2
     GO TO exit_script
    ELSE
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("   INFO > Constraint ",trim(constr->qual[i].
       constraint_name)," on table ",trim(constr->qual[i].table_name)," disabled")
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  dup_knt = count(*), n.source_vocabulary_cd, n.source_identifier,
  n.source_string, n.principle_type_cd
  FROM nomenclature n
  PLAN (n
   WHERE 0=0)
  GROUP BY n.source_vocabulary_cd, n.source_identifier, n.source_string,
   n.principle_type_cd
  HAVING count(*) > 1
  DETAIL
   tdup_knt = (tdup_knt+ dup_knt), tqual_knt = (tqual_knt+ 1)
  WITH nocounter
 ;end select
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO > Total number of ","duplicates to be deleted ",
  trim(cnvtstring((tdup_knt - tqual_knt))))
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO > Begin deleting ","duplicates ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 WHILE (continue=true)
   SET errcode = error(errmsg,1)
   SET errcode = 0
   SET hold->qual_knt = 0
   SELECT INTO "nl:"
    dup_knt = count(*), n.source_vocabulary_cd, n.source_identifier,
    n.source_string, n.principle_type_cd
    FROM nomenclature n
    PLAN (n
     WHERE 0=0)
    GROUP BY n.source_vocabulary_cd, n.source_identifier, n.source_string,
     n.principle_type_cd
    HAVING count(*) > 1
    HEAD REPORT
     knt = 0, stat = alterlist(hold->qual,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(hold->qual,(knt+ 9))
     ENDIF
     hold->qual[knt].source_vocabulary_cd = n.source_vocabulary_cd, hold->qual[knt].source_identifier
      = n.source_identifier, hold->qual[knt].principle_type_cd = n.principle_type_cd,
     hold->qual[knt].source_string = n.source_string, hold->qual[knt].dup_knt = dup_knt
    FOOT REPORT
     hold->qual_knt = knt, stat = alterlist(hold->qual,knt)
    WITH nocounter, maxrec = value(max_nbr)
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR > Getting unique ","items to delete")
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET err_level = 2
    GO TO exit_script
   ENDIF
   IF ((hold->qual_knt < max_nbr))
    SET continue = false
   ELSE
    SET continue = true
   ENDIF
   IF ((hold->qual_knt < 1))
    GO TO exit_while
   ENDIF
   FREE SET tdup_list
   RECORD tdup_list(
     1 qual_knt = i4
     1 qual[*]
       2 nomen_id = f8
       2 mnemonic = vc
       2 short_string = vc
       2 active_ind = i2
   )
   FREE SET dup_list
   RECORD dup_list(
     1 qual_knt = i4
     1 qual[*]
       2 primary_id = f8
       2 delete_id = f8
       2 mnemonic = vc
       2 short_string = vc
       2 active_ind = i2
       2 end_eff_dt_tm = dq8
   )
   SET tdup_list->qual_knt = 0
   SET dup_list->qual_knt = 0
   SET knt = 0
   SET stat = alterlist(dup_list->qual,10)
   FOR (i = 1 TO hold->qual_knt)
     SELECT INTO "nl:"
      n.nomenclature_id, n.beg_effective_dt_tm
      FROM nomenclature n
      PLAN (n
       WHERE (n.source_vocabulary_cd=hold->qual[i].source_vocabulary_cd)
        AND (n.source_identifier=hold->qual[i].source_identifier)
        AND (n.source_string=hold->qual[i].source_string)
        AND (n.principle_type_cd=hold->qual[i].principle_type_cd))
      ORDER BY cnvtdatetime(n.beg_effective_dt_tm) DESC
      HEAD REPORT
       tknt = 0, stat = alterlist(tdup_list->qual,10), tactive_ind = 0,
       tend_eff_dt_tm = cnvtdatetime("01-jan-1801 00:00:00")
      DETAIL
       tknt = (tknt+ 1)
       IF (mod(tknt,10)=1
        AND tknt != 1)
        stat = alterlist(tdup_list->qual,(tknt+ 9))
       ENDIF
       tdup_list->qual[tknt].nomen_id = n.nomenclature_id, tdup_list->qual[tknt].mnemonic = n
       .mnemonic, tdup_list->qual[tknt].short_string = n.short_string
       IF (tactive_ind=0
        AND n.active_ind=1)
        tactive_ind = 1
       ENDIF
       IF (datetimediff(tend_eff_dt_tm,n.end_effective_dt_tm) < 0)
        tend_eff_dt_tm = cnvtdatetime(n.end_effective_dt_tm)
       ENDIF
      FOOT REPORT
       IF (tknt > 1)
        FOR (j = 2 TO tknt)
          knt = (knt+ 1)
          IF (mod(knt,10)=1
           AND knt != 1)
           stat = alterlist(dup_list->qual,(knt+ 9))
          ENDIF
          dup_list->qual[knt].primary_id = tdup_list->qual[1].nomen_id, dup_list->qual[knt].
          active_ind = tactive_ind, dup_list->qual[knt].end_eff_dt_tm = cnvtdatetime(tend_eff_dt_tm),
          dup_list->qual[knt].delete_id = tdup_list->qual[j].nomen_id, dup_list->qual[knt].mnemonic
           = tdup_list->qual[j].mnemonic, dup_list->qual[knt].short_string = tdup_list->qual[j].
          short_string
        ENDFOR
       ENDIF
      WITH nocounter
     ;end select
     SET errcode = error(errmsg,1)
     IF (errcode > 0)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat("   ERROR > Mapping ","delete ids to primary ids")
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = errmsg
      SET err_level = 2
      GO TO exit_script
     ENDIF
   ENDFOR
   SET dup_list->qual_knt = knt
   SET stat = alterlist(dup_list->qual,knt)
   INSERT  FROM nomen_dup_hold n,
     (dummyt d  WITH seq = value(dup_list->qual_knt))
    SET d.seq = d.seq, n.primary_nomen_id = dup_list->qual[d.seq].primary_id, n.delete_nomen_id =
     dup_list->qual[d.seq].delete_id,
     n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.mnemonic = trim(substring(1,25,dup_list->qual[d
       .seq].mnemonic)), n.short_string = trim(substring(1,60,dup_list->qual[d.seq].short_string))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (n
     WHERE d.seq > 0)
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR > Inserting ",
     "mapping into the Nomen_Dup_Hold table")
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET err_level = 2
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    ndh1.primary_nomen_id
    FROM nomen_dup_hold ndh1,
     nomen_dup_hold ndh2
    PLAN (ndh1
     WHERE 0=0)
     JOIN (ndh2
     WHERE ndh2.delete_nomen_id=ndh1.primary_nomen_id)
    WITH nocounter, maxqual(ndh2,1)
   ;end select
   IF (curqual > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR > A ",
     "primary_nomen_id  is in the delete_nomen_id column")
    ROLLBACK
    SET err_level = 2
    GO TO exit_script
   ENDIF
   DELETE  FROM normalized_string_index n,
     (dummyt d  WITH seq = value(dup_list->qual_knt))
    SET d.seq = d.seq
    PLAN (d
     WHERE d.seq > 0)
     JOIN (n
     WHERE (n.nomenclature_id=dup_list->qual[d.seq].delete_id))
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR > Deleting ",
     "duplicates from the Normalized_String_Index table")
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET err_level = 2
    ROLLBACK
    GO TO exit_script
   ENDIF
   DELETE  FROM nomenclature n,
     (dummyt d  WITH seq = value(dup_list->qual_knt))
    SET d.seq = d.seq
    PLAN (d
     WHERE d.seq > 0)
     JOIN (n
     WHERE (n.nomenclature_id=dup_list->qual[d.seq].delete_id))
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR > Deleting ",
     "duplicates from the Nomenclature table")
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET err_level = 2
    ROLLBACK
    GO TO exit_script
   ENDIF
   COMMIT
   UPDATE  FROM nomenclature n,
     (dummyt d  WITH seq = value(dup_list->qual_knt))
    SET n.active_ind = dup_list->qual[d.seq].active_ind, n.end_effective_dt_tm = cnvtdatetime(
      dup_list->qual[d.seq].end_eff_dt_tm), n.updt_cnt = (n.updt_cnt+ 1)
    PLAN (d
     WHERE d.seq > 0)
     JOIN (n
     WHERE (n.nomenclature_id=dup_list->qual[d.seq].primary_id)
      AND (((n.active_ind != dup_list->qual[d.seq].active_ind)) OR (n.end_effective_dt_tm !=
     cnvtdatetime(dup_list->qual[d.seq].end_eff_dt_tm))) )
    WITH nocounter
   ;end update
   COMMIT
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   WARNING > Primary ",
     "nomenclature_id was not updated with the correct actvie_ind and or ","end_effective_dt_tm")
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET err_level = 1
   ENDIF
 ENDWHILE
#exit_while
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO > End deleting ","duplicates ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET errcode = error(errmsg,1)
 SET errcode = 0
 FREE SET hold
 FREE SET constr
 FREE SET tdup_list
 FREE SET dup_list
 SELECT INTO "nl:"
  ndh.delete_nomen_id
  FROM nomen_dup_hold ndh
  PLAN (ndh
   WHERE ndh.delete_nomen_id > 0)
  WITH nocounter, maxqual(ndh,1)
 ;end select
 IF (curqual < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO > No duplicate ",
   "nomenclature items where found")
  GO TO exit_script
 ENDIF
 FREE SET table_list
 RECORD table_list(
   1 tqual_knt = i4
   1 tqual[*]
     2 name = vc
     2 field_knt = i4
     2 field[*]
       3 name = vc
 )
 SET upt_line1 = fillstring(132," ")
 SET upt_line2 = fillstring(132," ")
 SET upt_line3 = fillstring(132," ")
 SET upt_line4 = fillstring(132," ")
 SET upt_line5 = fillstring(132," ")
 SET upt_line6 = fillstring(132," ")
 SET upt_line7 = fillstring(132," ")
 SET upt_line8 = fillstring(132," ")
 SET target_table = fillstring(40," ")
 SET target_field = fillstring(40," ")
 SET true = 1
 SET false = 0
 SET process_table = true
 SELECT INTO "nl:"
  dcd.table_name, dcd.column_name
  FROM dm_columns_doc dcd
  PLAN (dcd
   WHERE dcd.root_entity_name="NOMENCLATURE"
    AND dcd.root_entity_attr="NOMENCLATURE_ID"
    AND dcd.table_name != "NORMALIZED_STRING_INDEX"
    AND dcd.table_name != "NOMENCLATURE"
    AND dcd.table_name != "ALPHA_RESPONSES"
    AND dcd.table_name != "NOMEN_DUP_HOLD")
  ORDER BY dcd.table_name, dcd.column_name
  HEAD REPORT
   tknt = 0, stat = alterlist(table_list->tqual,10)
  HEAD dcd.table_name
   tknt = (tknt+ 1)
   IF (mod(tknt,10)=1
    AND tknt != 1)
    stat = alterlist(table_list->tqual,(tknt+ 9))
   ENDIF
   table_list->tqual[tknt].name = dcd.table_name, cknt = 0, stat = alterlist(table_list->tqual[tknt].
    field,10)
  DETAIL
   cknt = (cknt+ 1)
   IF (mod(cknt,10)=1
    AND cknt != 1)
    stat = alterlist(table_list->tqual[tknt].field,(cknt+ 9))
   ENDIF
   table_list->tqual[tknt].field[cknt].name = dcd.column_name
  FOOT  dcd.table_name
   table_list->tqual[tknt].field_knt = cknt, stat = alterlist(table_list->tqual[tknt].field,cknt)
  FOOT REPORT
   table_list->tqual_knt = tknt, stat = alterlist(table_list->tqual,tknt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed to find ","any tables")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 2
   GO TO exit_script
  ELSE
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> Failed to find ","any tables")
   SET err_level = 1
  ENDIF
 ENDIF
 IF ((table_list->tqual_knt > 0))
  FOR (i = 1 TO table_list->tqual_knt)
    SET target_table = trim(table_list->tqual[i].name)
    SET process_table = true
    FOR (j = 1 TO table_list->tqual[i].field_knt)
      SET target_field = trim(table_list->tqual[i].field[j].name)
      SET tupt_knt = 0
      SET upt_line1 = concat("update into ",trim(target_table)," t ")
      SET upt_line2 = concat("set t.",trim(target_field)," = ")
      SET upt_line3 = "(select n.primary_nomen_id from nomen_dup_hold n "
      SET upt_line4 = concat("where t.",trim(target_field))
      SET upt_line5 = " = n.delete_nomen_id) where "
      SET upt_line6 = concat("t.",trim(target_field)," in ")
      SET upt_line7 = "(select delete_nomen_id from nomen_dup_hold) "
      SET upt_line8 = " with nocounter go"
      IF (process_table=true)
       SET msg_knt = (msg_knt+ 1)
       SET stat = alterlist(err_log->msg,msg_knt)
       SET err_log->msg[msg_knt].err_msg = concat("   INFO> Updating ","field: ",trim(target_field),
        " on table ",trim(target_table),
        " BEGIN : ",format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
       CALL echo(concat("Updating field: ",trim(target_field)," on table ",trim(target_table),
         " BEGIN : ",
         format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d")))
       CALL parser(concat("rdb create index TEMP_INDEX on ",trim(target_table)," (",trim(target_field
          ),") tablespace i_nomen go"))
       SET errcode = error(errmsg,1)
       IF (errcode > 0)
        SET drop_index_ind = 0
       ELSE
        SET drop_index_ind = 1
        ROLLBACK
       ENDIF
       CALL parser(upt_line1)
       CALL parser(upt_line2)
       CALL parser(upt_line3)
       CALL parser(upt_line4)
       CALL parser(upt_line5)
       CALL parser(upt_line6)
       CALL parser(upt_line7)
       CALL parser(upt_line8)
       IF (curqual < 1)
        SET msg_knt = (msg_knt+ 1)
        SET stat = alterlist(err_log->msg,msg_knt)
        SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",
         trim(target_field),"  Rows ",
         "Updated: ",trim(cnvtstring(curqual)))
        SET errcode = error(errmsg,1)
        IF (errcode > 0
         AND substring(1,9,errmsg)="%CCL-E-18")
         SET msg_knt = (msg_knt+ 1)
         SET stat = alterlist(err_log->msg,msg_knt)
         SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Table ",trim(target_table),
          " doesn't exist")
         SET msg_knt = (msg_knt+ 1)
         SET stat = alterlist(err_log->msg,msg_knt)
         SET err_log->msg[msg_knt].err_msg = errmsg
         SET err_level = 1
         SET process_table = false
        ELSEIF (errcode > 0
         AND substring(1,9,errmsg)="%CCL-E-26")
         SET msg_knt = (msg_knt+ 1)
         SET stat = alterlist(err_log->msg,msg_knt)
         SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Column ",trim(target_field),
          " doesn't exist on table ",trim(target_table))
         SET msg_knt = (msg_knt+ 1)
         SET stat = alterlist(err_log->msg,msg_knt)
         SET err_log->msg[msg_knt].err_msg = errmsg
         SET err_level = 1
        ELSEIF (errcode > 0)
         SET msg_knt = (msg_knt+ 1)
         SET stat = alterlist(err_log->msg,msg_knt)
         SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ",
          "Unexpected error occurred while updating column ",trim(target_field)," in table ",trim(
           target_table))
         SET msg_knt = (msg_knt+ 1)
         SET stat = alterlist(err_log->msg,msg_knt)
         SET err_log->msg[msg_knt].err_msg = errmsg
         SET err_level = 1
         SET process_table = false
        ENDIF
       ELSE
        SET msg_knt = (msg_knt+ 1)
        SET stat = alterlist(err_log->msg,msg_knt)
        SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",
         trim(target_field),"  Rows ",
         "Updated: ",trim(cnvtstring(curqual)))
       ENDIF
       IF (drop_index_ind > 0)
        CALL parser("rdb drop index TEMP_INDEX go")
       ENDIF
       SET errcode = error(errmsg,1)
       COMMIT
      ENDIF
      SET errcode = error(errmsg,1)
    ENDFOR
  ENDFOR
 ENDIF
#entity_table_sec
 SET errcode = error(errmsg,1)
 SET errcode = 0
 SET target_table = "DCP_ENTITY_RELTN"
 SET target_field = "ENTITY2_ID"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
  " field = ",trim(target_field),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL parser(concat("rdb create index TEMP_INDEX on ",trim(target_table)," (",trim(target_field),
   ") tablespace i_nomen go"))
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET drop_index_ind = 0
 ELSE
  SET drop_index_ind = 1
 ENDIF
 UPDATE  FROM dcp_entity_reltn t
  SET t.entity2_id =
   (SELECT
    n.primary_nomen_id
    FROM nomen_dup_hold n
    WHERE t.entity2_id=n.delete_nomen_id)
  WHERE t.entity_reltn_mean="ORC/ICD9"
   AND t.entity2_id IN (
  (SELECT
   delete_nomen_id
   FROM nomen_dup_hold))
  WITH nocounter
 ;end update
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-18")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Table ",trim(target_table),
    " doesn't exist")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-26")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Column ",trim(target_field),
    " doesn't exist on table ",trim(target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ",
    "Unexpected error occurred while updating column ",trim(target_field)," in table ",trim(
     target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ENDIF
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ENDIF
 IF (drop_index_ind > 0)
  CALL parser("rdb drop index TEMP_INDEX go")
 ENDIF
 SET errcode = error(errmsg,1)
 COMMIT
 SET target_table = "SCD_TERM_DATA"
 SET target_field = "FKEY_ID"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
  " field = ",trim(target_field),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL parser(concat("rdb create index TEMP_INDEX on ",trim(target_table)," (",trim(target_field),
   ") tablespace i_nomen go"))
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET drop_index_ind = 0
 ELSE
  SET drop_index_ind = 1
 ENDIF
 UPDATE  FROM scd_term_data t
  SET t.fkey_id =
   (SELECT
    n.primary_nomen_id
    FROM nomen_dup_hold n
    WHERE t.fkey_id=n.delete_nomen_id)
  WHERE t.fkey_entity_name="NOMENCLATURE"
   AND t.fkey_id IN (
  (SELECT
   delete_nomen_id
   FROM nomen_dup_hold))
  WITH nocounter
 ;end update
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-18")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Table ",trim(target_table),
    " doesn't exist")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-26")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Column ",trim(target_field),
    " doesn't exist on table ",trim(target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ",
    "Unexpected error occurred while updating column ",trim(target_field)," in table ",trim(
     target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ENDIF
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ENDIF
 IF (drop_index_ind > 0)
  CALL parser("rdb drop index TEMP_INDEX go")
 ENDIF
 SET errcode = error(errmsg,1)
 COMMIT
 SET target_table = "SCD_TERM_DEFINITION"
 SET target_field = "FKEY_ID"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
  " field = ",trim(target_field),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL parser(concat("rdb create index TEMP_INDEX on ",trim(target_table)," (",trim(target_field),
   ") tablespace i_nomen go"))
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET drop_index_ind = 0
 ELSE
  SET drop_index_ind = 1
 ENDIF
 UPDATE  FROM scd_term_definition t
  SET t.fkey_id =
   (SELECT
    n.primary_nomen_id
    FROM nomen_dup_hold n
    WHERE t.fkey_id=n.delete_nomen_id)
  WHERE t.fkey_entity_name="NOMENCLATURE"
   AND t.fkey_id IN (
  (SELECT
   delete_nomen_id
   FROM nomen_dup_hold))
  WITH nocounter
 ;end update
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-18")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Table ",trim(target_table),
    " doesn't exist")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-26")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Column ",trim(target_field),
    " doesn't exist on table ",trim(target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ",
    "Unexpected error occurred while updating column ",trim(target_field)," in table ",trim(
     target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ENDIF
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ENDIF
 IF (drop_index_ind > 0)
  CALL parser("rdb drop index TEMP_INDEX go")
 ENDIF
 SET errcode = error(errmsg,1)
 COMMIT
 SET target_table = "OMF_PVF_FILTER"
 SET target_field = "NUM_ID"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
  " field = ",trim(target_field),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL parser(concat("rdb create index TEMP_INDEX on ",trim(target_table)," (",trim(target_field),
   ") tablespace i_nomen go"))
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET drop_index_ind = 0
 ELSE
  SET drop_index_ind = 1
 ENDIF
 UPDATE  FROM omf_pvf_filter t
  SET t.num_id =
   (SELECT
    n.primary_nomen_id
    FROM nomen_dup_hold n
    WHERE t.num_id=n.delete_nomen_id)
  WHERE t.parent_entity_name="NOMENCLATURE"
   AND t.num_id IN (
  (SELECT
   delete_nomen_id
   FROM nomen_dup_hold))
  WITH nocounter
 ;end update
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-18")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Table ",trim(target_table),
    " doesn't exist")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-26")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Column ",trim(target_field),
    " doesn't exist on table ",trim(target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ",
    "Unexpected error occurred while updating column ",trim(target_field)," in table ",trim(
     target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ENDIF
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ENDIF
 IF (drop_index_ind > 0)
  CALL parser("rdb drop index TEMP_INDEX go")
 ENDIF
 SET errcode = error(errmsg,1)
 COMMIT
 SET target_table = "OMF_PV_SECURITY_FILTER"
 SET target_field = "NUM_ID"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
  " field = ",trim(target_field),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL parser(concat("rdb create index TEMP_INDEX on ",trim(target_table)," (",trim(target_field),
   ") tablespace i_nomen go"))
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET drop_index_ind = 0
 ELSE
  SET drop_index_ind = 1
 ENDIF
 UPDATE  FROM omf_pv_security_filter t
  SET t.num_id =
   (SELECT
    n.primary_nomen_id
    FROM nomen_dup_hold n
    WHERE t.num_id=n.delete_nomen_id)
  WHERE t.parent_entity_name="NOMENCLATURE"
   AND t.num_id IN (
  (SELECT
   delete_nomen_id
   FROM nomen_dup_hold))
  WITH nocounter
 ;end update
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-18")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Table ",trim(target_table),
    " doesn't exist")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-26")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Column ",trim(target_field),
    " doesn't exist on table ",trim(target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ",
    "Unexpected error occurred while updating column ",trim(target_field)," in table ",trim(
     target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ENDIF
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ENDIF
 IF (drop_index_ind > 0)
  CALL parser("rdb drop index TEMP_INDEX go")
 ENDIF
 SET errcode = error(errmsg,1)
 COMMIT
 SET target_table = "ORDER_DETAIL"
 SET target_field = "OE_FIELD_VALUE"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
  " field = ",trim(target_field),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL parser(concat("rdb create index TEMP_INDEX on ",trim(target_table)," (",trim(target_field),
   ") tablespace i_nomen go"))
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET drop_index_ind = 0
 ELSE
  SET drop_index_ind = 1
 ENDIF
 UPDATE  FROM order_detail t
  SET t.oe_field_value =
   (SELECT
    n.primary_nomen_id
    FROM nomen_dup_hold n
    WHERE t.oe_field_value=n.delete_nomen_id)
  WHERE t.oe_field_meaning_id=20
   AND t.oe_field_value IN (
  (SELECT
   delete_nomen_id
   FROM nomen_dup_hold))
  WITH nocounter
 ;end update
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-18")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Table ",trim(target_table),
    " doesn't exist")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-26")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Column ",trim(target_field),
    " doesn't exist on table ",trim(target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ",
    "Unexpected error occurred while updating column ",trim(target_field)," in table ",trim(
     target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ENDIF
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ENDIF
 IF (drop_index_ind > 0)
  CALL parser("rdb drop index TEMP_INDEX go")
 ENDIF
 SET errcode = error(errmsg,1)
 COMMIT
 SET target_table = "BILL_ITEM_MODIFIER"
 SET target_field = "KEY3_ID"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
  " field = ",trim(target_field),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL parser(concat("rdb create index TEMP_INDEX on ",trim(target_table)," (",trim(target_field),
   ") tablespace i_nomen go"))
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET drop_index_ind = 0
 ELSE
  SET drop_index_ind = 1
 ENDIF
 UPDATE  FROM bill_item_modifier t
  SET t.key3_id =
   (SELECT
    n.primary_nomen_id
    FROM nomen_dup_hold n
    WHERE t.key3_id=n.delete_nomen_id)
  WHERE t.key3_entity_name="NOMENCLATURE"
   AND t.key3_id IN (
  (SELECT
   delete_nomen_id
   FROM nomen_dup_hold))
  WITH nocounter
 ;end update
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-18")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Table ",trim(target_table),
    " doesn't exist")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-26")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Column ",trim(target_field),
    " doesn't exist on table ",trim(target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ",
    "Unexpected error occurred while updating column ",trim(target_field)," in table ",trim(
     target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ENDIF
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ENDIF
 IF (drop_index_ind > 0)
  CALL parser("rdb drop index TEMP_INDEX go")
 ENDIF
 SET errcode = error(errmsg,1)
 COMMIT
 SET target_table = "NOMENCLATURE"
 SET target_field = "NOM_VER_GRP_ID"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
  " field = ",trim(target_field),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 UPDATE  FROM nomenclature t
  SET t.nom_ver_grp_id =
   (SELECT
    n.primary_nomen_id
    FROM nomen_dup_hold n
    WHERE t.nom_ver_grp_id=n.delete_nomen_id)
  WHERE t.nom_ver_grp_id IN (
  (SELECT
   delete_nomen_id
   FROM nomen_dup_hold))
  WITH nocounter
 ;end update
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-18")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Table ",trim(target_table),
    " doesn't exist")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-26")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Column ",trim(target_field),
    " doesn't exist on table ",trim(target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ",
    "Unexpected error occurred while updating column ",trim(target_field)," in table ",trim(
     target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ENDIF
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
 ENDIF
 SET errcode = error(errmsg,1)
 COMMIT
 SET target_table = "ALPHA_RESPONSES"
 SET target_field = "NOMENCLATURE_ID"
 FREE SET hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[*]
     2 ref_id = f8
     2 delete_id = f8
     2 primary_id = f8
     2 status = i2
 )
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
  " field = ",trim(target_field),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SELECT INTO "nl:"
  ar.nomenclature_id
  FROM nomen_dup_hold ndh,
   alpha_responses ar
  PLAN (ndh
   WHERE ndh.delete_nomen_id > 0)
   JOIN (ar
   WHERE ar.nomenclature_id=ndh.delete_nomen_id)
  HEAD REPORT
   knt = 0, stat = alterlist(hold->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(hold->qual,(knt+ 9))
   ENDIF
   hold->qual[knt].ref_id = ar.reference_range_factor_id, hold->qual[knt].delete_id = ndh
   .delete_nomen_id, hold->qual[knt].primary_id = ndh.primary_nomen_id,
   hold->qual[knt].status = 0
  FOOT REPORT
   hold->qual_knt = knt, stat = alterlist(hold->qual,knt)
  WITH nocounter
 ;end select
 IF ((hold->qual_knt < 1))
  SET errcode = error(errmsg,1)
  IF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-18")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Table ",trim(target_table),
    " doesn't exist")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0
   AND substring(1,9,errmsg)="%CCL-E-26")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ","Column ",trim(target_field),
    " doesn't exist on table ",trim(target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ELSEIF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ",
    "Unexpected error occurred while updating column ",trim(target_field)," in table ",trim(
     target_table))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ENDIF
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
  GO TO exit_script
 ENDIF
 DELETE  FROM alpha_responses ar,
   (dummyt d  WITH seq = value(hold->qual_knt))
  SET d.seq = d.seq
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ar
   WHERE (ar.reference_range_factor_id=hold->qual[d.seq].ref_id)
    AND (ar.nomenclature_id=hold->qual[d.seq].primary_id))
 ;end delete
 IF (curqual > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows deleted: ",
   trim(cnvtstring(curqual)))
 ENDIF
 UPDATE  FROM alpha_responses ar,
   (dummyt d  WITH seq = value(hold->qual_knt))
  SET d.seq = d.seq, ar.nomenclature_id = hold->qual[d.seq].primary_id
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ar
   WHERE (ar.reference_range_factor_id=hold->qual[d.seq].ref_id)
    AND (ar.nomenclature_id=hold->qual[d.seq].delete_id))
 ;end update
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
   target_field),"  Rows Updated: ",
  trim(cnvtstring(curqual)))
#exit_script
 IF (err_level <= 1)
  CALL parser("rdb drop index XAK6NOMENCLATURE go")
  SET errcode = error(errmsg,1)
  CALL parser("rdb create unique index XAK6NOMENCLATURE")
  CALL parser("on nomenclature (source_vocabulary_cd, source_identifier,")
  CALL parser("source_string, principle_type_cd) tablespace i_nomen go")
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> ",
    "Unexpected error occurred while creating unique index ","XAK6NOMENCLATURE")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ENDIF
 ENDIF
 IF (err_level=0)
  SET err_status = "SUCCESS"
 ELSEIF (err_level=1)
  SET err_status = "WARNING"
 ELSE
  SET err_status = "FAILURE"
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_MRG_NOMEN_DUPS   END : ",trim(err_status),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL error_logging(dvar)
END GO
