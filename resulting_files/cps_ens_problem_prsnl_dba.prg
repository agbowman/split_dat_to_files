CREATE PROGRAM cps_ens_problem_prsnl:dba
 SET add = 1
 SET upt = 2
 SET del = 3
 SET p_cnt = cnvtint( $1)
 SET pp_cnt = size(request->problem[p_cnt].problem_prsnl,5)
 SET active_code = 0.0
 SET inactive_code = 0.0
 SET recorder_code = 0.0
 SET problem_prsnl_id = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET code_set = 48
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,"ACTIVE",code_cnt,active_code)
 SET stat = uar_get_meaning_by_codeset(code_set,"INACTIVE",code_cnt,inactive_code)
 SET code_set = 12038
 SET stat = uar_get_meaning_by_codeset(code_set,"RECORDER",code_cnt,recorder_code)
 SET r_index = - (1)
 SELECT INTO "nl:"
  FROM problem_prsnl_r pp
  WHERE (pp.problem_id=request->problem[p_cnt].problem_id)
   AND pp.problem_reltn_cd=recorder_code
   AND pp.active_ind=1
   AND pp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND pp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   problem_prsnl_id = pp.problem_prsnl_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  FOR (i = 1 TO pp_cnt)
    IF ((request->problem[p_cnt].problem_prsnl[i].problem_reltn_cd=recorder_code))
     SET r_index = i
    ENDIF
  ENDFOR
  IF ((r_index=- (1)))
   SET r_index = 0
   SET stat = alterlist(reply->problem_list[p_cnt].prsnl_list,(pp_cnt+ 1))
  ENDIF
  SET new_code = 0.0
  SELECT INTO "nl:"
   y = seq(problem_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    new_code = cnvtreal(y)
   WITH format, counter
  ;end select
  IF (curqual=0)
   SET reply->problem_list[p_cnt].prsnl_list[1].problem_prsnl_id = 0
   SET reply->problem_list[p_cnt].prsnl_list[1].problem_reltn_cd = recorder_code
   SET reply->problem_list[p_cnt].prsnl_list[1].sreturnmsg =
   "ERROR:  Failed to Generate Next Sequence."
  ELSE
   IF ( NOT ((request->problem[p_cnt].problem_prsnl[r_index].beg_effective_dt_tm > 0)))
    SET request->problem[p_cnt].problem_prsnl[r_index].beg_effective_dt_tm = cnvtdatetime(
     current_date)
   ENDIF
   INSERT  FROM problem_prsnl_r pp
    SET pp.problem_prsnl_id = new_code, pp.problem_id = request->problem[p_cnt].problem_id, pp
     .problem_reltn_cd = recorder_code,
     pp.problem_reltn_dt_tm = cnvtdatetime(curdate,curtime3), pp.problem_reltn_prsnl_id =
     IF (r_index > 0)
      IF ((request->problem[p_cnt].problem_prsnl[r_index].problem_reltn_prsnl_id < 1)) reqinfo->
       updt_id
      ELSE request->problem[p_cnt].problem_prsnl[r_index].problem_reltn_prsnl_id
      ENDIF
     ELSE reqinfo->updt_id
     ENDIF
     , pp.active_ind = 1,
     pp.active_status_cd = active_code, pp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pp
     .active_status_prsnl_id = reqinfo->updt_id,
     pp.beg_effective_dt_tm =
     IF (r_index > 0)
      IF ((request->problem[p_cnt].problem_prsnl[r_index].beg_effective_dt_tm <= 0)) cnvtdatetime(
        curdate,curtime3)
      ELSE cnvtdatetime(request->problem[p_cnt].problem_prsnl[r_index].beg_effective_dt_tm)
      ENDIF
     ELSE cnvtdatetime(curdate,curtime3)
     ENDIF
     , pp.end_effective_dt_tm =
     IF (r_index > 0)
      IF ((request->problem[p_cnt].problem_prsnl[r_index].end_effective_dt_tm <= 0)) cnvtdatetime(
        "31-DEC-2100 00:00:00.00")
      ELSE cnvtdatetime(request->problem[p_cnt].problem_prsnl[r_index].end_effective_dt_tm)
      ENDIF
     ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
     ENDIF
     , pp.data_status_cd =
     IF (r_index > 0)
      IF ((request->problem[p_cnt].problem_prsnl[r_index].data_status_cd=0)) 0
      ELSE request->problem[p_cnt].problem_prsnl[r_index].data_status_cd
      ENDIF
     ELSE 0
     ENDIF
     ,
     pp.data_status_dt_tm =
     IF (r_index > 0)
      IF ((request->problem[p_cnt].problem_prsnl[r_index].data_status_dt_tm <= 0)) null
      ELSE cnvtdatetime(request->problem[p_cnt].problem_prsnl[r_index].data_status_dt_tm)
      ENDIF
     ELSE null
     ENDIF
     , pp.data_status_prsnl_id =
     IF (r_index > 0)
      IF ((request->problem[p_cnt].problem_prsnl[r_index].data_status_prsnl_id=0)) 0
      ELSE request->problem[p_cnt].problem_prsnl[r_index].data_status_prsnl_id
      ENDIF
     ELSE 0
     ENDIF
     , pp.contributor_system_cd =
     IF (r_index > 0)
      IF ((request->problem[p_cnt].problem_prsnl[r_index].contributor_system_cd=0)) 0
      ELSE request->problem[p_cnt].problem_prsnl[r_index].contributor_system_cd
      ENDIF
     ELSE 0
     ENDIF
     ,
     pp.updt_applctx = reqinfo->updt_applctx, pp.updt_cnt = 0, pp.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     pp.updt_id = reqinfo->updt_id, pp.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET reply->problem_list[p_cnt].prsnl_list[1].problem_prsnl_id = new_code
   SET reply->problem_list[p_cnt].prsnl_list[1].problem_reltn_cd = recorder_code
   IF (curqual=0)
    SET reply->problem_list[p_cnt].prsnl_list[1].sreturnmsg = "ERROR:  Failed to Insert row."
   ELSE
    SET reply->problem_list[p_cnt].prsnl_list[1].sreturnmsg = ""
   ENDIF
  ENDIF
 ENDIF
 IF (r_index=0)
  SET a = 1
 ELSE
  SET a = 0
 ENDIF
 FOR (i = 1 TO pp_cnt)
   SET a = (a+ 1)
   IF ( NOT ((request->problem[p_cnt].problem_prsnl[i].beg_effective_dt_tm > 0)))
    SET request->problem[p_cnt].problem_prsnl[i].beg_effective_dt_tm = cnvtdatetime(current_date)
   ENDIF
   SET problem_prsnl_id = 0
   SET new_code = 0.0
   SELECT INTO "nl:"
    FROM problem_prsnl_r pp
    WHERE (pp.problem_id=request->problem[p_cnt].problem_id)
     AND (pp.problem_prsnl_id=request->problem[p_cnt].problem_prsnl[i].problem_prsnl_id)
     AND (pp.problem_reltn_cd=request->problem[p_cnt].problem_prsnl[i].problem_reltn_cd)
     AND pp.active_ind=1
     AND pp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     problem_prsnl_id = pp.problem_prsnl_id
    WITH forupdate(pp)
   ;end select
   IF ((request->problem[p_cnt].problem_prsnl[i].prsnl_action_ind=del))
    IF (curqual > 0
     AND (request->problem[p_cnt].problem_prsnl[i].problem_reltn_cd != recorder_code))
     UPDATE  FROM problem_prsnl_r pp
      SET pp.active_ind = 0, pp.active_status_cd = inactive_code, pp.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       pp.active_status_prsnl_id = reqinfo->updt_id, pp.end_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), pp.updt_cnt = (pp.updt_cnt+ 1),
       pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id, pp.updt_applctx
        = reqinfo->updt_applctx,
       pp.updt_task = reqinfo->updt_task
      WHERE pp.problem_prsnl_id=problem_prsnl_id
     ;end update
     SET reply->problem_list[p_cnt].prsnl_list[a].problem_prsnl_id = problem_prsnl_id
     SET reply->problem_list[p_cnt].prsnl_list[a].problem_reltn_cd = request->problem[p_cnt].
     problem_prsnl[i].problem_reltn_cd
    ENDIF
    IF (((curqual=0) OR ((request->problem[p_cnt].problem_prsnl[i].problem_reltn_cd=recorder_code)))
    )
     SET reply->problem_list[p_cnt].prsnl_list[a].problem_prsnl_id = problem_prsnl_id
     SET reply->problem_list[p_cnt].prsnl_list[a].problem_reltn_cd = request->problem[p_cnt].
     problem_prsnl[i].problem_reltn_cd
     IF ((request->problem[p_cnt].problem_prsnl[i].problem_reltn_cd=recorder_code))
      SET reply->problem_list[p_cnt].prsnl_list[a].sreturnmsg = "WARNING:  Can not Remove Recorder."
     ELSE
      SET reply->problem_list[p_cnt].prsnl_list[a].sreturnmsg = "ERROR:  Failed to Update row."
     ENDIF
    ENDIF
   ELSEIF (curqual=0
    AND (request->problem[p_cnt].problem_prsnl[i].problem_reltn_cd != recorder_code))
    SELECT INTO "nl:"
     y = seq(problem_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_code = cnvtreal(y)
     WITH format, counter
    ;end select
    IF (curqual=0)
     SET reply->problem_list[p_cnt].prsnl_list[a].problem_prsnl_id = 0
     SET reply->problem_list[p_cnt].prsnl_list[a].problem_reltn_cd = request->problem[p_cnt].
     problem_prsnl[i].problem_reltn_cd
     SET reply->problem_list[p_cnt].prsnl_list[a].sreturnmsg =
     "ERROR:  Failed to Generate Next Sequence."
    ELSE
     IF ( NOT ((request->problem[p_cnt].problem_prsnl[i].beg_effective_dt_tm > 0)))
      SET request->problem[p_cnt].problem_prsnl[i].beg_effective_dt_tm = cnvtdatetime(current_date)
     ENDIF
     INSERT  FROM problem_prsnl_r pp
      SET pp.problem_prsnl_id = new_code, pp.problem_id = request->problem[p_cnt].problem_id, pp
       .problem_reltn_cd = request->problem[p_cnt].problem_prsnl[i].problem_reltn_cd,
       pp.problem_reltn_dt_tm =
       IF ((request->problem[p_cnt].problem_prsnl[i].problem_reltn_dt_tm <= 0)) cnvtdatetime(curdate,
         curtime3)
       ELSE cnvtdatetime(request->problem[p_cnt].problem_prsnl[i].problem_reltn_dt_tm)
       ENDIF
       , pp.problem_reltn_prsnl_id =
       IF ((request->problem[p_cnt].problem_prsnl[i].problem_reltn_prsnl_id=0)) reqinfo->updt_id
       ELSE request->problem[p_cnt].problem_prsnl[i].problem_reltn_prsnl_id
       ENDIF
       , pp.active_ind = 1,
       pp.active_status_cd = active_code, pp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pp
       .active_status_prsnl_id = reqinfo->updt_id,
       pp.beg_effective_dt_tm =
       IF ((request->problem[p_cnt].problem_prsnl[i].beg_effective_dt_tm <= 0)) cnvtdatetime(curdate,
         curtime3)
       ELSE cnvtdatetime(request->problem[p_cnt].problem_prsnl[i].beg_effective_dt_tm)
       ENDIF
       , pp.end_effective_dt_tm =
       IF ((request->problem[p_cnt].problem_prsnl[i].end_effective_dt_tm <= 0)) cnvtdatetime(
         "31-DEC-2100 00:00:00.00")
       ELSE cnvtdatetime(request->problem[p_cnt].problem_prsnl[i].end_effective_dt_tm)
       ENDIF
       , pp.data_status_cd =
       IF ((request->problem[p_cnt].problem_prsnl[i].data_status_cd=0)) 0
       ELSE request->problem[p_cnt].problem_prsnl[i].data_status_cd
       ENDIF
       ,
       pp.data_status_dt_tm =
       IF ((request->problem[p_cnt].problem_prsnl[i].data_status_dt_tm <= 0)) null
       ELSE cnvtdatetime(request->problem[p_cnt].problem_prsnl[i].data_status_dt_tm)
       ENDIF
       , pp.data_status_prsnl_id =
       IF ((request->problem[p_cnt].problem_prsnl[i].data_status_prsnl_id=0)) 0
       ELSE request->problem[p_cnt].problem_prsnl[i].data_status_prsnl_id
       ENDIF
       , pp.contributor_system_cd =
       IF ((request->problem[p_cnt].problem_prsnl[i].contributor_system_cd=0)) 0
       ELSE request->problem[p_cnt].problem_prsnl[i].contributor_system_cd
       ENDIF
       ,
       pp.updt_applctx = reqinfo->updt_applctx, pp.updt_cnt = 0, pp.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       pp.updt_id = reqinfo->updt_id, pp.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     SET reply->problem_list[p_cnt].prsnl_list[a].problem_prsnl_id = new_code
     SET reply->problem_list[p_cnt].prsnl_list[a].problem_reltn_cd = request->problem[p_cnt].
     problem_prsnl[i].problem_reltn_cd
     IF (curqual=0)
      SET reply->problem_list[p_cnt].prsnl_list[a].sreturnmsg = "ERROR:  Failed to Insert row."
     ELSE
      SET reply->problem_list[p_cnt].prsnl_list[a].sreturnmsg = ""
     ENDIF
    ENDIF
   ELSE
    SET reply->problem_list[p_cnt].prsnl_list[a].problem_prsnl_id = new_code
    SET reply->problem_list[p_cnt].prsnl_list[a].problem_reltn_cd = request->problem[p_cnt].
    problem_prsnl[i].problem_reltn_cd
    SET reply->problem_list[p_cnt].prsnl_list[a].sreturnmsg = ""
   ENDIF
 ENDFOR
 GO TO end_program
#end_program
END GO
