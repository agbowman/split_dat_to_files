CREATE PROGRAM cps_import_entity_reltn:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE qual_knt = i4 WITH private, constant(size(requestin->list_0,5))
 DECLARE x = i4 WITH public, noconstant(0)
 DECLARE reltn_cd = f8 WITH public, noconstant(0.0)
 DECLARE reltn_mean = c12 WITH public, noconstant(fillstring(12," "))
 FREE SET err_log
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 DECLARE dvar = i2 WITH public, noconstant(0)
 DECLARE log_file = c27 WITH public, constant("CPS_IMPORT_ENTITY_RELTN.LOG")
 DECLARE msg_knt = i4 WITH public, noconstant(0)
 DECLARE error_level = i2 WITH public, noconstant(0)
 DECLARE status_msg = c7 WITH public, noconstant(fillstring(7," "))
 DECLARE cat_cd = f8 WITH public, noconstant(0.0)
 DECLARE orc_mnemonic = c100 WITH public, noconstant(fillstring(100," "))
 DECLARE nomen_id = f8 WITH public, noconstant(0.0)
 DECLARE nomen_string = c100 WITH public, noconstant(fillstring(100," "))
 DECLARE alt_sel_cat_id = f8 WITH public, noconstant(0.0)
 DECLARE long_description = c100 WITH public, noconstant(fillstring(100," "))
 DECLARE nomen_category_id = f8 WITH public, noconstant(0.0)
 DECLARE category_name = c100 WITH public, noconstant(fillstring(100," "))
 DECLARE vocab_cd = f8 WITH public, noconstant(0.0)
 DECLARE principle_cd = f8 WITH public, noconstant(0.0)
 DECLARE stat = i2 WITH public, noconstant(0)
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE diag_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE entity1_id = f8 WITH public, noconstant(0.0)
 DECLARE entity1_display = c100 WITH public, noconstant(fillstring(100," "))
 DECLARE entity2_id = f8 WITH public, noconstant(0.0)
 DECLARE entity2_display = c100 WITH public, noconstant(fillstring(100," "))
 DECLARE found = i2 WITH public, noconstant(0)
 DECLARE ent_rel_id = f8 WITH public, noconstant(0.0)
 DECLARE continue = i2 WITH public, noconstant(true)
 DECLARE sequence = i4 WITH public, noconstant(0)
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_IMPORT_ENTITY_RELTN  BEG :: ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET code_set = 25321
 SET cdf_meaning = "DIAGNOSIS"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,diag_type_cd)
 IF (((stat != 0) OR (diag_type_cd < 1)) )
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(
   "   ERROR : Finding the CODE_VALUE for DIAGNOSIS_TYPE_CD ",trim(cdf_meaning)," from CODE_SET ",
   trim(cnvtstring(code_set)))
  SET commit_ind = 3
  SET error_level = 2
  GO TO exit_script
 ENDIF
