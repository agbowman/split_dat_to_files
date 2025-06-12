CREATE PROGRAM cps_add_problem_discipline:dba
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
 SET table_name = "PROBLEM_DISCIPLINE"
 SET failed = false
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET swarnmsg = fillstring(100," ")
 CALL add_discipline(action_begin,action_end)
 IF (((failed != false) OR (swarnmsg != " ")) )
  GO TO end_program
 ENDIF
 SUBROUTINE add_discipline(add_begin,add_end)
   FOR (pda_inx = add_begin TO add_end)
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
     SET active_code = 0.0
     SELECT INTO "NL:"
      FROM code_value c
      WHERE c.code_set=48
       AND c.cdf_meaning="ACTIVE"
      DETAIL
       active_code = c.code_value
      WITH nocounter
     ;end select
     INSERT  FROM problem_discipline pd
      SET pd.problem_discipline_id = new_code, pd.problem_id = request->problem[prob_index].
       problem_id, pd.management_discipline_cd =
       IF ((request->problem[prob_index].problem_discipline[pda_inx].management_discipline_cd=0)) 0
       ELSE request->problem[prob_index].problem_discipline[pda_inx].management_discipline_cd
       ENDIF
       ,
       pd.active_ind = 1, pd.active_status_cd = active_code, pd.active_status_dt_tm = cnvtdatetime(
        sysdate),
       pd.active_status_prsnl_id = reqinfo->updt_id, pd.beg_effective_dt_tm = cnvtdatetime(request->
        problem[prob_index].problem_discipline[pda_inx].beg_effective_dt_tm), pd.end_effective_dt_tm
        = cnvtdatetime("31-DEC-2100"),
       pd.data_status_cd =
       IF ((request->problem[prob_index].problem_discipline[pda_inx].data_status_cd=0)) 0
       ELSE request->problem[prob_index].problem_discipline[pda_inx].data_status_cd
       ENDIF
       , pd.data_status_dt_tm =
       IF ((request->problem[prob_index].problem_discipline[pda_inx].data_status_dt_tm <= 0)) null
       ELSE cnvtdatetime(request->problem[prob_index].problem_discipline[pda_inx].data_status_dt_tm)
       ENDIF
       , pd.data_status_prsnl_id =
       IF ((request->problem[prob_index].problem_discipline[pda_inx].data_status_prsnl_id=0)) 0
       ELSE request->problem[prob_index].problem_discipline[pda_inx].data_status_prsnl_id
       ENDIF
       ,
       pd.contributor_system_cd =
       IF ((request->problem[prob_index].problem_discipline[pda_inx].contributor_system_cd=0)) 0
       ELSE request->problem[prob_index].problem_discipline[pda_inx].contributor_system_cd
       ENDIF
       , pd.updt_applctx = reqinfo->updt_applctx, pd.updt_cnt = 0,
       pd.updt_dt_tm = cnvtdatetime(sysdate), pd.updt_id = reqinfo->updt_id, pd.updt_task = reqinfo->
       updt_task
      WITH nocounter
     ;end insert
     IF (curqual < 0)
      SET failed = insert_error
      RETURN
     ELSE
      SET failed = false
      SET reply->problem_list[prob_index].discipline_list[pda_inx].problem_discipline_id = new_code
     ENDIF
   ENDFOR
 END ;Subroutine
 GO TO end_program
#end_program
END GO
