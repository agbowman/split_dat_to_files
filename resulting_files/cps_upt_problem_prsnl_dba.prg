CREATE PROGRAM cps_upt_problem_prsnl:dba
 SET reply->status_data.status = "F"
 SET failed = false
 SET table_name = "PROBLEM_PRSNL"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET swarnmsg = fillstring(100," ")
 CALL upt_prsnl(action_begin,action_end)
 IF (((failed != false) OR (swarnmsg != "  ")) )
  GO TO end_program
 ENDIF
 SUBROUTINE upt_prsnl(upt_begin,upt_end)
  FOR (pprchg_inx = action_begin TO action_end)
    SELECT INTO "NL:"
     ppr.*
     FROM problem_prsnl_r ppr
     WHERE (ppr.problem_id=request->problem[prob_index].problem_id)
      AND (ppr.problem_prsnl_id=request->problem[prob_index].problem_prsnl[pprchg_inx].
     problem_prsnl_id)
     WITH nocounter, forupdate(ppr)
    ;end select
    IF (curqual <= 0)
     SET failed = lock_error
     SET reply->swarnmsg = "Failed to lock any rows"
     RETURN
    ENDIF
    CALL echo(build("LOCK SUCCESS"))
    UPDATE  FROM problem_prsnl_r ppr
     SET ppr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), ppr.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), ppr.updt_id = reqinfo->updt_id,
      ppr.updt_task = reqinfo->updt_task
     PLAN (ppr
      WHERE (ppr.problem_id=request->problem[prob_index].problem_id)
       AND (ppr.problem_prsnl_id=request->problem[prob_index].problem_prsnl[pprchg_inx].
      problem_prsnl_id))
     WITH nocounter
    ;end update
    IF (curqual <= 0)
     SET failed = update_error
     RETURN
    ENDIF
    CALL echo("UPDATE SUCCESS")
    SELECT INTO "NL:"
     p.*
     FROM prsnl p
     WHERE (p.person_id=request->problem[prob_index].problem_prsnl[pprchg_inx].problem_reltn_prsnl_id
     )
      AND p.active_ind=1
    ;end select
    IF (curqual <= 0)
     SET failed = none_found
     SET swarnmsg = "PRSNL not existing!!"
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
    IF (curqual <= 0)
     SET failed = gen_nbr_error
     RETURN
    ENDIF
    INSERT  FROM problem_prsnl_r ppr
     SET ppr.problem_id = request->problem[prob_index].problem_id, ppr.problem_prsnl_id = new_code,
      ppr.problem_reltn_prsnl_id = request->problem[prob_index].problem_prsnl[pprchg_inx].
      problem_reltn_prsnl_id,
      ppr.problem_reltn_cd = request->problem[prob_index].problem_prsnl[pprchg_inx].problem_reltn_cd,
      ppr.problem_reltn_dt_tm = cnvtdatetime(curdate,curtime3), ppr.active_ind = 1,
      ppr.active_status_cd = active_code, ppr.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      ppr.active_status_prsnl_id = reqinfo->updt_id,
      ppr.beg_effective_dt_tm = cnvtdatetime(request->problem[prob_index].problem_prsnl[pprchg_inx].
       beg_effective_dt_tm), ppr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ppr
      .contributor_system_cd =
      IF ((request->problem[prob_index].problem_prsnl[pprchg_inx].contributor_system_cd=0)) 0
      ELSE request->problem[prob_index].problem_prsnl[pprchg_inx].contributor_system_cd
      ENDIF
      ,
      ppr.data_status_cd =
      IF ((request->problem[prob_index].problem_prsnl[pprchg_inx].data_status_cd=0)) 0
      ELSE request->problem[prob_index].problem_prsnl[pprchg_inx].data_status_cd
      ENDIF
      , ppr.data_status_dt_tm =
      IF ((request->problem[prob_index].problem_prsnl[pprchg_inx].data_status_dt_tm <= 0)) null
      ELSE cnvtdatetime(request->problem[prob_index].problem_prsnl[pprchg_inx].data_status_dt_tm)
      ENDIF
      , ppr.data_status_prsnl_id =
      IF ((request->problem[prob_index].problem_prsnl[pprchg_inx].data_status_prsnl_id=0)) 0
      ELSE request->problem[prob_index].problem_prsnl[pprchg_inx].data_status_prsnl_id
      ENDIF
      ,
      ppr.updt_applctx = reqinfo->updt_applctx, ppr.updt_cnt = 0, ppr.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      ppr.updt_id = reqinfo->updt_id, ppr.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual < 0)
     CALL echo(build("Error in PPRCHG"))
     SET failed = insert_error
     RETURN
    ELSE
     CALL echo(build("Success in PPRCHG"))
     SET failed = false
     SET reply->problem_list[prob_index].prsnl_list[pprchg_inx].problem_prsnl_id = new_code
    ENDIF
  ENDFOR
  GO TO end_program
 END ;Subroutine
#end_program
END GO
