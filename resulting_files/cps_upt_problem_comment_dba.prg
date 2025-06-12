CREATE PROGRAM cps_upt_problem_comment:dba
 SET table_name = "PROBLEM_COMMENT"
 SET failed = false
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET swarnmsg = fillstring(100," ")
 CALL upt_comment(action_begin,action_end)
 IF (((failed != false) OR (swarnmsg != " ")) )
  GO TO end_program
 ENDIF
 SUBROUTINE upt_comment(upt_begin,upt_end)
   FOR (pc_chg_inx = upt_begin TO upt_end)
     SELECT INTO "NL:"
      pc.*
      FROM problem_comment pc
      WHERE (pc.problem_id=request->problem[prob_index].problem_id)
       AND (pc.problem_comment_id=request->problem[prob_index].problem_comment[pc_chg_inx].
      problem_comment_id)
      WITH nocounter, forupdate(pc)
     ;end select
     IF (curqual < 0)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM problem_comment pc
      SET pc.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), pc.updt_id = reqinfo->updt_id,
       pc.updt_task = reqinfo->updt_task
      PLAN (pc
       WHERE (pc.problem_id=request->problem[prob_index].problem_id)
        AND (pc.problem_comment_id=request->problem[prob_index].problem_comment[pc_chg_inx].
       problem_comment_id))
      WITH nocounter
     ;end update
     IF (curqual < 0)
      SET failed = update_error
      GO TO error_check
     ENDIF
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
      GO TO error_check
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
     INSERT  FROM problem_comment pc
      SET pc.problem_id = request->problem[prob_index].problem_id, pc.problem_comment_id = new_code,
       pc.comment_prsnl_id = request->problem[prob_index].problem_comment[pc_chg_inx].
       comment_prsnl_id,
       pc.problem_comment = request->problem[prob_index].problem_comment[pc_chg_inx].problem_comment,
       pc.comment_dt_tm = cnvtdatetime(curdate,curtime3), pc.active_ind = 1,
       pc.active_status_cd = active_code, pc.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pc
       .active_status_prsnl_id = reqinfo->updt_id,
       pc.beg_effective_dt_tm = cnvtdatetime(request->problem[prob_index].problem_comment[pc_chg_inx]
        .beg_effective_dt_tm), pc.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), pc
       .contributor_system_cd =
       IF ((request->problem[prob_index].problem_comment[pc_chg_inx].contributor_system_cd=0)) 0
       ELSE request->problem[prob_index].problem_comment[pc_chg_inx].contributor_system_cd
       ENDIF
       ,
       pc.data_status_cd =
       IF ((request->problem[prob_index].problem_comment[pc_chg_inx].data_status_cd=0)) 0
       ELSE request->problem[prob_index].problem_comment[pc_chg_inx].data_status_cd
       ENDIF
       , pc.data_status_dt_tm =
       IF ((request->problem[prob_index].problem_comment[pc_chg_inx].data_status_dt_tm <= 0)) null
       ELSE cnvtdatetime(request->problem[prob_index].problem_comment[pc_chg_inx].data_status_dt_tm)
       ENDIF
       , pc.data_status_prsnl_id =
       IF ((request->problem[prob_index].problem_comment[pc_chg_inx].data_status_prsnl_id=0)) 0
       ELSE request->problem[prob_index].problem_comment[pc_chg_inx].data_status_prsnl_id
       ENDIF
       ,
       pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0, pc.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual < 0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->problem_list[prob_index].comment_list[pc_chg_inx].problem_comment_id = new_code
      SET failed = false
     ENDIF
   ENDFOR
 END ;Subroutine
 GO TO end_program
#end_program
END GO
