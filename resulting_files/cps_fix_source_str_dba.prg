CREATE PROGRAM cps_fix_source_str:dba
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 FREE SET upt_list
 RECORD upt_list(
   1 qual_knt = i4
   1 qual[*]
     2 id = f8
     2 u_str = vc
     2 string_ident = vc
     2 source_ident = vc
     2 status = i2
     2 beg_dt_tm = dq8
 )
 FREE SET deact_list
 RECORD deact_list(
   1 qual_knt = i4
   1 qual[*]
     2 id = f8
 )
 FREE SET err_log
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 SET msg_knt = 0
 SET err_level = 0
 SET err_log->msg_qual = msg_knt
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET log_file = fillstring(30," ")
 SET false = 0
 SET true = 1
 SET dvar = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET source_vocab_cd = 0.0
 SET tot_str_nbr = size(requestin->list_0,5)
 SET i = 1
 SET knt = 0
 SET log_file = concat("CPS_FIX_",trim(cnvtupper(substring(1,6,requestin->list_0[1].
     source_vocabulary_mean))),"_SOURCE_STR.LOG")
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_SOURCE_STR begin : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET code_value = 0.0
 SET code_set = 400
 SET cdf_meaning = trim(requestin->list_0[i].source_vocabulary_mean)
 EXECUTE cpm_get_cd_for_cdf
 SET source_vocab_cd = code_value
 IF (code_value < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to find source_vocabulary_meaning ",
   trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)))
  SET err_level = 2
  SET reqinfo->commit_ind = 3
  GO TO exit_script
 ENDIF
 SET ver_nbr = 0.0
 SELECT INTO "nl:"
  cve.code_value
  FROM code_value_extension cve
  PLAN (cve
   WHERE cve.code_value=source_vocab_cd
    AND cve.field_name="VERSION")
  DETAIL
   ver_nbr = cnvtreal(cve.field_value)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (ver_nbr >= 1998)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Source_Strings for  ",trim(cdf_meaning),
    " do not need modification")
   SET err_level = 1
   SET reqinfo->commit_ind = 3
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (n
   WHERE n.source_string=trim(substring(1,100,requestin->list_0[d.seq].source_string))
    AND n.source_vocabulary_cd=source_vocab_cd
    AND (n.string_identifier=requestin->list_0[d.seq].string_identifier))
  HEAD REPORT
   knt = 0, stat = alterlist(upt_list->qual,1000)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,1000)=1
    AND knt != 1)
    stat = alterlist(upt_list->qual,(knt+ 999))
   ENDIF
   upt_list->qual[knt].id = n.nomenclature_id, upt_list->qual[knt].u_str = requestin->list_0[d.seq].
   source_string, upt_list->qual[knt].status = false,
   upt_list->qual[knt].beg_dt_tm = cnvtdatetime(n.beg_effective_dt_tm), upt_list->qual[knt].
   string_ident = n.string_identifier, upt_list->qual[knt].source_ident = n.source_identifier
  FOOT REPORT
   upt_list->qual_knt = knt, stat = alterlist(upt_list->qual,knt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to find any strings to update : beg ",
   "string_ident = ",trim(requestin->list_0[i].string_identifier)," end ","string_ident = ",
   trim(requestin->list_0[tot_str_nbr].string_identifier))
  SET err_level = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n,
   (dummyt d  WITH seq = value(size(upt_list->qual,5)))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (n
   WHERE (n.source_identifier=upt_list->qual[d.seq].source_ident)
    AND n.source_vocabulary_cd=source_vocab_cd
    AND (n.string_identifier=upt_list->qual[d.seq].string_ident)
    AND n.source_string=trim(substring(1,255,upt_list->qual[d.seq].u_str))
    AND (n.nomenclature_id != upt_list->qual[d.seq].id)
    AND n.active_ind > 0
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   knt = 0, stat = alterlist(deact_list->qual,1000)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,1000)=1
    AND knt != 1)
    stat = alterlist(deact_list->qual,(knt+ 999))
   ENDIF
   deact_list->qual[knt].id = n.nomenclature_id
  FOOT REPORT
   deact_list->qual_knt = knt, stat = alterlist(deact_list->qual,knt)
  WITH nocounter
 ;end select
 FOR (i = 1 TO upt_list->qual_knt)
  UPDATE  FROM nomenclature n
   SET n.source_string = upt_list->qual[i].u_str, n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n
    .updt_cnt = (n.updt_cnt+ 1)
   WHERE (n.nomenclature_id=upt_list->qual[i].id)
   WITH nocounter
  ;end update
  IF (curqual > 0)
   COMMIT
  ELSE
   ROLLBACK
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("  ERROR> Failed to update string ",
    "Nomenclature_Id = ",trim(cnvtstring(upt_list->qual[i].id)))
   SET errcode = error(errmsg,1)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 2
   GO TO exit_script
  ENDIF
 ENDFOR
 FOR (i = 1 TO deact_list->qual_knt)
  UPDATE  FROM nomenclature n
   SET n.active_ind = 0, n.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    n.updt_cnt = (n.updt_cnt+ 1)
   WHERE (n.nomenclature_id=deact_list->qual[i].id)
  ;end update
  IF (curqual > 0)
   COMMIT
  ELSE
   ROLLBACK
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to deactivate item ",
    "Nomenclature_Id = ",trim(cnvtstring(upt_list->qual[i].id)))
   SET errcode = error(errmsg,1)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET err_level = 1
  ENDIF
 ENDFOR
 FOR (ptr = 1 TO upt_list->qual_knt)
   IF ((upt_list->qual[ptr].status=true))
    EXECUTE cps_ens_normalized_index upt_list->qual[ptr].id
    IF (curqual < 1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat(
      "  WARNING> Failed to update Normalized_String_Index ","nomenclature_id = ",trim(cnvtstring(
        upt_list->qual[ptr].id)))
     SET errcode = error(errmsg,1)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = errmsg
     SET err_level = 2
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 COMMIT
 IF (err_level=2)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_SOURCE_STR       end :FAILURE ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSEIF (err_level=1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_SOURCE_STR       end :WARNING ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_SOURCE_STR       end :SUCCESS ",format(
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
