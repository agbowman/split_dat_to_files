CREATE PROGRAM cps_ens_problem_comment:dba
 SET failed = false
 SET swarnmsg = fillstring(100," ")
 SET serrmsg = fillstring(132," ")
 SET add = 1
 SET upt = 2
 SET del = 3
 SET pc_prob_qual = cnvtint( $1)
 SET comment_qual = request->problem[pc_prob_qual].problem_comment_cnt
 SET active_code = 0.0
 SET code_set = 48
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,"ACTIVE",code_cnt,active_code)
 FOR (pc_inx = 1 TO comment_qual)
   IF ( NOT ((request->problem[pc_prob_qual].problem_comment[pc_inx].beg_effective_dt_tm > 0)))
    SET request->problem[pc_prob_qual].problem_comment[pc_inx].beg_effective_dt_tm = cnvtdatetime(
     current_date)
   ENDIF
   IF ((request->problem[pc_prob_qual].problem_comment[pc_inx].comment_action_ind=upt)
    AND (request->problem[pc_prob_qual].problem_comment[pc_inx].problem_comment_id < 1))
    SET tproblem_comment_id = 0.0
    SELECT INTO "nl:"
     pc.probelm_comment_id
     FROM problem_comment pc
     PLAN (pc
      WHERE (pc.comment_prsnl_id=request->problem[pc_prob_qual].problem_comment[pc_inx].
      comment_prsnl_id)
       AND (pc.problem_id=request->problem[pc_prob_qual].problem_id)
       AND pc.active_ind=1)
     HEAD REPORT
      request->problem[pc_prob_qual].problem_comment[pc_inx].problem_comment_id = pc
      .problem_comment_id
     WITH nocounter
    ;end select
    IF (curqual < 1)
     SET request->problem[pc_prob_qual].problem_comment[pc_inx].comment_action_ind = add
    ENDIF
   ENDIF
   CASE (request->problem[pc_prob_qual].problem_comment[pc_inx].comment_action_ind)
    OF add:
     SET new_code = 0.0
     SELECT INTO "nl:"
      y = seq(problem_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_code = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual < 0)
      SET failed = gen_nbr
      RETURN
     ENDIF
     INSERT  FROM problem_comment pc
      SET pc.problem_id = request->problem[pc_prob_qual].problem_id, pc.problem_comment_id = new_code,
       pc.comment_prsnl_id = request->problem[pc_prob_qual].problem_comment[pc_inx].comment_prsnl_id,
       pc.problem_comment = request->problem[pc_prob_qual].problem_comment[pc_inx].problem_comment,
       pc.comment_dt_tm = cnvtdatetime(curdate,curtime3), pc.active_ind = 1,
       pc.active_status_cd = active_code, pc.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pc
       .active_status_prsnl_id = reqinfo->updt_id,
       pc.beg_effective_dt_tm = cnvtdatetime(request->problem[pc_prob_qual].problem_comment[pc_inx].
        beg_effective_dt_tm), pc.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), pc.data_status_cd
        =
       IF ((request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_cd=0)) 0
       ELSE request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_cd
       ENDIF
       ,
       pc.data_status_dt_tm =
       IF ((request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_dt_tm <= 0)) null
       ELSE cnvtdatetime(request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_dt_tm)
       ENDIF
       , pc.data_status_prsnl_id =
       IF ((request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_prsnl_id=0)) 0
       ELSE request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_prsnl_id
       ENDIF
       , pc.contributor_system_cd =
       IF ((request->problem[pc_prob_qual].problem_comment[pc_inx].contributor_system_cd=0)) 0
       ELSE request->problem[pc_prob_qual].problem_comment[pc_inx].contributor_system_cd
       ENDIF
       ,
       pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0, pc.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual < 0)
      SET failed = insert_error
     ELSE
      SET reply->problem_list[pc_prob_qual].comment_list[pc_inx].problem_comment_id = new_code
      SET failed = false
     ENDIF
     IF (failed != false)
      GO TO end_program
     ENDIF
    OF upt:
     SET request->problem[pc_prob_qual].problem_comment[pc_inx].end_effective_dt_tm = cnvtdatetime(
      curdate,curtime)
     SELECT INTO "NL:"
      pc.problem_comment_id
      FROM problem_comment pc
      WHERE (pc.problem_id=request->problem[pc_prob_qual].problem_id)
       AND (pc.problem_comment_id=request->problem[pc_prob_qual].problem_comment[pc_inx].
      problem_comment_id)
      WITH nocounter, forupdate(pc)
     ;end select
     IF (curqual < 0)
      SET failed = lock_error
     ELSE
      UPDATE  FROM problem_comment pc
       SET pc.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pc.active_ind = 0, pc.updt_dt_tm
         = cnvtdatetime(curdate,curtime3),
        pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task
       PLAN (pc
        WHERE (pc.problem_id=request->problem[pc_prob_qual].problem_id)
         AND (pc.problem_comment_id=request->problem[pc_prob_qual].problem_comment[pc_inx].
        problem_comment_id))
       WITH nocounter
      ;end update
      IF (curqual < 0)
       SET failed = update_error
       GO TO end_program
      ELSE
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
       ELSE
        INSERT  FROM problem_comment pc
         SET pc.problem_id = request->problem[pc_prob_qual].problem_id, pc.problem_comment_id =
          new_code, pc.comment_prsnl_id = request->problem[pc_prob_qual].problem_comment[pc_inx].
          comment_prsnl_id,
          pc.problem_comment = request->problem[pc_prob_qual].problem_comment[pc_inx].problem_comment,
          pc.comment_dt_tm = cnvtdatetime(curdate,curtime3), pc.active_ind = 1,
          pc.active_status_cd = active_code, pc.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
          pc.active_status_prsnl_id = reqinfo->updt_id,
          pc.beg_effective_dt_tm = cnvtdatetime(request->problem[pc_prob_qual].problem_comment[pc_inx
           ].beg_effective_dt_tm), pc.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), pc
          .contributor_system_cd =
          IF ((request->problem[pc_prob_qual].problem_comment[pc_inx].contributor_system_cd=0)) 0
          ELSE request->problem[pc_prob_qual].problem_comment[pc_inx].contributor_system_cd
          ENDIF
          ,
          pc.data_status_cd =
          IF ((request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_cd=0)) 0
          ELSE request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_cd
          ENDIF
          , pc.data_status_dt_tm =
          IF ((request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_dt_tm <= 0)) null
          ELSE cnvtdatetime(request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_dt_tm)
          ENDIF
          , pc.data_status_prsnl_id =
          IF ((request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_prsnl_id=0)) 0
          ELSE request->problem[pc_prob_qual].problem_comment[pc_inx].data_status_prsnl_id
          ENDIF
          ,
          pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0, pc.updt_dt_tm = cnvtdatetime(
           curdate,curtime3),
          pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task
         WITH nocounter
        ;end insert
        IF (curqual < 0)
         SET failed = insert_error
         GO TO end_program
        ELSE
         SET reply->problem_list[pc_prob_qual].comment_list[pc_inx].problem_comment_id = new_code
         SET failed = false
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF (failed != false)
      GO TO end_program
     ENDIF
   ENDCASE
 ENDFOR
 GO TO end_program
#end_program
END GO
