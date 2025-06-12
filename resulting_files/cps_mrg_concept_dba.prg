CREATE PROGRAM cps_mrg_concept:dba
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
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
 SET nbr_of_concepts = size(requestin->list_0,5)
 SET true = 1
 SET false = 0
 SET terminate = 2
 SET valid_concept = false
 SET failed = true
 SET log_file = "CPS_MRG_CONCEPT.LOG"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_MRG_CONCEPT begin : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET i = 1
#begin_for_loop
 IF (i > nbr_of_concepts)
  GO TO exit_script
 ENDIF
 FOR (i = i TO nbr_of_concepts)
   CALL is_concept_identifier_valid(requestin->list_0[i].cui_cy)
   IF (valid_concept=false)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat(
     "  WARNING> Failed to find current concept_identifier ",trim(requestin->list_0[i].cui_cy))
    SET err_level = 1
   ENDIF
   CALL is_concept_identifier_valid(requestin->list_0[i].cui_py)
   CALL mrg_concept_def(requestin->list_0[i].cui_cy,requestin->list_0[i].cui_py)
   IF (failed=true
    AND valid_concept=true)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to merge Concept_Definition",
     "   new CUI : ",trim(requestin->list_0[i].cui_cy),"   old CUI : ",trim(requestin->list_0[i].
      cui_py))
    SET err_level = 1
   ENDIF
   CALL mrg_nomen_concept(requestin->list_0[i].cui_cy,requestin->list_0[i].cui_py)
   IF (failed=true
    AND valid_concept=true)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("  WARNING> Failed to merge Nomenclature ",
     "current CUI : ",trim(requestin->list_0[i].cui_cy),"   old CUI : ",trim(requestin->list_0[i].
      cui_py))
    SET err_level = 1
   ENDIF
   IF (valid_concept=true)
    CALL deact_concept(requestin->list_0[i].cui_py)
    IF (failed=true)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = concat(
      "  WARNING> Failed to deactivate old concept_identifier","  old CUI : ",trim(requestin->list_0[
       i].cui_py))
     SET err_level = 1
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 COMMIT
 IF (err_level=2)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_MRG_CONCEPT end :FAILURE ",format(cnvtdatetime(
     curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSEIF (err_level=1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_MRG_CONCEPT end :WARNING ",format(cnvtdatetime(
     curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSE
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_MRG_CONCEPT end :SUCCESS ",format(cnvtdatetime(
     curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ENDIF
 CALL error_logging(dvar)
 GO TO end_program
 SUBROUTINE is_concept_identifier_valid(concept_identifier)
   SET valid_concept = false
   SELECT INTO "nl:"
    c.concept_identifier
    FROM concept c
    PLAN (c
     WHERE c.concept_identifier=concept_identifier)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET valid_concept = true
   ENDIF
 END ;Subroutine
 SUBROUTINE mrg_concept_def(new_cui,old_cui)
   SET failed = true
   UPDATE  FROM concept_definition c
    SET c.concept_identifier = new_cui, c.active_ind = 0, c.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime3),
     c.updt_id = 0.0, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     c.updt_task = 0.0, c.updt_applctx = 0.0
    WHERE c.concept_identifier=old_cui
    WITH nocounter
   ;end update
   IF (curqual > 1)
    SET failed = false
   ELSE
    SET errcode = error(errmsg,1)
    IF (errcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = errmsg
    ELSE
     SET failed = false
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE mrg_nomen_concept(new_cui,old_cui)
   SET failed = true
   UPDATE  FROM nomenclature n
    SET n.concept_identifier = new_cui, n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_cnt = (
     n.updt_cnt+ 1),
     n.updt_id = 0.0, n.updt_task = 0.0, n.updt_applctx = 0.0
    WHERE n.concept_identifier=old_cui
    WITH nocounter
   ;end update
   IF (curqual > 0)
    SET failed = false
   ELSE
    SET errcode = error(errmsg,1)
    IF (errcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = errmsg
    ELSE
     SET failed = false
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE deact_concept(concept_identifier)
   SET failed = true
   UPDATE  FROM concept c
    SET c.active_ind = 0, c.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     c.updt_cnt = (c.updt_cnt+ 1), c.updt_id = 0.0, c.updt_task = 0.0,
     c.updt_applctx = 0.0
    WHERE c.concept_identifier=concept_identifier
     AND c.active_ind > 0
    WITH nocounter
   ;end update
   IF (curqual=1)
    SET failed = false
   ELSE
    SET errcode = error(errmsg,1)
    IF (errcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = errmsg
    ELSE
     SET failed = false
    ENDIF
   ENDIF
 END ;Subroutine
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
