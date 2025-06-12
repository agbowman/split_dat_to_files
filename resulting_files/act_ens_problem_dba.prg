CREATE PROGRAM act_ens_problem:dba
 FREE SET reply
 RECORD reply(
   1 person_id = f8
   1 problem_list[*]
     2 problem_instance_id = f8
     2 problem_id = f8
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
   1 swarnmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE add = i2 WITH public, constant(1)
 DECLARE upt = i2 WITH public, constant(2)
 DECLARE del = i2 WITH public, constant(3)
 DECLARE force_add = i2 WITH public, constant(4)
 DECLARE force_upt = i2 WITH public, constant(5)
 DECLARE modify = i2 WITH public, constant(6)
 DECLARE inactivate = i2 WITH public, constant(7)
 DECLARE select_error = i2 WITH public, constant(1)
 DECLARE insert_error = i2 WITH public, constant(2)
 DECLARE gen_nbr_error = i2 WITH public, constant(3)
 DECLARE update_error = i2 WITH public, constant(4)
 DECLARE input_error = i2 WITH public, constant(5)
 DECLARE lock_error = i2 WITH public, constant(6)
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = i2 WITH public, noconstant(0)
 DECLARE swarnmsg = vc WITH public, noconstant(" ")
 DECLARE table_name = vc WITH public, noconstant(" ")
 DECLARE qual = i4 WITH public, noconstant(size(request->problem,5))
 DECLARE pd_cnt = i4 WITH public, noconstant(0)
 DECLARE pc_cnt = i4 WITH public, noconstant(0)
 DECLARE ppr_cnt = i4 WITH public, noconstant(0)
 DECLARE dvar = i4 WITH public, noconstant(0)
 DECLARE nbr_of_sec = i4 WITH public, noconstant(0)
 DECLARE nbr_of_grps = i4 WITH public, noconstant(0)
 DECLARE nxt_seq = i4 WITH public, noconstant(0)
 DECLARE do_upt = i2 WITH public, noconstant(0)
 DECLARE new_code = f8 WITH public, noconstant(0.0)
 DECLARE tproblem_id = f8 WITH public, noconstant(0.0)
 DECLARE ppr_problem = f8 WITH public, noconstant(0.0)
 DECLARE active = f8 WITH public, noconstant(0.0)
 DECLARE inactive = f8 WITH public, noconstant(0.0)
 DECLARE canceled = f8 WITH public, noconstant(0.0)
 DECLARE recorder = f8 WITH public, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET reply->person_id = request->person_id
 SET stat = alterlist(reply->problem_list,qual)
 SET current_date = cnvtdatetime(curdate,curtime3)
 SET ppr_problem = uar_get_code_by("MEANING",19169,"PPR_PROBLEM")
 SET canceled = uar_get_code_by("MEANING",12030,"CANCELED")
 SET inactive_stat = uar_get_code_by("MEANING",12030,"INACTIVE")
 SET recorder = uar_get_code_by("MEANING",12038,"RECORDER")
 IF ((reqdata->active_status_cd < 1))
  SET active = uar_get_code_by("MEANING",48,"ACTIVE")
 ELSE
  SET active = reqdata->active_status_cd
 ENDIF
 IF ((reqdata->inactive_status_cd < 1))
  SET inactive = uar_get_code_by("MEANING",48,"INACTIVE")
 ELSE
  SET inactive = reqdata->inactive_status_cd
 ENDIF
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
       AND p.life_cycle_status_cd != canceled)
    ELSE
     PLAN (p
      WHERE p.person_id=tperson_id
       AND p.problem_ftdesc=tprob_ftdesc
       AND p.active_ind=1
       AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND p.life_cycle_status_cd != canceled)
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
 SUBROUTINE get_next_seq(next_seq)
   CALL echo("***")
   CALL echo("***   get_next_seq")
   CALL echo("***")
   SET new_code = 0.0
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)"##################;rp0"
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
     ELSEIF ((p.course_cd != request->problem[tidx].course_cd))
      pure_dup = false
     ELSEIF ((p.family_aware_cd != request->problem[tidx].family_aware_cd))
      pure_dup = false
     ELSEIF ((p.life_cycle_status_cd != request->problem[tidx].life_cycle_status_cd))
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
     ELSEIF ((p.qualifier_cd != request->problem[tidx].qualifier_cd))
      pure_dup = false
     ELSEIF ((p.severity_cd != request->problem[tidx].severity_cd))
      pure_dup = false
     ELSEIF ((p.severity_class_cd != request->problem[tidx].severity_class_cd))
      pure_dup = false
     ELSEIF (((p.severity_ftdesc=null
      AND (request->problem[tidx].severity_ftdesc > " ")) OR (p.severity_ftdesc != null
      AND (p.severity_ftdesc != request->problem[tidx].severity_ftdesc))) )
      pure_dup = false
     ELSEIF (((p.annotated_display=null
      AND (request->problem[tidx].annotated_display > " ")) OR (p.annotated_display != null
      AND (p.annotated_display != request->problem[tidx].annotated_display))) )
      pure_dup = false
     ELSEIF (((p.probability=null
      AND (request->problem[tidx].probability > 0)) OR (p.probability != null
      AND (p.probability != request->problem[tidx].probability))) )
      pure_dup = false
     ELSEIF (((p.life_cycle_dt_tm=null
      AND (request->problem[tidx].life_cycle_dt_tm > 0)) OR (p.life_cycle_dt_tm != null
      AND (p.life_cycle_dt_tm != request->problem[tidx].life_cycle_dt_tm))) )
      pure_dup = false
     ELSEIF (((p.onset_dt_tm=null
      AND (request->problem[tidx].onset_dt_tm > 0)) OR (p.onset_dt_tm != null
      AND (p.onset_dt_tm != request->problem[tidx].onset_dt_tm))) )
      pure_dup = false
     ELSEIF ((p.onset_dt_flag != request->problem[tidx].onset_dt_flag))
      pure_dup = false
     ELSEIF ((p.onset_dt_cd != request->problem[tidx].onset_dt_cd))
      pure_dup = false
     ELSEIF (((p.status_updt_dt_tm=null
      AND (request->problem[tidx].status_upt_dt_tm > 0)) OR (p.status_updt_dt_tm != null
      AND (p.status_updt_dt_tm != request->problem[tidx].status_upt_dt_tm))) )
      pure_dup = false
     ELSEIF ((p.status_updt_precision_cd != request->problem[tidx].status_upt_precision_cd))
      pure_dup = false
     ELSEIF ((p.status_updt_flag != request->problem[tidx].status_upt_precision_flag))
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
    AND (request->problem[aidx].life_cycle_status_cd != canceled))
    SET request->problem[aidx].life_cycle_status_cd = canceled
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
     , p.classification_cd =
     IF ((request->problem[aidx].classification_cd=0)) 0.00
     ELSE request->problem[aidx].classification_cd
     ENDIF
     ,
     p.persistence_cd =
     IF ((request->problem[aidx].persistence_cd=0)) 0.00
     ELSE request->problem[aidx].persistence_cd
     ENDIF
     , p.confirmation_status_cd = request->problem[aidx].confirmation_status_cd, p
     .life_cycle_status_cd = request->problem[aidx].life_cycle_status_cd,
     p.life_cycle_dt_tm =
     IF ((request->problem[aidx].life_cycle_dt_tm != 0)) cnvtdatetime(request->problem[aidx].
       life_cycle_dt_tm)
     ELSE null
     ENDIF
     , p.onset_dt_flag = request->problem[aidx].onset_dt_flag, p.onset_dt_cd = request->problem[aidx]
     .onset_dt_cd,
     p.onset_dt_tm =
     IF ((request->problem[aidx].onset_dt_tm != 0)) cnvtdatetime(request->problem[aidx].onset_dt_tm)
     ELSE null
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
     , p.course_cd =
     IF ((request->problem[aidx].course_cd=0)) 0
     ELSE request->problem[aidx].course_cd
     ENDIF
     ,
     p.cancel_reason_cd =
     IF ((request->problem[aidx].cancel_reason_cd=0)) 0
     ELSE request->problem[aidx].cancel_reason_cd
     ENDIF
     , p.active_ind = 1, p.active_status_cd = active,
     p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
     updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59"), p.data_status_cd = reqdata->
     data_status_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
     p.data_status_prsnl_id = reqinfo->updt_id, p.contributor_system_cd = reqdata->
     contributor_system_cd, p.annotated_display =
     IF ((request->problem[aidx].annotated_display=" ")) null
     ELSE request->problem[aidx].annotated_display
     ENDIF
     ,
     p.qualifier_cd = request->problem[aidx].qualifier_cd, p.severity_class_cd = request->problem[
     aidx].severity_class_cd, p.severity_cd = request->problem[aidx].severity_cd,
     p.severity_ftdesc =
     IF ((request->problem[aidx].severity_ftdesc=" ")) null
     ELSE request->problem[aidx].severity_ftdesc
     ENDIF
     , p.status_updt_dt_tm =
     IF ((request->problem[aidx].status_upt_dt_tm <= 0)) null
     ELSE cnvtdatetime(request->problem[aidx].status_upt_dt_tm)
     ENDIF
     , p.status_updt_precision_cd = request->problem[aidx].status_upt_precision_cd,
     p.status_updt_flag = request->problem[aidx].status_upt_precision_flag, p.updt_applctx = reqinfo
     ->updt_applctx, p.updt_cnt = 0,
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
   CALL echo(build("***   INACTIVE:",inactive))
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
    IF ((((request->problem[aidx].problem_action_ind=modify)) OR ((request->problem[aidx].
    problem_action_ind=inactivate))) )
     UPDATE  FROM problem p
      SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.active_ind = 0, p
       .active_status_cd = inactive,
       p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
       updt_id, p.updt_applctx = reqinfo->updt_applctx,
       p.updt_task = reqinfo->updt_task, p.updt_cnt = (p.updt_cnt+ 1)
      PLAN (p
       WHERE (p.problem_instance_id=request->problem[aidx].problem_instance_id)
        AND (p.problem_id=request->problem[aidx].problem_id))
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM problem p
      SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_applctx = reqinfo->
       updt_applctx, p.updt_task = reqinfo->updt_task,
       p.updt_cnt = (p.updt_cnt+ 1)
      PLAN (p
       WHERE (p.problem_instance_id=request->problem[aidx].problem_instance_id)
        AND (p.problem_id=request->problem[aidx].problem_id))
      WITH nocounter
     ;end update
    ENDIF
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
     .comment_dt_tm = cnvtdatetime(request->problem[aidx].problem_comment[bidx].comment_dt_tm), pc
     .active_ind = 1,
     pc.active_status_cd = active, pc.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pc
     .active_status_prsnl_id = reqinfo->updt_id,
     pc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pc.end_effective_dt_tm =
     IF ((request->problem[aidx].problem_comment[bidx].end_effective_dt_tm <= 0)) cnvtdatetime(
       "31-DEC-2100 00:00:00.00")
     ELSE cnvtdatetime(request->problem[aidx].problem_comment[bidx].end_effective_dt_tm)
     ENDIF
     , pc.data_status_cd = reqdata->data_status_cd,
     pc.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pc.data_status_prsnl_id = reqinfo->
     updt_id, pc.contributor_system_cd = reqdata->contributor_system_cd,
     pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0, pc.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task
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
    SET pd.active_ind = 0, pd.active_status_cd = inactive, pd.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
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
     pd.active_ind = 1, pd.active_status_cd = active, pd.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3),
     pd.active_status_prsnl_id = reqinfo->updt_id, pd.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), pd.end_effective_dt_tm =
     IF ((request->problem[aidx].problem_discipline[bidx].end_effective_dt_tm <= 0)) cnvtdatetime(
       "31-DEC-2100 00:00:00.00")
     ELSE cnvtdatetime(request->problem[aidx].problem_discipline[bidx].end_effective_dt_tm)
     ENDIF
     ,
     pd.data_status_cd = reqdata->data_status_cd, pd.data_status_dt_tm = cnvtdatetime(curdate,
      curtime3), pd.data_status_prsnl_id = reqinfo->updt_id,
     pd.contributor_system_cd = reqdata->contributor_system_cd, pd.updt_applctx = reqinfo->
     updt_applctx, pd.updt_cnt = 0,
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
     AND pp.problem_reltn_cd=recorder
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
     pp.active_status_cd = active, pp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pp
     .active_status_prsnl_id = reqinfo->updt_id,
     pp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pp.end_effective_dt_tm =
     IF ((request->problem[aidx].problem_prsnl[bidx].end_effective_dt_tm <= 0)) cnvtdatetime(
       "31-DEC-2100 00:00:00.00")
     ELSE cnvtdatetime(request->problem[aidx].problem_prsnl[bidx].end_effective_dt_tm)
     ENDIF
     , pp.data_status_cd = reqdata->data_status_cd,
     pp.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pp.data_status_prsnl_id = reqinfo->
     updt_id, pp.contributor_system_cd = reqdata->contributor_system_cd,
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
     .problem_reltn_cd = recorder,
     pp.problem_reltn_dt_tm = cnvtdatetime(curdate,curtime3), pp.problem_reltn_prsnl_id = reqinfo->
     updt_id, pp.active_ind = 1,
     pp.active_status_cd = active, pp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pp
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
    SET pp.active_ind = 0, pp.active_status_cd = inactive, pp.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
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
 SUBROUTINE insert_proc_modifier(aidx,bidx)
   CALL echo("***")
   CALL echo("***   insert_proc_modifier")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   IF ((request->problem[aidx].problem_id=0.0))
    SET failed = input_error
    SET table_name = "PROBLEM"
    SET reply->swarnmsg = "Problem_id equals zero for secondary_desc insert"
    GO TO exit_script
   ENDIF
   FOR (a = 1 TO nbr_of_grps)
     SET nxt_seq = 0
     CALL get_next_seq(nxt_seq)
     IF (new_code > 0)
      SET request->problem[aidx].secondary_desc_list[bidx].group[a].secondary_desc_id = new_code
     ELSE
      SET failed = gen_nbr_error
      SET table_name = "PROC_MODIFIER"
      SET reply->swarnmsg = "Could not generate new proc_modifier_id"
      SET serrmsg = "Failed to generate number"
      GO TO exit_script
     ENDIF
     CALL echo(build("Inserting into PROC_MODIFIER table:",request->problem[aidx].
       secondary_desc_list[bidx].group[a].secondary_desc_id))
     INSERT  FROM proc_modifier pm
      SET pm.proc_modifier_id = request->problem[aidx].secondary_desc_list[bidx].group[a].
       secondary_desc_id, pm.active_ind = 1, pm.active_status_cd = active,
       pm.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pm.active_status_prsnl_id = reqinfo->
       updt_id, pm.parent_entity_name = "PROBLEM",
       pm.group_seq = request->problem[aidx].secondary_desc_list[bidx].group_sequence, pm.sequence =
       request->problem[aidx].secondary_desc_list[bidx].group[a].sequence, pm.beg_effective_dt_tm =
       cnvtdatetime(curdate,curtime3),
       pm.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), pm.parent_entity_id =
       request->problem[aidx].problem_id, pm.nomenclature_id = request->problem[aidx].
       secondary_desc_list[bidx].group[a].nomenclature_id,
       pm.updt_dt_tm = cnvtdatetime(curdate,curtime3), pm.updt_id = reqinfo->updt_id, pm.updt_cnt = 0,
       pm.updt_task = reqinfo->updt_task, pm.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = insert_error
      SET tablename = "PROC_MODIFIER"
      SET reply->swarnmsg = "ERROR:  Failed to Insert row."
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE update_proc_modifier(aidx,bidx)
   CALL echo("***")
   CALL echo("***   update_proc_modifier")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   CALL echo(build("Updating group_sequence on proc_modifier table:",request->problem[aidx].
     secondary_desc_list[bidx].group_sequence))
   UPDATE  FROM proc_modifier pm
    SET pm.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pm.active_ind = 0, pm
     .active_status_cd = inactive,
     pm.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pm.active_status_prsnl_id = reqinfo->
     updt_id, pm.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pm.updt_cnt = (pm.updt_cnt+ 1), pm.updt_id = reqinfo->updt_id, pm.updt_task = reqinfo->updt_task,
     pm.updt_applctx = reqinfo->updt_applctx
    WHERE (pm.parent_entity_id=request->problem[aidx].problem_id)
     AND pm.parent_entity_name="PROBLEM"
     AND (pm.group_seq=request->problem[aidx].secondary_desc_list[bidx].group_sequence)
     AND pm.active_ind=1
     AND pm.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = insert_error
    SET tablename = "PROC_MODIFIER"
    SET reply->swarnmsg = "ERROR:  Failed to Insert row."
   ENDIF
 END ;Subroutine
 SUBROUTINE check_secondary_description(aidx)
   CALL echo("***")
   CALL echo("***   check_secondary_description")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SET nbr_of_sec = size(request->problem[aidx].secondary_desc_list,5)
   FOR (y = 1 TO nbr_of_sec)
     SET haschanged = false
     SET nbr_of_grps = size(request->problem[aidx].secondary_desc_list[y].group,5)
     SET count1 = 0
     SELECT INTO "nl:"
      pm.parent_entity_id, pm.parent_entity_name, pm.group_seq,
      pm.active_ind, pm.beg_effective_dt_tm, pm.end_effective_dt_tm
      FROM proc_modifier pm
      WHERE (pm.parent_entity_id=request->problem[aidx].problem_id)
       AND pm.parent_entity_name="PROBLEM"
       AND (pm.group_seq=request->problem[aidx].secondary_desc_list[y].group_sequence)
       AND pm.active_ind=1
       AND pm.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 = (count1+ 1)
      WITH nocounter
     ;end select
     IF (count1=0)
      CALL echo("The value of count1 is zero, so inserting")
     ELSEIF (count1 > 0
      AND count1 != nbr_of_grps)
      CALL echo("The value of count1 != nbr_of_grps")
      SET haschanged = true
     ELSE
      CALL echo(build("Searching proc_modifier table:",request->problem[aidx].problem_id))
      SELECT INTO "nl:"
       pm.nomenclature_id, pm.sequence
       FROM (dummyt d  WITH seq = value(nbr_of_grps)),
        proc_modifier pm
       PLAN (d)
        JOIN (pm
        WHERE (pm.parent_entity_id=request->problem[aidx].problem_id)
         AND pm.parent_entity_name="PROBLEM"
         AND (pm.group_seq=request->problem[aidx].secondary_desc_list[y].group_sequence)
         AND pm.active_ind=1
         AND pm.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
         AND (pm.sequence=request->problem[aidx].secondary_desc_list[y].group[d.seq].sequence))
       HEAD REPORT
        haschanged = false
       DETAIL
        IF ((((request->problem[aidx].secondary_desc_list[y].group[d.seq].nomenclature_id != pm
        .nomenclature_id)) OR ((request->problem[aidx].secondary_desc_list[y].group[d.seq].
        secondary_desc_id != pm.proc_modifier_id))) )
         haschanged = true
        ENDIF
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET failed = validate
       SET reply->swarnmsg = build("Can't find any of the sequences for group_sequence:",request->
        problem[aidx].secondary_desc_list[y].group_sequence)
       GO TO exit_script
      ENDIF
     ENDIF
     IF (haschanged=false
      AND count1=0)
      CALL insert_proc_modifier(aidx,y)
     ELSEIF (haschanged=false
      AND count1 > 0)
      CALL echo(build("Did not update the sequence:",request->problem[aidx].secondary_desc_list[y].
        group_sequence))
     ELSE
      CALL update_proc_modifier(aidx,y)
      CALL insert_proc_modifier(aidx,y)
     ENDIF
   ENDFOR
   CALL echo(build("Inactivating hanging descriptions for problem_id:",request->problem[aidx].
     problem_id))
   UPDATE  FROM proc_modifier pm
    SET pm.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pm.active_ind = 0, pm
     .active_status_cd = reqdata->inactive_status_cd,
     pm.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pm.active_status_prsnl_id = reqinfo->
     updt_id, pm.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pm.updt_cnt = (pm.updt_cnt+ 1), pm.updt_id = reqinfo->updt_id, pm.updt_task = reqinfo->updt_task,
     pm.updt_applctx = reqinfo->updt_applctx
    WHERE (pm.parent_entity_id=request->problem[aidx].problem_id)
     AND pm.parent_entity_name="PROBLEM"
     AND pm.group_seq > nbr_of_sec
     AND pm.active_ind=1
   ;end update
   IF (curqual=0)
    CALL echo(build("No hanging descriptions found for diagnosis_group_id:",request->problem[aidx].
      problem_id))
   ENDIF
 END ;Subroutine
 FOR (j = 1 TO qual)
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
   IF ((request->problem[j].problem_id > 0))
    SELECT INTO "nl:"
     FROM problem p
     PLAN (p
      WHERE (p.problem_id=request->problem[j].problem_id)
       AND ((p.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
     ORDER BY p.beg_effective_dt_tm
     DETAIL
      CASE (request->person_idf)
       OF 0:
        request->person_id = p.person_id
       OF 1:
        request->person_id = request->person_id
       OF 2:
        request->person_id = null
      ENDCASE
      request->problem[j].problem_instance_id = p.problem_instance_id
      CASE (request->problem[j].nomenclature_idf)
       OF 0:
        request->problem[j].nomenclature_id = p.nomenclature_id
       OF 1:
        request->problem[j].nomenclature_id = request->problem[j].nomenclature_id
       OF 2:
        request->problem[j].nomenclature_id = null
      ENDCASE
      CASE (request->problem[j].annotated_displayf)
       OF 0:
        request->problem[j].annotated_display = p.annotated_display
       OF 1:
        request->problem[j].annotated_display = request->problem[j].annotated_display
       OF 2:
        request->problem[j].annotated_display = ""
      ENDCASE
      CASE (request->problem[j].problem_ftdescf)
       OF 0:
        request->problem[j].problem_ftdesc = p.problem_ftdesc
       OF 1:
        request->problem[j].problem_ftdesc = request->problem[j].problem_ftdesc
       OF 2:
        request->problem[j].problem_ftdesc = ""
      ENDCASE
      CASE (request->problem[j].classification_cdf)
       OF 0:
        request->problem[j].classification_cd = p.classification_cd
       OF 1:
        request->problem[j].classification_cd = request->problem[j].classification_cd
       OF 2:
        request->problem[j].classification_cd = null
      ENDCASE
      CASE (request->problem[j].confirmation_status_cdf)
       OF 0:
        request->problem[j].confirmation_status_cd = p.confirmation_status_cd
       OF 1:
        request->problem[j].confirmation_status_cd = request->problem[j].confirmation_status_cd
       OF 2:
        request->problem[j].confirmation_status_cd = null
      ENDCASE
      CASE (request->problem[j].qualifier_cdf)
       OF 0:
        request->problem[j].qualifier_cd = p.qualifier_cd
       OF 1:
        request->problem[j].qualifier_cd = request->problem[j].qualifier_cd
       OF 2:
        request->problem[j].qualifier_cd = null
      ENDCASE
      CASE (request->problem[j].life_cycle_status_cdf)
       OF 0:
        request->problem[j].life_cycle_status_cd = p.life_cycle_status_cd
       OF 1:
        request->problem[j].life_cycle_status_cd = request->problem[j].life_cycle_status_cd
       OF 2:
        request->problem[j].life_cycle_status_cd = null
      ENDCASE
      CASE (request->problem[j].life_cycle_dt_tmf)
       OF 0:
        request->problem[j].life_cycle_dt_tm = p.life_cycle_dt_tm
       OF 1:
        request->problem[j].life_cycle_dt_tm = request->problem[j].life_cycle_dt_tm
       OF 2:
        request->problem[j].life_cycle_dt_tm = null
      ENDCASE
      CASE (request->problem[j].persistence_cdf)
       OF 0:
        request->problem[j].persistence_cd = p.persistence_cd
       OF 1:
        request->problem[j].persistence_cd = request->problem[j].persistence_cd
       OF 2:
        request->problem[j].persistence_cd = null
      ENDCASE
      CASE (request->problem[j].certainty_cdf)
       OF 0:
        request->problem[j].certainty_cd = p.certainty_cd
       OF 1:
        request->problem[j].certainty_cd = request->problem[j].certainty_cd
       OF 2:
        request->problem[j].certainty_cd = null
      ENDCASE
      CASE (request->problem[j].ranking_cdf)
       OF 0:
        request->problem[j].ranking_cd = p.ranking_cd
       OF 1:
        request->problem[j].ranking_cd = request->problem[j].ranking_cd
       OF 2:
        request->problem[j].ranking_cd = null
      ENDCASE
      CASE (request->problem[j].probabilityf)
       OF 0:
        request->problem[j].probability = p.probability
       OF 1:
        request->problem[j].probability = request->problem[j].probability
       OF 2:
        request->problem[j].probability = null
      ENDCASE
      CASE (request->problem[j].onset_dt_flagf)
       OF 0:
        request->problem[j].onset_dt_flag = p.onset_dt_flag
       OF 1:
        request->problem[j].onset_dt_flag = request->problem[j].onset_dt_flag
       OF 2:
        request->problem[j].onset_dt_flag = null
      ENDCASE
      CASE (request->problem[j].onset_dt_cdf)
       OF 0:
        request->problem[j].onset_dt_cd = p.onset_dt_cd
       OF 1:
        request->problem[j].onset_dt_cd = request->problem[j].onset_dt_cd
       OF 2:
        request->problem[j].onset_dt_cd = null
      ENDCASE
      CASE (request->problem[j].onset_dt_tmf)
       OF 0:
        request->problem[j].onset_dt_tm = p.onset_dt_tm
       OF 1:
        request->problem[j].onset_dt_tm = request->problem[j].onset_dt_tm
       OF 2:
        request->problem[j].onset_dt_tm = null
      ENDCASE
      CASE (request->problem[j].course_cdf)
       OF 0:
        request->problem[j].course_cd = p.course_cd
       OF 1:
        request->problem[j].course_cd = request->problem[j].course_cd
       OF 2:
        request->problem[j].course_cd = null
      ENDCASE
      CASE (request->problem[j].severity_class_cdf)
       OF 0:
        request->problem[j].severity_class_cd = p.severity_class_cd
       OF 1:
        request->problem[j].severity_class_cd = request->problem[j].severity_class_cd
       OF 2:
        request->problem[j].severity_class_cd = null
      ENDCASE
      CASE (request->problem[j].severity_cdf)
       OF 0:
        request->problem[j].severity_cd = p.severity_cd
       OF 1:
        request->problem[j].severity_cd = request->problem[j].severity_cd
       OF 2:
        request->problem[j].severity_cd = null
      ENDCASE
      CASE (request->problem[j].severity_ftdescf)
       OF 0:
        request->problem[j].severity_ftdesc = p.severity_ftdesc
       OF 1:
        request->problem[j].severity_ftdesc = request->problem[j].severity_ftdesc
       OF 2:
        request->problem[j].severity_ftdesc = ""
      ENDCASE
      CASE (request->problem[j].prognosis_cdf)
       OF 0:
        request->problem[j].prognosis_cd = p.prognosis_cd
       OF 1:
        request->problem[j].prognosis_cd = request->problem[j].prognosis_cd
       OF 2:
        request->problem[j].prognosis_cd = null
      ENDCASE
      CASE (request->problem[j].person_aware_cdf)
       OF 0:
        request->problem[j].person_aware_cd = p.person_aware_cd
       OF 1:
        request->problem[j].person_aware_cd = request->problem[j].person_aware_cd
       OF 2:
        request->problem[j].person_aware_cd = null
      ENDCASE
      CASE (request->problem[j].family_aware_cdf)
       OF 0:
        request->problem[j].family_aware_cd = p.family_aware_cd
       OF 1:
        request->problem[j].family_aware_cd = request->problem[j].family_aware_cd
       OF 2:
        request->problem[j].family_aware_cd = null
      ENDCASE
      CASE (request->problem[j].person_aware_prognosis_cdf)
       OF 0:
        request->problem[j].person_aware_prognosis_cd = p.person_aware_prognosis_cd
       OF 1:
        request->problem[j].person_aware_prognosis_cd = request->problem[j].person_aware_prognosis_cd
       OF 2:
        request->problem[j].person_aware_prognosis_cd = null
      ENDCASE
      CASE (request->problem[j].beg_effective_dt_tmf)
       OF 0:
        request->problem[j].beg_effective_dt_tm = p.beg_effective_dt_tm
       OF 1:
        request->problem[j].beg_effective_dt_tm = request->problem[j].beg_effective_dt_tm
       OF 2:
        request->problem[j].beg_effective_dt_tm = null
      ENDCASE
      CASE (request->problem[j].end_effective_dt_tmf)
       OF 0:
        request->problem[j].end_effective_dt_tm = p.end_effective_dt_tm
       OF 1:
        request->problem[j].end_effective_dt_tm = request->problem[j].end_effective_dt_tm
       OF 2:
        request->problem[j].end_effective_dt_tm = null
      ENDCASE
      CASE (request->problem[j].status_upt_precision_flagf)
       OF 0:
        request->problem[j].status_upt_precision_flag = p.status_updt_flag
       OF 1:
        request->problem[j].status_upt_precision_flag = request->problem[j].status_upt_precision_flag
       OF 2:
        request->problem[j].status_upt_precision_flag = null
      ENDCASE
      CASE (request->problem[j].status_upt_precision_cdf)
       OF 0:
        request->problem[j].status_upt_precision_cd = p.status_updt_precision_cd
       OF 1:
        request->problem[j].status_upt_precision_cd = request->problem[j].status_upt_precision_cd
       OF 2:
        request->problem[j].status_upt_precision_cd = null
      ENDCASE
      CASE (request->problem[j].status_upt_dt_tmf)
       OF 0:
        request->problem[j].status_upt_dt_tm = p.status_updt_dt_tm
       OF 1:
        request->problem[j].status_upt_dt_tm = request->problem[j].status_upt_dt_tm
       OF 2:
        request->problem[j].status_upt_dt_tm = null
      ENDCASE
      CASE (request->problem[j].cancel_reason_cdf)
       OF 0:
        request->problem[j].cancel_reason_cd = p.cancel_reason_cd
       OF 1:
        request->problem[j].cancel_reason_cd = request->problem[j].cancel_reason_cd
       OF 2:
        request->problem[j].cancel_reason_cd = null
      ENDCASE
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed = input_error
     GO TO exit_script
    ENDIF
   ENDIF
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
     IF ((request->problem[j].problem_action_ind != inactivate))
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
     ENDIF
    ELSE
     SET reply->problem_list[j].sreturnmsg = "Problem is a pure duplicate : No action taken"
     SET reply->problem_list[j].problem_id = tproblem_id
     SET reply->problem_list[j].problem_instance_id = tproblem_instance_id
    ENDIF
   ENDIF
   SET pc_cnt = size(request->problem[j].problem_comment,5)
   IF (pc_cnt > 0)
    SET stat = alterlist(reply->problem_list[j].comment_list,pc_cnt)
    FOR (k = 1 TO pc_cnt)
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
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   SET pd_cnt = size(request->problem[j].problem_discipline,5)
   IF (pd_cnt > 0)
    SET stat = alterlist(reply->problem_list[j].discipline_list,pd_cnt)
    FOR (k = 1 TO pd_cnt)
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
      ENDIF
    ENDFOR
   ENDIF
   SET ppr_cnt = size(request->problem[j].problem_prsnl,5)
   IF (ppr_cnt > 0)
    SET stat = alterlist(reply->problem_list[j].prsnl_list,ppr_cnt)
    SET code_cnt = 1
    SET recorder_exist = false
    SET recorder_id = 0.0
    SET problem_prsnl_id = 0.0
    CALL does_recorder_prsnl_exist(j,recorder)
    IF (failed != false)
     SET reply->swarnmsg = "Couldn't determine if a RECORDER row exist"
     GO TO exit_script
    ENDIF
    IF (problem_prsnl_id > 0)
     SET recorder_exist = true
     SET recorder_id = problem_prsnl_id
    ENDIF
    FOR (k = 1 TO ppr_cnt)
      SET reply->problem_list[j].prsnl_list[k].problem_prsnl_id = request->problem[j].problem_prsnl[k
      ].problem_prsnl_id
      SET reply->problem_list[j].prsnl_list[k].problem_reltn_cd = request->problem[j].problem_prsnl[k
      ].problem_reltn_cd
      IF ((request->problem[j].problem_prsnl[k].problem_reltn_cd=recorder))
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
       ENDIF
      ENDIF
    ENDFOR
    IF (recorder_exist=false)
     SET list_size = size(reply->problem_list[j].prsnl_list,5)
     SET stat = alterlist(reply->problem_list[j].prsnl_list,(list_size+ 1))
     SET reply->problem_list[j].prsnl_list[(list_size+ 1)].problem_reltn_cd = recorder
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
     SET reply->problem_list[j].prsnl_list[(list_size+ 1)].problem_prsnl_id = new_code
    ENDIF
   ENDIF
   CALL check_secondary_description(j)
 ENDFOR
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
END GO
