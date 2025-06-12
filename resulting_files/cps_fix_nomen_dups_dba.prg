CREATE PROGRAM cps_fix_nomen_dups:dba
 SET true = 1
 SET false = 0
 SET dvar = 0
 SET continue = true
 FREE SET tdup_list
 RECORD tdup_list(
   1 qual_knt = i4
   1 qual[*]
     2 nomenclature_id = f8
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 source_string = vc
     2 principle_type_cd = f8
     2 mnemonic = vc
     2 short_string = vc
     2 beg_eff_dt_tm = dq8
 )
 FREE SET dup_list
 RECORD dup_list(
   1 qual_knt = i4
   1 qual[*]
     2 primary_id = f8
     2 delete_id = f8
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 source_string = vc
     2 principle_type_cd = f8
     2 mnemonic = vc
     2 short_string = vc
     2 beg_eff_dt_tm = dq8
 )
 FREE SET table_list
 RECORD table_list(
   1 tqual_knt = i4
   1 tqual[*]
     2 name = vc
     2 field_knt = i4
     2 field[*]
       3 name = vc
 )
 SET target_table = fillstring(40," ")
 SET target_field = fillstring(40," ")
 SET upt_line1 = fillstring(132," ")
 SET upt_line2 = fillstring(132," ")
 SET upt_line3 = fillstring(132," ")
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
 SET log_file = "CPS_FIX_NOMEN_DUPS.LOG"
 SET max_cknt = 0
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_NOMEN_DUPS begin : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin get duplicates ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SELECT INTO "nl:"
  n.source_vocabulary_cd, n.source_identifier, n.source_string,
  n.principle_type_cd, n.beg_effective_dt_tm
  FROM nomenclature n
  PLAN (n
   WHERE n.nomenclature_id >= 0
    AND n.source_string > " ")
  ORDER BY n.source_vocabulary_cd, n.source_identifier, n.source_string,
   n.principle_type_cd, cnvtdatetime(n.beg_effective_dt_tm) DESC
  HEAD REPORT
   knt = 0, stat = alterlist(dup_list->qual,10)
  HEAD n.source_vocabulary_cd
   dvar = 0
  HEAD n.source_identifier
   dvar = 0
  HEAD n.principle_type_cd
   dvar = 0
  HEAD n.source_string
   tknt = 0, stat = alterlist(tdup_list->qual,10), tnomenclature_id = n.nomenclature_id,
   tsource_vocabulary_cd = n.source_vocabulary_cd, tsource_string = n.source_string,
   tprinciple_type_cd = n.principle_type_cd
  DETAIL
   tknt = (tknt+ 1)
   IF (mod(tknt,10)=1
    AND tknt != 1)
    stat = alterlist(tdup_list->qual,(tknt+ 9))
   ENDIF
   tdup_list->qual[tknt].nomenclature_id = n.nomenclature_id, tdup_list->qual[tknt].
   source_vocabulary_cd = n.source_vocabulary_cd, tdup_list->qual[tknt].source_identifier = n
   .source_identifier,
   tdup_list->qual[tknt].source_string = n.source_string, tdup_list->qual[tknt].principle_type_cd = n
   .principle_type_cd, tdup_list->qual[tknt].mnemonic = n.mnemonic,
   tdup_list->qual[tknt].short_string = n.short_string, tdup_list->qual[tknt].beg_eff_dt_tm = n
   .beg_effective_dt_tm
  FOOT  n.source_string
   tdup_list->qual_knt = tknt, stat = alterlist(tdup_list->qual,tknt)
   IF (tknt > 1)
    FOR (i = 2 TO tknt)
      knt = (knt+ 1)
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(dup_list->qual,(knt+ 9))
      ENDIF
      dup_list->qual[knt].primary_id = tdup_list->qual[1].nomenclature_id, dup_list->qual[knt].
      delete_id = tdup_list->qual[i].nomenclature_id, dup_list->qual[knt].source_vocabulary_cd =
      tdup_list->qual[i].source_vocabulary_cd,
      dup_list->qual[knt].source_identifier = tdup_list->qual[i].source_identifier, dup_list->qual[
      knt].source_string = tdup_list->qual[i].source_string, dup_list->qual[knt].principle_type_cd =
      tdup_list->qual[i].principle_type_cd,
      dup_list->qual[knt].mnemonic = tdup_list->qual[i].mnemonic, dup_list->qual[knt].short_string =
      tdup_list->qual[i].short_string, dup_list->qual[knt].beg_eff_dt_tm = tdup_list->qual[i].
      beg_eff_dt_tm
    ENDFOR
   ENDIF
  FOOT REPORT
   dup_list->qual_knt = knt, stat = alterlist(dup_list->qual,knt)
  WITH nocounter
 ;end select
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO> Number of duplicates found = ",trim(cnvtstring(
    dup_list->qual_knt)))
 IF ((dup_list->qual_knt < 1))
  SET errcode = error(errmsg,1)
  IF (errcode > 1
   AND substring(1,10,errmsg) != "%CCL-W-274")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed to find any duplicates")
   SET err_level = 2
   GO TO exit_script
  ELSE
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> Did not find any duplicates")
   SET err_level = 1
  ENDIF
 ENDIF
 SET errcode = error(errmsg,1)
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin get blank source_strings ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n
  PLAN (n
   WHERE n.nomenclature_id > 0.0
    AND n.source_string <= " ")
  HEAD REPORT
   knt = dup_list->qual_knt, stat = alterlist(dup_list->qual,(knt+ 10))
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(dup_list->qual,(knt+ 9))
   ENDIF
   dup_list->qual[knt].primary_id = 0.0, dup_list->qual[knt].delete_id = n.nomenclature_id, dup_list
   ->qual[knt].source_vocabulary_cd = n.source_vocabulary_cd,
   dup_list->qual[knt].source_identifier = n.source_identifier, dup_list->qual[knt].source_string = n
   .source_string, dup_list->qual[knt].principle_type_cd = n.principle_type_cd,
   dup_list->qual[knt].mnemonic = n.mnemonic, dup_list->qual[knt].short_string = n.short_string,
   dup_list->qual[knt].beg_eff_dt_tm = n.beg_effective_dt_tm
  FOOT REPORT
   dup_list->qual_knt = knt, stat = alterlist(dup_list->qual,knt)
  WITH nocounter
 ;end select
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO> Number of duplicates found = ",trim(cnvtstring(
    dup_list->qual_knt)))
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed in finding blank source_string")
   SET err_level = 2
   GO TO exit_script
  ELSE
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> Did not find any blank source_string")
   SET err_level = 1
  ENDIF
  IF ((dup_list->qual_knt < 1))
   GO TO exit_script
  ENDIF
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin make nomen_dups table ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SELECT INTO TABLE "nomen_dups"
  primary_id = dup_list->qual[d.seq].primary_id, delete_id = dup_list->qual[d.seq].delete_id,
  updt_dt_tm = format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"),
  mnemonic = dup_list->qual[d.seq].mnemonic, short_string = dup_list->qual[d.seq].short_string
  FROM (dummyt d  WITH seq = value(dup_list->qual_knt))
  PLAN (d
   WHERE d.seq > 0)
  ORDER BY primary_id, delete_id
  WITH nocounter, maxcol = 132, organization = i
 ;end select
 IF ((curqual != dup_list->qual_knt))
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
  ENDIF
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed to make ",
   "the make the Nomen_Dups tables")
  SET err_level = 2
  GO TO exit_script
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin delete Normalized_String_Index table ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 DELETE  FROM normalized_string_index nsi,
   nomen_dups nd
  SET nsi.seq = 1
  PLAN (nd)
   JOIN (nsi
   WHERE nsi.nomenclature_id=nd.delete_id)
  WITH nocounter
 ;end delete
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: Normalized_String_Index  Field: ",
  "nomenclature_id Rows deleted: ",trim(cnvtstring(curqual)))
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed to delete any rows on table")
   SET err_level = 2
   GO TO exit_script
  ENDIF
 ELSE
  SET dvar = 0
  COMMIT
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin get table list ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SELECT INTO "nl:"
  dcd.table_name, dcd.column_name
  FROM dm_columns_doc dcd,
   user_tables ut,
   user_col_comments ucc
  PLAN (dcd
   WHERE dcd.root_entity_name="NOMENCLATURE"
    AND dcd.root_entity_attr="NOMENCLATURE_ID"
    AND dcd.table_name != "NORMALIZED_STRING_INDEX"
    AND dcd.table_name != "NOMENCLATURE")
   JOIN (ut
   WHERE ut.table_name=dcd.table_name)
   JOIN (ucc
   WHERE ucc.table_name=dcd.table_name
    AND ucc.column_name=dcd.column_name)
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
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed to find ","any tables")
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
   FOR (j = 1 TO table_list->tqual[i].field_knt)
     SET target_field = trim(table_list->tqual[i].field[j].name)
     SET upt_line1 = trim(concat("update into ",trim(target_table)," t,"," nomen_dups nd"))
     SET upt_line2 = trim(concat("set t.",trim(target_field)," = ","nd.primary_id"))
     SET upt_line3 = trim(concat("plan nd join t where t.",trim(target_field)," = nd.delete_id with ",
       "nocounter go"))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
      " field = ",trim(target_field),"  ",
      format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
     CALL parser(upt_line1)
     CALL parser(upt_line2)
     CALL parser(upt_line3)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",
      trim(target_field),"  Rows Updated: ",
      trim(cnvtstring(curqual)))
     SET errcode = error(errmsg,1)
     IF (errcode > 0
      AND substring(1,10,errmsg) != "%CCL-E-284")
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = errmsg
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed ","to update any id")
      SET err_level = 2
      GO TO exit_script
     ELSEIF (errcode > 0)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = errmsg
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat("   WARNING> Failed ","to update any id")
      SET err_level = 1
     ENDIF
     IF (curqual > 0)
      SET dvar = 0
      COMMIT
     ENDIF
     SET errcode = error(errmsg,1)
   ENDFOR
  ENDFOR
 ENDIF
 SET target_table = "DCP_ENTITY_RELTN"
 SET target_field = "ENTITY2_ID"
 SELECT INTO "nl:"
  ucc.table_name
  FROM user_tables ut,
   user_col_comments ucc
  PLAN (ut
   WHERE ut.table_name=target_table)
   JOIN (ucc
   WHERE ucc.column_name=target_field)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET continue = true
 ELSE
  SET continue = false
 ENDIF
 IF (continue=true)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
   " field = ",trim(target_field),"  ",
   format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  UPDATE  FROM dcp_entity_reltn t,
    nomen_dups nd
   SET t.entity2_id = nd.primary_id
   PLAN (nd)
    JOIN (t
    WHERE t.entity_reltn_mean="ORC/ICD9"
     AND t.entity2_id=nd.delete_id)
   WITH nocounter
  ;end update
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
  IF (curqual < 1)
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed ","to update any id")
    SET err_level = 2
    GO TO exit_script
   ENDIF
  ELSE
   SET dvar = 0
   COMMIT
  ENDIF
 ENDIF
 SET target_table = "SCD_TERM_DATA"
 SET target_field = "FKEY_ID"
 SELECT INTO "nl:"
  ucc.table_name
  FROM user_tables ut,
   user_col_comments ucc
  PLAN (ut
   WHERE ut.table_name=target_table)
   JOIN (ucc
   WHERE ucc.column_name=target_field)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET continue = true
 ELSE
  SET continue = false
 ENDIF
 IF (continue=true)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
   " field = ",trim(target_field),"  ",
   format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  UPDATE  FROM scd_term_data t,
    nomen_dups nd
   SET t.fkey_id = nd.primary_id
   PLAN (nd)
    JOIN (t
    WHERE t.fkey_entity_name="NOMENCLATURE"
     AND t.fkey_id=nd.delete_id)
   WITH nocounter
  ;end update
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
  IF (curqual < 1)
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed ","to update any id")
    SET err_level = 2
    GO TO exit_script
   ENDIF
  ELSE
   SET dvar = 0
   COMMIT
  ENDIF
 ENDIF
 SET target_table = "SCR_TERM_DEFINITION"
 SET target_field = "FKEY_ID"
 SELECT INTO "nl:"
  ucc.table_name
  FROM user_tables ut,
   user_col_comments ucc
  PLAN (ut
   WHERE ut.table_name=target_table)
   JOIN (ucc
   WHERE ucc.column_name=target_field)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET continue = true
 ELSE
  SET continue = false
 ENDIF
 IF (continue=true)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
   " field = ",trim(target_field),"  ",
   format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  UPDATE  FROM scr_term_definition t,
    nomen_dups nd
   SET t.fkey_id = nd.primary_id
   PLAN (nd)
    JOIN (t
    WHERE t.fkey_entity_name="NOMENCLATURE"
     AND t.fkey_id=nd.delete_id)
   WITH nocounter
  ;end update
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
  IF (curqual < 1)
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed ","to update any id")
    SET err_level = 2
    GO TO exit_script
   ENDIF
  ELSE
   SET dvar = 0
   COMMIT
  ENDIF
 ENDIF
 SET target_table = "OMF_PVF_FILTER"
 SET target_field = "NUM_ID"
 SELECT INTO "nl:"
  ucc.table_name
  FROM user_tables ut,
   user_col_comments ucc
  PLAN (ut
   WHERE ut.table_name=target_table)
   JOIN (ucc
   WHERE ucc.column_name=target_field)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET continue = true
 ELSE
  SET continue = false
 ENDIF
 IF (continue=true)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
   " field = ",trim(target_field),"  ",
   format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  UPDATE  FROM omf_pvf_filter t,
    nomen_dups nd
   SET t.num_id = nd.primary_id
   PLAN (nd)
    JOIN (t
    WHERE t.parent_entity_name="NOMENCLATURE"
     AND t.num_id=nd.delete_id)
   WITH nocounter
  ;end update
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
  IF (curqual < 1)
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed ","to update any id")
    SET err_level = 2
    GO TO exit_script
   ENDIF
  ELSE
   SET dvar = 0
   COMMIT
  ENDIF
 ENDIF
 SET target_table = "OMF_PV_SECURITY_FILTER"
 SET target_field = "NUM_ID"
 SELECT INTO "nl:"
  ucc.table_name
  FROM user_tables ut,
   user_col_comments ucc
  PLAN (ut
   WHERE ut.table_name=target_table)
   JOIN (ucc
   WHERE ucc.column_name=target_field)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET continue = true
 ELSE
  SET continue = false
 ENDIF
 IF (continue=true)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
   " field = ",trim(target_field),"  ",
   format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  UPDATE  FROM omf_pv_security_filter t,
    nomen_dups nd
   SET t.num_id = nd.primary_id
   PLAN (nd)
    JOIN (t
    WHERE t.parent_entity_name="NOMENCLATURE"
     AND t.num_id=nd.delete_id)
   WITH nocounter
  ;end update
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
  IF (curqual < 1)
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed ","to update any id")
    SET err_level = 2
    GO TO exit_script
   ENDIF
  ELSE
   SET dvar = 0
   COMMIT
  ENDIF
 ENDIF
 SET target_table = "ORDER_DETAIL"
 SET target_field = "OE_FIELD_VALUE"
 SELECT INTO "nl:"
  ucc.table_name
  FROM user_tables ut,
   user_col_comments ucc
  PLAN (ut
   WHERE ut.table_name=target_table)
   JOIN (ucc
   WHERE ucc.column_name=target_field)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET continue = true
 ELSE
  SET continue = false
 ENDIF
 IF (continue=true)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
   " field = ",trim(target_field),"  ",
   format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  UPDATE  FROM order_detail t,
    nomen_dups nd
   SET t.oe_field_value = nd.primary_id
   PLAN (nd)
    JOIN (t
    WHERE t.oe_field_meaning_id=20
     AND t.oe_field_value=nd.delete_id)
   WITH nocounter
  ;end update
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
  IF (curqual < 1)
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed ","to update any id")
    SET err_level = 2
    GO TO exit_script
   ENDIF
  ELSE
   SET dvar = 0
   COMMIT
  ENDIF
 ENDIF
 SET target_table = "BILL_ITEM_MODIFIER"
 SET target_field = "KEY3_ID"
 SELECT INTO "nl:"
  ucc.table_name
  FROM user_tables ut,
   user_col_comments ucc
  PLAN (ut
   WHERE ut.table_name=target_table)
   JOIN (ucc
   WHERE ucc.column_name=target_field)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET continue = true
 ELSE
  SET continue = false
 ENDIF
 IF (continue=true)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update table = ",trim(target_table),
   " field = ",trim(target_field),"  ",
   format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  UPDATE  FROM bill_item_modifier t,
    nomen_dups nd
   SET t.key3_id = nd.primary_id
   PLAN (nd)
    JOIN (t
    WHERE t.key3_entity_name="NOMENCLATURE"
     AND t.key3_id=nd.delete_id)
   WITH nocounter
  ;end update
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",trim(target_table),"  Field: ",trim(
    target_field),"  Rows Updated: ",
   trim(cnvtstring(curqual)))
  IF (curqual < 1)
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed ","to update any id")
    SET err_level = 2
    GO TO exit_script
   ENDIF
  ELSE
   SET dvar = 0
   COMMIT
  ENDIF
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin update nom_ver_grp_id ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 UPDATE  FROM nomenclature n,
   nomen_dups nd
  SET n.nom_ver_grp_id = nd.primary_id
  PLAN (nd)
   JOIN (n
   WHERE n.nom_ver_grp_id=nd.delete_id)
  WITH nocounter
 ;end update
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",
  "Nomenclature  Field: nom_ver_grp_id Rows updated: ",trim(cnvtstring(curqual)))
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed to update"," any rows on table")
   SET err_level = 2
   GO TO exit_script
  ENDIF
 ELSE
  SET dvar = 0
  COMMIT
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin write of nomen_duplicates.ids file ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET the_line = fillstring(132," ")
 SELECT INTO "NOMEN_DUPLICATE.IDS"
  primary_id = nd.primary_id, delete_id = nd.delete_id, now_dt_tm = format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"),
  mnemonic = nd.mnemonic, short_string = nd.short_string
  FROM nomen_dups nd
  DETAIL
   the_line = trim(concat(trim(cnvtstring(primary_id)),"<:>",trim(cnvtstring(delete_id)),"<:>",trim(
      mnemonic),
     "<:>",trim(short_string),"<:>",trim(now_dt_tm))), col 0, the_line,
   row + 1
  WITH nocounter, append, format = variable,
   noformfeed, maxrow = value((dup_list->qual_knt+ 1)), maxcol = 500
 ;end select
 IF ((curqual != (dup_list->qual_knt+ 1)))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   INFO> Curqual = ",trim(cnvtstring(curqual)),
   "  dup_list->qual_knt = ",trim(cnvtstring(dup_list->qual_knt)))
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed to write",
    " Nomen_Duplicates.dat file ","correctly")
  ENDIF
  SET err_level = 2
  GO TO exit_script
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin delete of id from nomenclature ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 DELETE  FROM nomenclature n,
   nomen_dups nd
  SET n.seq = 1
  PLAN (nd)
   JOIN (n
   WHERE n.nomenclature_id=nd.delete_id)
  WITH nocounter
 ;end delete
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO> Table: ",
  "Nomenclature  Field: nomenclature_id Rows deleted: ",trim(cnvtstring(curqual)))
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed to delete"," any rows on table")
   SET err_level = 2
   GO TO exit_script
  ENDIF
 ELSE
  SET dvar = 0
  COMMIT
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   TIME> Begin check for success ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 FREE SET tdup_list
 RECORD tdup_list(
   1 qual_knt = i4
   1 qual[*]
     2 nomenclature_id = f8
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 source_string = vc
     2 principle_type_cd = f8
     2 mnemonic = vc
     2 short_string = vc
     2 beg_eff_dt_tm = dq8
 )
 FREE SET dup_list
 RECORD dup_list(
   1 qual_knt = i4
   1 qual[*]
     2 primary_id = f8
     2 delete_id = f8
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 source_string = vc
     2 principle_type_cd = f8
     2 mnemonic = vc
     2 short_string = vc
     2 beg_eff_dt_tm = dq8
 )
 SELECT INTO "nl:"
  n.source_vocabulary_cd, n.source_identifier, n.source_string,
  n.principle_type_cd, n.beg_effective_dt_tm
  FROM nomenclature n
  PLAN (n
   WHERE n.nomenclature_id >= 0
    AND n.source_string > " ")
  ORDER BY n.source_vocabulary_cd, n.source_identifier, n.source_string,
   n.principle_type_cd, cnvtdatetime(n.beg_effective_dt_tm) DESC
  HEAD REPORT
   knt = 0, stat = alterlist(dup_list->qual,10)
  HEAD n.source_vocabulary_cd
   dvar = 0
  HEAD n.source_identifier
   dvar = 0
  HEAD n.principle_type_cd
   dvar = 0
  HEAD n.source_string
   tknt = 0, stat = alterlist(tdup_list->qual,10), tnomenclature_id = n.nomenclature_id,
   tsource_vocabulary_cd = n.source_vocabulary_cd, tsource_string = n.source_string,
   tprinciple_type_cd = n.principle_type_cd
  DETAIL
   tknt = (tknt+ 1)
   IF (mod(tknt,10)=1
    AND tknt != 1)
    stat = alterlist(tdup_list->qual,(tknt+ 9))
   ENDIF
   tdup_list->qual[tknt].nomenclature_id = n.nomenclature_id, tdup_list->qual[tknt].
   source_vocabulary_cd = n.source_vocabulary_cd, tdup_list->qual[tknt].source_identifier = n
   .source_identifier,
   tdup_list->qual[tknt].source_string = n.source_string, tdup_list->qual[tknt].principle_type_cd = n
   .principle_type_cd, tdup_list->qual[tknt].mnemonic = n.mnemonic,
   tdup_list->qual[tknt].short_string = n.short_string, tdup_list->qual[tknt].beg_eff_dt_tm = n
   .beg_effective_dt_tm
  FOOT  n.source_string
   tdup_list->qual_knt = tknt, stat = alterlist(tdup_list->qual,tknt)
   IF (tknt > 1)
    FOR (i = 2 TO tknt)
      knt = (knt+ 1)
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(dup_list->qual,(knt+ 9))
      ENDIF
      dup_list->qual[knt].primary_id = tdup_list->qual[1].nomenclature_id, dup_list->qual[knt].
      delete_id = tdup_list->qual[i].nomenclature_id, dup_list->qual[knt].source_vocabulary_cd =
      tdup_list->qual[i].source_vocabulary_cd,
      dup_list->qual[knt].source_identifier = tdup_list->qual[i].source_identifier, dup_list->qual[
      knt].source_string = tdup_list->qual[i].source_string, dup_list->qual[knt].principle_type_cd =
      tdup_list->qual[i].principle_type_cd,
      dup_list->qual[knt].mnemonic = tdup_list->qual[i].mnemonic, dup_list->qual[knt].short_string =
      tdup_list->qual[i].short_string, dup_list->qual[knt].beg_eff_dt_tm = tdup_list->qual[i].
      beg_eff_dt_tm
    ENDFOR
   ENDIF
  FOOT REPORT
   dup_list->qual_knt = knt, stat = alterlist(dup_list->qual,knt)
  WITH nocounter
 ;end select
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO> Number of duplicates found = ",trim(cnvtstring(
    dup_list->qual_knt)))
 IF ((dup_list->qual_knt < 1))
  SET errcode = error(errmsg,1)
  IF (errcode > 1
   AND substring(1,10,errmsg) != "%CCL-W-274")
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed to find any duplicates")
   SET err_level = 2
   GO TO exit_script
  ELSE
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   WARNING> Did not find any duplicates")
   SET err_level = 1
  ENDIF
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n
  PLAN (n
   WHERE n.nomenclature_id > 0.0
    AND n.source_string <= " ")
  HEAD REPORT
   knt = dup_list->qual_knt, stat = alterlist(dup_list->qual,(knt+ 10))
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(dup_list->qual,(knt+ 9))
   ENDIF
   dup_list->qual[knt].primary_id = 0.0, dup_list->qual[knt].delete_id = n.nomenclature_id, dup_list
   ->qual[knt].source_vocabulary_cd = n.source_vocabulary_cd,
   dup_list->qual[knt].source_identifier = n.source_identifier, dup_list->qual[knt].source_string = n
   .source_string, dup_list->qual[knt].principle_type_cd = n.principle_type_cd,
   dup_list->qual[knt].mnemonic = n.mnemonic, dup_list->qual[knt].short_string = n.short_string,
   dup_list->qual[knt].beg_eff_dt_tm = n.beg_effective_dt_tm
  FOOT REPORT
   dup_list->qual_knt = knt, stat = alterlist(dup_list->qual,knt)
  WITH nocounter
 ;end select
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO> Number of duplicates found = ",trim(cnvtstring(
    dup_list->qual_knt)))
 IF ((dup_list->qual_knt > 0))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   WARNING> FAILED TO DELETE ALL DUPLICATES")
  SET err_level = 2
  SET errcode = error(errmsg,1)
  SET the_line = fillstring(132," ")
  SELECT INTO "NOMEN_DUPS_FAILED.IDS"
   primary_id = nd.primary_id, delete_id = nd.delete_id, now_dt_tm = format(cnvtdatetime(curdate,
     curtime3),"dd-mmm-yyyy hh:mm:ss;;d"),
   mnemonic = nd.mnemonic, short_string = nd.short_string
   FROM nomen_dups nd
   DETAIL
    the_line = trim(concat(trim(cnvtstring(primary_id)),"<:>",trim(cnvtstring(delete_id)),"<:>",trim(
       mnemonic),
      "<:>",trim(short_string),"<:>",trim(now_dt_tm))), col 0, the_line,
    row + 1
   WITH nocounter, append, format = variable,
    noformfeed, maxrow = value((dup_list->qual_knt+ 1)), maxcol = 500
  ;end select
  IF ((curqual != (dup_list->qual_knt+ 1)))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   INFO> Curqual = ",trim(cnvtstring(curqual)),
    "  dup_list->qual_knt = ",trim(cnvtstring(dup_list->qual_knt)))
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed to write",
     " Nomen_Duplicates.dat file ","correctly")
   ENDIF
   SET err_level = 2
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (err_level=2)
  SET the_status = "FAILURE"
 ELSEIF (err_level=1)
  SET the_status = "WARNING"
 ELSE
  SET the_status = "SUCCESS"
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_NOMEN_DUPS   END :",trim(the_status),"  ",format
  (cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL error_logging(dvar)
 GO TO end_program
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
#end_program
END GO