#start_for_loop
 SET x = (x+ 1)
 IF (x > qual_knt)
  GO TO exit_import
 ENDIF
 FOR (x = x TO qual_knt)
   SET reltn_cd = 0
   SET reltn_mean = trim(requestin->list_0[x].entity_reltn)
   SET code_set = 14369
   SET cdf_meaning = reltn_mean
   SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,reltn_cd)
   IF (((stat != 0) OR (reltn_cd < 1)) )
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat(
     "   INFO : Couldn't Find the CODE_VALUE for ENTITY_RELTN ",trim(cdf_meaning)," from CODE_SET ",
     trim(cnvtstring(code_set)))
    SET error_level = 1
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   IF ((requestin->list_0[x].blast="Y"))
    SET continue = true
    WHILE (continue=true)
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      DELETE  FROM dcp_entity_reltn d
       WHERE d.entity_reltn_mean=reltn_mean
       WITH nocounter, maxqual(n,100)
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET msg_knt = (msg_knt+ 1)
       SET stat = alterlist(err_log->msg,msg_knt)
       SET err_log->msg[msg_knt].err_msg = concat("   ERROR : Blasting the ENTITY_RELTN",trim(
         requestin->list_0[x].entity_reltn))
       SET msg_knt = (msg_knt+ 1)
       SET stat = alterlist(err_log->msg,msg_knt)
       SET err_log->msg[msg_knt].err_msg = serrmsg
       SET commit_ind = 3
       SET error_level = 2
       GO TO exit_script
      ENDIF
      IF (curqual=100)
       SET continue = true
      ELSE
       SET continue = false
      ENDIF
    ENDWHILE
   ENDIF
   SET cat_cd = 0
   SET orc_mnemonic = fillstring(100," ")
   SET nomen_id = 0
   SET nomen_string = fillstring(100," ")
   SET alt_sel_cat_id = 0
   SET long_description = fillstring(100," ")
   SET nomen_category_id = 0
   SET category_name = fillstring(100," ")
   IF ((((requestin->list_0[x].entity_reltn="ORC/ICD9")) OR ((requestin->list_0[x].entity_reltn=
   "ORC/NOMENCAT")))
    AND (requestin->list_0[x].hna_mnemonic > " "))
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "NL:"
     FROM order_catalog oc
     PLAN (oc
      WHERE oc.primary_mnemonic=trim(requestin->list_0[x].hna_mnemonic)
       AND oc.active_ind=1)
     DETAIL
      cat_cd = oc.catalog_cd, orc_mnemonic = oc.primary_mnemonic
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("   ERROR : Finding the CATALOG_CD for hna_mnemonic ",
      trim(requestin->list_0[x].hna_mnemonic))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = serrmsg
     SET commit_ind = 3
     SET error_level = 2
     GO TO exit_script
    ENDIF
    IF (cat_cd < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat(
      "   WARNING : No item added.  Failed to find the CATALOG_CD for hna_mnemonic ",trim(requestin->
       list_0[x].hna_mnemonic))
     SET error_level = 1
     GO TO start_for_loop
    ENDIF
   ENDIF
   IF ((((requestin->list_0[x].entity_reltn="ORC/ICD9")) OR ((requestin->list_0[x].entity_reltn=
   "ALTSEL/NOMEN")))
    AND (requestin->list_0[x].source_string > " "))
    SET vocab_cd = 0.0
    IF ((requestin->list_0[x].source_vocabulary_mean > " "))
     SET code_set = 400
     SET cdf_meaning = trim(requestin->list_0[x].source_vocabulary_mean)
     SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,vocab_cd)
     IF (stat != 0)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat(
       "   ERROR : Finding the CODE_VALUE for SOURCE_VOCABULARY_MEAN ",trim(cdf_meaning),
       " from CODE_SET ",trim(cnvtstring(code_set)))
      SET commit_ind = 3
      SET error_level = 2
      GO TO exit_script
     ENDIF
    ENDIF
    SET principle_cd = 0.0
    IF ((requestin->list_0[x].principle_type_mean > " "))
     SET code_set = 401
     SET cdf_meaning = trim(requestin->list_0[x].principle_type_mean)
     SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,principle_cd)
     IF (stat != 0)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat(
       "   ERROR : Finding the CODE_VALUE for PRINCIPLE_TYPE_MEAN ",trim(cdf_meaning),
       " from CODE_SET ",trim(cnvtstring(code_set)))
      SET commit_ind = 3
      SET error_level = 2
      GO TO exit_script
     ENDIF
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "NL:"
     FROM nomenclature n
     PLAN (n
      WHERE n.source_vocabulary_cd=vocab_cd
       AND (n.source_identifier=requestin->list_0[x].source_identifier)
       AND (n.source_string=requestin->list_0[x].source_string)
       AND n.principle_type_cd=principle_cd)
     HEAD REPORT
      nomen_id = n.nomenclature_id, nomen_string = n.source_string
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat(
      "   ERROR : Finding the NOMENCLATURE_ID for SOURCE_VOCABULARY_MEAN ",trim(requestin->list_0[x].
       source_vocabulary_mean)," PRINCIPLE_TYPE_MEAN ",trim(requestin->list_0[x].principle_type_mean),
      " SOURCE_IDENTIFIER ",
      trim(requestin->list_0[x].source_identifier))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("           SOURCE_STRING ",trim(requestin->list_0[x]
       .source_string))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = serrmsg
     SET commit_ind = 3
     SET error_level = 2
     GO TO exit_script
    ENDIF
    IF (nomen_id < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat(
      "   WARNING : Finding the NOMENCLATURE_ID for SOURCE_VOCABULARY_MEAN ",trim(requestin->list_0[x
       ].source_vocabulary_mean)," PRINCIPLE_TYPE_MEAN ",trim(requestin->list_0[x].
       principle_type_mean)," SOURCE_IDENTIFIER ",
      trim(requestin->list_0[x].source_identifier))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("            SOURCE_STRING ",trim(requestin->list_0[x
       ].source_string))
     SET error_level = 1
     GO TO start_for_loop
    ENDIF
   ENDIF
   IF ((((requestin->list_0[x].entity_reltn="ALTSEL/NOMEN")) OR ((requestin->list_0[x].entity_reltn=
   "ALTSEL/NOMCT")))
    AND (requestin->list_0[x].long_description > " "))
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "NL:"
     FROM alt_sel_cat a
     PLAN (a
      WHERE a.long_description_key_cap=trim(requestin->list_0[x].long_description)
       AND a.owner_id=0
       AND a.security_flag=2)
     DETAIL
      alt_sel_cat_id = a.alt_sel_category_id, long_description = a.long_description
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat(
      "   ERROR : Finding the ALT_SEL_CATEOGRY_ID for LONG_DESCRIPTION ",trim(requestin->list_0[x].
       long_description))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = serrmsg
     SET commit_ind = 3
     SET error_level = 2
     GO TO exit_script
    ENDIF
    IF (alt_sel_cat_id < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat(
      "   WARNING : Finding the ALT_SEL_CATEOGRY_ID for LONG_DESCRIPTION ",trim(requestin->list_0[x].
       long_description))
     SET error_level = 1
     GO TO start_for_loop
    ENDIF
   ENDIF
   IF ((((requestin->list_0[x].entity_reltn="ORC/NOMENCAT")) OR ((requestin->list_0[x].entity_reltn=
   "ALTSEL/NOMCT")))
    AND (requestin->list_0[x].category_name > " "))
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "NL:"
     FROM nomen_category n
     PLAN (n
      WHERE n.parent_entity_id < 1
       AND n.category_type_cd=diag_type_cd
       AND n.category_name=trim(requestin->list_0[x].category_name))
     HEAD REPORT
      nomen_category_id = n.nomen_category_id, category_name = n.category_name
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat(
      "   ERROR : Finding the NOMEN_CATEGORY_ID for CATEGORY_NAME ",trim(requestin->list_0[x].
       category_name))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = serrmsg
     SET commit_ind = 3
     SET error_level = 2
     GO TO exit_script
    ENDIF
    IF (nomen_category_id < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat(
      "   WARNING : Finding the NOMEN_CATEGORY_ID for CATEGORY_NAME ",trim(requestin->list_0[x].
       category_name))
     SET error_level = 1
     GO TO start_for_loop
    ENDIF
   ENDIF
   CALL echo(build("catalog_cd       = ",cat_cd))
   CALL echo(build("Primary Mnemonic = ",orc_mnemonic))
   CALL echo(build("Nomen_id         = ",nomen_id))
   CALL echo(build("Nomen String     = ",nomen_string))
   CALL echo(build("Alt Sel id       = ",alt_sel_cat_id))
   CALL echo(build("Long Description = ",long_description))
   CALL echo(build("Nomen Cat id     = ",nomen_category_id))
   CALL echo(build("Category Name    = ",category_name))
   SET entity1_id = 0
   SET entity1_display = fillstring(100," ")
   SET entity2_id = 0
   SET entity2_display = fillstring(100," ")
   SET sequence = cnvtint(requestin->list_0[x].sequence)
   IF (reltn_mean="ORC/ICD9")
    SET entity1_id = cat_cd
    SET entity1_display = orc_mnemonic
    SET entity2_id = nomen_id
    SET entity2_display = nomen_string
   ELSEIF (reltn_mean="ORC/NOMENCAT")
    SET entity1_id = cat_cd
    SET entity1_display = orc_mnemonic
    SET entity2_id = nomen_category_id
    SET entity2_display = category_name
   ELSEIF (reltn_mean="ALTSEL/NOMEN")
    SET entity1_id = alt_sel_cat_id
    SET entity1_display = long_description
    SET entity2_id = nomen_id
    SET entity2_display = nomen_string
   ELSEIF (reltn_mean="ALTSEL/NOMCT")
    SET entity1_id = alt_sel_cat_id
    SET entity1_display = long_description
    SET entity2_id = nomen_category_id
    SET entity2_display = category_name
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   WARNING : Unknown RELTN_MEAN ",trim(requestin->
      list_0[x].reltn_mean))
    SET error_level = 1
    GO TO start_for_loop
   ENDIF
   IF (entity1_id > 0
    AND entity2_id > 0)
    SET found = 0
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "NL:"
     FROM dcp_entity_reltn der
     PLAN (der
      WHERE der.entity_reltn_mean=reltn_mean
       AND der.entity1_id=entity1_id
       AND der.entity1_display=entity1_display
       AND der.entity2_id=entity2_id
       AND der.entity2_display=entity2_display
       AND der.active_ind=1)
     DETAIL
      found = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat(
      "   ERROR : Checking for duplicate relationships.  RELTN_MEAN = ",trim(reltn_mean),
      "  ENTITY1_ID = ",trim(cnvtstring(entity1_id)),"  ENTITY2_ID = ",
      trim(cnvtstring(entity2_id)))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = serrmsg
     SET commit_ind = 3
     SET error_level = 2
     GO TO exit_script
    ENDIF
    IF (found=0)
     SET ent_rel_id = 0
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      nextseqnum = seq(carenet_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       ent_rel_id = cnvtreal(nextseqnum)
      WITH format
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat(
       "   ERROR : Generating the DCP_ENTITY_RELTN_ID.  RELTN_MEAN = ",trim(reltn_mean),
       "  ENTITY1_ID = ",trim(cnvtstring(entity1_id)),"  ENTITY2_ID = ",
       trim(cnvtstring(entity2_id)))
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = serrmsg
      SET commit_ind = 3
      SET error_level = 2
      GO TO exit_script
     ENDIF
     INSERT  FROM dcp_entity_reltn der
      SET der.dcp_entity_reltn_id = ent_rel_id, der.entity_reltn_mean = reltn_mean, der.entity1_id =
       entity1_id,
       der.entity1_display = entity1_display, der.entity2_id = entity2_id, der.entity2_display =
       entity2_display,
       der.rank_sequence = sequence, der.active_ind = 1, der.begin_effective_dt_tm = cnvtdatetime(
        curdate,curtime3),
       der.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"), der.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), der.updt_id = reqinfo->updt_id,
       der.updt_task = reqinfo->updt_task, der.updt_applctx = reqinfo->updt_applctx, der.updt_cnt = 0
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = concat(
       "   ERROR : Inserting a relationship.  RELTN_MEAN = ",trim(reltn_mean),"  ENTITY1_ID = ",trim(
        cnvtstring(entity1_id)),"  ENTITY2_ID = ",
       trim(cnvtstring(entity2_id)))
      SET msg_knt = (msg_knt+ 1)
      SET stat = alterlist(err_log->msg,msg_knt)
      SET err_log->msg[msg_knt].err_msg = serrmsg
      SET commit_ind = 3
      SET error_level = 2
      GO TO exit_script
     ENDIF
    ELSE
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat(
      "   ERROR : Relationship already exist.  RELTN_MEAN = ",trim(reltn_mean),"  ENTITY1_ID = ",trim
      (cnvtstring(entity1_id)),"  ENTITY2_ID = ",
      trim(cnvtstring(entity2_id)))
     SET commit_ind = 3
     SET error_level = 2
     GO TO exit_script
    ENDIF
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   WARNING : Invalid entity ids ENTITY1_ID = ",trim(
      cnvtstring(entity1_id)),"  ENTITY2_ID = ",trim(cnvtstring(entity2_id)))
    SET error_level = 1
    GO TO start_for_loop
   ENDIF
 ENDFOR
#exit_import
#exit_script
 COMMIT
 IF (error_level=0)
  SET status_msg = "SUCCESS"
 ELSEIF (error_level=1)
  SET status_msg = "WARNING"
 ELSEIF (error_level=2)
  SET status_msg = "FAILURE"
 ELSE
  SET status_msg = "UNKNOWN"
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_IMPORT_ENTITY_RELTN  END :: ",trim(status_msg),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
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
 SET script_version = "003 10/31/02 SF3151"
END GO
