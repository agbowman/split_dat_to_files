CREATE PROGRAM bhs_prax_upd_problem
 RECORD requestin(
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
 )
 DECLARE jsonout = vc
 DECLARE praxify = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,"PRAXIFY"))
 DECLARE authverified = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE active = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE management_discipline = vc
 DECLARE prsnl_str = vc
 DECLARE problem_reltn_cd = f8
 DECLARE problem_reltn_prsnl_id = f8
 DECLARE problem_instance_id = f8
 DECLARE problem_id = f8
 DECLARE probability = f8
 DECLARE nomen_id = f8
 DECLARE proc_cnt = i2
 DECLARE relt_prob_cnt = i2
 DECLARE relt_prob_str = vc
 DECLARE relt_problem_id = f8
 DECLARE relt_subtype_cd = f8
 DECLARE logged_in_prsnl_id = f8
 SET logged_in_prsnl_id =  $43
 DECLARE source_identifier = vc
 DECLARE source_vocabulary_cd = f8
 DECLARE child_ftdesc = vc
 DECLARE problem_uuid = vc
 DECLARE problem_instance_uuid = vc
 DECLARE problem_beg_effective_dt_tm = dq8
 DECLARE formatted_comment = vc
 DECLARE formatted_display = vc
 DECLARE c_praxify_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",89,"PRAXIFY"))
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 IF (textlen(trim( $5,3)))
  SET req_format_str->param =  $5
  EXECUTE bhs_prax_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET formatted_comment = rep_format_str->param
 ENDIF
 IF (textlen(trim( $6,3)))
  SET req_format_str->param =  $6
  EXECUTE bhs_prax_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET formatted_display = rep_format_str->param
 ENDIF
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 SELECT INTO "NL:"
  FROM problem p
  PLAN (p
   WHERE (p.problem_instance_id= $42)
    AND p.active_ind=1)
  ORDER BY p.problem_instance_id
  HEAD p.problem_instance_id
   problem_uuid = p.problem_uuid, problem_instance_uuid = p.problem_instance_uuid,
   problem_beg_effective_dt_tm = p.beg_effective_dt_tm
  WITH nocounter, time = 30
 ;end select
 IF (problem_beg_effective_dt_tm <= 0)
  CALL echo("INVALID PROBLEM_INSTANCE_ID...EXITING")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM nomenclature n
  PLAN (n
   WHERE (n.nomenclature_id= $4)
    AND n.active_ind=1)
  ORDER BY n.nomenclature_id
  HEAD n.nomenclature_id
   source_identifier = n.source_identifier, source_vocabulary_cd = n.source_vocabulary_cd
  WITH nocounter, time = 30
 ;end select
 SET stat = alterlist(requestin->problem,1)
 SET requestin->person_id =  $2
 SET requestin->problem[1].nomenclature_id =  $4
 SET requestin->problem[1].annotated_display = formatted_display
 SET requestin->problem[1].classification_cd =  $11
 SET requestin->problem[1].confirmation_status_cd =  $10
 SET requestin->problem[1].life_cycle_status_cd =  $12
 SET requestin->problem[1].onset_dt_cd =  $7
 SET requestin->problem[1].onset_dt_flag =  $8
 SET requestin->problem[1].onset_dt_tm = cnvtdatetime( $9)
 SET requestin->problem[1].ranking_cd =  $14
 SET requestin->problem[1].persistence_cd =  $25
 SET requestin->problem[1].certainty_cd =  $26
 SET probability =  $27
 SET probability = (probability/ 100)
 SET requestin->problem[1].probability = probability
 SET requestin->problem[1].person_aware_cd =  $28
 SET requestin->problem[1].prognosis_cd =  $30
 SET requestin->problem[1].person_aware_prognosis_cd =  $31
 SET requestin->problem[1].family_aware_cd =  $29
 SET requestin->problem[1].course_cd =  $21
 SET requestin->problem[1].cancel_reason_cd =  $13
 SET requestin->problem[1].life_cycle_dt_cd =  $15
 SET requestin->problem[1].life_cycle_dt_flag =  $16
 SET requestin->problem[1].qualifier_cd =  $18
 SET requestin->problem[1].severity_class_cd =  $19
 SET requestin->problem[1].severity_cd =  $20
 SET requestin->problem[1].status_upt_precision_cd =  $22
 SET requestin->problem[1].status_upt_dt_tm = cnvtdatetime( $23)
 SET requestin->problem[1].status_upt_precision_flag =  $24
 SET requestin->problem[1].originating_nomenclature_id =  $4
 SET requestin->problem[1].contributor_system_cd = c_praxify_cd
 SET requestin->problem[1].life_cycle_dt_tm = cnvtdatetime( $17)
 SET requestin->problem[1].beg_effective_dt_tm = problem_beg_effective_dt_tm
 SET requestin->problem[1].end_effective_dt_tm = 0.0
 SET requestin->problem[1].problem_ftdesc = ""
 SET requestin->problem[1].problem_action_ind = 2
 SET requestin->problem[1].show_in_pm_history_ind =  $40
 SET requestin->problem[1].problem_id =  $41
 SET requestin->problem[1].source_vocabulary_cd = source_vocabulary_cd
 SET requestin->problem[1].source_identifier = source_identifier
 SET requestin->problem[1].problem_instance_id =  $42
 SET requestin->problem[1].severity_ftdesc =  $44
 SET requestin->problem[1].problem_uuid = problem_uuid
 SET requestin->problem[1].problem_instance_uuid = problem_instance_uuid
 IF (formatted_comment != "")
  SET stat = alterlist(requestin->problem[1].problem_comment,1)
  SET requestin->problem[1].problem_comment[1].beg_effective_dt_tm = 0.0
  SET requestin->problem[1].problem_comment[1].comment_action_ind = 4
  SET requestin->problem[1].problem_comment[1].comment_dt_tm = cnvtdatetime(curdate,curtime3)
  SET requestin->problem[1].problem_comment[1].comment_prsnl_id =  $3
  SET requestin->problem[1].problem_comment[1].end_effective_dt_tm = cnvtdatetime(
   "31-DEC-2100 23:59:59")
  SET requestin->problem[1].problem_comment[1].problem_comment = formatted_comment
  SET requestin->problem[1].problem_comment[1].problem_comment_id = - (1)
  SET requestin->problem[1].problem_comment[1].comment_tz = app_tz
 ENDIF
 SET mcnt =  $32
 SET stat = alterlist(requestin->problem[1].problem_discipline,mcnt)
 FOR (x = 1 TO mcnt)
   SET management_discipline = piece( $33,"|",x,"NOT FOUND")
   SET requestin->problem[1].problem_discipline[x].beg_effective_dt_tm = 0.0
   SET requestin->problem[1].problem_discipline[x].discipline_action_ind = 2
   SET requestin->problem[1].problem_discipline[x].end_effective_dt_tm = 0.0
   SET requestin->problem[1].problem_discipline[x].management_discipline_cd = cnvtint(
    management_discipline)
 ENDFOR
 SET pcnt =  $34
 SET stat = alterlist(requestin->problem[1].problem_prsnl,pcnt)
 FOR (x = 1 TO pcnt)
   SET prsnl_str = piece( $35,"|",x,"NOT FOUND")
   SET problem_reltn_cd = cnvtint(piece(prsnl_str,",",2,"NOT FOUND"))
   SET problem_reltn_prsnl_id = cnvtint(piece(prsnl_str,",",1,"NOT FOUND"))
   SET requestin->problem[1].problem_prsnl[x].beg_effective_dt_tm = cnvtdatetime(curdate,0)
   SET requestin->problem[1].problem_prsnl[x].end_effective_dt_tm = 0.0
   SET requestin->problem[1].problem_prsnl[x].problem_reltn_cd = problem_reltn_cd
   SET requestin->problem[1].problem_prsnl[x].problem_reltn_dt_tm = cnvtdatetime(curdate,0)
   SET requestin->problem[1].problem_prsnl[x].problem_reltn_prsnl_id = problem_reltn_prsnl_id
   SET requestin->problem[1].problem_prsnl[x].prsnl_action_ind = 2
   SET requestin->problem[1].problem_prsnl[x].problem_prsnl_id = - ((1 * x))
 ENDFOR
 SET proc_cnt =  $36
 IF (proc_cnt > 0)
  SET stat = alterlist(requestin->problem[1].secondary_desc_list,(proc_cnt+ 1))
  FOR (x = 1 TO proc_cnt)
    SET nomen_id = cnvtreal(piece( $37,"|",x,"NOT FOUND"))
    SET stat = alterlist(requestin->problem[1].secondary_desc_list[x].group,1)
    SET requestin->problem[1].secondary_desc_list[x].group[1].nomenclature_id = nomen_id
    SET requestin->problem[1].secondary_desc_list[x].group[1].sequence = 1
    SET requestin->problem[1].secondary_desc_list[x].group_sequence = x
  ENDFOR
  IF (proc_cnt > 0)
   SET requestin->problem[1].secondary_desc_list[(proc_cnt+ 1)].group_sequence = (proc_cnt+ 1)
  ENDIF
 ENDIF
 SET relt_prob_cnt =  $38
 SET stat = alterlist(requestin->problem[1].related_problem_list,relt_prob_cnt)
 FOR (x = 1 TO relt_prob_cnt)
   SET relt_prob_str = piece( $39,"|",x,"NOT FOUND")
   SET relt_problem_id = cnvtint(piece(relt_prob_str,",",1,"NOT FOUND"))
   SET relt_subtype_cd = cnvtint(piece(relt_prob_str,",",2,"NOT FOUND"))
   SET nomen_id = 0.0
   SELECT INTO "nl:"
    FROM problem p,
     nomenclature n
    PLAN (p
     WHERE p.problem_id=relt_problem_id)
     JOIN (n
     WHERE n.nomenclature_id=p.nomenclature_id
      AND n.active_ind=1)
    HEAD REPORT
     nomen_id = p.nomenclature_id, child_ftdesc = n.source_string
    WITH nocounter, time = 30
   ;end select
   SET requestin->problem[1].related_problem_list[x].child_entity_id = relt_problem_id
   SET requestin->problem[1].related_problem_list[x].child_nomen_id = nomen_id
   SET requestin->problem[1].related_problem_list[x].reltn_subtype_cd = relt_subtype_cd
   SET requestin->problem[1].related_problem_list[x].active_ind = 1
   SET requestin->problem[1].related_problem_list[x].priority = x
   SET requestin->problem[1].related_problem_list[x].child_ftdesc = child_ftdesc
 ENDFOR
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
 SET i_request->prsnl_id = (logged_in_prsnl_id * 1.00)
 CALL echorecord(i_request)
 EXECUTE bhs_prax_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
 IF ((i_reply->status_data.status != "S"))
  CALL echo("IMPERSONATE USER FAILED!")
 ENDIF
 SET stat = tdbexecute(600005,4170147,4170165,"REC",requestin,
  "REC",requestout)
 CALL echo(build("TDBEXECUTE=",stat))
 CALL echorecord(requestin)
 SET jsonout = cnvtrectojson(requestout)
#exit_script
 SELECT INTO  $1
  jsonout
  FROM dummyt d
  HEAD REPORT
   col 01, jsonout
  WITH format, separator = " ", maxcol = 32000,
   time = 30
 ;end select
END GO
