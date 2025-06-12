CREATE PROGRAM cps_add_problem:dba
 SET failed = false
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 CALL add_problem(action_begin,action_end)
 IF (((failed != false) OR (swarnmsg != " ")) )
  CALL echo(swarnmsg)
  GO TO end_program
 ENDIF
 SUBROUTINE add_problem(add_begin,add_end)
   FOR (i = add_begin TO add_end)
     IF ((request->problem[i].nomenclature_id > 0))
      SELECT INTO "NL:"
       p.problem_id
       FROM problem p
       PLAN (p
        WHERE (p.person_id=request->person_id)
         AND (p.nomenclature_id=request->problem[i].nomenclature_id)
         AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
         AND (p.life_cycle_status_cd=request->problem[i].life_cycle_status_cd))
      ;end select
      IF (curqual > 0)
       SET failed = true
       SET swarnmsg = "This problem already exists !!"
       RETURN
      ENDIF
     ELSE
      SELECT INTO "NL:"
       p.problem_id
       FROM problem p
       PLAN (p
        WHERE (p.person_id=request->person_id)
         AND (p.problem_ftdesc=request->problem[i].problem_ftdesc)
         AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
         AND (p.life_cycle_status_cd=request->problem[i].life_cycle_status_cd))
      ;end select
      IF (curqual > 0)
       SET failed = true
       SET swarnmsg = "This problem already exists !!"
       RETURN
      ENDIF
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
     ELSE
      SET request->problem[i].problem_id = new_code
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
     SET table_name = "PROBLEM"
     INSERT  FROM problem p
      SET p.problem_instance_id = new_code, p.problem_id = request->problem[i].problem_id, p
       .nomenclature_id =
       IF ((request->problem[i].nomenclature_id=0)) 0.00
       ELSE request->problem[i].nomenclature_id
       ENDIF
       ,
       p.person_id = request->person_id, p.problem_ftdesc =
       IF ((request->problem[i].problem_ftdesc=" ")) null
       ELSE request->problem[i].problem_ftdesc
       ENDIF
       , p.estimated_resolution_dt_tm =
       IF ((request->problem[i].estimated_resolution_dt_tm=0)) null
       ELSE cnvtdatetime(request->problem[i].estimated_resolution_dt_tm)
       ENDIF
       ,
       p.actual_resolution_dt_tm =
       IF ((request->problem[i].actual_resolution_dt_tm=0)) null
       ELSE cnvtdatetime(request->problem[i].actual_resolution_dt_tm)
       ENDIF
       , p.classification_cd =
       IF ((request->problem[i].classification_cd=0)) 0.00
       ELSE request->problem[i].classification_cd
       ENDIF
       , p.persistence_cd =
       IF ((request->problem[i].persistence_cd=0)) 0.00
       ELSE request->problem[i].persistence_cd
       ENDIF
       ,
       p.confirmation_status_cd = request->problem[i].confirmation_status_cd, p.life_cycle_status_cd
        = request->problem[i].life_cycle_status_cd, p.life_cycle_dt_tm = cnvtdatetime(curdate,
        curtime3),
       p.onset_dt_cd = request->problem[i].onset_dt_cd, p.onset_dt_tm = cnvtdatetime(request->
        problem[i].onset_dt_tm), p.ranking_cd =
       IF ((request->problem[i].ranking_cd=0)) 0
       ELSE request->problem[i].ranking_cd
       ENDIF
       ,
       p.certainty_cd =
       IF ((request->problem[i].certainty_cd=0)) 0
       ELSE request->problem[i].certainty_cd
       ENDIF
       , p.probability =
       IF ((request->problem[i].probability=0)) null
       ELSE request->problem[i].probability
       ENDIF
       , p.person_aware_cd =
       IF ((request->problem[i].person_aware_cd=0)) 0
       ELSE request->problem[i].person_aware_cd
       ENDIF
       ,
       p.prognosis_cd =
       IF ((request->problem[i].prognosis_cd=0)) 0
       ELSE request->problem[i].prognosis_cd
       ENDIF
       , p.person_aware_prognosis_cd =
       IF ((request->problem[i].person_aware_prognosis_cd=0)) 0
       ELSE request->problem[i].person_aware_prognosis_cd
       ENDIF
       , p.family_aware_cd =
       IF ((request->problem[i].family_aware_cd=0)) 0
       ELSE request->problem[i].family_aware_cd
       ENDIF
       ,
       p.sensitivity =
       IF ((request->problem[i].sensitivity=0)) null
       ELSE request->problem[i].sensitivity
       ENDIF
       , p.course_cd =
       IF ((request->problem[i].course_cd=0)) 0
       ELSE request->problem[i].course_cd
       ENDIF
       , p.cancel_reason_cd =
       IF ((request->problem[i].cancel_reason_cd=0)) 0
       ELSE request->problem[i].cancel_reason_cd
       ENDIF
       ,
       p.active_ind = 1, p.active_status_cd = active_code, p.active_status_dt_tm = cnvtdatetime(
        curdate,curtime3),
       p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(request->
        problem[i].beg_effective_dt_tm), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       p.data_status_cd =
       IF ((request->problem[i].data_status_cd=0)) 0
       ELSE request->problem[i].data_status_cd
       ENDIF
       , p.data_status_dt_tm =
       IF ((request->problem[i].data_status_dt_tm <= 0)) null
       ELSE cnvtdatetime(request->problem[i].data_status_dt_tm)
       ENDIF
       , p.data_status_prsnl_id =
       IF ((request->problem[i].data_status_prsnl_id=0)) 0
       ELSE request->problem[i].data_status_prsnl_id
       ENDIF
       ,
       p.contributor_system_cd =
       IF ((request->problem[i].contributor_system_cd=0)) 0
       ELSE request->problem[i].contributor_system_cd
       ENDIF
       , p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
       p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
       reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual <= 0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->problem_list[i].problem_id = request->problem[i].problem_id
      SET reply->problem_list[i].problem_instance_id = new_code
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
