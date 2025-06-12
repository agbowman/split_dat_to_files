CREATE PROGRAM cv_get_graph_data:dba
 DECLARE exp1 = i4 WITH noconstant(0)
 DECLARE event_component_cd = f8 WITH noconstant(uar_get_code_by("MEANING",18189,"CLINCALEVENT"))
 DECLARE form_cnt = i4 WITH noconstant(0)
 DECLARE valid_time = dq8 WITH noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 dcp_forms_activity[*]
      2 dcp_forms_ref_id = f8
      2 dcp_forms_activity_id = f8
      2 encntr_id = f8
      2 event_id = f8
      2 data_dt_tm = dq8
      2 clinical_event[*]
        3 event_id = f8
        3 event_cd = f8
        3 task_assay_cd = f8
        3 task_assay_disp = vc
        3 task_assay_mean = vc
        3 result_val = vc
        3 result_units_cd = f8
        3 result_units_disp = vc
        3 result_units_mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  CALL echo("Reply already defined")
 ENDIF
 SELECT
  FROM dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   clinical_event ce1,
   clinical_event ce2
  PLAN (dfa
   WHERE (dfa.person_id=request->person_id)
    AND (dfa.dcp_forms_ref_id=request->dcp_forms_ref_id))
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND dfac.component_cd=event_component_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=dfac.parent_entity_id
    AND ce1.valid_until_dt_tm=cnvtdatetime(valid_time)
    AND (ce1.result_status_cd=reqdata->auth_auth_cd)
    AND ce1.event_id != dfac.parent_entity_id)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.valid_until_dt_tm=cnvtdatetime(valid_time)
    AND (ce2.result_status_cd=reqdata->auth_auth_cd)
    AND ce1.event_id != dfac.parent_entity_id)
  ORDER BY dfac.parent_entity_id
  HEAD dfac.parent_entity_id
   form_cnt = (form_cnt+ 1), input_cnt = 0, stat = alterlist(reply->dcp_forms_activity,form_cnt),
   reply->dcp_forms_activity[form_cnt].dcp_forms_activity_id = dfa.dcp_forms_activity_id, reply->
   dcp_forms_activity[form_cnt].encntr_id = dfa.encntr_id, reply->dcp_forms_activity[form_cnt].
   event_id = dfac.parent_entity_id,
   reply->dcp_forms_activity[form_cnt].data_dt_tm = dfa.form_dt_tm
  DETAIL
   input_cnt = (input_cnt+ 1)
   IF (mod(input_cnt,10)=1)
    stat = alterlist(reply->dcp_forms_activity[form_cnt].clinical_event,(input_cnt+ 9))
   ENDIF
   reply->dcp_forms_activity[form_cnt].clinical_event[input_cnt].result_val = ce2.result_val, reply->
   dcp_forms_activity[form_cnt].clinical_event[input_cnt].result_units_cd = ce2.result_units_cd,
   reply->dcp_forms_activity[form_cnt].clinical_event[input_cnt].event_cd = ce2.event_cd,
   reply->dcp_forms_activity[form_cnt].clinical_event[input_cnt].task_assay_cd = ce2.task_assay_cd,
   reply->dcp_forms_activity[form_cnt].clinical_event[input_cnt].event_id = ce2.event_id
  FOOT  dfac.parent_entity_id
   stat = alterlist(reply->dcp_forms_activity[form_cnt].clinical_event,input_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
