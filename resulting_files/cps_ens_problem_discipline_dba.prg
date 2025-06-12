CREATE PROGRAM cps_ens_problem_discipline:dba
 SET add = 1
 SET upt = 2
 SET del = 3
 SET p_cnt = cnvtint( $1)
 SET pd_cnt = size(request->problem[p_cnt].problem_discipline,5)
 SET active_code = 0.0
 SET inactive_code = 0.0
 SET code_cnt = 1
 SET code_set = 48
 SET stat = uar_get_meaning_by_codeset(code_set,"ACTIVE",code_cnt,active_code)
 SET stat = uar_get_meaning_by_codeset(code_set,"INACTIVE",code_cnt,inactive_code)
 FOR (i = 1 TO pd_cnt)
   IF ( NOT ((request->problem[p_cnt].problem_discipline[i].beg_effective_dt_tm > 0)))
    SET request->problem[p_cnt].problem_discipline[i].beg_effective_dt_tm = cnvtdatetime(current_date
     )
   ENDIF
   SET problem_discipline_id = 0
   SELECT INTO "nl:"
    FROM problem_discipline pd
    WHERE (pd.problem_id=request->problem[p_cnt].problem_id)
     AND (pd.management_discipline_cd=request->problem[p_cnt].problem_discipline[i].
    management_discipline_cd)
     AND pd.active_ind=1
     AND pd.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pd.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     problem_discipline_id = pd.problem_discipline_id
    WITH forupdate(pd)
   ;end select
   IF ((request->problem[p_cnt].problem_discipline[i].discipline_action_ind=del))
    IF (curqual > 0)
     UPDATE  FROM problem_discipline pd
      SET pd.active_ind = 0, pd.active_status_cd = inactive_code, pd.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       pd.active_status_prsnl_id = reqinfo->updt_id, pd.end_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), pd.updt_cnt = (pd.updt_cnt+ 1),
       pd.updt_dt_tm = cnvtdatetime(curdate,curtime3), pd.updt_id = reqinfo->updt_id, pd.updt_applctx
        = reqinfo->updt_applctx,
       pd.updt_task = reqinfo->updt_task
      WHERE pd.problem_discipline_id=problem_discipline_id
     ;end update
     SET reply->problem_list[p_cnt].discipline_list[i].problem_discipline_id = problem_discipline_id
     SET reply->problem_list[p_cnt].discipline_list[i].management_discipline_cd = request->problem[
     p_cnt].problem_discipline[i].management_discipline_cd
    ENDIF
    IF (curqual=0)
     SET reply->problem_list[p_cnt].discipline_list[i].problem_discipline_id = problem_discipline_id
     SET reply->problem_list[p_cnt].discipline_list[i].management_discipline_cd = request->problem[
     p_cnt].problem_discipline[i].management_discipline_cd
     SET reply->problem_list[p_cnt].discipline_list[i].sreturnmsg = "ERROR:  Failed to Update row."
    ENDIF
   ELSE
    IF (curqual=0)
     SET new_code = 0.0
     SELECT INTO "nl:"
      y = seq(problem_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_code = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET reply->problem_list[p_cnt].discipline_list[i].problem_discipline_id = 0
      SET reply->problem_list[p_cnt].discipline_list[i].management_discipline_cd = request->problem[
      p_cnt].problem_discipline[i].management_discipline_cd
      SET reply->problem_list[p_cnt].discipline_list[i].sreturnmsg =
      "ERROR:  Failed to Generate Next Sequence."
     ELSE
      INSERT  FROM problem_discipline pd
       SET pd.problem_discipline_id = new_code, pd.problem_id = request->problem[p_cnt].problem_id,
        pd.management_discipline_cd = request->problem[p_cnt].problem_discipline[i].
        management_discipline_cd,
        pd.active_ind = 1, pd.active_status_cd = active_code, pd.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        pd.active_status_prsnl_id = reqinfo->updt_id, pd.beg_effective_dt_tm =
        IF ((request->problem[p_cnt].problem_discipline[i].beg_effective_dt_tm <= 0)) cnvtdatetime(
          curdate,curtime3)
        ELSE cnvtdatetime(request->problem[p_cnt].problem_discipline[i].beg_effective_dt_tm)
        ENDIF
        , pd.end_effective_dt_tm =
        IF ((request->problem[p_cnt].problem_discipline[i].end_effective_dt_tm <= 0)) cnvtdatetime(
          "31-DEC-2100 00:00:00.00")
        ELSE cnvtdatetime(request->problem[p_cnt].problem_discipline[i].end_effective_dt_tm)
        ENDIF
        ,
        pd.data_status_cd =
        IF ((request->problem[p_cnt].problem_discipline[i].data_status_cd=0)) 0
        ELSE request->problem[p_cnt].problem_discipline[i].data_status_cd
        ENDIF
        , pd.data_status_dt_tm =
        IF ((request->problem[p_cnt].problem_discipline[i].data_status_dt_tm <= 0)) null
        ELSE cnvtdatetime(request->problem[p_cnt].problem_discipline[i].data_status_dt_tm)
        ENDIF
        , pd.data_status_prsnl_id =
        IF ((request->problem[p_cnt].problem_discipline[i].data_status_prsnl_id=0)) 0
        ELSE request->problem[p_cnt].problem_discipline[i].data_status_prsnl_id
        ENDIF
        ,
        pd.contributor_system_cd =
        IF ((request->problem[p_cnt].problem_discipline[i].contributor_system_cd=0)) 0
        ELSE request->problem[p_cnt].problem_discipline[i].contributor_system_cd
        ENDIF
        , pd.updt_applctx = reqinfo->updt_applctx, pd.updt_cnt = 0,
        pd.updt_dt_tm = cnvtdatetime(curdate,curtime3), pd.updt_id = reqinfo->updt_id, pd.updt_task
         = reqinfo->updt_task
       WITH nocounter
      ;end insert
      SET reply->problem_list[p_cnt].discipline_list[i].problem_discipline_id = new_code
      SET reply->problem_list[p_cnt].discipline_list[i].management_discipline_cd = request->problem[
      p_cnt].problem_discipline[i].management_discipline_cd
      IF (curqual=0)
       SET reply->problem_list[p_cnt].discipline_list[i].sreturnmsg = "ERROR:  Failed to Insert row."
      ELSE
       SET reply->problem_list[p_cnt].discipline_list[i].sreturnmsg = ""
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 GO TO end_program
#end_program
END GO
