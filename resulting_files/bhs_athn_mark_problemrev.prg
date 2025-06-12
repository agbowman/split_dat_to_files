CREATE PROGRAM bhs_athn_mark_problemrev
 FREE RECORD result
 RECORD result(
   1 problem_cnt = i4
   1 problem[*]
     2 person_id = f8
     2 problem_instance_id = f8
     2 problem_id = f8
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
     2 life_cycle_dt_cd = f8
     2 life_cycle_dt_flag = i2
     2 persistence_cd = f8
     2 certainty_cd = f8
     2 ranking_cd = f8
     2 probability = f8
     2 onset_dt_flag = i2
     2 onset_dt_cd = f8
     2 onset_dt_tm = dq8
     2 onset_tz = i4
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
     2 contributor_system_cd = f8
     2 problem_uuid = vc
     2 problem_instance_uuid = vc
     2 problem_type_flag = i2
     2 show_in_pm_history_ind = i2
     2 laterality_cd = f8
     2 originating_nomenclature_id = f8
     2 problem_prsnl[*]
       3 prsnl_action_ind = i2
       3 problem_reltn_dt_tm = dq8
       3 problem_reltn_cd = f8
       3 problem_prsnl_id = f8
       3 problem_reltn_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 review_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4170162
 RECORD req4170162(
   1 person_id = f8
   1 life_cycle_status_flag = i2
 ) WITH protect
 FREE RECORD rep4170162
 RECORD rep4170162(
   1 person_org_sec_on = i2
   1 problem[*]
     2 problem_instance_id = f8
     2 problem_id = f8
     2 nomenclature_id = f8
     2 organization_id = f8
     2 source_string = vc
     2 annotated_display = vc
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c40
     2 source_vocabulary_mean = c12
     2 source_identifier = vc
     2 problem_ftdesc = vc
     2 classification_cd = f8
     2 classification_disp = c40
     2 classification_mean = c12
     2 confirmation_status_cd = f8
     2 confirmation_status_disp = c40
     2 confirmation_status_mean = c12
     2 qualifier_cd = f8
     2 qualifier_disp = c40
     2 qualifier_mean = c12
     2 life_cycle_status_cd = f8
     2 life_cycle_status_disp = c40
     2 life_cycle_status_mean = c12
     2 life_cycle_dt_tm = dq8
     2 persistence_cd = f8
     2 persistence_disp = c40
     2 persistence_mean = c12
     2 certainty_cd = f8
     2 certainty_disp = c40
     2 certainty_mean = c12
     2 ranking_cd = f8
     2 ranking_disp = c40
     2 ranking_mean = c12
     2 probability = f8
     2 onset_dt_flag = i2
     2 onset_dt_cd = f8
     2 onset_dt_disp = c40
     2 onset_dt_mean = c12
     2 onset_dt_tm = dq8
     2 course_cd = f8
     2 course_disp = c40
     2 course_mean = c12
     2 severity_class_cd = f8
     2 severity_class_disp = c40
     2 severity_class_mean = c12
     2 severity_cd = f8
     2 severity_disp = c40
     2 severity_mean = c12
     2 severity_ftdesc = vc
     2 prognosis_cd = f8
     2 prognosis_disp = c40
     2 prognosis_mean = c12
     2 person_aware_cd = f8
     2 person_aware_disp = c40
     2 person_aware_mean = c12
     2 family_aware_cd = f8
     2 family_aware_disp = c40
     2 family_aware_mean = c12
     2 person_aware_prognosis_cd = f8
     2 person_aware_prognosis_disp = c40
     2 person_aware_prognosis_mean = c12
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 status_upt_precision_flag = i2
     2 status_upt_precision_cd = f8
     2 status_upt_precision_disp = c40
     2 status_upt_precision_mean = c12
     2 status_upt_dt_tm = dq8
     2 cancel_reason_cd = f8
     2 cancel_reason_disp = c40
     2 cancel_reason_mean = c12
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 contributor_system_mean = c12
     2 responsible_prsnl_id = f8
     2 responsible_prsnl_name = vc
     2 recorder_prsnl_id = f8
     2 recorder_prsnl_name = vc
     2 concept_cki = vc
     2 updt_id = f8
     2 updt_name_full_formatted = vc
     2 problem_discipline[*]
       3 problem_discipline_id = f8
       3 management_discipline_cd = f8
       3 management_discipline_disp = c40
       3 management_discipline_mean = c12
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
     2 problem_comment[*]
       3 problem_comment_id = f8
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 name_full_formatted = vc
       3 problem_comment = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 secondary_desc[*]
       3 group_sequence = i2
       3 group[*]
         4 sequence = i2
         4 secondary_desc_id = f8
         4 nomenclature_id = f8
         4 source_string = vc
     2 problem_prsnl[*]
       3 problem_prsnl_id = f8
       3 problem_reltn_prsnl_id = f8
       3 problem_prsnl_full_name = vc
       3 problem_reltn_dt_tm = dq8
       3 problem_reltn_cd = f8
       3 problem_reltn_disp = c40
       3 problem_reltn_mean = c12
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
     2 problem_uuid = vc
     2 problem_instance_uuid = vc
     2 problem_action_dt_tm = dq8
     2 problem_type_flag = i4
     2 show_in_pm_history_ind = i2
     2 life_cycle_dt_cd = f8
     2 life_cycle_dt_flag = i2
     2 laterality_cd = f8
     2 originating_nomenclature_id = f8
     2 originating_source_string = vc
     2 onset_tz = i4
     2 originating_active_ind = i2
     2 originating_end_effective_dt_tm = dq8
     2 originating_source_vocab_cd = f8
     2 active_status_prsnl_id = f8
     2 active_prsnl_name_ful_formatted = vc
   1 related_problem_list[*]
     2 nomen_entity_reltn_id = f8
     2 parent_entity_id = f8
     2 parent_nomen_id = f8
     2 parent_source_string = vc
     2 parent_ftdesc = vc
     2 child_entity_id = f8
     2 child_nomen_id = f8
     2 child_source_string = vc
     2 child_ftdesc = vc
     2 reltn_subtype_cd = f8
     2 reltn_subtype_disp = vc
     2 reltn_subtype_mean = c12
     2 priority = i4
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
     2 problem_type_flag = i2
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
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetproblemserver(null) = i4
 DECLARE findproblemdetails(null) = i4
 DECLARE callproblemensureserver(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callgetproblemserver(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = findproblemdetails(null)
 IF (stat=fail)
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
 DECLARE v3 = vc WITH protect, noconstant("")
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
    v1, row + 1, col + 1,
    "<Problems>", row + 1
    FOR (idx = 1 TO size(result->problem,5))
      col + 1, "<Problem>", row + 1,
      v2 = build("<ProblemId>",cnvtint(result->problem[idx].problem_id),"</ProblemId>"), col + 1, v2,
      row + 1, v3 = build("<ReviewDtTm>",datetimezoneformat(result->problem[idx].review_dt_tm,
        curtimezonesys,"MM/dd/yyyy HH:mm",curtimezonedef),"</ReviewDtTm>"), col + 1,
      v3, row + 1, col + 1,
      "</Problem>", row + 1
    ENDFOR
    col + 1, "</Problems>", row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req4170162
 FREE RECORD rep4170162
 FREE RECORD req4170165
 FREE RECORD rep4170165
 FREE RECORD i_request
 FREE RECORD i_reply
 SUBROUTINE callgetproblemserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(4170146)
   DECLARE requestid = i4 WITH constant(4170162)
   SET req4170162->person_id =  $2
   SET req4170162->life_cycle_status_flag = 2
   CALL echorecord(req4170162)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req4170162,
    "REC",rep4170162,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep4170162)
   IF ((rep4170162->status_data.status != "F"))
    SET result->problem_cnt = size(rep4170162->problem,5)
    SET stat = alterlist(result->problem,result->problem_cnt)
    FOR (idx = 1 TO result->problem_cnt)
      SET result->problem[idx].problem_id = rep4170162->problem[idx].problem_id
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE findproblemdetails(null)
   IF ((result->problem_cnt <= 0))
    CALL echo("PROBLEM_CNT IS ZERO...EXITING!")
    RETURN(fail)
   ENDIF
   DECLARE ppr_cnt = i4 WITH protect, noconstant(0)
   DECLARE end_of_time = dq8 WITH protect, constant(cnvtdatetime("31 DEC 2100 00:00:00"))
   SELECT INTO "NL:"
    FROM problem p,
     nomenclature n,
     problem_prsnl_r ppr
    PLAN (p
     WHERE expand(idx,1,result->problem_cnt,p.problem_id,result->problem[idx].problem_id)
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (n
     WHERE n.nomenclature_id=outerjoin(p.nomenclature_id))
     JOIN (ppr
     WHERE ppr.problem_id=outerjoin(p.problem_id)
      AND ppr.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
      AND ppr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime))
      AND ppr.active_ind=outerjoin(1))
    ORDER BY p.problem_id, p.beg_effective_dt_tm DESC, ppr.problem_prsnl_id
    HEAD p.problem_id
     pos = locateval(locidx,1,result->problem_cnt,p.problem_id,result->problem[locidx].problem_id)
     IF (pos > 0)
      result->problem[pos].person_id = p.person_id, result->problem[pos].problem_instance_id = p
      .problem_instance_id, result->problem[pos].nomenclature_id = p.nomenclature_id,
      result->problem[pos].annotated_display = p.annotated_display, result->problem[pos].
      problem_ftdesc = p.problem_ftdesc, result->problem[pos].classification_cd = p.classification_cd,
      result->problem[pos].confirmation_status_cd = p.confirmation_status_cd, result->problem[pos].
      qualifier_cd = p.qualifier_cd, result->problem[pos].life_cycle_status_cd = p
      .life_cycle_status_cd,
      result->problem[pos].life_cycle_dt_tm = p.life_cycle_dt_tm, result->problem[pos].persistence_cd
       = p.persistence_cd, result->problem[pos].certainty_cd = p.certainty_cd,
      result->problem[pos].ranking_cd = p.ranking_cd, result->problem[pos].probability = p
      .probability, result->problem[pos].onset_dt_flag = p.onset_dt_flag,
      result->problem[pos].onset_dt_cd = p.onset_dt_cd, result->problem[pos].onset_dt_tm = p
      .onset_dt_tm, result->problem[pos].course_cd = p.course_cd,
      result->problem[pos].severity_class_cd = p.severity_class_cd, result->problem[pos].severity_cd
       = p.severity_cd, result->problem[pos].severity_ftdesc = p.severity_ftdesc,
      result->problem[pos].prognosis_cd = p.prognosis_cd, result->problem[pos].person_aware_cd = p
      .person_aware_cd, result->problem[pos].family_aware_cd = p.family_aware_cd,
      result->problem[pos].person_aware_prognosis_cd = p.person_aware_prognosis_cd, result->problem[
      pos].beg_effective_dt_tm = p.beg_effective_dt_tm
      IF (p.end_effective_dt_tm < end_of_time)
       result->problem[pos].end_effective_dt_tm = p.end_effective_dt_tm
      ENDIF
      result->problem[pos].status_upt_precision_flag = p.status_updt_flag, result->problem[pos].
      status_upt_precision_cd = p.status_updt_precision_cd, result->problem[pos].status_upt_dt_tm = p
      .status_updt_dt_tm,
      result->problem[pos].cancel_reason_cd = p.cancel_reason_cd, result->problem[pos].
      contributor_system_cd = p.contributor_system_cd, result->problem[pos].problem_uuid = p
      .problem_uuid,
      result->problem[pos].problem_instance_uuid = p.problem_instance_uuid, result->problem[pos].
      problem_type_flag = p.problem_type_flag, result->problem[pos].show_in_pm_history_ind = p
      .show_in_pm_history_ind,
      result->problem[pos].life_cycle_dt_cd = p.life_cycle_dt_cd, result->problem[pos].
      life_cycle_dt_flag = p.life_cycle_dt_flag, result->problem[pos].laterality_cd = p.laterality_cd,
      result->problem[pos].originating_nomenclature_id = p.originating_nomenclature_id, result->
      problem[pos].onset_tz = p.onset_tz, result->problem[pos].source_vocabulary_cd = n
      .source_vocabulary_cd,
      result->problem[pos].source_identifier = n.source_identifier
     ENDIF
     ppr_cnt = 0
    HEAD ppr.problem_prsnl_id
     IF (pos > 0
      AND ppr.problem_prsnl_id > 0.0)
      ppr_cnt = (ppr_cnt+ 1), stat = alterlist(result->problem[pos].problem_prsnl,ppr_cnt), result->
      problem[pos].problem_prsnl[ppr_cnt].problem_reltn_dt_tm = ppr.problem_reltn_dt_tm,
      result->problem[pos].problem_prsnl[ppr_cnt].problem_reltn_cd = ppr.problem_reltn_cd, result->
      problem[pos].problem_prsnl[ppr_cnt].problem_prsnl_id = ppr.problem_prsnl_id, result->problem[
      pos].problem_prsnl[ppr_cnt].problem_reltn_prsnl_id = ppr.problem_reltn_prsnl_id,
      result->problem[pos].problem_prsnl[ppr_cnt].beg_effective_dt_tm = ppr.beg_effective_dt_tm,
      result->problem[pos].problem_prsnl[ppr_cnt].end_effective_dt_tm = ppr.end_effective_dt_tm
     ENDIF
    WITH nocounter, time = 30
   ;end select
 END ;Subroutine
 SUBROUTINE callproblemensureserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(4170147)
   DECLARE requestid = i4 WITH constant(4170165)
   DECLARE problem_action_review_ind = i2 WITH protect, constant(9)
   DECLARE prsnl_action_update_ind = i2 WITH protect, constant(2)
   IF ((result->problem_cnt <= 0))
    CALL echo("PROBLEM_CNT IS ZERO...EXITING!")
    RETURN(fail)
   ENDIF
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
   SET req4170165->person_id = result->problem[1].person_id
   SET stat = alterlist(req4170165->problem,result->problem_cnt)
   FOR (idx = 1 TO result->problem_cnt)
     SET req4170165->problem[idx].problem_action_ind = problem_action_review_ind
     SET req4170165->problem[idx].problem_id = result->problem[idx].problem_id
     SET req4170165->problem[idx].problem_instance_id = result->problem[idx].problem_instance_id
     SET req4170165->problem[idx].nomenclature_id = result->problem[idx].nomenclature_id
     SET req4170165->problem[idx].annotated_display = result->problem[idx].annotated_display
     SET req4170165->problem[idx].source_vocabulary_cd = result->problem[idx].source_vocabulary_cd
     SET req4170165->problem[idx].source_identifier = result->problem[idx].source_identifier
     SET req4170165->problem[idx].problem_ftdesc = result->problem[idx].problem_ftdesc
     SET req4170165->problem[idx].classification_cd = result->problem[idx].classification_cd
     SET req4170165->problem[idx].confirmation_status_cd = result->problem[idx].
     confirmation_status_cd
     SET req4170165->problem[idx].qualifier_cd = result->problem[idx].qualifier_cd
     SET req4170165->problem[idx].life_cycle_status_cd = result->problem[idx].life_cycle_status_cd
     SET req4170165->problem[idx].life_cycle_dt_tm = result->problem[idx].life_cycle_dt_tm
     SET req4170165->problem[idx].life_cycle_dt_cd = result->problem[idx].life_cycle_dt_cd
     SET req4170165->problem[idx].life_cycle_dt_flag = result->problem[idx].life_cycle_dt_flag
     SET req4170165->problem[idx].persistence_cd = result->problem[idx].persistence_cd
     SET req4170165->problem[idx].certainty_cd = result->problem[idx].certainty_cd
     SET req4170165->problem[idx].ranking_cd = result->problem[idx].ranking_cd
     SET req4170165->problem[idx].probability = result->problem[idx].probability
     SET req4170165->problem[idx].onset_dt_flag = result->problem[idx].onset_dt_flag
     SET req4170165->problem[idx].onset_dt_cd = result->problem[idx].onset_dt_cd
     SET req4170165->problem[idx].onset_dt_tm = result->problem[idx].onset_dt_tm
     SET req4170165->problem[idx].onset_tz = result->problem[idx].onset_tz
     SET req4170165->problem[idx].course_cd = result->problem[idx].course_cd
     SET req4170165->problem[idx].severity_class_cd = result->problem[idx].severity_class_cd
     SET req4170165->problem[idx].severity_cd = result->problem[idx].severity_cd
     SET req4170165->problem[idx].severity_ftdesc = result->problem[idx].severity_ftdesc
     SET req4170165->problem[idx].prognosis_cd = result->problem[idx].prognosis_cd
     SET req4170165->problem[idx].person_aware_cd = result->problem[idx].person_aware_cd
     SET req4170165->problem[idx].family_aware_cd = result->problem[idx].family_aware_cd
     SET req4170165->problem[idx].person_aware_prognosis_cd = result->problem[idx].
     person_aware_prognosis_cd
     SET req4170165->problem[idx].beg_effective_dt_tm = result->problem[idx].beg_effective_dt_tm
     SET req4170165->problem[idx].end_effective_dt_tm = result->problem[idx].end_effective_dt_tm
     SET req4170165->problem[idx].status_upt_precision_flag = result->problem[idx].
     status_upt_precision_flag
     SET req4170165->problem[idx].status_upt_precision_cd = result->problem[idx].
     status_upt_precision_cd
     SET req4170165->problem[idx].status_upt_dt_tm = result->problem[idx].status_upt_dt_tm
     SET req4170165->problem[idx].cancel_reason_cd = result->problem[idx].cancel_reason_cd
     SET req4170165->problem[idx].contributor_system_cd = result->problem[idx].contributor_system_cd
     SET req4170165->problem[idx].problem_uuid = result->problem[idx].problem_uuid
     SET req4170165->problem[idx].problem_instance_uuid = result->problem[idx].problem_instance_uuid
     SET req4170165->problem[idx].problem_type_flag = result->problem[idx].problem_type_flag
     SET req4170165->problem[idx].show_in_pm_history_ind = result->problem[idx].
     show_in_pm_history_ind
     SET req4170165->problem[idx].laterality_cd = result->problem[idx].laterality_cd
     SET req4170165->problem[idx].originating_nomenclature_id = result->problem[idx].
     originating_nomenclature_id
     SET ppr_cnt = size(result->problem[idx].problem_prsnl,5)
     SET stat = alterlist(req4170165->problem[idx].problem_prsnl,ppr_cnt)
     FOR (jdx = 1 TO ppr_cnt)
       SET req4170165->problem[idx].problem_prsnl[jdx].prsnl_action_ind = prsnl_action_update_ind
       SET req4170165->problem[idx].problem_prsnl[jdx].problem_reltn_dt_tm = result->problem[idx].
       problem_prsnl[jdx].problem_reltn_dt_tm
       SET req4170165->problem[idx].problem_prsnl[jdx].problem_reltn_cd = result->problem[idx].
       problem_prsnl[jdx].problem_reltn_cd
       SET req4170165->problem[idx].problem_prsnl[jdx].problem_prsnl_id = result->problem[idx].
       problem_prsnl[jdx].problem_prsnl_id
       SET req4170165->problem[idx].problem_prsnl[jdx].problem_reltn_prsnl_id = result->problem[idx].
       problem_prsnl[jdx].problem_reltn_prsnl_id
       SET req4170165->problem[idx].problem_prsnl[jdx].beg_effective_dt_tm = result->problem[idx].
       problem_prsnl[jdx].beg_effective_dt_tm
       SET req4170165->problem[idx].problem_prsnl[jdx].end_effective_dt_tm = result->problem[idx].
       problem_prsnl[jdx].end_effective_dt_tm
     ENDFOR
   ENDFOR
   CALL echorecord(req4170165)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req4170165,
    "REC",rep4170165,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep4170165)
   IF ((rep4170165->status_data.status != "F"))
    FOR (idx = 1 TO size(rep4170165->problem_list,5))
      SET result->problem[idx].review_dt_tm = rep4170165->problem_list[idx].review_dt_tm
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
