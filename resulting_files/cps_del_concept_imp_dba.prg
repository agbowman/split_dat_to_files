CREATE PROGRAM cps_del_concept_imp:dba
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
 FREE SET nomen_list
 RECORD nomen_list(
   1 qual_knt = i4
   1 qual[*]
     2 id = f8
     2 concept_ident = vc
 )
 SET log_file = fillstring(30," ")
 SET msg_knt = 0
 SET err_log->msg_qual = msg_knt
 SET err_level = 0
 SET dvar = 0
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET nbr_of_concepts = size(requestin->list_0,5)
 SET true = 1
 SET false = 0
 SET failed = true
 SET knt = 0
 SET log_file = "CPS_DEL_CONCEPT_IMP.LOG"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_DEL_CONCEPT_IMP begin : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET errcode = error(errmsg,1)
 SET errcode = 0
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n,
   (dummyt d  WITH seq = value(nbr_of_concepts))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (n
   WHERE (n.concept_identifier=requestin->list_0[d.seq].cui)
    AND n.active_ind > 0)
  HEAD REPORT
   knt = 0, stat = alterlist(nomen_list->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(nomen_list->qual,(knt+ 9))
   ENDIF
   nomen_list->qual[knt].id = n.nomenclature_id, nomen_list->qual[knt].concept_ident = n
   .concept_identifier
  FOOT REPORT
   nomen_list->qual_knt = knt, stat = alterlist(nomen_list->qual,knt)
  WITH nocounter
 ;end select
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
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat("   FAILURE> Failed to delete all normalized_strings ",
    "associated with concept_identifier between ",trim(nomen_list->qual[1].concept_ident)," and ",
    trim(nomen_list->qual[knt].concept_ident))
   SET err_level = 2
   SET reqinfo->commit_ind = 3
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((nomen_list->qual_knt > 0))
  UPDATE  FROM nomenclature n,
    (dummyt d  WITH seq = value(nomen_list->qual_knt))
   SET d.seq = 1, n.active_ind = 0, n.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_cnt = (n.updt_cnt+ 1), n.updt_id = 0.0,
    n.updt_task = 0.0, n.updt_applctx = 0.0
   PLAN (d
    WHERE d.seq > 0)
    JOIN (n
    WHERE (n.nomenclature_id=nomen_list->qual[d.seq].id))
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = errmsg
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = concat(
    "   FAILURE> Failed to deactivate all nomenclature items ",
    "associated with concept_identifier between ",trim(nomen_list->qual[1].concept_ident)," and ",
    trim(nomen_list->qual[knt].concept_ident))
   SET err_level = 2
   SET reqinfo->commit_ind = 3
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 UPDATE  FROM concept_definition c,
   (dummyt d  WITH seq = value(nbr_of_concepts))
  SET d.seq = 1, c.active_ind = 0, c.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (c.updt_cnt+ 1), c.updt_id = 0.0,
   c.updt_task = 0.0, c.updt_applctx = 0.0
  PLAN (d
   WHERE d.seq > 0)
   JOIN (c
   WHERE (c.concept_identifier=requestin->list_0[d.seq].cui)
    AND c.active_ind > 0)
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = errmsg
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(
   "   FAILURE> Failed to deactivate all concept_definitions ",
   "associated with concept_identifier between ",trim(nomen_list->qual[1].concept_ident)," and ",trim
   (nomen_list->qual[knt].concept_ident))
  SET err_level = 2
  SET reqinfo->commit_ind = 3
  ROLLBACK
  GO TO exit_script
 ENDIF
 UPDATE  FROM concept c,
   (dummyt d  WITH seq = value(nbr_of_concepts))
  SET d.seq = 1, c.active_ind = 0, c.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (c.updt_cnt+ 1), c.updt_id = 0.0,
   c.updt_task = 0.0, c.updt_applctx = 0.0
  PLAN (d
   WHERE d.seq > 0)
   JOIN (c
   WHERE (c.concept_identifier=requestin->list_0[d.seq].cui)
    AND c.active_ind > 0)
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = errmsg
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   FAILURE> Failed to deactivate all concepts ",
   "associated with concept_identifier between ",trim(nomen_list->qual[1].concept_ident)," and ",trim
   (nomen_list->qual[knt].concept_ident))
  SET err_level = 2
  SET reqinfo->commit_ind = 3
  ROLLBACK
  GO TO exit_script
 ENDIF
#exit_script
 COMMIT
 IF (err_level > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_DEL_CONCEPT_IMP end : ","FAILURE ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_DEL_CONCEPT_IMP end : ","SUCCESS ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ENDIF
 CALL error_logging(dvar)
 GO TO end_program
#end_program
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
END GO
