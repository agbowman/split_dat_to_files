CREATE PROGRAM cps_upt_problem_discipline:dba
 SET reply->status_data.status = "F"
 SET failed = false
 SET table_name = "PROBLEM_DISCIPLINE"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 CALL upt_discipline(action_begin,action_end)
 IF (failed != false)
  GO TO end_program
 ENDIF
 SUBROUTINE upt_discipline(upt_begin,upt_end)
  FOR (pdchg_inx = upt_begin TO upt_end)
    SELECT INTO "NL:"
     pd.*
     FROM problem_discipline pd
     WHERE (pd.problem_id=request->problem[prob_index].problem_id)
      AND (pd.problem_discipline_id=request->problem[prob_index].problem_discipline[pdchg_inx].
     problem_discipline_id)
     WITH nocounter, forupdate(pd)
    ;end select
    IF (curqual < 0)
     SET failed = lock_error
     RETURN
    ENDIF
    UPDATE  FROM problem_discipline pd
     SET pd.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pd.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), pd.updt_applctx = reqinfo->updt_applctx,
      pd.updt_id = reqinfo->updt_id, pd.updt_task = reqinfo->updt_task
     PLAN (pd
      WHERE (pd.problem_id=request->problem[prob_index].problem_id)
       AND (pd.problem_discipline_id=request->problem[prob_index].problem_discipline[pdchg_inx].
      problem_discipline_id))
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
    INSERT  FROM problem_discipline pd
     SET pd.problem_discipline_id = new_code, pd.problem_id = request->problem[prob_index].problem_id,
      pd.management_discipline_cd =
      IF ((request->problem[prob_index].problem_discipline[pdchg_inx].management_discipline_cd=0)) 0
      ELSE request->problem[prob_index].problem_discipline[pdchg_inx].management_discipline_cd
      ENDIF
      ,
      pd.active_ind = 1, pd.active_status_cd = active_code, pd.active_status_dt_tm = cnvtdatetime(
       curdate,curtime3),
      pd.active_status_prsnl_id = reqinfo->updt_id, pd.beg_effective_dt_tm = cnvtdatetime(request->
       problem[prob_index].problem_discipline[pdchg_inx].beg_effective_dt_tm), pd.end_effective_dt_tm
       = cnvtdatetime("31-DEC-2100"),
      pd.data_status_cd =
      IF ((request->problem[prob_index].problem_discipline[pdchg_inx].data_status_cd=0)) 0
      ELSE request->problem[prob_index].problem_discipline[pdchg_inx].data_status_cd
      ENDIF
      , pd.data_status_dt_tm =
      IF ((request->problem[prob_index].problem_discipline[pdchg_inx].data_status_dt_tm <= 0)) null
      ELSE cnvtdatetime(request->problem[prob_index].problem_discipline[pdchg_inx].data_status_dt_tm)
      ENDIF
      , pd.data_status_prsnl_id =
      IF ((request->problem[prob_index].problem_discipline[pdchg_inx].data_status_prsnl_id=0)) 0
      ELSE request->problem[prob_index].problem_discipline[pdchg_inx].data_status_prsnl_id
      ENDIF
      ,
      pd.contributor_system_cd =
      IF ((request->problem[prob_index].problem_discipline[pdchg_inx].contributor_system_cd=0)) 0
      ELSE request->problem[prob_index].problem_discipline[pdchg_inx].contributor_system_cd
      ENDIF
      , pd.updt_applctx = reqinfo->updt_applctx, pd.updt_cnt = 0,
      pd.updt_dt_tm = cnvtdatetime(curdate,curtime3), pd.updt_id = reqinfo->updt_id, pd.updt_task =
      reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual < 0)
     SET failed = insert_error
     RETURN
    ELSE
     SET failed = false
     SET reply->problem_list[prob_index].discipline_list[pdchg_inx].problem_discipline_id = new_code
    ENDIF
  ENDFOR
  GO TO end_program
 END ;Subroutine
#end_program
END GO
