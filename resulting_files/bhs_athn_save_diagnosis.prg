CREATE PROGRAM bhs_athn_save_diagnosis
 FREE RECORD result
 RECORD result(
   1 modify_ind = i2
   1 encntr_id = f8
   1 person_id = f8
   1 diag_ft_desc = vc
   1 diagnosis_display = vc
   1 severity_ftdesc = vc
   1 performed_prsnl_name_first = vc
   1 performed_prsnl_name_last = vc
   1 performed_dt_tm = dq8
   1 comment = vc
   1 diag_prsnl_name = vc
   1 source_concept_cki = vc
   1 source_vocabulary_code = f8
   1 patient_relationship_cd = f8
   1 originating_nomenclature_id = f8
   1 target_nomenclature_id = f8
   1 target_concept_cki = vc
   1 diagnosis_id = f8
   1 diagnosis_group = f8
   1 prev_comment = vc
   1 long_blob_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4170155
 RECORD req4170155(
   1 item[*]
     2 action_ind = i2
     2 diagnosis_id = f8
     2 diagnosis_group = f8
     2 encntr_id = f8
     2 person_id = f8
     2 nomenclature_id = f8
     2 concept_cki = vc
     2 diag_ft_desc = vc
     2 diagnosis_display = vc
     2 conditional_qual_cd = f8
     2 confirmation_status_cd = f8
     2 diag_dt_tm = dq8
     2 classification_cd = f8
     2 clinical_service_cd = f8
     2 diag_type_cd = f8
     2 ranking_cd = f8
     2 severity_cd = f8
     2 severity_ftdesc = vc
     2 severity_class_cd = f8
     2 certainty_cd = f8
     2 probability = i4
     2 long_blob_id = f8
     2 comment = gvc
     2 active_ind = i2
     2 diag_prsnl_id = f8
     2 diag_prsnl_name = vc
     2 diag_priority = i4
     2 clinical_diag_priority = i4
     2 secondary_desc_list[*]
       3 group_sequence = i4
       3 group[*]
         4 secondary_desc_id = f8
         4 nomenclature_id = f8
         4 sequence = i4
     2 related_dx_list[*]
       3 active_ind = i2
       3 child_entity_id = f8
       3 reltn_subtype_cd = f8
       3 priority = i4
       3 child_dx_type_cd = f8
       3 child_clin_srv_cd = f8
       3 child_nomen_id = f8
       3 child_ft_desc = vc
     2 related_proc_list[*]
       3 active_ind = i2
       3 procedure_id = f8
       3 reltn_subtype_cd = f8
       3 priority = i4
     2 laterality_cd = f8
     2 originating_nomenclature_id = f8
     2 updt_trans_nomen_ind = i2
     2 trans_nomen_id = f8
   1 user_id = f8
 ) WITH protect
 FREE RECORD rep4170155
 RECORD rep4170155(
   1 error_string = vc
   1 item[*]
     2 diagnosis_id = f8
     2 diagnosis_group = f8
     2 review_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4175107
 RECORD req4175107(
   1 source_nomenclature_id = f8
   1 source_concept_cki = vc
   1 source_vocabulary_code = f8
   1 begin_effective_dt_tm = dq8
   1 person_id = f8
   1 user_context
     2 user_id = f8
     2 patient_relationship_cd = f8
   1 carry_forward_ind = i2
   1 local_time_zone = i4
 ) WITH protect
 FREE RECORD rep4175107
 RECORD rep4175107(
   1 source_nomenclature
     2 nomenclature_id = f8
     2 source_string = vc
     2 concept_cki = vc
     2 source_identifier = vc
     2 source_vocabulary_code = f8
     2 specific_ind = i2
   1 target_nomenclatures[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 concept_cki = vc
     2 source_identifier = vc
     2 source_vocabulary_code = f8
     2 specific_ind = i2
   1 carried_forward_status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE calldiagnosisassistant(null) = i4
 DECLARE calldiagnosisensureserver(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE crlf = vc WITH protect, constant(concat(char(13),char(10)))
 SET result->status_data.status = "F"
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 SET result->modify_ind = evaluate( $22,0.0,0,1)
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $4 <= 0.0))
  CALL echo("INVALID NOMENCLATURE ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET result->encntr_id =  $2
 SELECT INTO "NL:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=result->encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < sysdate
    AND e.end_effective_dt_tm > sysdate)
  ORDER BY e.person_id
  HEAD e.person_id
   result->person_id = e.person_id
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "NL:"
  FROM person p
  PLAN (p
   WHERE (p.person_id= $21))
  ORDER BY p.person_id
  HEAD p.person_id
   result->diag_prsnl_name = p.name_full_formatted
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "NL:"
  FROM nomenclature n
  PLAN (n
   WHERE (n.nomenclature_id= $4)
    AND n.active_ind=1)
  ORDER BY n.nomenclature_id
  HEAD n.nomenclature_id
   result->source_concept_cki = n.concept_cki, result->source_vocabulary_code = n
   .source_vocabulary_cd
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "NL:"
  FROM encntr_prsnl_reltn epr
  PLAN (epr
   WHERE (epr.encntr_id= $2)
    AND (epr.prsnl_person_id= $3)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm < sysdate
    AND epr.end_effective_dt_tm > sysdate)
  ORDER BY epr.priority_seq
  HEAD epr.encntr_id
   result->patient_relationship_cd = epr.encntr_prsnl_r_cd
  WITH nocounter, time = 30
 ;end select
 IF ((result->modify_ind=1))
  SELECT INTO "NL:"
   FROM diagnosis d,
    long_blob lb
   PLAN (d
    WHERE (d.diagnosis_id= $22)
     AND d.active_ind=1
     AND d.beg_effective_dt_tm < sysdate
     AND d.end_effective_dt_tm > sysdate)
    JOIN (lb
    WHERE lb.parent_entity_name=outerjoin("DIAGNOSIS")
     AND lb.parent_entity_id=outerjoin(d.diagnosis_group))
   ORDER BY d.diagnosis_id, lb.updt_dt_tm DESC
   HEAD d.diagnosis_id
    result->diagnosis_group = d.diagnosis_group, result->diagnosis_id = d.diagnosis_id
   HEAD lb.parent_entity_id
    IF (lb.parent_entity_id > 0)
     result->prev_comment = lb.long_blob, result->long_blob_id = lb.long_blob_id
    ENDIF
   WITH nocounter, time = 30
  ;end select
  IF ((result->diagnosis_id <= 0))
   CALL echo("INVALID DIAGNOSIS_ID PARAMETER...EXITING")
   GO TO exit_script
  ENDIF
 ENDIF
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 IF (textlen(trim( $6,3)))
  SET req_format_str->param =  $6
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->diag_ft_desc = rep_format_str->param
 ENDIF
 IF (textlen(trim( $7,3)))
  SET req_format_str->param =  $7
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->diagnosis_display = trim(rep_format_str->param,3)
 ENDIF
 IF (textlen(trim( $17,3)))
  SET req_format_str->param =  $17
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->severity_ftdesc = trim(rep_format_str->param,3)
 ENDIF
 IF (textlen(trim( $20,3)))
  SET req_format_str->param =  $20
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->comment = nullterm(trim(rep_format_str->param,3))
 ENDIF
 DECLARE month_str = vc WITH protect, noconstant("")
 DECLARE day_str = vc WITH protect, noconstant("")
 DECLARE year_str = vc WITH protect, noconstant("")
 DECLARE time_str = vc WITH protect, noconstant("")
 DECLARE tz_str = vc WITH protect, noconstant("")
 DECLARE performed_date_str = vc WITH protect, noconstant("")
 IF (textlen(trim(result->comment,3)) > 0)
  SELECT INTO "NL:"
   FROM person p
   PLAN (p
    WHERE (p.person_id= $3)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm < sysdate
     AND p.end_effective_dt_tm > sysdate)
   ORDER BY p.person_id
   HEAD p.person_id
    result->performed_prsnl_name_first = p.name_first, result->performed_prsnl_name_last = p
    .name_last
   WITH nocounter, time = 30
  ;end select
  SET result->performed_dt_tm = cnvtdatetime(curdate,curtime3)
  CALL echo(build("PERFORMED_DT_TM: ",format(result->performed_dt_tm,";;Q")))
  SET month_str = format(result->performed_dt_tm,"MM;;D")
  IF (substring(1,1,month_str)="0")
   SET month_str = substring(2,1,month_str)
  ENDIF
  CALL echo(build("MONTH_STR:",month_str))
  SET day_str = format(result->performed_dt_tm,"DD;;D")
  CALL echo(build("DAY_STR:",day_str))
  SET year_str = format(result->performed_dt_tm,"YYYY;;D")
  CALL echo(build("YEAR_STR:",year_str))
  SET time_str = cnvtupper(format(result->performed_dt_tm,"HH:MM;;S"))
  IF (substring(1,1,time_str)="0")
   SET time_str = substring(2,(size(time_str) - 1),time_str)
  ENDIF
  CALL echo(build("TIME_STR:",time_str))
  SET performed_date_str = trim(concat(month_str,"/",day_str,"/",year_str,
    " ",time_str),3)
  SET result->comment = concat(performed_date_str," - ",result->performed_prsnl_name_last,"  , ",
   result->performed_prsnl_name_first,
   crlf,result->comment)
  CALL echo(build("FORMATTED COMMENT:",result->comment))
 ENDIF
 IF (textlen(trim(result->prev_comment,3)) > 0)
  IF (textlen(trim(result->comment,3)) > 0)
   SET result->comment = concat(result->comment,crlf,crlf,result->prev_comment)
  ELSE
   SET result->comment = result->prev_comment
  ENDIF
  CALL echo(build("MODIFIED COMMENT:",result->comment))
 ENDIF
 SET stat = calldiagnosisassistant(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = calldiagnosisensureserver(null)
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
    v1, row + 1, v2 = build("<DiagnosisID>",cnvtint(result->diagnosis_id),"</DiagnosisID>"),
    col + 1, v2, row + 1,
    v3 = build("<DiagnosisGroup>",cnvtint(result->diagnosis_group),"</DiagnosisGroup>"), col + 1, v3,
    row + 1, col + 1, "</ReplyMessage>",
    row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req4170155
 FREE RECORD rep4170155
 FREE RECORD req4175107
 FREE RECORD rep4175107
 FREE RECORD i_request
 FREE RECORD i_reply
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 SUBROUTINE calldiagnosisensureserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(4170140)
   DECLARE requestid = i4 WITH constant(4170155)
   DECLARE errmsg = vc WITH protect, noconstant("")
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
   SET stat = alterlist(req4170155->item,1)
   SET req4170155->item[1].action_ind = evaluate(result->modify_ind,1,2,1)
   SET req4170155->item[1].diagnosis_id = result->diagnosis_id
   SET req4170155->item[1].diagnosis_group = result->diagnosis_group
   SET req4170155->item[1].encntr_id = result->encntr_id
   SET req4170155->item[1].person_id = result->person_id
   IF ((result->originating_nomenclature_id > 0))
    SET req4170155->item[1].nomenclature_id = result->target_nomenclature_id
    SET req4170155->item[1].concept_cki = result->target_concept_cki
   ELSE
    SET req4170155->item[1].nomenclature_id =  $4
    SET req4170155->item[1].concept_cki = result->source_concept_cki
   ENDIF
   SET req4170155->item[1].diag_ft_desc = result->diag_ft_desc
   SET req4170155->item[1].diagnosis_display = result->diagnosis_display
   SET req4170155->item[1].conditional_qual_cd =  $8
   SET req4170155->item[1].confirmation_status_cd =  $9
   SET req4170155->item[1].diag_dt_tm = cnvtdatetime( $10)
   SET req4170155->item[1].classification_cd =  $11
   SET req4170155->item[1].clinical_service_cd =  $12
   SET req4170155->item[1].diag_type_cd =  $13
   SET req4170155->item[1].ranking_cd =  $14
   SET req4170155->item[1].severity_class_cd =  $15
   SET req4170155->item[1].severity_cd =  $16
   SET req4170155->item[1].severity_ftdesc = result->severity_ftdesc
   SET req4170155->item[1].certainty_cd =  $18
   SET req4170155->item[1].probability =  $19
   SET req4170155->item[1].long_blob_id = result->long_blob_id
   SET req4170155->item[1].comment = result->comment
   SET req4170155->item[1].active_ind = 1
   SET req4170155->item[1].diag_prsnl_id =  $21
   SET req4170155->item[1].diag_prsnl_name = result->diag_prsnl_name
   SET req4170155->item[1].originating_nomenclature_id = result->originating_nomenclature_id
   CALL echorecord(req4170155)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req4170155,
    "REC",rep4170155,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep4170155)
   IF ((rep4170155->status_data.status="S"))
    IF (size(rep4170155->item,5) > 0)
     SET result->diagnosis_id = rep4170155->item[1].diagnosis_id
     SET result->diagnosis_group = rep4170155->item[1].diagnosis_group
    ENDIF
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE calldiagnosisassistant(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(3202004)
   DECLARE requestid = i4 WITH protect, constant(4175107)
   SET req4175107->source_nomenclature_id =  $4
   SET req4175107->source_concept_cki = result->source_concept_cki
   SET req4175107->source_vocabulary_code = result->source_vocabulary_code
   SET req4175107->begin_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET req4175107->person_id = result->person_id
   SET req4175107->user_context.user_id =  $3
   SET req4175107->user_context.patient_relationship_cd = result->patient_relationship_cd
   SET req4175107->carry_forward_ind = 1
   SET req4175107->local_time_zone = app_tz
   CALL echorecord(req4175107)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req4175107,
    "REC",rep4175107,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep4175107)
   IF ((rep4175107->status_data.status != "F"))
    IF (size(rep4175107->target_nomenclatures,5) > 0)
     SET result->originating_nomenclature_id =  $4
     SET result->target_nomenclature_id = rep4175107->target_nomenclatures[1].nomenclature_id
     SET result->target_concept_cki = rep4175107->target_nomenclatures[1].concept_cki
    ENDIF
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
