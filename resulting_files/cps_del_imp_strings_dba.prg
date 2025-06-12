CREATE PROGRAM cps_del_imp_strings:dba
 FREE SET nomen_list
 RECORD nomen_list(
   1 qual_knt = i4
   1 qual[*]
     2 id = f8
     2 end_eff_dt_tm = dq8
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
 SET true = 1
 SET false = 0
 SET failed = true
 SET list_size = size(requestin->list_0,5)
 SET knt = 0
 SET log_file = "CPS_DEL_IMP_STRS.LOG"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_DEL_IMP_STRINGS begin : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n,
   (dummyt d  WITH seq = value(list_size))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (n
   WHERE (n.string_identifier=requestin->list_0[d.seq].sui)
    AND n.active_ind > 0)
  HEAD REPORT
   knt = 0, stat = alterlist(nomen_list->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(nomen_list->qual,(knt+ 9))
   ENDIF
   nomen_list->qual[knt].id = n.nomenclature_id, nomen_list->qual[knt].end_eff_dt_tm = n
   .end_effective_dt_tm
  FOOT REPORT
   nomen_list->qual_knt = knt, stat = alterlist(nomen_list->qual,knt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SET errcode = error(errmsg,1)
 SET errcode = 0
 IF ((nomen_list->qual_knt > 0))
  DELETE  FROM normalized_string_index n,
    (dummyt d  WITH seq = value(nomen_list->qual_knt))
   SET d.seq = 1
   PLAN (d
    WHERE d.seq > 0)
    JOIN (n
    WHERE (n.nomenclature_id=nomen_list->qual[d.seq].id))
   WITH nocounter
  ;end delete
  IF (curqual < 1)
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   WARNING> Failed to delete all normalized_strings ",
     "associated with string_identifier(s) between ",trim(requestin->list_0[1].sui)," and ",trim(
      requestin->list_0[list_size].sui))
    SET err_level = 1
   ENDIF
  ENDIF
 ENDIF
 IF ((nomen_list->qual_knt > 0))
  SET now_dt_tm = cnvtdatetime(curdate,curtime3)
  UPDATE  FROM nomenclature n,
    (dummyt d  WITH seq = value(nomen_list->qual_knt))
   SET d.seq = 1, n.updt_dt_tm = cnvtdatetime(now_dt_tm), n.active_ind = 0,
    n.end_effective_dt_tm = cnvtdatetime(now_dt_tm), n.updt_id = 0.0, n.updt_cnt = (n.updt_cnt+ 1),
    n.updt_task = 0.0, n.updt_applctx = 0.0
   PLAN (d
    WHERE cnvtdatetime(nomen_list->qual[d.seq].end_eff_dt_tm) > cnvtdatetime(now_dt_tm))
    JOIN (n
    WHERE (n.nomenclature_id=nomen_list->qual[d.seq].id))
   WITH nocounter
  ;end update
  IF ((curqual != nomen_list->qual_knt))
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = errmsg
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat(
     "   ERROR> Failed to deactivate all nomenclature items ",
     "associated with string_identifier(s) between ",trim(requestin->list_0[1].sui)," and ",trim(
      requestin->list_0[list_size].sui))
    SET reqinfo->commit_ind = 3
    SET err_level = 2
    ROLLBACK
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
#exit_script
 COMMIT
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("  Total number of id's : ",trim(cnvtstring(nomen_list->
    qual_knt)),"  begining sui = ",trim(requestin->list_0[1].sui),"  ending sui = ",
  trim(requestin->list_0[list_size].sui))
 IF (err_level=0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_DEL_IMP_STRINGS   end : ","SUCCESS ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSEIF (err_level=1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_DEL_IMP_STRINGS   end : ","WARNING ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_DEL_IMP_STRINGS   end : ","FAILURE ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ENDIF
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
