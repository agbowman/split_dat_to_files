CREATE PROGRAM bhs_gvw_teachback:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = gvc
    1 status_data[1]
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
 ENDIF
 FREE RECORD form
 RECORD form(
   1 mf_person_id = f8
   1 mf_encntr_id = f8
   1 power_forms_cnt = i4
   1 power_forms[*]
     2 mf_form_id = f8
     2 ms_form_descrip = vc
   1 mn_result_cnt = i4
   1 results[*]
     2 mf_event_cd = f8
     2 mf_event_id = f8
     2 ms_display = vc
     2 ms_event_prefix = vc
     2 ms_event_title = vc
 )
 DECLARE mf_languagespoken_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"LANGUAGESPOKEN")),
 protect
 DECLARE mf_languagespokenv001_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "LANGUAGESPOKENV001")), protect
 DECLARE mf_teachbackdesignatedlearners_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKDESIGNATEDLEARNERS")), protect
 DECLARE mf_teachbackconditiondiagnosis_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKCONDITIONDIAGNOSIS")), protect
 DECLARE mf_teachbackresultsconditiondiagnosis_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",
   72,"TEACHBACKRESULTSCONDITIONDIAGNOSIS")), protect
 DECLARE mf_teachbackconditiondiagnosiscomplete_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",
   72,"TEACHBACKCONDITIONDIAGNOSISCOMPLETE")), protect
 DECLARE mf_teachbacksignssymptoms_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKSIGNSSYMPTOMS")), protect
 DECLARE mf_teachbackresultssignssymptoms_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKRESULTSSIGNSSYMPTOMS")), protect
 DECLARE mf_teachbacksignssymptomscomplete_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKSIGNSSYMPTOMSCOMPLETE")), protect
 DECLARE mf_teachbackmedications_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKMEDICATIONS")), protect
 DECLARE mf_teachbackresultsmedications_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKRESULTSMEDICATIONS")), protect
 DECLARE mf_teachbackmedicationscomplete_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKMEDICATIONSCOMPLETE")), protect
 DECLARE mf_teachbackfollowup_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKFOLLOWUP")), protect
 DECLARE mf_teachbackresultsfollowup_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKRESULTSFOLLOWUP")), protect
 DECLARE mf_teachbackfollowupcomplete_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKFOLLOWUPCOMPLETE")), protect
 DECLARE mf_teachbacktransitiondischarge_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKTRANSITIONDISCHARGE")), protect
 DECLARE mf_teachbackresultstransitiondischarge_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",
   72,"TEACHBACKRESULTSTRANSITIONDISCHARGE")), protect
 DECLARE mf_teachbacktransitiondischargecompl_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKTRANSITIONDISCHARGECOMPL")), protect
 DECLARE mf_teachbackother_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TEACHBACKOTHER")),
 protect
 DECLARE mf_teachbackresultsother_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKRESULTSOTHER")), protect
 DECLARE mf_teachbackothercomplete_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TEACHBACKOTHERCOMPLETE")), protect
 DECLARE mf_planfornextteachingsession_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PLANFORNEXTTEACHINGSESSION")), protect
 DECLARE mf_concernsregardingteachback_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "CONCERNSREGARDINGTEACHBACK")), protect
 DECLARE mf_reasonteachbacknotdonethisshift_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "REASONTEACHBACKNOTDONETHISSHIFT")), protect
 DECLARE mf_auth_cs8 = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_altered_cs8 = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cs8 = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE ms_rhead = vc WITH constant("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}\deftab1134"),
 protect
 DECLARE ms_rh2b = vc WITH constant("\plain \f0 \fs18 \b \cb2 \pard\sl0 "), protect
 DECLARE ms_reol = vc WITH constant("\par "), protect
 DECLARE ms_wr = vc WITH constant(" \plain \f0 \fs18 \cb2 "), protect
 DECLARE ms_wb = vc WITH constant(" \plain \f0 \fs18 \b \cb2 "), protect
 DECLARE ms_rtfeof = vc WITH noconstant("}"), protect
 DECLARE mn_form_idx = i2 WITH noconstant(0), protect
 DECLARE mn_result_idx = i2 WITH noconstant(0), protect
 DECLARE mn_result_idx2 = i2 WITH noconstant(0), protect
 DECLARE mn_result_loc = i2 WITH noconstant(0), protect
 DECLARE ms_outputrtf = vc WITH noconstant(""), protect
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
  DETAIL
   form->mf_person_id = e.person_id, form->mf_encntr_id = e.encntr_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE dfr.description="Patient/Family Education*"
   AND dfr.active_ind=1
  DETAIL
   form->power_forms_cnt = (form->power_forms_cnt+ 1), stat = alterlist(form->power_forms,form->
    power_forms_cnt), form->power_forms[form->power_forms_cnt].mf_form_id = dfr.dcp_forms_ref_id,
   form->power_forms[form->power_forms_cnt].ms_form_descrip = trim(dfr.description)
  WITH nocounter
 ;end select
 SET form->mn_result_cnt = 23
 SET stat = alterlist(form->results,form->mn_result_cnt)
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackdesignatedlearners_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Designated Learner(s): "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_languagespokenv001_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Language Spoken: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackconditiondiagnosis_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Condition/Diagnosis: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackresultsconditiondiagnosis_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back Results, Condition/Diagnosis: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackconditiondiagnosiscomplete_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Condition/Diagnosis Complete: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbacksignssymptoms_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Signs/Symptoms: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackresultssignssymptoms_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back Results, Signs/Symptoms: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbacksignssymptomscomplete_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Signs/Symptoms Complete: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackmedications_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Medications: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackresultsmedications_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back Results, Medications: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackmedicationscomplete_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Medications Complete: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackfollowup_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Follow Up: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackresultsfollowup_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back Results, Follow Up: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackfollowupcomplete_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Follow Up Complete: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbacktransitiondischarge_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Transition/Discharge: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackresultstransitiondischarge_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back Results, Transition/Discharge: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbacktransitiondischargecompl_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Transition/Discharge Complete: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackother_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Other: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackresultsother_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back Results, Other: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_teachbackothercomplete_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Teach Back, Other Complete: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_planfornextteachingsession_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Plan for Next Teaching Session: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_concernsregardingteachback_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Concerns Regarding Teach Back: "
 SET mn_result_idx = (mn_result_idx+ 1)
 SET form->results[mn_result_idx].mf_event_cd = mf_reasonteachbacknotdonethisshift_cs72
 SET form->results[mn_result_idx].ms_event_prefix = "Reason Teach Back Not Done This Shift: "
 SELECT
  dfa.encntr_id, form = dfa.description, frm_activity_id = dfa.dcp_forms_activity_id,
  section_name = section.event_title_text, dta_name = dta.event_title_text, dta_disp =
  uar_get_code_display(dta.task_assay_cd),
  dta_ec_disp = uar_get_code_display(dta.event_cd), dta.result_val, frm_end_dttm = ce.event_end_dt_tm,
  sect_end_dttm = section.event_end_dt_tm, dta_end_dttm = dta.event_end_dt_tm
  FROM dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   clinical_event ce,
   clinical_event section,
   clinical_event dta,
   ce_date_result ced
  PLAN (dfa
   WHERE (dfa.encntr_id=request->visit[1].encntr_id)
    AND dfa.active_ind=1
    AND dfa.form_status_cd IN (mf_auth_cs8, mf_altered_cs8, mf_modified_cs8)
    AND expand(mn_form_idx,1,form->power_forms_cnt,dfa.dcp_forms_ref_id,form->power_forms[mn_form_idx
    ].mf_form_id)
    AND dfa.form_dt_tm >= cnvtdatetime((curdate - 2),curtime3))
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND dfac.parent_entity_name="CLINICAL_EVENT")
   JOIN (ce
   WHERE ce.event_id=dfac.parent_entity_id
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (section
   WHERE section.parent_event_id=ce.event_id
    AND section.valid_until_dt_tm > sysdate
    AND section.event_title_text="Teach Back"
    AND section.result_status_cd IN (mf_auth_cs8, mf_altered_cs8, mf_modified_cs8))
   JOIN (dta
   WHERE dta.parent_event_id=section.event_id
    AND dta.valid_until_dt_tm > sysdate
    AND dta.result_status_cd IN (mf_auth_cs8, mf_altered_cs8, mf_modified_cs8)
    AND dta.event_end_dt_tm >= cnvtdatetime((curdate - 2),curtime3)
    AND expand(mn_result_idx,1,form->mn_result_cnt,dta.event_cd,form->results[mn_result_idx].
    mf_event_cd))
   JOIN (ced
   WHERE ced.event_id=outerjoin(dta.event_id))
  ORDER BY dta.event_cd, dta.event_end_dt_tm DESC
  HEAD dta.event_cd
   mn_result_loc = 0, mn_result_loc = locateval(mn_result_idx2,1,form->mn_result_cnt,dta.event_cd,
    form->results[mn_result_idx2].mf_event_cd)
   IF (mn_result_loc != 0)
    IF (ced.event_id > 0)
     form->results[mn_result_idx2].ms_display = concat(" ",trim(format(ced.result_dt_tm,
        "MM/DD/YYYY;;d"),3))
    ELSE
     form->results[mn_result_idx2].ms_display = trim(dta.result_val)
    ENDIF
    form->results[mn_result_idx2].ms_event_title = trim(dta.event_title_text), form->results[
    mn_result_idx2].mf_event_id = dta.event_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  ce.event_title_text, event_cd_disp = uar_get_code_display(ce.event_cd), task_assay_disp =
  uar_get_code_display(ce.task_assay_cd),
  ce.result_val, ce.encntr_id, ce.event_end_dt_tm
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND ce.event_cd IN (mf_languagespoken_cs72, mf_languagespokenv001_cs72)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (mf_auth_cs8, mf_altered_cs8, mf_modified_cs8))
  ORDER BY ce.event_end_dt_tm DESC
  HEAD REPORT
   mn_result_loc = 0, mn_result_loc = locateval(mn_result_idx2,1,form->mn_result_cnt,
    mf_languagespokenv001_cs72,form->results[mn_result_idx2].mf_event_cd)
   IF (mn_result_loc != 0)
    form->results[mn_result_idx2].ms_display = trim(ce.result_val), form->results[mn_result_idx2].
    ms_event_title = trim(ce.event_title_text), form->results[mn_result_idx2].mf_event_id = ce
    .event_id
   ENDIF
  WITH nocounter, format, format(date,";;Q"),
   time = 600
 ;end select
 FOR (mn_result_idx = 1 TO form->mn_result_cnt)
   IF (mn_result_idx=1)
    SET ms_outputrtf = concat(ms_rh2b,form->results[mn_result_idx].ms_event_prefix,ms_wr,form->
     results[mn_result_idx].ms_display,ms_reol)
   ELSE
    SET ms_outputrtf = concat(ms_outputrtf,ms_wb,form->results[mn_result_idx].ms_event_prefix,ms_wr,
     form->results[mn_result_idx].ms_display,
     ms_reol)
   ENDIF
 ENDFOR
 SET reply->text = concat(ms_rhead,ms_outputrtf,ms_rtfeof)
 CALL echo(concat("ms_outputrtf is : ",ms_outputrtf))
 CALL echo(concat("reply->text is : ",reply->text))
 GO TO exit_script
#exit_script
 FREE RECORD form
END GO
