CREATE PROGRAM cps_fix_nomen_codes:dba
 FREE SET upt_list
 RECORD upt_list(
   1 qual_knt = i4
   1 qual[*]
     2 nomen_id = f8
     2 old_code = vc
     2 new_code = vc
     2 sui = vc
     2 cui = vc
     2 str = vc
     2 active_ind = i2
     2 end_dt_tm = dq8
     2 beg_dt_tm = dq8
     2 change_code = vc
     2 activate = vc
     2 deactivate = vc
     2 dup_sui_cui = vc
 )
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 FREE SET err_log
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 SET log_file = fillstring(30," ")
 SET msg_knt = 0
 SET err_log->msg_qual = msg_knt
 SET err_level = 0
 SET dvar = 0
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET nbr_to_chk = size(requestin->list_0,5)
 SET i = 1
 SET knt = 0
 SET true = 1
 SET false = 0
 SET vocab_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 400
 SET code_value = 0.0
 SET deactivated_items = "FALSE"
 SET changed_codes = "FALSE"
 SET log_file = concat("CPS_FIX_",trim(cnvtupper(substring(1,6,requestin->list_0[i].source_vocab_mean
     ))),"_CODES.LOG")
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_NOMEN_CODES begin : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET code_value = 0.0
 SET code_set = 400
 SET cdf_meaning = cnvtupper(trim(requestin->list_0[i].source_vocab_mean))
 EXECUTE cpm_get_cd_for_cdf
 SET vocab_cd = code_value
 IF (code_value < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to find vocabulary cdf_meaning ",trim(
    cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
  SET err_level = 2
  SET reqinfo->commit_ind = 3
  SET log_file = concat("CPS_FIX__CODES.LOG")
  GO TO exit_script
 ENDIF
 SET db_version = fillstring(12," ")
 SELECT INTO "nl:"
  c.code_value
  FROM code_value_extension c
  PLAN (c
   WHERE c.code_value=vocab_cd
    AND c.field_name="VERSION")
  DETAIL
   db_version = c.field_value
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (cnvtreal(db_version) >= 1997)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = "  WARNING> Database version is NOT less than 1997"
   SET err_level = 1
   SET reqinfo->commit_ind = 3
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT DISTINCT INTO "nl:"
  n.nomenclature_id, n.updt_dt_tm, n.concept_identifier,
  n.string_identifier
  FROM nomenclature n,
   (dummyt d  WITH seq = value(nbr_to_chk))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (n
   WHERE (n.concept_identifier=requestin->list_0[d.seq].cui)
    AND (n.string_identifier=requestin->list_0[d.seq].sui)
    AND n.source_vocabulary_cd=vocab_cd
    AND n.source_string=substring(1,255,requestin->list_0[d.seq].str))
  ORDER BY n.concept_identifier, n.string_identifier, cnvtdatetime(n.updt_dt_tm) DESC
  HEAD REPORT
   knt = 0, stat = alterlist(upt_list->qual,10), prev_cui = fillstring(18," "),
   prev_sui = fillstring(18," "), new_cui_sui = false
  HEAD n.concept_identifier
   dvar = 0
  HEAD n.string_identifier
   dvar = 0
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(upt_list->qual,(knt+ 9))
   ENDIF
   upt_list->qual[knt].nomen_id = n.nomenclature_id, upt_list->qual[knt].old_code = n
   .source_identifier, upt_list->qual[knt].new_code = requestin->list_0[d.seq].scd,
   upt_list->qual[knt].sui = n.string_identifier, upt_list->qual[knt].cui = n.concept_identifier,
   upt_list->qual[knt].str = n.source_string,
   upt_list->qual[knt].active_ind = n.active_ind, upt_list->qual[knt].beg_dt_tm = n
   .beg_effective_dt_tm, upt_list->qual[knt].end_dt_tm = n.end_effective_dt_tm
   IF ((n.source_identifier != requestin->list_0[d.seq].scd))
    upt_list->qual[knt].change_code = "TRUE"
   ELSE
    upt_list->qual[knt].change_code = "FALSE"
   ENDIF
   IF (n.string_identifier=trim(prev_sui)
    AND n.concept_identifier=trim(prev_cui))
    new_cui_sui = false, upt_list->qual[knt].dup_sui_cui = "TRUE"
   ELSE
    new_cui_sui = true, upt_list->qual[knt].dup_sui_cui = "FALSE"
   ENDIF
   IF (new_cui_sui=true
    AND n.active_ind < 1)
    upt_list->qual[knt].activate = "TRUE"
   ELSE
    upt_list->qual[knt].activate = "FALSE"
   ENDIF
   IF (new_cui_sui=false
    AND n.active_ind > 0)
    upt_list->qual[knt].deactivate = "TRUE"
   ELSE
    upt_list->qual[knt].deactivate = "FALSE"
   ENDIF
   prev_sui = n.string_identifier, prev_cui = n.concept_identifier
  FOOT REPORT
   upt_list->qual_knt = knt, stat = alterlist(upt_list->qual,knt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to find any data to update")
  SET errcode = error(errmsg,1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = errmsg
  SET err_level = 1
  GO TO exit_script
 ENDIF
 FREE SET chg_code_list
 RECORD chg_code_list(
   1 qual_knt = i2
   1 qual[*]
     2 nomen_id = f8
     2 old_code = vc
     2 new_code = vc
     2 success = i2
 )
 SELECT INTO "nl:"
  nomen_id = upt_list->qual[d.seq].nomen_id
  FROM (dummyt d  WITH seq = value(upt_list->qual_knt))
  PLAN (d
   WHERE d.seq > 0
    AND (upt_list->qual[d.seq].change_code="TRUE"))
  HEAD REPORT
   knt = 0, stat = alterlist(chg_code_list->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(chg_code_list->qual,(knt+ 9))
   ENDIF
   chg_code_list->qual[knt].nomen_id = upt_list->qual[d.seq].nomen_id, chg_code_list->qual[knt].
   old_code = upt_list->qual[d.seq].old_code, chg_code_list->qual[knt].new_code = upt_list->qual[d
   .seq].new_code
  FOOT REPORT
   chg_code_list->qual_knt = knt, stat = alterlist(chg_code_list->qual,knt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to find any codes to change")
  SET errcode = error(errmsg,1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = errmsg
  SET err_level = 1
 ELSE
  UPDATE  FROM nomenclature n,
    (dummyt d  WITH seq = value(chg_code_list->qual_knt))
   SET d.seq = 1, n.source_identifier = chg_code_list->qual[d.seq].new_code, n.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    n.updt_cnt = (n.updt_cnt+ 1), n.updt_id = 0.0, n.updt_task = 0.0,
    n.updt_applctx = 0.0
   PLAN (d
    WHERE d.seq > 0)
    JOIN (n
    WHERE (n.nomenclature_id=chg_code_list->qual[d.seq].nomen_id))
   WITH nocounter, status(chg_code_list->qual[d.seq].success)
  ;end update
  IF ((curqual != chg_code_list->qual_knt))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Update source_identifier for ",
    "selected nomenclature_id's")
   SET errcode = error(errmsg,1)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
   SET changed_codes = "FALSE"
  ELSE
   SET changed_codes = "TRUE"
  ENDIF
  COMMIT
 ENDIF
 FREE SET deact_list
 RECORD deact_list(
   1 qual_knt = i4
   1 qual[*]
     2 nomen_id = f8
     2 end_dt_tm = dq8
     2 success = i2
 )
 SELECT INTO "nl:"
  nomen_id = upt_list->qual[d.seq].nomen_id
  FROM (dummyt d  WITH seq = value(upt_list->qual_knt))
  PLAN (d
   WHERE d.seq > 0
    AND (upt_list->qual[d.seq].deactivate="TRUE"))
  HEAD REPORT
   knt = 0, stat = alterlist(deact_list->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(deact_list->qual,(knt+ 9))
   ENDIF
   deact_list->qual[knt].nomen_id = upt_list->qual[d.seq].nomen_id, deact_list->qual[knt].end_dt_tm
    = upt_list->qual[d.seq].end_dt_tm
  FOOT REPORT
   deact_list->qual_knt = knt, stat = alterlist(deact_list->qual,knt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to find any items to deactivate")
  SET errcode = error(errmsg,1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = errmsg
  SET err_level = 1
 ELSE
  UPDATE  FROM nomenclature n,
    (dummyt d  WITH seq = value(deact_list->qual_knt))
   SET d.seq = 1, n.active_ind = 0, n.end_effective_dt_tm =
    IF (cnvtdatetime(deact_list->qual[d.seq].end_dt_tm) < cnvtdatetime(curdate,curtime3))
     cnvtdatetime(deact_list->qual[d.seq].end_dt_tm)
    ELSE cnvtdatetime(curdate,curtime3)
    ENDIF
    ,
    n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_cnt = (n.updt_cnt+ 1), n.updt_id = 0.0,
    n.updt_task = 0.0, n.updt_applctx = 0.0
   PLAN (d
    WHERE d.seq > 0)
    JOIN (n
    WHERE (n.nomenclature_id=deact_list->qual[d.seq].nomen_id))
   WITH nocounter, status(deact_list->qual[d.seq].success)
  ;end update
  IF ((curqual != deact_list->qual_knt))
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to deactivate the ",
    "selected nomenclature_id's")
   SET errcode = error(errmsg,1)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
   SET deactivated_items = "FALSE"
  ELSE
   SET deactivated_items = "TRUE"
  ENDIF
  COMMIT
 ENDIF
#exit_script
 COMMIT
 IF (changed_codes="FALSE"
  AND (chg_code_list->qual_knt > 0))
  FOR (x = 1 TO chg_code_list->qual_knt)
    IF ((chg_code_list->qual[x].success < 1))
     SET snomen_id = fillstring(20," ")
     SET scode = fillstring(20," ")
     SET snomen_id = trim(cnvtstring(chg_code_list->qual[x].nomen_id))
     SET scode = trim(cnvtstring(chg_code_list->qual[x].new_code))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to change",
      " items source_identifier : Nomen_id = ",snomen_id,"   Correct source_identifier = ",scode)
    ENDIF
  ENDFOR
 ENDIF
 IF (deactivated_items="FALSE"
  AND (deact_list->qual_knt > 0))
  FOR (x = 1 TO chg_code_list->qual_knt)
    IF ((deact_list->qual[x].success < 1))
     SET snomen_id = fillstring(20," ")
     SET snomen_id = trim(cnvtstring(deact_list->qual[x].nomen_id))
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to ",
      " deactivate item : Nomen_id = ",snomen_id)
    ENDIF
  ENDFOR
 ENDIF
 IF (err_level=2)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_NOMEN_CODES      end :FAILURE ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSEIF (err_level=1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_NOMEN_CODES      end :WARNING ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_NOMEN_CODES      end :SUCCESS ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ENDIF
 SET err_log->msg_qual = msg_knt
 CALL error_logging(dvar)
 GO TO end_program
 SUBROUTINE error_logging(lvar)
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
