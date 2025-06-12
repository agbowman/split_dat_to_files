CREATE PROGRAM bhs_sys_get_problems_run
 DECLARE output_err_msg(err_msg=vc) = null
 DECLARE get_problems_by_person(null) = i2
 DECLARE get_problems_by_person_reply(null) = i2
 DECLARE cs12030_active_cd = f8 WITH constant(uar_get_code_by("MEANING",12030,"ACTIVE"))
 IF (validate(bhs_problems_req->mode," ")=" ")
  CALL echo("No request mode found. Exitting Script")
  GO TO exit_script
 ELSE
  IF (trim(cnvtlower(bhs_problems_req->mode))="person")
   SET d0 = get_problems_by_person(null)
  ELSE
   SET d0 = output_err_msg(build2("Invalid request mode (",trim(cnvtlower(bhs_problems_req->mode)),
     ") found. Exitting Script"))
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE output_err_msg(err_msg)
   IF ((validate(bhs_problems_reply->p_cnt,- (1))=- (1)))
    CALL echo(trim(err_msg))
   ELSE
    SET bhs_problems_reply->status = - (1)
    SET bhs_problems_reply->errmsg = trim(err_msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_problems_by_person_reply(null)
   FREE RECORD bhs_problems_reply
   RECORD bhs_problems_reply(
     1 p_cnt = i4
     1 persons[*]
       2 person_id = f8
       2 p_cnt = i4
       2 problems[*]
         3 problem_id = f8
         3 problem_instance_id = f8
         3 nomenclature_id = f8
         3 problem = vc
     1 status = i2
     1 errmsg = vc
   ) WITH persist
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_problems_by_person(null)
   IF (get_problems_by_person_reply(null)=0)
    SET d0 = output_err_msg(
     "Unable to create REPLY record structure. Exiting 'get_problems_by_person'")
    RETURN(0)
   ENDIF
   IF (size(bhs_problems_req->persons,5) <= 0)
    SET d0 = output_err_msg("No persons found in bhs_problems_req. Exiting 'get_problems_by_person'")
    RETURN(0)
   ENDIF
   SET stat = alterlist(bhs_problems_reply->persons,size(bhs_problems_req->persons,5))
   SET bhs_problems_reply->p_cnt = size(bhs_problems_reply->persons,5)
   FOR (p = 1 TO bhs_problems_reply->p_cnt)
     SET bhs_problems_reply->persons[p].person_id = bhs_problems_req->persons[p].person_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(bhs_problems_reply->p_cnt)),
     problem p,
     nomenclature n
    PLAN (d)
     JOIN (p
     WHERE (bhs_problems_reply->persons[d.seq].person_id=p.person_id)
      AND p.active_ind=1
      AND p.life_cycle_status_cd=cs12030_active_cd
      AND p.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 23:59:59")
      AND p.cancel_reason_cd <= 0.00)
     JOIN (n
     WHERE outerjoin(p.nomenclature_id)=n.nomenclature_id)
    ORDER BY p.onset_dt_tm, p.problem_id
    HEAD REPORT
     p_cnt = 0
    HEAD p.problem_id
     p_cnt = (bhs_problems_reply->persons[d.seq].p_cnt+ 1), stat = alterlist(bhs_problems_reply->
      persons[d.seq].problems,p_cnt), bhs_problems_reply->persons[d.seq].p_cnt = p_cnt,
     bhs_problems_reply->persons[d.seq].problems[p_cnt].problem_id = p.problem_id, bhs_problems_reply
     ->persons[d.seq].problems[p_cnt].problem_instance_id = p.problem_instance_id
     IF (n.nomenclature_id > 0.0)
      bhs_problems_reply->persons[d.seq].problems[p_cnt].nomenclature_id = n.nomenclature_id,
      bhs_problems_reply->persons[d.seq].problems[p_cnt].problem = n.source_string
     ELSE
      bhs_problems_reply->persons[d.seq].problems[p_cnt].problem = p.problem_ftdesc
     ENDIF
    WITH nocounter
   ;end select
   SET bhs_problems_reply->status = 1
   RETURN(1)
 END ;Subroutine
#exit_script
END GO
