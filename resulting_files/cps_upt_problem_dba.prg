CREATE PROGRAM cps_upt_problem:dba
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 person_id = f8
    1 problem_list[1]
      2 problem_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET failed = false
 SET table_name = "PROBLEM"
 SET swarnmsg = fillstring(100," ")
 CALL upt_problem(action_begin,action_end)
 IF (((failed != false) OR (swarnmsg != " ")) )
  GO TO end_program
 ENDIF
 SUBROUTINE upt_problem(upt_begin,upt_end)
   FOR (pchg_inx = upt_begin TO upt_end)
     SELECT INTO "NL:"
      p.*
      FROM problem p
      WHERE (p.problem_id=request->problem[pchg_inx].problem_id)
       AND (p.problem_instance_id=request->problem[pchg_inx].problem_instance_id)
      WITH nocounter, forupdate(p)
     ;end select
     IF (curqual < 0)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM problem p
      SET p.end_effective_dt_tm = cnvtdatetime(sysdate), p.updt_dt_tm = cnvtdatetime(sysdate), p
       .updt_applctx = reqinfo->updt_applctx,
       p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task
      PLAN (p
       WHERE (p.problem_id=request->problem[pchg_inx].problem_id)
        AND (p.problem_instance_id=request->problem[pchg_inx].problem_instance_id))
      WITH nocounter
     ;end update
     IF (curqual < 0)
      SET failed = update_error
      RETURN
     ENDIF
     SET active_code = 0.0
     SELECT INTO "NL:"
      c.*
      FROM code_value c
      WHERE c.code_set=48
       AND c.cdf_meaning="ACTIVE"
      DETAIL
       active_code = c.code_value
      WITH nocounter
     ;end select
     SET new_code = 0.0
     SELECT INTO "nl:"
      y = seq(problem_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_code = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual < 0)
      SET failed = gen_nbr_error
      RETURN
     ENDIF
     INSERT  FROM problem p
      SET p.problem_instance_id = new_code, p.problem_id = request->problem[pchg_inx].problem_id, p
       .nomenclature_id =
       IF ((request->problem[pchg_inx].nomenclature_id=0)) 0
       ELSE request->problem[pchg_inx].nomenclature_id
       ENDIF
       ,
       p.person_id = request->person_id, p.problem_ftdesc =
       IF ((request->problem[pchg_inx].problem_ftdesc=" ")) null
       ELSE request->problem[pchg_inx].problem_ftdesc
       ENDIF
       , p.estimated_resolution_dt_tm =
       IF ((request->problem[pchg_inx].estimated_resolution_dt_tm=0)) null
       ELSE cnvtdatetime(request->problem[pchg_inx].estimated_resolution_dt_tm)
       ENDIF
       ,
       p.actual_resolution_dt_tm =
       IF ((request->problem[pchg_inx].actual_resolution_dt_tm=0)) null
       ELSE cnvtdatetime(request->problem[pchg_inx].actual_resolution_dt_tm)
       ENDIF
       , p.classification_cd =
       IF ((request->problem[pchg_inx].classification_cd=0)) 0
       ELSE request->problem[pchg_inx].classification_cd
       ENDIF
       , p.persistence_cd =
       IF ((request->problem[pchg_inx].persistence_cd=0)) 0
       ELSE request->problem[pchg_inx].persistence_cd
       ENDIF
       ,
       p.confirmation_status_cd = request->problem[pchg_inx].confirmation_status_cd, p
       .life_cycle_status_cd = request->problem[pchg_inx].life_cycle_status_cd, p.life_cycle_dt_tm =
       cnvtdatetime(sysdate),
       p.onset_dt_cd = request->problem[pchg_inx].onset_dt_cd, p.onset_dt_tm = cnvtdatetime(request->
        problem[pchg_inx].onset_dt_tm), p.ranking_cd =
       IF ((request->problem[pchg_inx].ranking_cd=0)) 0
       ELSE request->problem[pchg_inx].ranking_cd
       ENDIF
       ,
       p.certainty_cd =
       IF ((request->problem[pchg_inx].certainty_cd=0)) 0
       ELSE request->problem[pchg_inx].certainty_cd
       ENDIF
       , p.probability =
       IF ((request->problem[pchg_inx].probability=0)) null
       ELSE request->problem[pchg_inx].probability
       ENDIF
       , p.person_aware_cd =
       IF ((request->problem[pchg_inx].person_aware_cd=0)) 0
       ELSE request->problem[pchg_inx].person_aware_cd
       ENDIF
       ,
       p.prognosis_cd =
       IF ((request->problem[pchg_inx].prognosis_cd=0)) 0
       ELSE request->problem[pchg_inx].prognosis_cd
       ENDIF
       , p.person_aware_prognosis_cd =
       IF ((request->problem[pchg_inx].person_aware_prognosis_cd=0)) 0
       ELSE request->problem[pchg_inx].person_aware_prognosis_cd
       ENDIF
       , p.family_aware_cd =
       IF ((request->problem[pchg_inx].family_aware_cd=0)) 0
       ELSE request->problem[pchg_inx].family_aware_cd
       ENDIF
       ,
       p.sensitivity =
       IF ((request->problem[pchg_inx].sensitivity=0)) null
       ELSE request->problem[pchg_inx].sensitivity
       ENDIF
       , p.course_cd =
       IF ((request->problem[pchg_inx].course_cd=0)) 0
       ELSE request->problem[pchg_inx].course_cd
       ENDIF
       , p.cancel_reason_cd =
       IF ((request->problem[pchg_inx].cancel_reason_cd=0)) 0
       ELSE request->problem[pchg_inx].cancel_reason_cd
       ENDIF
       ,
       p.active_ind = 1, p.active_status_cd = active_code, p.active_status_dt_tm = cnvtdatetime(
        sysdate),
       p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(request->
        problem[pchg_inx].beg_effective_dt_tm), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       p.data_status_cd =
       IF ((request->problem[pchg_inx].data_status_cd=0)) 0
       ELSE request->problem[pchg_inx].data_status_cd
       ENDIF
       , p.data_status_dt_tm =
       IF ((request->problem[pchg_inx].data_status_dt_tm <= 0)) null
       ELSE cnvtdatetime(request->problem[pchg_inx].data_status_dt_tm)
       ENDIF
       , p.data_status_prsnl_id =
       IF ((request->problem[pchg_inx].data_status_prsnl_id=0)) 0
       ELSE request->problem[pchg_inx].data_status_prsnl_id
       ENDIF
       ,
       p.contributor_system_cd =
       IF ((request->problem[pchg_inx].contributor_system_cd=0)) 0
       ELSE request->problem[pchg_inx].contributor_system_cd
       ENDIF
       , p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
       p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
       updt_task
      WITH nocounter
     ;end insert
     IF (curqual <= 0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->problem_list[pchg_inx].problem_instance_id = new_code
      SET reply->problem_list[pchg_inx].problem_id = request->problem[pchg_inx].problem_id
     ENDIF
   ENDFOR
 END ;Subroutine
 GO TO end_program
#error_check
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg_error
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
 ENDIF
 GO TO end_program
#end_program
END GO
