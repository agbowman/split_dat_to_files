CREATE PROGRAM cps_ens_problem:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 person_id = f8
   1 problem_list[*]
     2 problem_id = f8
     2 problem_instance_id = f8
     2 problem_ftdesc = vc
     2 nomenclature_id = f8
     2 sreturnmsg = vc
     2 comment_list[*]
       3 problem_comment_id = f8
     2 discipline_list[*]
       3 problem_discipline_id = f8
       3 management_discipline_cd = f8
       3 sreturnmsg = vc
     2 prsnl_list[*]
       3 problem_prsnl_id = f8
       3 problem_reltn_cd = f8
       3 sreturnmsg = vc
   1 swarnmsg = c100
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET swarnmsg = fillstring(100," ")
 SET reply->swarnmsg = fillstring(100," ")
 SET add = 1
 SET upt = 2
 SET del = 3
 SET force_add = 4
 SET force_upt = 5
 SET qual = request->problem_cnt
 SET reply->person_id = request->person_id
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->problem_list,qual)
 SET current_date = cnvtdatetime(curdate,curtime3)
 SET do_upt = false
 SET tproblem_id = 0.0
 SET dvar = 0
 SET cdf_meaning = fillstring(12," ")
 SET ob_trigger_on = false
 SET new_code = 0.0
 SET existing_interface_problem = false
 SET do_ob_add = false
 SET do_ob_upd = false
 SET do_ob_del = false
 SET obaknt = 0
 SET obuknt = 0
 SET obdknt = 0
 SET obakntc = 0
 SET obukntc = 0
 SET obakntd = 0
 SET obukntd = 0
 SET obakntp = 0
 SET obukntp = 0
 DECLARE user_tz = i4 WITH public, noconstant(0)
 DECLARE sys_tz = i4 WITH public, noconstant(0)
 IF (curutc > 0)
  SET user_tz = curtimezoneapp
  SET sys_tz = curtimezonesys
 ELSE
  SET user_tz = 0
  SET sys_tz = 0
 ENDIF
 FREE RECORD req_out
 RECORD req_out(
   1 message
     2 cqminfo
       3 appname = vc
       3 contribalias = vc
       3 contribrefnum = vc
       3 contribdttm = dq8
       3 priority = i4
       3 class = vc
       3 type = vc
       3 subtype = vc
       3 subtype_detail = vc
       3 debug_ind = i4
       3 verbosity_flag = i4
       3 downtime_comp_msg = gvc
       3 comp_msg_size = i4
     2 esoinfo
       3 scriptcontrolval = ui4
       3 scriptcontrolargs = vc
       3 dbnullprefix = vc
       3 aliasprefix = vc
       3 codeprefix = vc
       3 personprefix = vc
       3 eprsnlprefix = vc
       3 prsnlprefix = vc
       3 orderprefix = vc
       3 orgprefix = vc
       3 hlthplanprefix = vc
       3 nomenprefix = vc
       3 itemprefix = vc
       3 longlist[*]
         4 lval = i4
         4 strmeaning = vc
       3 stringlist[*]
         4 strval = vc
         4 strmeaning = vc
       3 doublelist[*]
         4 dval = f8
         4 strmeaning = vc
       3 sendobjectind = ui1
     2 triginfo[*]
       3 person_id = f8
       3 problem[*]
         4 interface_action_cd = f8
         4 problem_id = f8
         4 problem_instance_id = f8
         4 discipline[*]
           5 problem_discipline_id = f8
           5 interface_action_cd = f8
         4 prsnl[*]
           5 problem_prsnl_id = f8
           5 interface_action_cd = f8
         4 comment[*]
           5 problem_comment_id = f8
   1 params[*]
 )
 SET code_value = 0.0
 SET code_set = 19169
 SET cdf_meaning = "PPR_PROBLEM"
 EXECUTE cpm_get_cd_for_cdf
 SET interface_type_cd = code_value
 CALL echo("***")
 CALL echo(build("***   interface_type_cd :",interface_type_cd))
 CALL echo("***")
 IF (code_value > 0)
  CALL echo("***")
  CALL echo("***   checking to see if out-bound triggers are on")
  CALL echo("***")
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM eso_trigger et
   PLAN (et
    WHERE et.interface_type_cd=interface_type_cd
     AND et.active_ind=1)
   WITH nocounter
  ;end select
  CALL echo("***")
  CALL echo(build("***   curqual :",curqual))
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "ESO_TRIGGER"
   GO TO exit_script
  ENDIF
  IF (curqual > 0)
   CALL echo("***")
   CALL echo("***   on_trigger_on = TRUE")
   CALL echo("***")
   SET ob_trigger_on = true
   SET code_value = 0.0
   SET code_set = 22229
   SET cdf_meaning = "ADD"
   EXECUTE cpm_get_cd_for_cdf
   SET ob_add_cd = code_value
   IF (code_value < 1)
    SET failed = select_error
    SET table_name = "CODE_VALUE"
    SET serrmsg = concat("cdf_meaning ",trim(cdf_meaning)," not found in code_set ",trim(cnvtstring(
       code_set)))
    GO TO exit_script
   ENDIF
   SET code_value = 0.0
   SET code_set = 22229
   SET cdf_meaning = "UPDATE"
   EXECUTE cpm_get_cd_for_cdf
   SET ob_upd_cd = code_value
   IF (code_value < 1)
    SET failed = select_error
    SET table_name = "CODE_VALUE"
    SET serrmsg = concat("cdf_meaning ",trim(cdf_meaning)," not found in code_set ",trim(cnvtstring(
       code_set)))
    GO TO exit_script
   ENDIF
   FREE RECORD ob_add
   RECORD ob_add(
     1 person_id = f8
     1 problem[*]
       2 interface_action_cd = f8
       2 problem_id = f8
       2 problem_instance_id = f8
       2 discipline[*]
         3 problem_discipline_id = f8
         3 interface_action_cd = f8
       2 prsnl[*]
         3 problem_prsnl_id = f8
         3 interface_action_cd = f8
       2 comment[*]
         3 problem_comment_id = f8
   )
   FREE RECORD ob_upd
   RECORD ob_upd(
     1 person_id = f8
     1 problem[*]
       2 interface_action_cd = f8
       2 problem_id = f8
       2 problem_instance_id = f8
       2 discipline[*]
         3 problem_discipline_id = f8
         3 interface_action_cd = f8
       2 prsnl[*]
         3 problem_prsnl_id = f8
         3 interface_action_cd = f8
       2 comment[*]
         3 problem_comment_id = f8
   )
   FREE RECORD ob_del
   RECORD ob_del(
     1 person_id = f8
     1 problem[*]
       2 interface_action_cd = f8
       2 problem_id = f8
       2 problem_instance_id = f8
       2 discipline[*]
         3 problem_discipline_id = f8
         3 interface_action_cd = f8
       2 prsnl[*]
         3 problem_prsnl_id = f8
         3 interface_action_cd = f8
       2 comment[*]
         3 problem_comment_id = f8
   )
  ENDIF
 ENDIF
 SET active_code = 0.0
 IF ((reqdata->active_status_cd < 1))
  SET code_value = 0.0
  SET code_set = 48
  SET cdf_meaning = "ACTIVE"
  EXECUTE cpm_get_cd_for_cdf
  SET active_code = code_value
 ELSE
  SET active_code = reqdata->active_status_cd
 ENDIF
 SET inactive_code = 0.0
 IF ((reqdata->active_status_cd < 1))
  SET code_value = 0.0
  SET code_set = 48
  SET cdf_meaning = "INACTIVE"
  EXECUTE cpm_get_cd_for_cdf
  SET inactive_code = code_value
 ELSE
  SET inactive_code = reqdata->inactive_status_cd
 ENDIF
 SET canceled_cd = 0.0
 SET code_value = 0.0
 SET code_set = 12030
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 SUBROUTINE is_problem_dup(tperson_id,tnomen_id,tprob_ftdesc)
   CALL echo("***")
   CALL echo("***   Is_Problem_Dup")
   CALL echo("***")
   SELECT
    IF (tnomen_id > 0)
     PLAN (p
      WHERE p.person_id=tperson_id
       AND p.nomenclature_id=tnomen_id
       AND p.active_ind=1
       AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND p.life_cycle_status_cd != canceled_cd)
    ELSE
     PLAN (p
      WHERE p.person_id=tperson_id
       AND p.problem_ftdesc=tprob_ftdesc
       AND p.active_ind=1
       AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND p.life_cycle_status_cd != canceled_cd)
    ENDIF
    INTO "nl:"
    p.updt_dt_tm
    FROM problem p
    ORDER BY p.problem_instance_id DESC
    HEAD REPORT
     tproblem_id = p.problem_id, tproblem_instance_id = p.problem_instance_id
    WITH nocounter, maxqual(p,1)
   ;end select
   IF (curqual > 0)
    SET do_upt = true
   ENDIF
 END ;Subroutine
 SUBROUTINE get_new_problem_id(lvar)
   CALL echo("***")
   CALL echo("***   Get_New_Prob_Id")
   CALL echo("***")
   SET new_code = 0.0
   SELECT INTO "nl:"
    y = seq(problem_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_code = cnvtreal(y)
    WITH format, counter
   ;end select
 END ;Subroutine
 SUBROUTINE is_pure_dup(tnomen_id,tidx)
   CALL echo("***")
   CALL echo("***   Is_Pure_Dup")
   CALL echo("***")
   IF ((request->problem[tidx].probability > 0))
    SET tprobability = request->problem[tidx].probability
   ELSE
    SET tprobability = null
   ENDIF
   IF ((request->problem[tidx].sensitivity > 0))
    SET tsensitivity = request->problem[tidx].sensitivity
   ELSE
    SET tsensitivity = null
   ENDIF
   SELECT
    IF (tnomen_id > 0)
     PLAN (p
      WHERE (p.person_id=request->person_id)
       AND (p.nomenclature_id=request->problem[tidx].nomenclature_id)
       AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ELSE
     PLAN (p
      WHERE (p.person_id=request->person_id)
       AND (p.problem_ftdesc=request->problem[tidx].problem_ftdesc)
       AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ENDIF
    INTO "nl:"
    p.updt_dt_tm
    FROM problem p
    ORDER BY p.problem_instance_id DESC
    HEAD REPORT
     tproblem_id = p.problem_id, tproblem_instance_id = p.problem_instance_id
     IF ((p.cancel_reason_cd != request->problem[tidx].cancel_reason_cd))
      pure_dup = false
     ELSEIF ((p.certainty_cd != request->problem[tidx].certainty_cd))
      pure_dup = false
     ELSEIF ((p.classification_cd != request->problem[tidx].classification_cd))
      pure_dup = false
     ELSEIF ((p.confirmation_status_cd != request->problem[tidx].confirmation_status_cd))
      pure_dup = false
     ELSEIF ((p.contributor_system_cd != request->problem[tidx].contributor_system_cd))
      pure_dup = false
     ELSEIF ((p.course_cd != request->problem[tidx].course_cd))
      pure_dup = false
     ELSEIF ((p.family_aware_cd != request->problem[tidx].family_aware_cd))
      pure_dup = false
     ELSEIF ((p.life_cycle_status_cd != request->problem[tidx].life_cycle_status_cd))
      pure_dup = false
     ELSEIF ((p.onset_dt_cd != request->problem[tidx].onset_dt_cd))
      pure_dup = false
     ELSEIF ((p.persistence_cd != request->problem[tidx].persistence_cd))
      pure_dup = false
     ELSEIF ((p.person_aware_cd != request->problem[tidx].person_aware_cd))
      pure_dup = false
     ELSEIF ((p.person_aware_prognosis_cd != request->problem[tidx].person_aware_prognosis_cd))
      pure_dup = false
     ELSEIF ((p.prognosis_cd != request->problem[tidx].prognosis_cd))
      pure_dup = false
     ELSEIF ((p.ranking_cd != request->problem[tidx].ranking_cd))
      pure_dup = false
     ELSEIF (((p.probability=null
      AND (request->problem[tidx].probability > 0)) OR (p.probability != null
      AND (p.probability != request->problem[tidx].probability))) )
      pure_dup = false
     ELSEIF (((p.sensitivity=null
      AND (request->problem[tidx].sensitivity > 0)) OR (p.sensitivity != null
      AND (p.sensitivity != request->problem[tidx].sensitivity))) )
      pure_dup = false
     ELSEIF (((p.life_cycle_dt_tm=null
      AND (request->problem[tidx].life_cycle_dt_tm > 0)) OR (p.life_cycle_dt_tm != null
      AND (p.life_cycle_dt_tm != request->problem[tidx].life_cycle_dt_tm))) )
      pure_dup = false
     ELSEIF (((p.onset_dt_tm=null
      AND (request->problem[tidx].onset_dt_tm > 0)) OR (p.onset_dt_tm != null
      AND (p.onset_dt_tm != request->problem[tidx].onset_dt_tm))) )
      pure_dup = false
     ELSE
      pure_dup = true
     ENDIF
    WITH nocounter, maxqual(p,1)
   ;end select
 END ;Subroutine
 SUBROUTINE is_update(aidx)
   CALL echo("***")
   CALL echo("***   Is_Update")
   CALL echo("***")
   IF ( NOT ((request->problem[aidx].beg_effective_dt_tm > 0)))
    SET request->problem[aidx].beg_effective_dt_tm = cnvtdatetime(current_date)
   ENDIF
   SET reply->problem_list[aidx].nomenclature_id = request->problem[aidx].nomenclature_id
   SET reply->problem_list[aidx].problem_ftdesc = request->problem[aidx].problem_ftdesc
   IF ((request->problem[aidx].problem_action_ind=del)
    AND (request->problem[aidx].life_cycle_status_cd != canceled_cd))
    SET request->problem[aidx].life_cycle_status_cd = canceled_cd
   ENDIF
   SET do_upt = false
   IF ((request->problem[j].problem_action_ind=force_add))
    SET do_upt = false
   ELSEIF ((request->problem[aidx].problem_id < 1))
    SET tproblem_id = 0.0
    SET tproblem_instance_id = 0.0
    CALL is_problem_dup(request->person_id,request->problem[aidx].nomenclature_id,request->problem[
     aidx].problem_ftdesc)
    IF (tproblem_id > 0)
     SET request->problem[aidx].problem_id = tproblem_id
     SET request->problem[aidx].problem_instance_id = tproblem_instance_id
     SET reply->problem_list[aidx].problem_id = tproblem_id
     SET reply->problem_list[aidx].problem_instance_id = tproblem_instance_id
     SET existing_interface_problem = true
    ENDIF
   ELSEIF ((request->problem[aidx].problem_instance_id < 1))
    SET failed = input_error
    SET reply->swarnmsg = concat("Problem_instance_id must be greater ",
     "than 0 when problem_id is greater than 0")
    SET serrmsg = "Invalid Request Data"
    SET table_name = "REQUEST"
   ELSE
    SET do_upt = true
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_problem(aidx)
   CALL echo("***")
   CALL echo("***   Insert_Problem")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM problem p
    SET p.problem_instance_id = new_code, p.problem_id = request->problem[aidx].problem_id, p
     .nomenclature_id =
     IF ((request->problem[aidx].nomenclature_id=0)) 0.00
     ELSE request->problem[aidx].nomenclature_id
     ENDIF
     ,
     p.person_id = request->person_id, p.problem_ftdesc =
     IF ((request->problem[aidx].problem_ftdesc=" ")) null
     ELSE request->problem[aidx].problem_ftdesc
     ENDIF
     , p.estimated_resolution_dt_tm =
     IF ((request->problem[aidx].estimated_resolution_dt_tm=0)) null
     ELSE cnvtdatetime(request->problem[aidx].estimated_resolution_dt_tm)
     ENDIF
     ,
     p.actual_resolution_dt_tm =
     IF ((request->problem[aidx].actual_resolution_dt_tm=0)) null
     ELSE cnvtdatetime(request->problem[aidx].actual_resolution_dt_tm)
     ENDIF
     , p.classification_cd =
     IF ((request->problem[aidx].classification_cd=0)) 0.00
     ELSE request->problem[aidx].classification_cd
     ENDIF
     , p.persistence_cd =
     IF ((request->problem[aidx].persistence_cd=0)) 0.00
     ELSE request->problem[aidx].persistence_cd
     ENDIF
     ,
     p.confirmation_status_cd = request->problem[aidx].confirmation_status_cd, p.life_cycle_status_cd
      = request->problem[aidx].life_cycle_status_cd, p.life_cycle_dt_tm =
     IF ((request->problem[aidx].life_cycle_dt_tm != 0)) cnvtdatetime(request->problem[aidx].
       life_cycle_dt_tm)
     ELSE null
     ENDIF
     ,
     p.life_cycle_tz =
     IF ((request->problem[aidx].life_cycle_tz > 0)) request->problem[aidx].life_cycle_tz
     ELSE user_tz
     ENDIF
     , p.onset_dt_cd = request->problem[aidx].onset_dt_cd, p.onset_dt_tm =
     IF ((request->problem[aidx].onset_dt_tm != 0)) cnvtdatetime(request->problem[aidx].onset_dt_tm)
     ELSE null
     ENDIF
     ,
     p.onset_tz =
     IF ((request->problem[aidx].onset_tz > 0)) request->problem[aidx].onset_tz
     ELSE user_tz
     ENDIF
     , p.ranking_cd =
     IF ((request->problem[aidx].ranking_cd=0)) 0
     ELSE request->problem[aidx].ranking_cd
     ENDIF
     , p.certainty_cd =
     IF ((request->problem[aidx].certainty_cd=0)) 0
     ELSE request->problem[aidx].certainty_cd
     ENDIF
     ,
     p.probability =
     IF ((request->problem[aidx].probability=0)) null
     ELSE request->problem[aidx].probability
     ENDIF
     , p.person_aware_cd =
     IF ((request->problem[aidx].person_aware_cd=0)) 0
     ELSE request->problem[aidx].person_aware_cd
     ENDIF
     , p.prognosis_cd =
     IF ((request->problem[aidx].prognosis_cd=0)) 0
     ELSE request->problem[aidx].prognosis_cd
     ENDIF
     ,
     p.person_aware_prognosis_cd =
     IF ((request->problem[aidx].person_aware_prognosis_cd=0)) 0
     ELSE request->problem[aidx].person_aware_prognosis_cd
     ENDIF
     , p.family_aware_cd =
     IF ((request->problem[aidx].family_aware_cd=0)) 0
     ELSE request->problem[aidx].family_aware_cd
     ENDIF
     , p.sensitivity =
     IF ((request->problem[aidx].sensitivity=0)) null
     ELSE request->problem[aidx].sensitivity
     ENDIF
     ,
     p.course_cd =
     IF ((request->problem[aidx].course_cd=0)) 0
     ELSE request->problem[aidx].course_cd
     ENDIF
     , p.cancel_reason_cd =
     IF ((request->problem[aidx].cancel_reason_cd=0)) 0
     ELSE request->problem[aidx].cancel_reason_cd
     ENDIF
     , p.active_ind = 1,
     p.active_status_cd = active_code, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
     .active_status_prsnl_id = reqinfo->updt_id,
     p.beg_effective_dt_tm = cnvtdatetime(request->problem[aidx].beg_effective_dt_tm), p
     .beg_effective_tz =
     IF ((request->problem[aidx].beg_effective_tz > 0)) request->problem[aidx].beg_effective_tz
     ELSE user_tz
     ENDIF
     , p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59"),
     p.data_status_cd =
     IF ((request->problem[aidx].data_status_cd=0)) 0
     ELSE request->problem[aidx].data_status_cd
     ENDIF
     , p.data_status_dt_tm =
     IF ((request->problem[aidx].data_status_dt_tm <= 0)) null
     ELSE cnvtdatetime(request->problem[aidx].data_status_dt_tm)
     ENDIF
     , p.data_status_prsnl_id =
     IF ((request->problem[aidx].data_status_prsnl_id=0)) 0
     ELSE request->problem[aidx].data_status_prsnl_id
     ENDIF
     ,
     p.contributor_system_cd =
     IF ((request->problem[aidx].contributor_system_cd=0)) 0
     ELSE request->problem[aidx].contributor_system_cd
     ENDIF
     , p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = insert_error
    SET table_name = "PROBLEM"
    SET reply->swarnmsg = "Could not insert problem"
   ENDIF
 END ;Subroutine
 SUBROUTINE deactivate_problem(aidx)
   CALL echo("***")
   CALL echo("***   Deactivate_Problem")
   CALL echo(build("***   inactive_code :",inactive_code))
   CALL echo(build("***   reqdata->active_status_cd",reqdata->inactive_status_cd))
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "NL:"
    p.problem_instance_id
    FROM problem p
    PLAN (p
     WHERE (p.problem_instance_id=request->problem[aidx].problem_instance_id)
      AND (p.problem_id=request->problem[aidx].problem_id))
    WITH nocounter, forupdate(p)
   ;end select
   IF (curqual < 1)
    SET failed = lock_error
    SET table_name = "PROBLEM"
    SET reply->swarnmsg = "Could not lock problem row"
    SET ierrcode = error(serrmsg,1)
   ELSE
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM problem p
     SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.active_ind = 0, p.active_status_cd
       = inactive_code,
      p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
      updt_id, p.updt_applctx = reqinfo->updt_applctx,
      p.updt_task = reqinfo->updt_task
     PLAN (p
      WHERE (p.problem_instance_id=request->problem[aidx].problem_instance_id)
       AND (p.problem_id=request->problem[aidx].problem_id))
     WITH nocounter
    ;end update
    IF (curqual < 1)
     SET failed = update_error
     SET table_name = "PROBLEM"
     SET reply->swarnmsg = "Could not update problem"
     SET ierrcode = error(serrmsg,1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_comment(aidx,bidx)
   CALL echo("***")
   CALL echo("***   Insert_Comment")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM problem_comment pc
    SET pc.problem_id = request->problem[aidx].problem_id, pc.problem_comment_id = new_code, pc
     .comment_prsnl_id = request->problem[aidx].problem_comment[bidx].comment_prsnl_id,
     pc.problem_comment = request->problem[aidx].problem_comment[bidx].problem_comment, pc
     .comment_dt_tm = cnvtdatetime(curdate,curtime3), pc.comment_tz =
     IF ((request->problem[aidx].problem_comment[bidx].comment_tz > 0)) request->problem[aidx].
      problem_comment[bidx].comment_tz
     ELSE user_tz
     ENDIF
     ,
     pc.active_ind = 1, pc.active_status_cd = active_code, pc.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     pc.active_status_prsnl_id = reqinfo->updt_id, pc.beg_effective_dt_tm = cnvtdatetime(request->
      problem[aidx].problem_comment[bidx].beg_effective_dt_tm), pc.beg_effective_tz =
     IF ((request->problem[aidx].problem_comment[bidx].beg_effective_tz > 0)) request->problem[aidx].
      problem_comment[bidx].beg_effective_tz
     ELSE user_tz
     ENDIF
     ,
     pc.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), pc.data_status_cd =
     IF ((request->problem[aidx].problem_comment[bidx].data_status_cd=0)) 0
     ELSE request->problem[aidx].problem_comment[bidx].data_status_cd
     ENDIF
     , pc.data_status_dt_tm =
     IF ((request->problem[aidx].problem_comment[bidx].data_status_dt_tm <= 0)) null
     ELSE cnvtdatetime(request->problem[aidx].problem_comment[bidx].data_status_dt_tm)
     ENDIF
     ,
     pc.data_status_prsnl_id =
     IF ((request->problem[aidx].problem_comment[bidx].data_status_prsnl_id=0)) 0
     ELSE request->problem[aidx].problem_comment[bidx].data_status_prsnl_id
     ENDIF
     , pc.contributor_system_cd =
     IF ((request->problem[aidx].problem_comment[bidx].contributor_system_cd=0)) 0
     ELSE request->problem[aidx].problem_comment[bidx].contributor_system_cd
     ENDIF
     , pc.updt_applctx = reqinfo->updt_applctx,
     pc.updt_cnt = 0, pc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_id = reqinfo->updt_id,
     pc.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = insert_error
    SET table_name = "PROBLEM_COMMENT"
   ENDIF
 END ;Subroutine
 SUBROUTINE does_comment_exist(aidx,bidx)
   CALL echo("***")
   CALL echo("***   Does_Comment_Exist")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SET problem_comment_id = 0.0
   SET comment_exist = false
   SELECT INTO "nl:"
    FROM problem_comment pc
    PLAN (pc
     WHERE (pc.problem_id=request->problem[aidx].problem_id)
      AND (pc.comment_prsnl_id=request->problem[aidx].problem_comment[bidx].comment_prsnl_id))
    DETAIL
     IF ((pc.problem_comment=request->problem[aidx].problem_comment[bidx].problem_comment))
      problem_comment_id = pc.problem_comment_id, comment_exist = true
     ENDIF
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "PROBLEM_COMMENT"
   ELSEIF (comment_exist=true)
    SET reply->problem_list[aidx].comment_list[bidx].problem_comment_id = problem_comment_id
   ENDIF
 END ;Subroutine
 SUBROUTINE does_discipline_exist(aidx,bidx)
   CALL echo("***")
   CALL echo("***   Does_Discipline_Exist")
   CALL echo("***")
   SET discipline_exist = false
   SET problem_discipline_id = 0.0
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM problem_discipline pd
    PLAN (pd
     WHERE (pd.problem_id=request->problem[aidx].problem_id)
      AND (pd.management_discipline_cd=request->problem[aidx].problem_discipline[bidx].
     management_discipline_cd)
      AND pd.active_ind=1
      AND pd.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pd.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     problem_discipline_id = pd.problem_discipline_id
    WITH nocounter, forupdate(pd)
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "PROBLEM_DISCIPLINE"
   ENDIF
   IF (problem_discipline_id > 0)
    SET discipline_exist = true
    SET reply->problem_list[aidx].discipline_list[bidx].problem_discipline_id = problem_discipline_id
   ENDIF
 END ;Subroutine
 SUBROUTINE deactivate_discipline(aidx,bidx)
   CALL echo("***")
   CALL echo("***   Deactivate_Discipline")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM problem_discipline pd
    SET pd.active_ind = 0, pd.active_status_cd = inactive_code, pd.active_status_dt_tm = cnvtdatetime
     (curdate,curtime3),
     pd.active_status_prsnl_id = reqinfo->updt_id, pd.end_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), pd.updt_cnt = (pd.updt_cnt+ 1),
     pd.updt_dt_tm = cnvtdatetime(curdate,curtime3), pd.updt_id = reqinfo->updt_id, pd.updt_applctx
      = reqinfo->updt_applctx,
     pd.updt_task = reqinfo->updt_task
    PLAN (pd
     WHERE pd.problem_discipline_id=problem_discipline_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "PROBLEM_DISCIPLINE"
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_discipline(aidx,bidx)
   CALL echo("***")
   CALL echo("***   Insert_Discipline")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM problem_discipline pd
    SET pd.problem_discipline_id = new_code, pd.problem_id = request->problem[aidx].problem_id, pd
     .management_discipline_cd = request->problem[aidx].problem_discipline[bidx].
     management_discipline_cd,
     pd.active_ind = 1, pd.active_status_cd = active_code, pd.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     pd.active_status_prsnl_id = reqinfo->updt_id, pd.beg_effective_dt_tm =
     IF ((request->problem[aidx].problem_discipline[bidx].beg_effective_dt_tm <= 0)) cnvtdatetime(
       curdate,curtime3)
     ELSE cnvtdatetime(request->problem[aidx].problem_discipline[bidx].beg_effective_dt_tm)
     ENDIF
     , pd.end_effective_dt_tm =
     IF ((request->problem[aidx].problem_discipline[bidx].end_effective_dt_tm <= 0)) cnvtdatetime(
       "31-DEC-2100 00:00:00.00")
     ELSE cnvtdatetime(request->problem[aidx].problem_discipline[bidx].end_effective_dt_tm)
     ENDIF
     ,
     pd.data_status_cd =
     IF ((request->problem[aidx].problem_discipline[bidx].data_status_cd=0)) 0
     ELSE request->problem[aidx].problem_discipline[bidx].data_status_cd
     ENDIF
     , pd.data_status_dt_tm =
     IF ((request->problem[aidx].problem_discipline[bidx].data_status_dt_tm <= 0)) null
     ELSE cnvtdatetime(request->problem[aidx].problem_discipline[bidx].data_status_dt_tm)
     ENDIF
     , pd.data_status_prsnl_id =
     IF ((request->problem[aidx].problem_discipline[bidx].data_status_prsnl_id=0)) 0
     ELSE request->problem[aidx].problem_discipline[bidx].data_status_prsnl_id
     ENDIF
     ,
     pd.contributor_system_cd =
     IF ((request->problem[aidx].problem_discipline[bidx].contributor_system_cd=0)) 0
     ELSE request->problem[aidx].problem_discipline[bidx].contributor_system_cd
     ENDIF
     , pd.updt_applctx = reqinfo->updt_applctx, pd.updt_cnt = 0,
     pd.updt_dt_tm = cnvtdatetime(curdate,curtime3), pd.updt_id = reqinfo->updt_id, pd.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "PROBLEM_DISCIPLINE"
    SET reply->problem_list[aidx].discipline_list[bidx].sreturnmsg = "ERROR:  Failed to Insert row."
   ENDIF
   SET reply->problem_list[aidx].discipline_list[bidx].problem_discipline_id = new_code
   SET reply->problem_list[aidx].discipline_list[bidx].management_discipline_cd = request->problem[
   aidx].problem_discipline[bidx].management_discipline_cd
 END ;Subroutine
 SUBROUTINE does_prsnl_exist(aidx,reltn_cd,prsnl_id)
   CALL echo("***")
   CALL echo("***   Does_Prsnl_Exist")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM problem_prsnl_r pp
    WHERE (pp.problem_id=request->problem[aidx].problem_id)
     AND pp.problem_reltn_prsnl_id=prsnl_id
     AND pp.problem_reltn_cd=reltn_cd
     AND pp.active_ind=1
     AND pp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     problem_prsnl_id = pp.problem_prsnl_id
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "PROBLEM_PRSNL_R"
   ELSEIF (curqual > 0)
    SET recorder_exist = true
   ENDIF
 END ;Subroutine
 SUBROUTINE does_recorder_prsnl_exist(aidx,reltn_cd)
   CALL echo("***")
   CALL echo("***   Does_Prsnl_Exist")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM problem_prsnl_r pp
    WHERE (pp.problem_id=request->problem[aidx].problem_id)
     AND pp.problem_reltn_cd=reltn_cd
     AND pp.active_ind=1
     AND pp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     problem_prsnl_id = pp.problem_prsnl_id
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "PROBLEM_PRSNL_R"
   ELSEIF (curqual > 0)
    SET recorder_exist = true
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_prsnl(aidx,bidx)
   CALL echo("***")
   CALL echo("***   Insert_Prsnl")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM problem_prsnl_r pp
    SET pp.problem_prsnl_id = new_code, pp.problem_id = request->problem[aidx].problem_id, pp
     .problem_reltn_cd = request->problem[aidx].problem_prsnl[bidx].problem_reltn_cd,
     pp.problem_reltn_dt_tm =
     IF ((request->problem[aidx].problem_prsnl[bidx].problem_reltn_dt_tm <= 0)) cnvtdatetime(curdate,
       curtime3)
     ELSE cnvtdatetime(request->problem[aidx].problem_prsnl[bidx].problem_reltn_dt_tm)
     ENDIF
     , pp.problem_reltn_prsnl_id =
     IF ((request->problem[aidx].problem_prsnl[bidx].problem_reltn_prsnl_id=0)) reqinfo->updt_id
     ELSE request->problem[aidx].problem_prsnl[bidx].problem_reltn_prsnl_id
     ENDIF
     , pp.active_ind = 1,
     pp.active_status_cd = active_code, pp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pp
     .active_status_prsnl_id = reqinfo->updt_id,
     pp.beg_effective_dt_tm =
     IF ((request->problem[aidx].problem_prsnl[bidx].beg_effective_dt_tm <= 0)) cnvtdatetime(curdate,
       curtime3)
     ELSE cnvtdatetime(request->problem[aidx].problem_prsnl[bidx].beg_effective_dt_tm)
     ENDIF
     , pp.end_effective_dt_tm =
     IF ((request->problem[aidx].problem_prsnl[bidx].end_effective_dt_tm <= 0)) cnvtdatetime(
       "31-DEC-2100 00:00:00.00")
     ELSE cnvtdatetime(request->problem[aidx].problem_prsnl[bidx].end_effective_dt_tm)
     ENDIF
     , pp.data_status_cd = request->problem[aidx].problem_prsnl[bidx].data_status_cd,
     pp.data_status_dt_tm =
     IF ((request->problem[aidx].problem_prsnl[bidx].data_status_dt_tm <= 0)) null
     ELSE cnvtdatetime(request->problem[aidx].problem_prsnl[bidx].data_status_dt_tm)
     ENDIF
     , pp.data_status_prsnl_id = request->problem[aidx].problem_prsnl[bidx].data_status_prsnl_id, pp
     .contributor_system_cd = request->problem[aidx].problem_prsnl[bidx].contributor_system_cd,
     pp.updt_applctx = reqinfo->updt_applctx, pp.updt_cnt = 0, pp.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     pp.updt_id = reqinfo->updt_id, pp.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = insert_error
    SET tablename = "PROBLEM_PRSNL_R"
    SET reply->problem_list[aidx].prsnl_list[bidx].sreturnmsg = "ERROR:  Failed to Insert row."
   ENDIF
 END ;Subroutine
 SUBROUTINE add_recorder(aidx)
   CALL echo("***")
   CALL echo("***   Add_Recorder")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM problem_prsnl_r pp
    SET pp.problem_prsnl_id = new_code, pp.problem_id = request->problem[aidx].problem_id, pp
     .problem_reltn_cd = recorder_code,
     pp.problem_reltn_dt_tm = cnvtdatetime(curdate,curtime3), pp.problem_reltn_prsnl_id = reqinfo->
     updt_id, pp.active_ind = 1,
     pp.active_status_cd = active_code, pp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pp
     .active_status_prsnl_id = reqinfo->updt_id,
     pp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pp.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"), pp.updt_applctx = reqinfo->updt_applctx,
     pp.updt_cnt = 0, pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id,
     pp.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = insert_error
    SET tablename = "PROBLEM_PRSNL_R"
   ENDIF
 END ;Subroutine
 SUBROUTINE deactivate_prsnl(aidx,bidx)
   CALL echo("***")
   CALL echo("***   Deactivate_Prsnl")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM problem_prsnl_r pp
    SET pp.active_ind = 0, pp.active_status_cd = inactive_code, pp.active_status_dt_tm = cnvtdatetime
     (curdate,curtime3),
     pp.active_status_prsnl_id = reqinfo->updt_id, pp.end_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), pp.updt_cnt = (pp.updt_cnt+ 1),
     pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id, pp.updt_applctx
      = reqinfo->updt_applctx,
     pp.updt_task = reqinfo->updt_task
    WHERE pp.problem_prsnl_id=problem_prsnl_id
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "PROBLEM_PRSNL_R"
    SET reply->problem_list[aidx].prsnl_list[bidx].sreturnmsg = "Failed to deactivate data row"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_problem_ob_add(aidx)
   CALL echo("***")
   CALL echo("***   Add_Problem_Ob_Add")
   CALL echo("***")
   SET problem_added = true
   SET ob_add->person_id = request->person_id
   SET obaknt = (obaknt+ 1)
   SET stat = alterlist(ob_add->problem,obaknt)
   SET ob_add->problem[obaknt].interface_action_cd = ob_add_cd
   SET ob_add->problem[obaknt].problem_id = request->problem[aidx].problem_id
   SET ob_add->problem[obaknt].problem_instance_id = request->problem[aidx].problem_instance_id
 END ;Subroutine
 SUBROUTINE add_problem_ob_upd(aidx)
   CALL echo("***")
   CALL echo("***   Add_Problem_Ob_Upd")
   CALL echo("***")
   SET problem_updated = true
   SET ob_upd->person_id = request->person_id
   SET obuknt = (obuknt+ 1)
   SET stat = alterlist(ob_upd->problem,obuknt)
   SET ob_upd->problem[obuknt].interface_action_cd = ob_upd_cd
   SET ob_upd->problem[obuknt].problem_id = request->problem[aidx].problem_id
   SET ob_upd->problem[obuknt].problem_instance_id = request->problem[aidx].problem_instance_id
 END ;Subroutine
 SUBROUTINE add_comment_ob_add(aidx,bidx)
   CALL echo("***")
   CALL echo("***   Add_Comment_Ob_Add")
   CALL echo("***")
   SET obakntc = (obakntc+ 1)
   SET stat = alterlist(ob_add->problem[obaknt].comment,obakntc)
   SET ob_add->problem[obaknt].comment[obakntc].problem_comment_id = request->problem[aidx].
   problem_comment[bidx].problem_comment_id
 END ;Subroutine
 SUBROUTINE add_comment_ob_upd(aidx,bidx)
   CALL echo("***")
   CALL echo("***   Add_Comment_Ob_Upd")
   CALL echo("***")
   SET obukntc = (obukntc+ 1)
   SET stat = alterlist(ob_upd->problem[obuknt].comment,obukntc)
   SET ob_upd->problem[obuknt].comment[obukntc].problem_comment_id = request->problem[aidx].
   problem_comment[bidx].problem_comment_id
 END ;Subroutine
 SUBROUTINE add_discipline_ob_add(aidx,bidx)
   CALL echo("***")
   CALL echo("***   Add_Discipline_Ob_Add")
   CALL echo("***")
   SET obakntd = (obakntd+ 1)
   SET stat = alterlist(ob_add->problem[obaknt].discipline,obakntd)
   SET ob_add->problem[obaknt].discipline[obakntd].interface_action_cd = ob_add_cd
   SET ob_add->problem[obaknt].discipline[obakntd].problem_discipline_id = request->problem[aidx].
   problem_discipline[bidx].problem_discipline_id
 END ;Subroutine
 SUBROUTINE add_discipline_ob_upd(aidx,bidx)
   CALL echo("***")
   CALL echo("***   Add_Discipline_Ob_Upd")
   CALL echo("***")
   SET obukntd = (obukntd+ 1)
   SET stat = alterlist(ob_upd->problem[obuknt].discipline,obukntd)
   SET ob_upd->problem[obuknt].discipline[obukntd].interface_action_cd = ob_upd_cd
   SET ob_upd->problem[obuknt].discipline[obukntd].problem_discipline_id = request->problem[aidx].
   problem_discipline[bidx].problem_discipline_id
 END ;Subroutine
 SUBROUTINE add_prsnl_ob_add(aidx,bidx,item_id)
   CALL echo("***")
   CALL echo("***   Add_Prsnl_Ob_Add")
   CALL echo("***")
   SET obakntp = (obakntp+ 1)
   SET stat = alterlist(ob_add->problem[obaknt].prsnl,obakntp)
   SET ob_add->problem[obaknt].prsnl[obakntp].problem_prsnl_id = item_id
   SET ob_add->problem[obaknt].prsnl[obakntp].interface_action_cd = ob_add_cd
 END ;Subroutine
 SUBROUTINE add_prsnl_ob_upd(aidx,bidx,item_id)
   CALL echo("***")
   CALL echo("***   Add_Prsnl_Ob_Upd")
   CALL echo("***")
   SET obukntp = (obukntp+ 1)
   SET stat = alterlist(ob_upd->problem[obuknt].prsnl,obukntp)
   SET ob_upd->problem[obuknt].prsnl[obukntp].problem_prsnl_id = item_id
   SET ob_upd->problem[obuknt].prsnl[obukntp].interface_action_cd = ob_upd_cd
 END ;Subroutine
 SET obaknt = 0
 SET obuknt = 0
 SET obdknt = 0
 SET obakntc = 0
 SET obukntc = 0
 SET obakntd = 0
 SET obukntd = 0
 SET obakntp = 0
 SET obukntp = 0
 FOR (j = 1 TO qual)
   SET obakntc = 0
   SET obukntc = 0
   SET obakntd = 0
   SET obukntd = 0
   SET obakntp = 0
   SET obukntp = 0
   SET problem_added = false
   SET problem_updated = false
   SET problem_deleted = false
   SET comment_added = false
   SET comment_updated = false
   SET comment_deleted = false
   SET prsnl_added = false
   SET prsnl_updated = false
   SET prsnl_deleted = false
   SET discipline_added = false
   SET discipline_updated = false
   SET discipline_updated = false
   SET existing_interface_problem = false
   CALL is_update(j)
   IF (failed != false)
    GO TO exit_script
   ENDIF
   IF (do_upt=false)
    CALL get_new_problem_id(dvar)
    IF (new_code > 0)
     SET request->problem[j].problem_id = new_code
     SET request->problem[j].problem_instance_id = new_code
    ELSE
     SET failed = gen_nbr_error
     SET table_name = "PROBLEM"
     SET reply->swarnmsg = "Could not generate new problem_id "
     SET serrmsg = "Failed to generate number"
     GO TO exit_script
    ENDIF
    CALL insert_problem(j)
    IF (failed != false)
     GO TO exit_script
    ENDIF
    SET reply->problem_list[j].problem_id = request->problem[j].problem_id
    SET reply->problem_list[j].problem_instance_id = new_code
    IF (ob_trigger_on=true)
     CALL echo("***")
     CALL echo("***   ob_trigger_on = TRUE")
     CALL echo("***")
     CALL add_problem_ob_add(j)
     SET do_ob_add = true
    ENDIF
   ELSE
    SET pure_dup = false
    SET tproblem_id = 0.0
    SET tproblem_instance_id = 0.0
    IF ((request->problem[j].problem_action_ind != force_upt))
     CALL is_pure_dup(request->problem[j].nomenclature_id,j)
    ENDIF
    IF (pure_dup=false)
     CALL deactivate_problem(j)
     IF (failed != false)
      GO TO exit_script
     ENDIF
     CALL get_new_problem_id(dvar)
     IF (new_code < 1)
      SET failed = gen_nbr_error
      SET table_name = "PROBLEM"
      SET reply->swarnmsg = "Could not generate new problem_id "
      SET serrmsg = "Failed to generate number"
      GO TO exit_script
     ELSE
      SET request->problem[j].problem_instance_id = new_code
     ENDIF
     CALL insert_problem(j)
     IF (failed != false)
      GO TO exit_script
     ENDIF
     SET reply->problem_list[j].problem_id = request->problem[j].problem_id
     SET reply->problem_list[j].problem_instance_id = new_code
     IF (ob_trigger_on=true)
      CALL echo("***")
      CALL echo("***   ob_trigger_on = TRUE")
      CALL echo("***")
      CALL add_problem_ob_upd(j)
      SET do_ob_upd = true
     ENDIF
    ELSE
     SET reply->problem_list[j].sreturnmsg = "Problem is a pure duplicate : No action taken"
     SET reply->problem_list[j].problem_id = tproblem_id
     SET reply->problem_list[j].problem_instance_id = tproblem_instance_id
    ENDIF
   ENDIF
   IF ((request->problem[j].problem_comment_cnt > 0))
    SET stat = alterlist(reply->problem_list[j].comment_list,request->problem[j].problem_comment_cnt)
    FOR (k = 1 TO request->problem[j].problem_comment_cnt)
     IF ( NOT ((request->problem[j].problem_comment[k].beg_effective_dt_tm > 0)))
      SET request->problem[j].problem_comment[k].beg_effective_dt_tm = cnvtdatetime(current_date)
     ENDIF
     IF (do_upt=false)
      CALL get_new_problem_id(dvar)
      IF (new_code < 1)
       SET failed = gen_nbr_error
       SET table_name = "PROBLEM_COMMENT"
       SET reply->swarnmsg = "Could not generate new problem_comment_id"
       SET serrmsg = "Failed to generate number"
       GO TO exit_script
      ENDIF
      SET request->problem[j].problem_comment[k].problem_comment_id = new_code
      SET reply->problem_list[j].comment_list[k].problem_comment_id = new_code
      CALL insert_comment(j,k)
      IF (failed != false)
       GO TO exit_script
      ENDIF
      IF (ob_trigger_on=true)
       CALL echo("***")
       CALL echo("***   ob_trigger_on = TRUE")
       CALL echo("***")
       IF (problem_added=true)
        CALL add_comment_ob_add(j,k)
       ELSEIF (problem_updated=true)
        CALL add_comment_ob_upd(j,k)
       ELSE
        CALL add_problem_ob_upd(j)
        SET do_ob_upd = true
        CALL add_comment_ob_upd(j,k)
       ENDIF
      ENDIF
     ELSE
      IF ((reply->problem_list[j].comment_list[k].problem_comment_id < 1))
       SET comment_exist = false
       CALL does_comment_exist(j,k)
       IF (failed != false)
        GO TO exit_script
       ENDIF
       IF (comment_exist=false)
        CALL get_new_problem_id(dvar)
        IF (new_code < 1)
         SET failed = gen_nbr_error
         SET table_name = "PROBLEM_COMMENT"
         SET reply->swarnmsg = "Could not generate new problem_comment_id"
         SET serrmsg = "Failed to generate number"
         GO TO exit_script
        ENDIF
        SET request->problem[j].problem_comment[k].problem_comment_id = new_code
        SET reply->problem_list[j].comment_list[k].problem_comment_id = new_code
        CALL insert_comment(j,k)
        IF (failed != false)
         GO TO exit_script
        ENDIF
        IF (ob_trigger_on=true)
         CALL echo("***")
         CALL echo("***   ob_trigger_on = TRUE")
         CALL echo("***")
         IF (problem_added=true)
          CALL add_comment_ob_add(j,k)
         ELSEIF (problem_updated=true)
          CALL add_comment_ob_upd(j,k)
         ELSE
          CALL add_problem_ob_upd(j)
          SET do_ob_upd = true
          CALL add_comment_ob_upd(j,k)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   IF ((request->problem[j].problem_discipline_cnt > 0))
    SET stat = alterlist(reply->problem_list[j].discipline_list,request->problem[j].
     problem_discipline_cnt)
    FOR (k = 1 TO request->problem[j].problem_discipline_cnt)
      SET reply->problem_list[j].discipline_list[k].management_discipline_cd = request->problem[j].
      problem_discipline[k].management_discipline_cd
      SET discipline_exist = false
      SET problem_discipline_id = 0.0
      CALL does_discipline_exist(j,k)
      IF (failed != false)
       GO TO exit_script
      ENDIF
      IF (discipline_exist=true
       AND (request->problem[j].problem_discipline[k].discipline_action_ind=del))
       SET reply->problem_list[j].discipline_list[k].problem_discipline_id = problem_discipline_id
       SET reply->problem_list[j].discipline_list[k].management_discipline_cd = request->problem[j].
       problem_discipline[k].management_discipline_cd
       SET request->problem[j].problem_discipline[k].problem_discipline_id = problem_discipline_id
       CALL deactivate_discipline(j,k)
       IF (failed != false)
        GO TO exit_script
       ENDIF
       IF (ob_trigger_on=true)
        CALL echo("***")
        CALL echo("***   ob_trigger_on = TRUE")
        CALL echo("***   ob_del_cd touched")
        CALL echo("***")
        SET ob_interface_cd = ob_upd_cd
        IF (problem_updated != true)
         CALL add_problem_ob_upd(j)
         SET do_ob_upd = true
         SET problem_updated = true
         CALL add_discipline_ob_upd(j,k)
        ELSE
         CALL add_discipline_ob_upd(j,k)
        ENDIF
       ENDIF
      ELSEIF (discipline_exist=false
       AND (request->problem[j].problem_discipline[k].discipline_action_ind != del))
       CALL get_new_problem_id(dvar)
       IF (new_code < 1)
        SET failed = gen_nbr_error
        SET table_name = "PROBLEM_DISCIPLINE"
        SET reply->swarnmsg = "Could not generate new problem_discipline_id"
        SET serrmsg = "Failed to generate number"
        GO TO exit_script
       ENDIF
       SET reply->problem_list[j].discipline_list[k].problem_discipline_id = new_code
       SET request->problem[j].problem_discipline[k].problem_discipline_id = new_code
       SET reply->problem_list[j].discipline_list[k].management_discipline_cd = request->problem[j].
       problem_discipline[k].management_discipline_cd
       CALL insert_discipline(j,k)
       IF (failed != false)
        GO TO exit_script
       ENDIF
       IF (ob_trigger_on=true)
        CALL echo("***")
        CALL echo("***   ob_trigger_on = TRUE")
        CALL echo("***")
        IF (problem_added=true)
         CALL add_discipline_ob_add(j,k)
        ELSEIF (problem_updated=true)
         CALL add_discipline_ob_upd(j,k)
        ELSE
         CALL add_problem_ob_upd(j)
         SET do_ob_upd = true
         SET problem_updated = true
         CALL add_discipline_ob_upd(j,k)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((request->problem[j].problem_prsnl_cnt > 0))
    SET stat = alterlist(reply->problem_list[j].prsnl_list,request->problem[j].problem_prsnl_cnt)
    SET code_set = 12038
    SET code_cnt = 1
    SET recorder_code = 0.0
    SET stat = uar_get_meaning_by_codeset(code_set,"RECORDER",code_cnt,recorder_code)
    SET recorder_exist = false
    SET recorder_id = 0.0
    SET problem_prsnl_id = 0.0
    CALL does_recorder_prsnl_exist(j,recorder_code)
    IF (failed != false)
     SET reply->swarnmsg = "Couldn't determine if a RECORDER row exist"
     GO TO exit_script
    ENDIF
    IF (problem_prsnl_id > 0)
     SET recorder_exist = true
     SET recorder_id = problem_prsnl_id
    ENDIF
    FOR (k = 1 TO request->problem[j].problem_prsnl_cnt)
      SET reply->problem_list[j].prsnl_list[k].problem_prsnl_id = request->problem[j].problem_prsnl[k
      ].problem_prsnl_id
      SET reply->problem_list[j].prsnl_list[k].problem_reltn_cd = request->problem[j].problem_prsnl[k
      ].problem_reltn_cd
      IF ((request->problem[j].problem_prsnl[k].problem_reltn_cd=recorder_code))
       SET reply->problem_list[j].prsnl_list[k].problem_prsnl_id = recorder_id
       IF ((request->problem[j].problem_prsnl[k].prsnl_action_ind=del))
        SET reply->problem_list[j].prsnl_list[j].sreturnmsg = "WARNING:  Can not Remove Recorder."
       ELSEIF (recorder_exist=false)
        CALL get_new_problem_id(dvar)
        IF (new_code < 1)
         SET failed = gen_nbr_error
         SET table_name = "PROBLEM_PRSNL_R"
         SET reply->swarnmsg = "Could not generate new problem_comment_id"
         SET serrmsg = "Failed to generate number"
         GO TO exit_script
        ENDIF
        SET request->problem[j].problem_prsnl[k].problem_prsnl_id = new_code
        CALL insert_prsnl(j,k)
        IF (failed != false)
         SET reply->swarnmsg = "Failed inserting PROBLEM_PRSNL_RELTN row"
         GO TO exit_script
        ENDIF
        SET recorder_exist = true
        SET reply->problem_list[j].prsnl_list[k].problem_prsnl_id = new_code
        IF (ob_trigger_on=true)
         CALL echo("***")
         CALL echo("***   ob_trigger_on = TRUE")
         CALL echo("***")
         IF (problem_added=true)
          CALL add_prsnl_ob_add(j,k,new_code)
         ELSEIF (problem_updated=true)
          CALL add_prsnl_ob_upd(j,k,new_code)
         ELSE
          CALL add_problem_ob_upd(j)
          SET do_ob_upd = true
          SET problem_updated = true
          CALL add_prsnl_ob_upd(j,k,new_code)
         ENDIF
        ENDIF
       ENDIF
      ELSE
       IF ((request->problem[j].problem_prsnl[k].problem_prsnl_id < 1))
        SET problem_prsnl_id = 0.0
        CALL does_prsnl_exist(j,request->problem[j].problem_prsnl[k].problem_reltn_cd,request->
         problem[j].problem_prsnl[k].problem_reltn_prsnl_id)
        SET request->problem[j].problem_prsnl[k].problem_prsnl_id = problem_prsnl_id
        SET reply->problem_list[j].prsnl_list[k].problem_prsnl_id = problem_prsnl_id
        IF (failed != false)
         SET reply->swarnmsg = "Failed to determine if relationship exist"
         GO TO exit_script
        ENDIF
       ELSE
        SET problem_prsnl_id = request->problem[j].problem_prsnl[k].problem_prsnl_id
       ENDIF
       IF ((request->problem[j].problem_prsnl[k].prsnl_action_ind=del)
        AND problem_prsnl_id > 0)
        CALL deactivate_prsnl(j,k)
        IF (failed != false)
         SET reply->swarnmsg = "Failed to deactivate data row"
         GO TO exit_script
        ENDIF
        IF (ob_trigger_on=true)
         IF (problem_added=true)
          CALL add_prsnl_ob_add(j,k,problem_prsnl_id)
         ELSEIF (problem_updated=true)
          CALL add_prsnl_ob_upd(j,k,problem_prsnl_id)
         ELSE
          CALL add_problem_ob_upd(j)
          SET do_ob_upd = true
          SET problem_updated = true
          CALL add_prsnl_ob_upd(j,k,problem_prsnl_id)
         ENDIF
        ENDIF
       ELSEIF (problem_prsnl_id < 1
        AND (request->problem[j].problem_prsnl[k].prsnl_action_ind != del))
        CALL get_new_problem_id(dvar)
        IF (new_code < 1)
         SET failed = gen_nbr_error
         SET table_name = "PROBLEM_PRSNL_ID"
         SET reply->swarnmsg = "Could not generate new problem_comment_id"
         SET serrmsg = "Failed to generate number"
         GO TO exit_script
        ENDIF
        SET problem_prsnl_id = new_code
        SET reply->problem_list[j].prsnl_list[k].problem_prsnl_id = new_code
        CALL insert_prsnl(j,k)
        IF (failed != false)
         SET reply->swarnmsg = "Failed to insert item"
         GO TO exit_script
        ENDIF
        IF (ob_trigger_on=true)
         IF (problem_added=true)
          CALL add_prsnl_ob_add(j,k,problem_prsnl_id)
         ELSEIF (problem_updated=true)
          CALL add_prsnl_ob_upd(j,k,problem_prsnl_id)
         ELSE
          CALL add_problem_ob_upd(j)
          SET do_ob_upd = true
          SET problem_updated = true
          CALL add_prsnl_ob_upd(j,k,problem_prsnl_id)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    IF (recorder_exist=false)
     SET list_size = size(reply->problem_list[j].prsnl_list,5)
     SET stat = alterlist(reply->problem_list[j].prsnl_list,(list_size+ 1))
     SET reply->problem_list[j].prsnl_list[(list_size+ 1)].problem_reltn_cd = recorder_code
     CALL get_new_problem_id(dvar)
     IF (new_code < 1)
      SET failed = gen_nbr_error
      SET table_name = "PROBLEM_PRSNL_ID"
      SET reply->swarnmsg = "Could not generate new problem_comment_id"
      SET serrmsg = "Failed to generate number"
      GO TO exit_script
     ENDIF
     SET problem_prsnl_id = new_code
     CALL add_recorder(j)
     IF (failed != false)
      SET reply->swarnmsg = "Failed to insert the recorder of the problem"
      SET reply->problem_list[j].prsnl_list[(list_size+ 1)].sreturnmsg =
      "ERROR:  Failed to Insert row."
      GO TO exit_script
     ENDIF
     IF (ob_trigger_on=true)
      CALL echo("***")
      CALL echo("***   ob_trigger_on = TRUE")
      CALL echo("***")
      IF (problem_added=true)
       CALL add_prsnl_ob_add(j,k,problem_prsnl_id)
      ELSEIF (problem_updated=true)
       CALL add_prsnl_ob_upd(j,k,problem_prsnl_id)
      ELSE
       CALL add_problem_ob_upd(j)
       SET do_ob_upd = true
       SET problem_updated = true
       CALL add_prsnl_ob_upd(j,k,problem_prsnl_id)
      ENDIF
     ENDIF
     SET reply->problem_list[j].prsnl_list[(list_size+ 1)].problem_prsnl_id = new_code
    ENDIF
   ENDIF
 ENDFOR
 IF (ob_trigger_on=true)
  EXECUTE si_srvrtl
  SUBROUTINE init_srv_stuff(messageid,get_hreq,get_hrep)
    CALL echo("In Init_Srv_Stuff() routine...")
    SET m_idx = size(srvrec->qual,5)
    SET m_idx = (m_idx+ 1)
    SET stat = alterlist(srvrec->qual,m_idx)
    SET srvrec->qual[m_idx].msg_id = messageid
    CALL echo(build("srvrec->qual[m_idx]->msg_id = ",srvrec->qual[m_idx].msg_id))
    SET srvrec->qual[m_idx].hmsg = uar_srvselectmessage(srvrec->qual[m_idx].msg_id)
    IF (srvrec->qual[m_idx].hmsg)
     IF (get_hreq)
      SET srvrec->qual[m_idx].hreq = uar_srvcreaterequest(srvrec->qual[m_idx].hmsg)
      IF ( NOT (srvrec->qual[m_idx].hreq))
       CALL echo("The uar_SrvCreateRequest() FAILED!!")
       RETURN(0)
      ENDIF
     ENDIF
     IF (get_hrep)
      SET srvrec->qual[m_idx].hrep = uar_srvcreatereply(srvrec->qual[m_idx].hmsg)
      IF ( NOT (srvrec->qual[m_idx].hrep))
       CALL echo("The uar_SrvCreateReply() FAILED!!")
       IF (srvrec->qual[m_idx].hreq)
        CALL uar_srvdestroyinstance(srvrec->qual[m_idx].hreq)
        SET srvrec->qual[m_idx].hreq = 0
       ENDIF
       RETURN(0)
      ENDIF
     ENDIF
    ELSE
     CALL echo("The uar_SrvSelectMessage() FAILED!!")
     RETURN(0)
    ENDIF
    CALL echo("Exiting Init_Srv_Stuff() routine... ")
    RETURN(1)
  END ;Subroutine
  SUBROUTINE cleanup_srv_stuff(dummy1)
    CALL echo("In CleanUp_Srv_Stuff() routine...")
    FOR (i = 1 TO size(srvrec->qual,5))
      CALL echo(build("i = ",i))
      IF ((srvrec->qual[i].hreq > 0))
       CALL uar_srvdestroyinstance(srvrec->qual[i].hreq)
      ENDIF
      IF ((srvrec->qual[i].hrep > 0))
       CALL uar_srvdestroyinstance(srvrec->qual[i].hrep)
      ENDIF
    ENDFOR
    IF (size(srvrec->qual,5))
     SET stat = alterlist(srvrec->qual,0)
    ENDIF
    CALL echo("Exiting CleanUp_Srv_Stuff() routine...")
    RETURN(1)
  END ;Subroutine
  FREE RECORD srvrec
  RECORD srvrec(
    1 qual[*]
      2 msg_id = i4
      2 hmsg = i4
      2 hreq = i4
      2 hrep = i4
      2 status = i4
  )
  DECLARE init_srv_stuff(messageid,get_hreq,get_hrep) = i2
  DECLARE cleanup_srv_stuff(dummy1) = i2
  DECLARE hmsgtype = i4
  DECLARE hmsgstruct = i4
  DECLARE hcqmstruct = i4
  DECLARE htrigitem = i4
  DECLARE hproblemitem = i4
  DECLARE hdisciplineitem = i4
  DECLARE hcommentitem = i4
  DECLARE hprsnlitem = i4
  DECLARE cqmmessageid = i4
  DECLARE trigmessageid = i4
  SET cqmmessageid = 1215001
  SET trigmessageid = 1215024
 ENDIF
 IF (do_ob_add=true)
  CALL echo("***")
  CALL echo("***   doing out-bound add logic")
  CALL echo("***")
  SET hmsgtype = 0
  SET hmsgstruct = 0
  SET hcqmstruct = 0
  SET htrigitem = 0
  SET hproblemitem = 0
  SET hdisciplineitem = 0
  SET hprsnlitem = 0
  SET hcommentitem = 0
  SET cqmmessageid = 1215001
  SET trigmessageid = 1215024
  CALL init_srv_stuff(cqmmessageid,1,1)
  CALL init_srv_stuff(trigmessageid,1,1)
  CALL echo("***")
  CALL echo("***   Getting hMsgType")
  CALL echo("***")
  SET hmsgtype = uar_srvcreaterequesttype(srvrec->qual[2].hmsg)
  SET stat = uar_srvrecreateinstance(srvrec->qual[1].hreq,hmsgtype)
  CALL uar_srvdestroytype(hmsgtype)
  CALL echo("***")
  CALL echo("***   Getting hMsgStruct")
  CALL echo("***")
  SET hmsgstruct = uar_srvgetstruct(srvrec->qual[1].hreq,"message")
  IF (hmsgstruct)
   CALL echo("***")
   CALL echo("***   Getting hCqmStruct")
   CALL echo("***")
   SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"cqminfo")
   IF (hcqmstruct)
    CALL echo("***")
    CALL echo("***   Populating fields in hCqmStruct")
    CALL echo("***")
    SET stat = uar_srvsetstring(hcqmstruct,"AppName","FSIESO")
    SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias","CPS_ENS_PROBLEM")
    SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",trim(cnvtstring(ob_add->person_id)))
    SET stat = uar_srvsetlong(hcqmstruct,"Priority",99)
    SET stat = uar_srvsetstring(hcqmstruct,"Class","PM_PROBLEM")
    SET stat = uar_srvsetstring(hcqmstruct,"Type","PPR")
    SET stat = uar_srvsetstring(hcqmstruct,"Subtype","PC1")
    SET stat = uar_srvsetstring(hcqmstruct,"Subtype_detail",trim(cnvtstring(ob_add->person_id)))
    SET stat = uar_srvsetlong(hcqmstruct,"Debug_Ind",0)
    SET stat = uar_srvsetlong(hcqmstruct,"Verbosity_Flag",0)
    CALL echo("***")
    CALL echo("***   Getting hTrigItem")
    CALL echo("***")
    SET htrigitem = uar_srvadditem(hmsgstruct,"TRIGInfo")
    IF (htrigitem)
     CALL echo("***")
     CALL echo("***   Populating fields in hTrigItem")
     CALL echo("***")
     SET stat = uar_srvsetdouble(htrigitem,"person_id",ob_add->person_id)
     SET pknt = 0
     WHILE (pknt < size(ob_add->problem,5))
       SET pknt = (pknt+ 1)
       CALL echo("***")
       CALL echo("***   Getting hProblemItem")
       CALL echo("***")
       SET hproblemitem = uar_srvadditem(htrigitem,"problem")
       IF (hproblemitem)
        CALL echo("***")
        CALL echo("***   Populating fields in hProblemItem")
        CALL echo("***")
        SET stat = uar_srvsetdouble(hproblemitem,"interface_action_cd",ob_add->problem[pknt].
         interface_action_cd)
        SET stat = uar_srvsetdouble(hproblemitem,"problem_id",ob_add->problem[pknt].problem_id)
        SET stat = uar_srvsetdouble(hproblemitem,"problem_instance_id",ob_add->problem[pknt].
         problem_instance_id)
        SET dknt = 0
        WHILE (dknt < size(ob_add->problem[pknt].discipline,5))
          SET dknt = (dknt+ 1)
          CALL echo("***")
          CALL echo("***   Getting hDisciplineItem")
          CALL echo("***")
          SET hdisciplineitem = uar_srvadditem(hproblemitem,"discipline")
          IF (hdisciplineitem)
           CALL echo("***")
           CALL echo("***   Populating fields in hDisciplineItem")
           CALL echo("***")
           SET stat = uar_srvsetdouble(hdisciplineitem,"interface_action_cd",ob_add->problem[pknt].
            discipline[dknt].interface_action_cd)
           SET stat = uar_srvsetdouble(hdisciplineitem,"problem_discipline_id",ob_add->problem[pknt].
            discipline[dknt].problem_discipline_id)
          ELSE
           CALL echo("FAILURE hDisciplineItem")
          ENDIF
        ENDWHILE
        SET plknt = 0
        WHILE (plknt < size(ob_add->problem[pknt].prsnl,5))
          SET plknt = (plknt+ 1)
          CALL echo("***")
          CALL echo("***   Getting hPrsnlItem")
          CALL echo("***")
          SET hprsnlitem = uar_srvadditem(hproblemitem,"prsnl")
          IF (hprsnlitem)
           CALL echo("***")
           CALL echo("***   Populating fields in hPrsnlItem")
           CALL echo("***")
           SET stat = uar_srvsetdouble(hprsnlitem,"interface_action_cd",ob_add->problem[pknt].prsnl[
            plknt].interface_action_cd)
           SET stat = uar_srvsetdouble(hprsnlitem,"problem_prsnl_id",ob_add->problem[pknt].prsnl[
            plknt].problem_prsnl_id)
          ELSE
           CALL echo("FAILURE hPrsnlItem")
          ENDIF
        ENDWHILE
        SET cknt = 0
        WHILE (cknt < size(ob_add->problem[pknt].comment,5))
          SET cknt = (cknt+ 1)
          CALL echo("***")
          CALL echo("***   Getting hCommentItem")
          CALL echo("***")
          SET hcommentitem = uar_srvadditem(hproblemitem,"comment")
          IF (hcommentitem)
           CALL echo("***")
           CALL echo("***   Populating field in hCommentItem")
           CALL echo("***")
           SET stat = uar_srvsetdouble(hcommentitem,"problem_comment_id",ob_add->problem[pknt].
            comment[cknt].problem_comment_id)
          ELSE
           CALL echo("FAILURE hCommentItem")
          ENDIF
        ENDWHILE
       ELSE
        CALL ehco("FAILURE hProblemItem")
       ENDIF
     ENDWHILE
    ELSE
     CALL echo("FAILURE hTrigItem")
    ENDIF
   ELSE
    CALL echo("FAILURE!! hCqmStruct")
   ENDIF
  ELSE
   CALL echo("FAILURE!! hMsgStruct")
  ENDIF
  CALL echo("***")
  CALL echo("***   Doing uar_SrvExecute")
  CALL echo("***")
  SET iret = uar_srvexecute(srvrec->qual[1].hmsg,srvrec->qual[1].hreq,srvrec->qual[1].hrep)
  CASE (iret)
   OF 0:
    CALL echo("Successful Srv Execute ")
   OF 1:
    CALL echo("Srv Execute failed - Communication Error - FSI Hold Release Server may be down")
   OF 2:
    IF (messageid=0)
     CALL echo("TDB Message Id is zero...")
    ELSE
     CALL echo("SrvSelectMessage failed -- May need to perfrom CCLSECLOGIN")
    ENDIF
   OF 3:
    CALL echo("Failed to allocate either the Request or Reply Handle")
  ENDCASE
  CALL cleanup_srv_stuff(1)
  IF (iret > 0)
   CALL echo(" CQM server is not running.  Start Downtime logic.")
   SET req_out->message.cqminfo.appname = "FSIESO"
   SET req_out->message.cqminfo.contribalias = "CPS_ENS_PROBLEM"
   SET req_out->message.cqminfo.contribrefnum = nullterm(trim(cnvtstring(ob_add->person_id)))
   SET req_out->message.cqminfo.priority = 99
   SET req_out->message.cqminfo.class = "PM_PROBLEM"
   SET req_out->message.cqminfo.type = "PPR"
   SET req_out->message.cqminfo.subtype = "PC1"
   SET req_out->message.cqminfo.subtype_detail = nullterm(trim(cnvtstring(ob_add->person_id)))
   SET req_out->message.cqminfo.debug_ind = 0
   SET req_out->message.cqminfo.verbosity_flag = 0
   SET stat = alterlist(req_out->message.triginfo,1)
   IF ((ob_add->person_id > 0))
    SET req_out->message.triginfo[1].person_id = ob_add->person_id
   ENDIF
   SET prob_qual = size(ob_add->problem,5)
   SET stat = alterlist(req_out->message.triginfo[1].problem,prob_qual)
   FOR (prob_idx = 1 TO prob_qual)
     IF ((ob_add->problem[prob_idx].interface_action_cd > 0))
      SET req_out->message.triginfo[1].problem[prob_idx].interface_action_cd = ob_add->problem[
      prob_idx].interface_action_cd
     ENDIF
     IF ((ob_add->problem[prob_idx].problem_id > 0))
      SET req_out->message.triginfo[1].problem[prob_idx].problem_id = ob_add->problem[prob_idx].
      problem_id
     ENDIF
     IF ((ob_add->problem[prob_idx].problem_instance_id > 0))
      SET req_out->message.triginfo[1].problem[prob_idx].problem_instance_id = ob_add->problem[
      prob_idx].problem_instance_id
     ENDIF
     SET d_qual = 0
     SET d_qual = size(ob_add->problem[prob_idx].discipline,5)
     SET stat = alterlist(req_out->message.triginfo[1].problem[prob_idx].discipline,d_qual)
     FOR (d_idx = 1 TO d_qual)
      IF ((ob_add->problem[prob_idx].discipline[d_qual].problem_discipline_id > 0))
       SET req_out->message.triginfo[1].problem[prob_idx].discipline[d_idx].problem_discipline_id =
       ob_add->problem[prob_idx].discipline[d_idx].problem_discipline_id
      ENDIF
      IF ((ob_add->problem[prob_idx].discipline[d_qual].interface_action_cd > 0))
       SET req_out->message.triginfo[1].problem[prob_idx].discipline[d_idx].interface_action_cd =
       ob_add->problem[prob_idx].discipline[d_idx].interface_action_cd
      ENDIF
     ENDFOR
     SET prsnl_qual = 0
     SET prsnl_qual = size(ob_add->problem[prob_idx].prsnl,5)
     SET stat = alterlist(req_out->message.triginfo[1].problem[prob_idx].prsnl,prsnl_qual)
     FOR (prsnl_idx = 1 TO prsnl_qual)
      IF ((ob_add->problem[prob_idx].prsnl[prsnl_idx].problem_prsnl_id > 0))
       SET req_out->message.triginfo[1].problem[prob_idx].prsnl[prsnl_idx].problem_prsnl_id = ob_add
       ->problem[prob_idx].prsnl[prsnl_idx].problem_prsnl_id
      ENDIF
      IF ((ob_add->problem[prob_idx].prsnl[prsnl_idx].interface_action_cd > 0))
       SET req_out->message.triginfo[1].problem[prob_idx].prsnl[prsnl_idx].interface_action_cd =
       ob_add->problem[prob_idx].prsnl[prsnl_idx].interface_action_cd
      ENDIF
     ENDFOR
     SET c_qual = 0
     SET c_qual = size(ob_add->problem[prob_idx].comment,5)
     SET stat = alterlist(req_out->message.triginfo[1].problem[prob_idx].comment,c_qual)
     FOR (c_idx = 1 TO c_qual)
       IF ((ob_add->problem[prob_idx].comment[c_idx].problem_comment_id > 0))
        SET req_out->message.triginfo[1].problem[prob_idx].comment[c_idx].problem_comment_id = ob_add
        ->problem[prob_idx].comment[c_idx].problem_comment_id
       ENDIF
     ENDFOR
   ENDFOR
   EXECUTE eso_add_cqm_downtime  WITH replace("REQUEST","REQ_OUT")
  ENDIF
 ENDIF
 IF (do_ob_upd=true)
  CALL echo("***")
  CALL echo("***   doing out-bound add logic")
  CALL echo("***")
  SET hmsgtype = 0
  SET hmsgstruct = 0
  SET hcqmstruct = 0
  SET htrigitem = 0
  SET hproblemitem = 0
  SET hdisciplineitem = 0
  SET hprsnlitem = 0
  SET hcommentitem = 0
  SET cqmmessageid = 1215001
  SET trigmessageid = 1215024
  CALL init_srv_stuff(cqmmessageid,1,1)
  CALL init_srv_stuff(trigmessageid,1,1)
  SET hmsgtype = uar_srvcreaterequesttype(srvrec->qual[2].hmsg)
  SET stat = uar_srvrecreateinstance(srvrec->qual[1].hreq,hmsgtype)
  CALL uar_srvdestroytype(hmsgtype)
  SET hmsgstruct = uar_srvgetstruct(srvrec->qual[1].hreq,"message")
  IF (hmsgstruct)
   SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"cqminfo")
   IF (hcqmstruct)
    SET stat = uar_srvsetstring(hcqmstruct,"AppName","FSIESO")
    SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias","CPS_ENS_PROBLEM")
    SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",trim(cnvtstring(ob_upd->person_id)))
    SET stat = uar_srvsetlong(hcqmstruct,"Priority",99)
    SET stat = uar_srvsetstring(hcqmstruct,"Class","PM_PROBLEM")
    SET stat = uar_srvsetstring(hcqmstruct,"Type","PPR")
    SET stat = uar_srvsetstring(hcqmstruct,"Subtype","PC2")
    SET stat = uar_srvsetstring(hcqmstruct,"Subtype_detail",trim(cnvtstring(ob_upd->person_id)))
    SET stat = uar_srvsetlong(hcqmstruct,"Debug_Ind",0)
    SET stat = uar_srvsetlong(hcqmstruct,"Verbosity_Flag",0)
    SET htrigitem = uar_srvadditem(hmsgstruct,"TRIGInfo")
    IF (htrigitem)
     SET stat = uar_srvsetdouble(htrigitem,"person_id",ob_upd->person_id)
     SET pknt = 0
     WHILE (pknt < size(ob_upd->problem,5))
       SET pknt = (pknt+ 1)
       SET hproblemitem = uar_srvadditem(htrigitem,"problem")
       IF (hproblemitem)
        SET stat = uar_srvsetdouble(hproblemitem,"interface_action_cd",ob_upd->problem[pknt].
         interface_action_cd)
        SET stat = uar_srvsetdouble(hproblemitem,"problem_id",ob_upd->problem[pknt].problem_id)
        SET stat = uar_srvsetdouble(hproblemitem,"problem_instance_id",ob_upd->problem[pknt].
         problem_instance_id)
        SET dknt = 0
        WHILE (dknt < size(ob_upd->problem[pknt].discipline,5))
          SET dknt = (dknt+ 1)
          SET hdisciplineitem = uar_srvadditem(hproblemitem,"discipline")
          IF (hdisciplineitem)
           SET stat = uar_srvsetdouble(hdisciplineitem,"interface_action_cd",ob_upd->problem[pknt].
            discipline[dknt].interface_action_cd)
           SET stat = uar_srvsetdouble(hdisciplineitem,"problem_discipline_id",ob_upd->problem[pknt].
            discipline[dknt].problem_discipline_id)
          ELSE
           CALL echo("FAILURE hDisciplineItem")
          ENDIF
        ENDWHILE
        SET plknt = 0
        WHILE (plknt < size(ob_upd->problem[pknt].prsnl,5))
          SET plknt = (plknt+ 1)
          SET hprsnlitem = uar_srvadditem(hproblemitem,"prsnl")
          IF (hprsnlitem)
           SET stat = uar_srvsetdouble(hprsnlitem,"interface_action_cd",ob_upd->problem[pknt].prsnl[
            plknt].interface_action_cd)
           SET stat = uar_srvsetdouble(hprsnlitem,"problem_prsnl_id",ob_upd->problem[pknt].prsnl[
            plknt].problem_prsnl_id)
          ELSE
           CALL echo("FAILURE hPrsnlItem")
          ENDIF
        ENDWHILE
        SET cknt = 0
        WHILE (cknt < size(ob_upd->problem[pknt].comment,5))
          SET cknt = (cknt+ 1)
          SET hcommentitem = uar_srvadditem(hproblemitem,"comment")
          IF (hcommentitem)
           SET stat = uar_srvsetdouble(hcommentitem,"problem_comment_id",ob_upd->problem[pknt].
            comment[cknt].problem_comment_id)
          ELSE
           CALL echo("FAILURE hCommentItem")
          ENDIF
        ENDWHILE
       ELSE
        CALL ehco("FAILURE hProblemItem")
       ENDIF
     ENDWHILE
    ELSE
     CALL echo("FAILURE hTrigItem")
    ENDIF
   ELSE
    CALL echo("FAILURE!! hCqmStruct")
   ENDIF
  ELSE
   CALL echo("FAILURE!! hMsgStruct")
  ENDIF
  SET iret = uar_srvexecute(srvrec->qual[1].hmsg,srvrec->qual[1].hreq,srvrec->qual[1].hrep)
  CASE (iret)
   OF 0:
    CALL echo("Successful Srv Execute ")
   OF 1:
    CALL echo("Srv Execute failed - Communication Error - FSI Hold Release Server may be down")
   OF 2:
    IF (messageid=0)
     CALL echo("TDB Message Id is zero...")
    ELSE
     CALL echo("SrvSelectMessage failed -- May need to perfrom CCLSECLOGIN")
    ENDIF
   OF 3:
    CALL echo("Failed to allocate either the Request or Reply Handle")
  ENDCASE
  CALL cleanup_srv_stuff(1)
  IF (iret > 0)
   CALL echo(" CQM server is not running.  Start Downtime logic.")
   SET req_out->message.cqminfo.appname = "FSIESO"
   SET req_out->message.cqminfo.contribalias = "CPS_ENS_PROBLEM"
   SET req_out->message.cqminfo.contribrefnum = nullterm(trim(cnvtstring(ob_add->person_id)))
   SET req_out->message.cqminfo.priority = 99
   SET req_out->message.cqminfo.class = "PM_PROBLEM"
   SET req_out->message.cqminfo.type = "PPR"
   SET req_out->message.cqminfo.subtype = "PC2"
   SET req_out->message.cqminfo.subtype_detail = nullterm(trim(cnvtstring(ob_add->person_id)))
   SET req_out->message.cqminfo.debug_ind = 0
   SET req_out->message.cqminfo.verbosity_flag = 0
   SET stat = alterlist(req_out->message.triginfo,1)
   IF ((ob_add->person_id > 0))
    SET req_out->message.triginfo[1].person_id = ob_add->person_id
   ENDIF
   SET prob_qual = size(ob_add->problem,5)
   SET stat = alterlist(req_out->message.triginfo[1].problem,prob_qual)
   FOR (prob_idx = 1 TO prob_qual)
     IF ((ob_add->problem[prob_idx].interface_action_cd > 0))
      SET req_out->message.triginfo[1].problem[prob_idx].interface_action_cd = ob_add->problem[
      prob_idx].interface_action_cd
     ENDIF
     IF ((ob_add->problem[prob_idx].problem_id > 0))
      SET req_out->message.triginfo[1].problem[prob_idx].problem_id = ob_add->problem[prob_idx].
      problem_id
     ENDIF
     IF ((ob_add->problem[prob_idx].problem_instance_id > 0))
      SET req_out->message.triginfo[1].problem[prob_idx].problem_instance_id = ob_add->problem[
      prob_idx].problem_instance_id
     ENDIF
     SET d_qual = 0
     SET d_qual = size(ob_add->problem[prob_idx].discipline,5)
     SET stat = alterlist(req_out->message.triginfo[1].problem[prob_idx].discipline,d_qual)
     FOR (d_idx = 1 TO d_qual)
      IF ((ob_add->problem[prob_idx].discipline[d_qual].problem_discipline_id > 0))
       SET req_out->message.triginfo[1].problem[prob_idx].discipline[d_idx].problem_discipline_id =
       ob_add->problem[prob_idx].discipline[d_idx].problem_discipline_id
      ENDIF
      IF ((ob_add->problem[prob_idx].discipline[d_qual].interface_action_cd > 0))
       SET req_out->message.triginfo[1].problem[prob_idx].discipline[d_idx].interface_action_cd =
       ob_add->problem[prob_idx].discipline[d_idx].interface_action_cd
      ENDIF
     ENDFOR
     SET prsnl_qual = 0
     SET prsnl_qual = size(ob_add->problem[prob_idx].prsnl,5)
     SET stat = alterlist(req_out->message.triginfo[1].problem[prob_idx].prsnl,prsnl_qual)
     FOR (prsnl_idx = 1 TO prsnl_qual)
      IF ((ob_add->problem[prob_idx].prsnl[prsnl_idx].problem_prsnl_id > 0))
       SET req_out->message.triginfo[1].problem[prob_idx].prsnl[prsnl_idx].problem_prsnl_id = ob_add
       ->problem[prob_idx].prsnl[prsnl_idx].problem_prsnl_id
      ENDIF
      IF ((ob_add->problem[prob_idx].prsnl[prsnl_idx].interface_action_cd > 0))
       SET req_out->message.triginfo[1].problem[prob_idx].prsnl[prsnl_idx].interface_action_cd =
       ob_add->problem[prob_idx].prsnl[prsnl_idx].interface_action_cd
      ENDIF
     ENDFOR
     SET c_qual = 0
     SET c_qual = size(ob_add->problem[prob_idx].comment,5)
     SET stat = alterlist(req_out->message.triginfo[1].problem[prob_idx].comment,c_qual)
     FOR (c_idx = 1 TO c_qual)
       IF ((ob_add->problem[prob_idx].comment[c_idx].problem_comment_id > 0))
        SET req_out->message.triginfo[1].problem[prob_idx].comment[c_idx].problem_comment_id = ob_add
        ->problem[prob_idx].comment[c_idx].problem_comment_id
       ENDIF
     ENDFOR
   ENDFOR
   EXECUTE eso_add_cqm_downtime  WITH replace("REQUEST","REQ_OUT")
  ENDIF
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  SET reqinfo->commit_ind = false
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ENDIF
 SET script_version = "017 11/18/03 SF3151"
END GO
