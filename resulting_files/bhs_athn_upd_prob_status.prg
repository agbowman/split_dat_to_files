CREATE PROGRAM bhs_athn_upd_prob_status
 FREE RECORD result
 RECORD result(
   1 comment = vc
   1 person_id = f8
   1 problem_instance_id = f8
   1 problem_id = f8
   1 organization_id = f8
   1 nomenclature_id = f8
   1 annotated_display = vc
   1 source_vocabulary_cd = f8
   1 source_identifier = vc
   1 problem_ftdesc = vc
   1 classification_cd = f8
   1 confirmation_status_cd = f8
   1 qualifier_cd = f8
   1 life_cycle_status_cd = f8
   1 life_cycle_dt_tm = dq8
   1 life_cycle_dt_cd = f8
   1 life_cycle_dt_flag = i2
   1 persistence_cd = f8
   1 certainty_cd = f8
   1 ranking_cd = f8
   1 probability = f8
   1 onset_dt_flag = i2
   1 onset_dt_cd = f8
   1 onset_dt_tm = dq8
   1 onset_tz = i4
   1 course_cd = f8
   1 severity_class_cd = f8
   1 severity_cd = f8
   1 severity_ftdesc = vc
   1 prognosis_cd = f8
   1 person_aware_cd = f8
   1 family_aware_cd = f8
   1 person_aware_prognosis_cd = f8
   1 end_effective_dt_tm = dq8
   1 status_upt_precision_flag = i2
   1 status_upt_precision_cd = f8
   1 status_upt_dt_tm = dq8
   1 cancel_reason_cd = f8
   1 contributor_system_cd = f8
   1 problem_uuid = vc
   1 problem_instance_uuid = vc
   1 problem_type_flag = i2
   1 show_in_pm_history_ind = i2
   1 laterality_cd = f8
   1 originating_nomenclature_id = f8
   1 problem_prsnl[*]
     2 prsnl_action_ind = i2
     2 problem_reltn_dt_tm = dq8
     2 problem_reltn_cd = f8
     2 problem_prsnl_id = f8
     2 problem_reltn_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 new_problem_instance_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4170165
 RECORD req4170165(
   1 person_id = f8
   1 problem[*]
     2 problem_action_ind = i2
     2 problem_id = f8
     2 problem_instance_id = f8
     2 organization_id = f8
     2 nomenclature_id = f8
     2 annotated_display = vc
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 problem_ftdesc = vc
     2 classification_cd = f8
     2 confirmation_status_cd = f8
     2 qualifier_cd = f8
     2 life_cycle_status_cd = f8
     2 life_cycle_dt_tm = dq8
     2 persistence_cd = f8
     2 certainty_cd = f8
     2 ranking_cd = f8
     2 probability = f8
     2 onset_dt_flag = i2
     2 onset_dt_cd = f8
     2 onset_dt_tm = dq8
     2 course_cd = f8
     2 severity_class_cd = f8
     2 severity_cd = f8
     2 severity_ftdesc = vc
     2 prognosis_cd = f8
     2 person_aware_cd = f8
     2 family_aware_cd = f8
     2 person_aware_prognosis_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 status_upt_precision_flag = i2
     2 status_upt_precision_cd = f8
     2 status_upt_dt_tm = dq8
     2 cancel_reason_cd = f8
     2 problem_comment[*]
       3 problem_comment_id = f8
       3 comment_action_ind = i2
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 problem_comment = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 problem_discipline[*]
       3 discipline_action_ind = i2
       3 problem_discipline_id = f8
       3 management_discipline_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 problem_prsnl[*]
       3 prsnl_action_ind = i2
       3 problem_reltn_dt_tm = dq8
       3 problem_reltn_cd = f8
       3 problem_prsnl_id = f8
       3 problem_reltn_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 secondary_desc_list[*]
       3 group_sequence = i4
       3 group[*]
         4 secondary_desc_id = f8
         4 nomenclature_id = f8
         4 sequence = i4
     2 related_problem_list[*]
       3 active_ind = i2
       3 child_entity_id = f8
       3 reltn_subtype_cd = f8
       3 priority = i4
       3 child_nomen_id = f8
       3 child_ftdesc = vc
     2 contributor_system_cd = f8
     2 problem_uuid = vc
     2 problem_instance_uuid = vc
     2 problem_type_flag = i4
     2 show_in_pm_history_ind = i2
     2 life_cycle_dt_cd = f8
     2 life_cycle_dt_flag = i2
     2 laterality_cd = f8
     2 originating_nomenclature_id = f8
     2 onset_tz = i4
   1 user_id = f8
   1 skip_fsi_trigger = i2
 ) WITH protect
 FREE RECORD rep4170165
 RECORD rep4170165(
   1 person_org_sec_on = i2
   1 person_id = f8
   1 problem_list[*]
     2 problem_id = f8
     2 problem_instance_id = f8
     2 problem_ftdesc = vc
     2 nomenclature_id = f8
     2 sreturnmsg = vc
     2 review_dt_tm = dq8
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
     2 problem_uuid = vc
     2 problem_instance_uuid = vc
     2 related_problem_list[*]
       3 active_ind = i2
       3 child_entity_id = f8
       3 reltn_subtype_cd = f8
       3 priority = i4
       3 child_nomen_id = f8
       3 child_ftdesc = vc
     2 beg_effective_dt_tm = dq8
   1 swarnmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callproblemensureserver(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 SET result->status_data.status = "F"
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 IF (( $2 <= 0.0))
  CALL echo("INVALID PROBLEM ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $5 <= 0.0))
  CALL echo("INVALID STATUS CODE PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 IF (textlen(trim( $9,3)))
  SET req_format_str->param =  $9
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->comment = nullterm(trim(rep_format_str->param,3))
 ENDIF
 DECLARE ppr_cnt = i4 WITH protect, noconstant(0)
 DECLARE end_of_time = dq8 WITH protect, constant(cnvtdatetime("31 DEC 2100 00:00:00"))
 SELECT INTO "NL:"
  FROM problem p,
   nomenclature n,
   problem_prsnl_r ppr
  PLAN (p
   WHERE (p.problem_id= $2)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= sysdate
    AND p.end_effective_dt_tm > sysdate)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
   JOIN (ppr
   WHERE ppr.problem_id=outerjoin(p.problem_id)
    AND ppr.beg_effective_dt_tm <= outerjoin(sysdate)
    AND ppr.end_effective_dt_tm > outerjoin(sysdate)
    AND ppr.active_ind=outerjoin(1))
  ORDER BY p.problem_id, p.beg_effective_dt_tm DESC, ppr.beg_effective_dt_tm
  HEAD p.problem_id
   result->person_id = p.person_id, result->problem_id = p.problem_id, result->problem_instance_id =
   p.problem_instance_id,
   result->organization_id = p.organization_id, result->problem_ftdesc = p.problem_ftdesc, result->
   classification_cd = p.classification_cd,
   result->confirmation_status_cd = p.confirmation_status_cd, result->qualifier_cd = p.qualifier_cd,
   result->persistence_cd = p.persistence_cd,
   result->certainty_cd = p.certainty_cd, result->ranking_cd = p.ranking_cd, result->probability = p
   .probability,
   result->onset_dt_flag = p.onset_dt_flag, result->onset_dt_cd = p.onset_dt_cd
   IF (p.onset_dt_tm > 0)
    result->onset_dt_tm = p.onset_dt_tm
   ENDIF
   result->course_cd = p.course_cd, result->severity_class_cd = p.severity_class_cd, result->
   severity_cd = p.severity_cd,
   result->severity_ftdesc = p.severity_ftdesc, result->prognosis_cd = p.prognosis_cd, result->
   person_aware_cd = p.person_aware_cd,
   result->family_aware_cd = p.family_aware_cd, result->person_aware_prognosis_cd = p
   .person_aware_prognosis_cd
   IF (p.end_effective_dt_tm < end_of_time)
    result->end_effective_dt_tm = p.end_effective_dt_tm
   ENDIF
   result->status_upt_precision_flag = p.status_updt_flag, result->status_upt_precision_cd = p
   .status_updt_precision_cd
   IF (p.status_updt_dt_tm > 0)
    result->status_upt_dt_tm = p.status_updt_dt_tm
   ENDIF
   result->cancel_reason_cd = p.cancel_reason_cd, result->annotated_display = p.annotated_display,
   result->nomenclature_id = n.nomenclature_id,
   result->source_vocabulary_cd = n.source_vocabulary_cd, result->source_identifier = n
   .source_identifier, result->contributor_system_cd = p.contributor_system_cd,
   result->problem_uuid = p.problem_uuid, result->problem_instance_uuid = p.problem_instance_uuid,
   result->problem_type_flag = p.problem_type_flag,
   result->show_in_pm_history_ind = p.show_in_pm_history_ind, result->life_cycle_dt_cd = p
   .life_cycle_dt_cd, result->life_cycle_dt_flag = p.life_cycle_dt_flag,
   result->laterality_cd = p.laterality_cd, result->originating_nomenclature_id = p
   .originating_nomenclature_id, result->onset_tz = p.onset_tz,
   ppr_cnt = 0
  HEAD ppr.problem_reltn_prsnl_id
   IF (ppr.problem_reltn_prsnl_id > 0)
    ppr_cnt = (ppr_cnt+ 1), stat = alterlist(result->problem_prsnl,ppr_cnt), result->problem_prsnl[
    ppr_cnt].problem_reltn_dt_tm = ppr.problem_reltn_dt_tm,
    result->problem_prsnl[ppr_cnt].problem_reltn_cd = ppr.problem_reltn_cd, result->problem_prsnl[
    ppr_cnt].problem_prsnl_id = ppr.problem_prsnl_id, result->problem_prsnl[ppr_cnt].
    problem_reltn_prsnl_id = ppr.problem_reltn_prsnl_id
    IF (ppr.beg_effective_dt_tm > 0)
     result->problem_prsnl[ppr_cnt].beg_effective_dt_tm = ppr.beg_effective_dt_tm
    ENDIF
    IF (ppr.end_effective_dt_tm > 0)
     result->problem_prsnl[ppr_cnt].end_effective_dt_tm = ppr.end_effective_dt_tm
    ENDIF
   ENDIF
  WITH nocounter, time = 30
 ;end select
 IF ((result->problem_instance_id <= 0))
  CALL echo("INVALID PROBLEM_ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callproblemensureserver(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, v2 = build("<ProblemInstanceId>",cnvtint(result->new_problem_instance_id),
     "</ProblemInstanceId>"),
    col + 1, v2, row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req4170165
 FREE RECORD rep4170165
 FREE RECORD i_request
 FREE RECORD i_reply
 SUBROUTINE callproblemensureserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(4170147)
   DECLARE requestid = i4 WITH constant(4170165)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE c_canceled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"CANCELED"))
   DECLARE c_resolved_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"RESOLVED"))
   DECLARE problem_action_update_ind = i2 WITH protect, constant(2)
   DECLARE prsnl_action_update_ind = i2 WITH protect, constant(2)
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET stat = alterlist(req4170165->problem,1)
   SET req4170165->problem[1].problem_action_ind = problem_action_update_ind
   SET req4170165->problem[1].beg_effective_dt_tm = cnvtdatetime( $4)
   SET req4170165->problem[1].life_cycle_status_cd =  $5
   IF (( $5=c_canceled_cd)
    AND ( $6 > 0))
    SET req4170165->problem[1].cancel_reason_cd =  $6
   ELSE
    SET req4170165->problem[1].cancel_reason_cd = result->cancel_reason_cd
   ENDIF
   IF (( $5=c_resolved_cd))
    IF (textlen(trim( $8,3)) > 0)
     SET req4170165->problem[1].life_cycle_dt_tm = cnvtdatetime( $8)
    ELSE
     SET req4170165->problem[1].life_cycle_dt_tm = 0.0
    ENDIF
   ELSE
    SET req4170165->problem[1].life_cycle_dt_tm = cnvtdatetime( $4)
   ENDIF
   SET req4170165->person_id = result->person_id
   SET req4170165->problem[1].problem_id = result->problem_id
   SET req4170165->problem[1].problem_instance_id = result->problem_instance_id
   SET req4170165->problem[1].nomenclature_id = result->nomenclature_id
   SET req4170165->problem[1].annotated_display = result->annotated_display
   SET req4170165->problem[1].source_vocabulary_cd = result->source_vocabulary_cd
   SET req4170165->problem[1].source_identifier = result->source_identifier
   SET req4170165->problem[1].problem_ftdesc = result->problem_ftdesc
   SET req4170165->problem[1].classification_cd = result->classification_cd
   SET req4170165->problem[1].confirmation_status_cd = result->confirmation_status_cd
   SET req4170165->problem[1].qualifier_cd = result->qualifier_cd
   SET req4170165->problem[1].life_cycle_dt_cd = result->life_cycle_dt_cd
   SET req4170165->problem[1].life_cycle_dt_flag = result->life_cycle_dt_flag
   SET req4170165->problem[1].persistence_cd = result->persistence_cd
   SET req4170165->problem[1].certainty_cd = result->certainty_cd
   SET req4170165->problem[1].ranking_cd = result->ranking_cd
   SET req4170165->problem[1].probability = result->probability
   SET req4170165->problem[1].onset_dt_flag = result->onset_dt_flag
   SET req4170165->problem[1].onset_dt_cd = result->onset_dt_cd
   SET req4170165->problem[1].onset_dt_tm = result->onset_dt_tm
   SET req4170165->problem[1].onset_tz = result->onset_tz
   SET req4170165->problem[1].course_cd = result->course_cd
   SET req4170165->problem[1].severity_class_cd = result->severity_class_cd
   SET req4170165->problem[1].severity_cd = result->severity_cd
   SET req4170165->problem[1].severity_ftdesc = result->severity_ftdesc
   SET req4170165->problem[1].prognosis_cd = result->prognosis_cd
   SET req4170165->problem[1].person_aware_cd = result->person_aware_cd
   SET req4170165->problem[1].family_aware_cd = result->family_aware_cd
   SET req4170165->problem[1].person_aware_prognosis_cd = result->person_aware_prognosis_cd
   SET req4170165->problem[1].end_effective_dt_tm = result->end_effective_dt_tm
   SET req4170165->problem[1].status_upt_precision_flag = result->status_upt_precision_flag
   SET req4170165->problem[1].status_upt_precision_cd = result->status_upt_precision_cd
   SET req4170165->problem[1].status_upt_dt_tm = result->status_upt_dt_tm
   IF (( $7 > 0))
    SET req4170165->problem[1].contributor_system_cd =  $7
   ELSE
    SET req4170165->problem[1].contributor_system_cd = result->contributor_system_cd
   ENDIF
   SET req4170165->problem[1].problem_uuid = result->problem_uuid
   SET req4170165->problem[1].problem_instance_uuid = result->problem_instance_uuid
   SET req4170165->problem[1].problem_type_flag = result->problem_type_flag
   SET req4170165->problem[1].show_in_pm_history_ind = result->show_in_pm_history_ind
   SET req4170165->problem[1].laterality_cd = result->laterality_cd
   SET req4170165->problem[1].originating_nomenclature_id = result->originating_nomenclature_id
   SET ppr_cnt = size(result->problem_prsnl,5)
   SET stat = alterlist(req4170165->problem[1].problem_prsnl,ppr_cnt)
   FOR (jdx = 1 TO ppr_cnt)
     SET req4170165->problem[1].problem_prsnl[jdx].prsnl_action_ind = prsnl_action_update_ind
     SET req4170165->problem[1].problem_prsnl[jdx].problem_reltn_dt_tm = result->problem_prsnl[jdx].
     problem_reltn_dt_tm
     SET req4170165->problem[1].problem_prsnl[jdx].problem_reltn_cd = result->problem_prsnl[jdx].
     problem_reltn_cd
     SET req4170165->problem[1].problem_prsnl[jdx].problem_prsnl_id = result->problem_prsnl[jdx].
     problem_prsnl_id
     SET req4170165->problem[1].problem_prsnl[jdx].problem_reltn_prsnl_id = result->problem_prsnl[jdx
     ].problem_reltn_prsnl_id
     SET req4170165->problem[1].problem_prsnl[jdx].beg_effective_dt_tm = result->problem_prsnl[jdx].
     beg_effective_dt_tm
     SET req4170165->problem[1].problem_prsnl[jdx].end_effective_dt_tm = result->problem_prsnl[jdx].
     end_effective_dt_tm
   ENDFOR
   IF (textlen(trim(result->comment,3)) > 0)
    SET stat = alterlist(req4170165->problem[1].problem_comment,1)
    SET req4170165->problem[1].problem_comment[1].comment_action_ind = 4
    SET req4170165->problem[1].problem_comment[1].comment_dt_tm = cnvtdatetime( $4)
    SET req4170165->problem[1].problem_comment[1].end_effective_dt_tm = end_of_time
    SET req4170165->problem[1].problem_comment[1].comment_prsnl_id =  $3
    SET req4170165->problem[1].problem_comment[1].problem_comment = result->comment
    SET req4170165->problem[1].problem_comment[1].problem_comment_id = - (1)
    SET req4170165->problem[1].problem_comment[1].comment_tz = app_tz
   ENDIF
   CALL echorecord(req4170165)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req4170165,
    "REC",rep4170165,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep4170165)
   IF ((rep4170165->status_data.status="S"))
    IF (size(rep4170165->problem_list,5) > 0)
     SET result->new_problem_instance_id = rep4170165->problem_list[1].problem_instance_id
    ENDIF
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
