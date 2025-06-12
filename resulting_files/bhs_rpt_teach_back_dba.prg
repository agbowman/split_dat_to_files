CREATE PROGRAM bhs_rpt_teach_back:dba
 PROMPT
  "Output to File/Printer/MINE " = "MINE",
  "Facility:" = 673936.00,
  "Nurse Unit :" = value(*),
  "Begin dt/tm:" = "CURDATE",
  "End dt/tm" = "CURDATE",
  "Email Address(es), if multiple, separate with comma:" = ""
  WITH outdev, mf_facility, mf_nurseunit,
  md_bdate, md_edate, ms_emailadd
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
 FREE RECORD forms
 RECORD forms(
   1 mn_power_forms_cnt = i2
   1 power_forms[*]
     2 mf_form_id = f8
     2 ms_form_descrip = vc
 ) WITH protect
 FREE RECORD nunit
 RECORD nunit(
   1 mn_cnt = i4
   1 list[*]
     2 mf_unit_cd = f8
     2 ms_unit_name = vc
 ) WITH protect
 FREE RECORD output_rec
 RECORD output_rec(
   1 ml_enc_cnt = i4
   1 encs[*]
     2 ms_pat_name = vc
     2 ms_fin_nbr = vc
     2 ms_pat_loc = vc
     2 ms_admit_dt = vc
     2 ms_form_signed_dt = vc
     2 ms_form_signed_by = vc
     2 mf_event_id = f8
     2 ms_attend_phys = vc
     2 ml_results_cnt = i4
     2 results[*]
       3 mf_event_cd = f8
       3 mf_event_id = f8
       3 ms_display = vc
       3 ms_event_title = vc
       3 d_event_dttm = dq8
       3 ms_event_dttm_s = vc
 ) WITH protect
 DECLARE mf_languagespoken_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"LANGUAGESPOKEN")),
 protect
 DECLARE mf_languagespoken_v001_cs72 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
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
 DECLARE mf_inpatient_cs71 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_daystay_cs71 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_observation_cs71 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OBSERVATION"))
 DECLARE mf_emergency_cs71 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_fin_cs319 = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_auth_cs8 = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_altered_cs8 = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cs8 = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_attend_phys_cs333 = f8 WITH protect, constant(uar_get_code_by("meaning",333,"ATTENDDOC"))
 DECLARE mf_facility = f8 WITH protect, constant( $MF_FACILITY)
 DECLARE ms_loc_ind = c1 WITH protect, constant(substring(1,1,reflect(parameter(3,0))))
 DECLARE mn_idx = i2 WITH noconstant(0), protect
 DECLARE mn_form_idx = i2 WITH noconstant(0), protect
 DECLARE mn_enc_idx = i2 WITH noconstant(0), protect
 DECLARE mn_result_idx = i2 WITH noconstant(0), protect
 DECLARE mn_result_idx2 = i2 WITH noconstant(0), protect
 DECLARE mn_result_loc = i2 WITH noconstant(0), protect
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE ml_cnt2 = i4 WITH noconstant(0), protect
 DECLARE ml_loc = i4 WITH noconstant(0), protect
 DECLARE ml_loc2 = i4 WITH noconstant(0), protect
 DECLARE ml_max_chars_per_line = i4 WITH noconstant(0), protect
 DECLARE ms_msg1 = vc WITH noconstant(""), protect
 DECLARE ms_msg2 = vc WITH noconstant(""), protect
 DECLARE ms_email_list = vc WITH noconstant( $MS_EMAILADD), protect
 DECLARE ms_var_output = vc WITH noconstant(""), protect
 DECLARE mn_email_ind = i2 WITH noconstant(0), protect
 DECLARE mc_filedelimiter1 = c WITH noconstant(""), protect
 DECLARE mc_filedelimiter2 = c WITH noconstant(""), protect
 DECLARE mn_designatedlearners_idx = i2 WITH noconstant(0), protect
 DECLARE mn_conditiondiagnosis_idx = i2 WITH noconstant(0), protect
 DECLARE mn_resultsconditiondiagnos_idx = i2 WITH noconstant(0), protect
 DECLARE mn_conditiondiagnosiscompl_idx = i2 WITH noconstant(0), protect
 DECLARE mn_signssymptoms_idx = i2 WITH noconstant(0), protect
 DECLARE mn_resultssignssymptoms_idx = i2 WITH noconstant(0), protect
 DECLARE mn_signssymptomscomplete_idx = i2 WITH noconstant(0), protect
 DECLARE mn_medications_idx = i2 WITH noconstant(0), protect
 DECLARE mn_resultsmedications_idx = i2 WITH noconstant(0), protect
 DECLARE mn_medicationscomplete_idx = i2 WITH noconstant(0), protect
 DECLARE mn_followup_idx = i2 WITH noconstant(0), protect
 DECLARE mn_resultsfollowup_idx = i2 WITH noconstant(0), protect
 DECLARE mn_followupcomplete_idx = i2 WITH noconstant(0), protect
 DECLARE mn_transitiondischarge_idx = i2 WITH noconstant(0), protect
 DECLARE mn_resultstransitiondisch_idx = i2 WITH noconstant(0), protect
 DECLARE mn_transitiondischcompl_idx = i2 WITH noconstant(0), protect
 DECLARE mn_other_idx = i2 WITH noconstant(0), protect
 DECLARE mn_resultsother_idx = i2 WITH noconstant(0), protect
 DECLARE mn_othercomplete_idx = i2 WITH noconstant(0), protect
 DECLARE mn_planfornextsession_idx = i2 WITH noconstant(0), protect
 DECLARE mn_concernsreteachback_idx = i2 WITH noconstant(0), protect
 DECLARE mn_reasonnotdonethisshift_idx = i2 WITH noconstant(0), protect
 DECLARE md_beg_date_qual = dq8 WITH noconstant, protect
 DECLARE md_end_date_qual = dq8 WITH noconstant, protect
 EXECUTE bhs_sys_stand_subroutine
 IF (( $MD_BDATE="OPSJOB"))
  SET md_beg_date_qual = cnvtdatetime((curdate - 7),000000)
  SET md_end_date_qual = cnvtdatetime(curdate,235959)
 ELSE
  SET md_beg_date_qual = cnvtdatetime(cnvtdate2( $MD_BDATE,"DD-MMM-YYYY"),000000)
  SET md_end_date_qual = cnvtdatetime(cnvtdate2( $MD_EDATE,"DD-MMM-YYYY"),235959)
 ENDIF
 IF (datetimediff(md_end_date_qual,md_beg_date_qual) > 31)
  CALL echo("Date range > 31")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    ms_msg1 = "Your date range is larger than 31 days.", ms_msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), ms_msg1,
    row + 2, ms_msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_script
 ELSEIF (datetimediff(md_end_date_qual,md_beg_date_qual) < 0)
  CALL echo("Date range < 0")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    ms_msg1 = "Your date range is incorrect", ms_msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), ms_msg1,
    row + 2, ms_msg2
   WITH dio = 08
  ;end select
  GO TO exit_script
 ENDIF
 IF (((findstring("@", $MS_EMAILADD) > 0) OR (( $MS_EMAILADD="OPSJOB"))) )
  SET mn_email_ind = 1
  SET ms_var_output = "teachback_report.csv"
  SET mc_filedelimiter1 = '"'
  SET mc_filedelimiter2 = ","
  IF (( $MS_EMAILADD="OPSJOB"))
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="BHS_RPT_TEACH_BACK"
    HEAD REPORT
     ml_cnt = 0
    DETAIL
     ml_cnt = (ml_cnt+ 1)
     IF (ml_cnt=1)
      ms_email_list = trim(di.info_name)
     ELSE
      ms_email_list = concat(ms_email_list,", ",trim(di.info_name))
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SET mn_email_ind = 0
  SET ms_var_output =  $OUTDEV
  SET mc_filedelimiter1 = ""
  SET mc_filedelimiter2 = ""
 ENDIF
 CALL echo(ms_email_list)
 DECLARE ml_tmp_idx = i2 WITH public, noconstant(1)
 DECLARE ml_tmp_cnt = i2 WITH public, constant(cnvtint(substring(2,3,reflect(parameter(3,0)))))
 DECLARE ms_data_type = c1 WITH public, noconstant(substring(1,1,reflect(parameter(3,0))))
 CASE (ms_data_type)
  OF "F":
   SET nunit->mn_cnt = (nunit->mn_cnt+ 1)
   SET stat = alterlist(nunit->list,nunit->mn_cnt)
   SET nunit->list[nunit->mn_cnt].mf_unit_cd = parameter(3,1)
   SET nunit->list[nunit->mn_cnt].ms_unit_name = uar_get_code_display(nunit->list[nunit->mn_cnt].
    mf_unit_cd)
  OF "L":
   FOR (ml_tmp_idx = 1 TO ml_tmp_cnt)
     SET nunit->mn_cnt = (nunit->mn_cnt+ 1)
     SET stat = alterlist(nunit->list,nunit->mn_cnt)
     SET nunit->list[nunit->mn_cnt].mf_unit_cd = parameter(3,ml_tmp_idx)
     SET nunit->list[nunit->mn_cnt].ms_unit_name = uar_get_code_display(nunit->list[nunit->mn_cnt].
      mf_unit_cd)
     CALL echo(build("parm3 ml_tmp_idx     =  ",parameter(3,ml_tmp_idx)))
   ENDFOR
  ELSE
   SELECT INTO "nl:"
    FROM nurse_unit n,
     code_value cv
    PLAN (n
     WHERE n.loc_facility_cd=mf_facility
      AND n.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=n.location_cd
      AND cv.code_set=220
      AND cv.active_ind=1
      AND cv.cdf_meaning="NURSEUNIT")
    ORDER BY cv.display
    HEAD REPORT
     nunit->mn_cnt = 0
    DETAIL
     nunit->mn_cnt = (nunit->mn_cnt+ 1), stat = alterlist(nunit->list,nunit->mn_cnt), nunit->list[
     nunit->mn_cnt].mf_unit_cd = cv.code_value,
     nunit->list[nunit->mn_cnt].ms_unit_name = cv.display
    WITH nocounter
   ;end select
 ENDCASE
 SET mn_idx = 1
 SET mn_designatedlearners_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_conditiondiagnosis_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_resultsconditiondiagnos_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_conditiondiagnosiscompl_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_signssymptoms_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_resultssignssymptoms_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_signssymptomscomplete_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_medications_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_resultsmedications_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_medicationscomplete_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_followup_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_resultsfollowup_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_followupcomplete_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_transitiondischarge_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_resultstransitiondisch_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_transitiondischcompl_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_other_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_resultsother_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_othercomplete_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_planfornextsession_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_concernsreteachback_idx = mn_idx
 SET mn_idx = (mn_idx+ 1)
 SET mn_reasonnotdonethisshift_idx = mn_idx
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE dfr.description="Patient/Family Education*"
   AND dfr.active_ind=1
  DETAIL
   forms->mn_power_forms_cnt = (forms->mn_power_forms_cnt+ 1), stat = alterlist(forms->power_forms,
    forms->mn_power_forms_cnt), forms->power_forms[forms->mn_power_forms_cnt].mf_form_id = dfr
   .dcp_forms_ref_id,
   forms->power_forms[forms->mn_power_forms_cnt].ms_form_descrip = trim(dfr.description)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dfa.encntr_id, patient_name = substring(1,50,p.name_full_formatted), fin = ea.alias,
  fac = uar_get_code_display(e.loc_facility_cd), unit = uar_get_code_display(e.loc_nurse_unit_cd),
  admit_dt_tm = format(e.reg_dt_tm,"MM/DD/YYYY hh:mm;;d"),
  attending_phys = substring(1,55,md.name_full_formatted), frm_end_dttm = ce.event_end_dt_tm, form =
  dfa.description,
  form_signed_by = substring(1,55,pr.name_full_formatted)
  FROM encntr_domain ed,
   encounter e,
   dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   clinical_event ce,
   clinical_event section,
   clinical_event dta,
   ce_date_result ced,
   person p,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl md,
   prsnl pr
  PLAN (ed
   WHERE expand(ml_loc,1,nunit->mn_cnt,ed.loc_nurse_unit_cd,nunit->list[ml_loc].mf_unit_cd))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_inpatient_cs71, mf_daystay_cs71, mf_observation_cs71,
   mf_emergency_cs71)
    AND e.disch_dt_tm = null)
   JOIN (dfa
   WHERE dfa.encntr_id=e.encntr_id
    AND dfa.person_id=e.person_id
    AND dfa.form_dt_tm BETWEEN cnvtdatetime(md_beg_date_qual) AND cnvtdatetime(md_end_date_qual)
    AND dfa.active_ind=1
    AND dfa.form_status_cd IN (mf_auth_cs8, mf_altered_cs8, mf_modified_cs8)
    AND expand(mn_form_idx,1,forms->mn_power_forms_cnt,dfa.dcp_forms_ref_id,forms->power_forms[
    mn_form_idx].mf_form_id))
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
    AND dta.result_status_cd IN (mf_auth_cs8, mf_altered_cs8, mf_modified_cs8))
   JOIN (ced
   WHERE ced.event_id=outerjoin(dta.event_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cs319
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=mf_attend_phys_cs333
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > sysdate)
   JOIN (md
   WHERE md.person_id=epr.prsnl_person_id
    AND md.end_effective_dt_tm > sysdate
    AND md.physician_ind=1)
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id)
  ORDER BY unit, ea.alias, dta.event_cd,
   dta.event_end_dt_tm DESC
  HEAD REPORT
   mn_enc_idx = 0
  HEAD e.encntr_id
   mn_result_idx = 0, mn_enc_idx = (mn_enc_idx+ 1), output_rec->ml_enc_cnt = mn_enc_idx,
   stat = alterlist(output_rec->encs,output_rec->ml_enc_cnt), output_rec->encs[mn_enc_idx].
   ms_pat_name = trim(p.name_full_formatted), output_rec->encs[mn_enc_idx].ms_fin_nbr = trim(ea.alias
    ),
   output_rec->encs[mn_enc_idx].ms_pat_loc = uar_get_code_display(e.loc_nurse_unit_cd), output_rec->
   encs[mn_enc_idx].ms_admit_dt = trim(format(e.reg_dt_tm,"MM/DD/YYYY hh:mm;;d"),3), output_rec->
   encs[mn_enc_idx].ms_attend_phys = substring(1,60,md.name_full_formatted),
   output_rec->encs[mn_enc_idx].ms_form_signed_dt = trim(format(ce.event_end_dt_tm,
     "MM/DD/YYYY hh:mm;;d"),3), output_rec->encs[mn_enc_idx].ms_form_signed_by = substring(1,60,pr
    .name_full_formatted), output_rec->encs[mn_enc_idx].mf_event_id = ce.event_id,
   output_rec->encs[mn_enc_idx].ml_results_cnt = mn_idx, stat = alterlist(output_rec->encs[mn_enc_idx
    ].results,output_rec->encs[mn_enc_idx].ml_results_cnt), output_rec->encs[mn_enc_idx].results[
   mn_designatedlearners_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,
    "TEACHBACKDESIGNATEDLEARNERS"),
   output_rec->encs[mn_enc_idx].results[mn_conditiondiagnosis_idx].mf_event_cd = uar_get_code_by(
    "DISPLAYKEY",72,"TEACHBACKCONDITIONDIAGNOSIS"), output_rec->encs[mn_enc_idx].results[
   mn_resultsconditiondiagnos_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,
    "TEACHBACKRESULTSCONDITIONDIAGNOSIS"), output_rec->encs[mn_enc_idx].results[
   mn_conditiondiagnosiscompl_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,
    "TEACHBACKCONDITIONDIAGNOSISCOMPLETE"),
   output_rec->encs[mn_enc_idx].results[mn_signssymptoms_idx].mf_event_cd = uar_get_code_by(
    "DISPLAYKEY",72,"TEACHBACKSIGNSSYMPTOMS"), output_rec->encs[mn_enc_idx].results[
   mn_resultssignssymptoms_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,
    "TEACHBACKRESULTSSIGNSSYMPTOMS"), output_rec->encs[mn_enc_idx].results[
   mn_signssymptomscomplete_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,
    "TEACHBACKSIGNSSYMPTOMSCOMPLETE"),
   output_rec->encs[mn_enc_idx].results[mn_medications_idx].mf_event_cd = uar_get_code_by(
    "DISPLAYKEY",72,"TEACHBACKMEDICATIONS"), output_rec->encs[mn_enc_idx].results[
   mn_resultsmedications_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,
    "TEACHBACKRESULTSMEDICATIONS"), output_rec->encs[mn_enc_idx].results[mn_medicationscomplete_idx].
   mf_event_cd = uar_get_code_by("DISPLAYKEY",72,"TEACHBACKMEDICATIONSCOMPLETE"),
   output_rec->encs[mn_enc_idx].results[mn_followup_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",
    72,"TEACHBACKFOLLOWUP"), output_rec->encs[mn_enc_idx].results[mn_resultsfollowup_idx].mf_event_cd
    = uar_get_code_by("DISPLAYKEY",72,"TEACHBACKRESULTSFOLLOWUP"), output_rec->encs[mn_enc_idx].
   results[mn_followupcomplete_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,
    "TEACHBACKFOLLOWUPCOMPLETE"),
   output_rec->encs[mn_enc_idx].results[mn_transitiondischarge_idx].mf_event_cd = uar_get_code_by(
    "DISPLAYKEY",72,"TEACHBACKTRANSITIONDISCHARGE"), output_rec->encs[mn_enc_idx].results[
   mn_resultstransitiondisch_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,
    "TEACHBACKRESULTSTRANSITIONDISCHARGE"), output_rec->encs[mn_enc_idx].results[
   mn_transitiondischcompl_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,
    "TEACHBACKTRANSITIONDISCHARGECOMPL"),
   output_rec->encs[mn_enc_idx].results[mn_other_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,
    "TEACHBACKOTHER"), output_rec->encs[mn_enc_idx].results[mn_resultsother_idx].mf_event_cd =
   uar_get_code_by("DISPLAYKEY",72,"TEACHBACKRESULTSOTHER"), output_rec->encs[mn_enc_idx].results[
   mn_othercomplete_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,"TEACHBACKOTHERCOMPLETE"),
   output_rec->encs[mn_enc_idx].results[mn_planfornextsession_idx].mf_event_cd = uar_get_code_by(
    "DISPLAYKEY",72,"PLANFORNEXTTEACHINGSESSION"), output_rec->encs[mn_enc_idx].results[
   mn_concernsreteachback_idx].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,
    "CONCERNSREGARDINGTEACHBACK"), output_rec->encs[mn_enc_idx].results[mn_reasonnotdonethisshift_idx
   ].mf_event_cd = uar_get_code_by("DISPLAYKEY",72,"REASONTEACHBACKNOTDONETHISSHIFT")
  HEAD dta.event_cd
   mn_result_loc = 0, mn_result_loc = locateval(mn_result_idx2,1,output_rec->encs[mn_enc_idx].
    ml_results_cnt,dta.event_cd,output_rec->encs[mn_enc_idx].results[mn_result_idx2].mf_event_cd)
   IF (mn_result_loc != 0)
    IF (ced.event_id > 0)
     output_rec->encs[mn_enc_idx].results[mn_result_idx2].ms_display = trim(format(ced.result_dt_tm,
       "MM/DD/YYYY;;d"),3)
    ELSE
     output_rec->encs[mn_enc_idx].results[mn_result_idx2].ms_display = trim(dta.result_val)
    ENDIF
    output_rec->encs[mn_enc_idx].results[mn_result_idx2].ms_event_title = trim(dta.event_title_text),
    output_rec->encs[mn_enc_idx].results[mn_result_idx2].mf_event_id = dta.event_id, output_rec->
    encs[mn_enc_idx].results[mn_result_idx2].d_event_dttm = dta.event_end_dt_tm,
    output_rec->encs[mn_enc_idx].results[mn_result_idx2].ms_event_dttm_s = trim(format(dta
      .event_end_dt_tm,"MM/DD/YYYY hh:mm;;d"),3)
   ENDIF
  WITH format, separator = " ", format(date,";;Q"),
   expand = 1
 ;end select
 IF (((curqual=0) OR ((output_rec->ml_enc_cnt=0))) )
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    ms_msg1 = concat("No patients were found for the selected time frame/unit"), col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), ms_msg1
   WITH dio = 08
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO value(trim(ms_var_output))
  nurse_unit = trim(substring(1,20,output_rec->encs[d.seq].ms_pat_loc)), patient_name = trim(
   substring(1,50,output_rec->encs[d.seq].ms_pat_name)), admit_date = trim(substring(1,20,output_rec
    ->encs[d.seq].ms_admit_dt)),
  fin = trim(substring(1,14,output_rec->encs[d.seq].ms_fin_nbr)), last_performed = trim(substring(1,
    20,output_rec->encs[d.seq].ms_form_signed_dt)), documented_by = trim(substring(1,60,output_rec->
    encs[d.seq].ms_form_signed_by)),
  designated_learner = trim(substring(1,50,output_rec->encs[d.seq].results[mn_designatedlearners_idx]
    .ms_display)), des_learner_charted = trim(substring(1,20,output_rec->encs[d.seq].results[
    mn_designatedlearners_idx].ms_event_dttm_s)), conditions_diagnosis = trim(substring(1,90,
    output_rec->encs[d.seq].results[mn_conditiondiagnosis_idx].ms_display)),
  cond_diag_charted = trim(substring(1,20,output_rec->encs[d.seq].results[mn_conditiondiagnosis_idx].
    ms_event_dttm_s)), rslt_conditions_diagnosis = trim(substring(1,90,output_rec->encs[d.seq].
    results[mn_resultsconditiondiagnos_idx].ms_display)), rslt_cond_diag_charted = trim(substring(1,
    20,output_rec->encs[d.seq].results[mn_resultsconditiondiagnos_idx].ms_event_dttm_s)),
  condition_diagnosis_complete = trim(substring(1,20,output_rec->encs[d.seq].results[
    mn_conditiondiagnosiscompl_idx].ms_display)), cond_diag_compl_charted = trim(substring(1,20,
    output_rec->encs[d.seq].results[mn_conditiondiagnosiscompl_idx].ms_event_dttm_s)), signs_symptoms
   = trim(substring(1,90,output_rec->encs[d.seq].results[mn_signssymptoms_idx].ms_display)),
  signs_symptoms_charted = trim(substring(1,20,output_rec->encs[d.seq].results[mn_signssymptoms_idx].
    ms_event_dttm_s)), rslt_signs_symptoms = trim(substring(1,90,output_rec->encs[d.seq].results[
    mn_resultssignssymptoms_idx].ms_display)), rslt_signs_sympt_charted = trim(substring(1,20,
    output_rec->encs[d.seq].results[mn_resultssignssymptoms_idx].ms_event_dttm_s)),
  signs_symptoms_complete = trim(substring(1,20,output_rec->encs[d.seq].results[
    mn_signssymptomscomplete_idx].ms_display)), signs_sympt_compl_charted = trim(substring(1,20,
    output_rec->encs[d.seq].results[mn_signssymptomscomplete_idx].ms_event_dttm_s)), medications =
  trim(substring(1,90,output_rec->encs[d.seq].results[mn_medications_idx].ms_display)),
  medications_charted = trim(substring(1,20,output_rec->encs[d.seq].results[mn_medications_idx].
    ms_event_dttm_s)), rslt_medications = trim(substring(1,90,output_rec->encs[d.seq].results[
    mn_resultsmedications_idx].ms_display)), rslt_medications_charted = trim(substring(1,20,
    output_rec->encs[d.seq].results[mn_resultsmedications_idx].ms_event_dttm_s)),
  medications_complete = trim(substring(1,20,output_rec->encs[d.seq].results[
    mn_medicationscomplete_idx].ms_display)), medications_compl_charted = trim(substring(1,20,
    output_rec->encs[d.seq].results[mn_medicationscomplete_idx].ms_event_dttm_s)), followup = trim(
   substring(1,90,output_rec->encs[d.seq].results[mn_followup_idx].ms_display)),
  followup_charted = trim(substring(1,20,output_rec->encs[d.seq].results[mn_followup_idx].
    ms_event_dttm_s)), rslt_followup = trim(substring(1,90,output_rec->encs[d.seq].results[
    mn_resultsfollowup_idx].ms_display)), rslt_followup_charted = trim(substring(1,20,output_rec->
    encs[d.seq].results[mn_resultsfollowup_idx].ms_event_dttm_s)),
  followup_complete = trim(substring(1,20,output_rec->encs[d.seq].results[mn_followupcomplete_idx].
    ms_display)), followup_compl_charted = trim(substring(1,20,output_rec->encs[d.seq].results[
    mn_followupcomplete_idx].ms_event_dttm_s)), transition_discharge = trim(substring(1,90,output_rec
    ->encs[d.seq].results[mn_transitiondischarge_idx].ms_display)),
  trans_disch_charted = trim(substring(1,20,output_rec->encs[d.seq].results[
    mn_transitiondischarge_idx].ms_event_dttm_s)), rslt_transition_disch = trim(substring(1,90,
    output_rec->encs[d.seq].results[mn_resultstransitiondisch_idx].ms_display)),
  rslt_trans_disch_charted = trim(substring(1,20,output_rec->encs[d.seq].results[
    mn_resultstransitiondisch_idx].ms_event_dttm_s)),
  transition_disch_complete = trim(substring(1,20,output_rec->encs[d.seq].results[
    mn_transitiondischcompl_idx].ms_display)), trans_disch_compl_charted = trim(substring(1,20,
    output_rec->encs[d.seq].results[mn_transitiondischcompl_idx].ms_event_dttm_s)), other = trim(
   substring(1,90,output_rec->encs[d.seq].results[mn_other_idx].ms_display)),
  other_charted = trim(substring(1,20,output_rec->encs[d.seq].results[mn_other_idx].ms_event_dttm_s)),
  rslt_other = trim(substring(1,90,output_rec->encs[d.seq].results[mn_resultsother_idx].ms_display)),
  rslt_other_charted = trim(substring(1,20,output_rec->encs[d.seq].results[mn_resultsother_idx].
    ms_event_dttm_s)),
  other_complete = trim(substring(1,90,output_rec->encs[d.seq].results[mn_othercomplete_idx].
    ms_display)), other_compl_charted = trim(substring(1,20,output_rec->encs[d.seq].results[
    mn_othercomplete_idx].ms_event_dttm_s)), plan_for_next_session = trim(substring(1,90,output_rec->
    encs[d.seq].results[mn_planfornextsession_idx].ms_display)),
  plan_for_next_sess_charted = trim(substring(1,20,output_rec->encs[d.seq].results[
    mn_planfornextsession_idx].ms_event_dttm_s)), concerns_about_teach_back = trim(substring(1,90,
    output_rec->encs[d.seq].results[mn_concernsreteachback_idx].ms_display)), concerns_charted = trim
  (substring(1,20,output_rec->encs[d.seq].results[mn_concernsreteachback_idx].ms_event_dttm_s)),
  reason_not_done = trim(substring(1,90,output_rec->encs[d.seq].results[mn_reasonnotdonethisshift_idx
    ].ms_display)), reason_not_done_charted = trim(substring(1,20,output_rec->encs[d.seq].results[
    mn_reasonnotdonethisshift_idx].ms_event_dttm_s))
  FROM (dummyt d  WITH seq = size(output_rec->encs,5))
  PLAN (d)
  ORDER BY patient_name, patient_name
  WITH nocounter, format, pcformat(value(mc_filedelimiter1),value(mc_filedelimiter2))
 ;end select
#exit_script
 IF (mn_email_ind=1)
  CALL emailfile(ms_var_output,ms_var_output,ms_email_list,concat("Teach Back Report - ",format(
     cnvtdatetime(curdate,curtime),";;q")," - ",curprog),0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    SUBROUTINE cclrtf_print(par_flag,par_xpixel,par_yoffset,par_numcol,par_blob,par_bloblen,par_check
     )
      m_output_buffer_len = 0, blob_out = fillstring(30000," "), blob_buf = fillstring(200," "),
      m_linefeed = concat(char(10)), numlines = 0, textindex = 0,
      numcol = par_numcol, whiteflag = 0, yincrement = 12,
      yoffset = 0,
      CALL uar_rtf(par_blob,par_bloblen,blob_out,size(blob_out),m_output_buffer_len,par_flag),
      m_output_buffer_len = minval(m_output_buffer_len,size(trim(blob_out)))
      IF (m_output_buffer_len > 0)
       m_cc = 1
       WHILE (m_cc)
        m_cc2 = findstring(m_linefeed,blob_out,m_cc),
        IF (m_cc2)
         blob_len = (m_cc2 - m_cc)
         IF (blob_len <= par_numcol)
          m_blob_buf = substring(m_cc,blob_len,blob_out), yoffset = (y_pos+ par_yoffset)
          IF (par_check)
           CALL print(calcpos(par_xpixel,yoffset)),
           CALL print(trim(check(m_blob_buf)))
          ELSE
           CALL print(calcpos(par_xpixel,yoffset)),
           CALL print(trim(m_blob_buf))
          ENDIF
          par_yoffset = (par_yoffset+ yincrement), numlines = (numlines+ 1), row + 1
         ELSE
          m_blobbuf = substring(m_cc,blob_len,blob_out),
          CALL cclrtf_printline(par_numcol,blob_out,blob_len,par_check)
         ENDIF
         IF (m_cc2 >= m_output_buffer_len)
          m_cc = 0
         ELSE
          m_cc = (m_cc2+ 1)
         ENDIF
        ELSE
         blob_len = ((m_output_buffer_len - m_cc)+ 1), m_blobbuf = substring(m_cc,blob_len,blob_out),
         CALL cclrtf_printline(par_numcol,blob_out,blob_len,par_check),
         m_cc = 0
        ENDIF
       ENDWHILE
      ENDIF
      m_numlines = numlines
    END ;Subroutine report
    ,
    SUBROUTINE cclrtf_printline(par_numcol,blob_out,blob_len,par_check)
      textindex = 0, numcol = par_numcol, whiteflag = 0,
      printcol = 0, rownum = 0, lastline = 0,
      m_linefeed = concat(char(10))
      WHILE (blob_len > 0)
        IF (blob_len <= par_numcol)
         numcol = blob_len, lastline = 1
        ENDIF
        textindex = (m_cc+ par_numcol)
        IF (lastline=0)
         whiteflag = 0
         WHILE (whiteflag=0)
          IF (((substring(textindex,1,blob_out)=" ") OR (substring(textindex,1,blob_out)=m_linefeed
          )) )
           whiteflag = 1
          ELSE
           textindex = (textindex - 1)
          ENDIF
          ,
          IF (((textindex=m_cc) OR (textindex=0)) )
           textindex = (m_cc+ par_numcol), whiteflag = 1
          ENDIF
         ENDWHILE
         numcol = ((textindex - m_cc)+ 1)
        ENDIF
        m_blob_buf = substring(m_cc,numcol,blob_out)
        IF (m_blob_buf > " ")
         numlines = (numlines+ 1), yoffset = (y_pos+ par_yoffset)
         IF (par_check)
          CALL print(calcpos(par_xpixel,yoffset)),
          CALL print(trim(check(m_blob_buf)))
         ELSE
          CALL print(calcpos(par_xpixel,yoffset)),
          CALL print(trim(m_blob_buf))
         ENDIF
         par_yoffset = (par_yoffset+ yincrement), row + 1
        ELSE
         blob_len = 0
        ENDIF
        m_cc = (m_cc+ numcol)
        IF (blob_len > numcol)
         blob_len = (blob_len - numcol)
        ELSE
         blob_len = 0
        ENDIF
      ENDWHILE
    END ;Subroutine report
    , ms_msg1 = "Teach Back Report file emailed to: ",
    col 0, "{PS/792 0 translate 90 rotate/}", y_pos = 18,
    row + 1, "{F/1}{CPI/9}",
    CALL print(calcpos(18,(y_pos+ 0))),
    ms_msg1, row + 2, y_pos = (y_pos+ 16),
    x_pos = 30, ml_max_chars_per_line = 80,
    CALL cclrtf_print(1,x_pos,0,ml_max_chars_per_line,ms_email_list,size(ms_email_list,1),1)
   WITH dio = 08
  ;end select
 ENDIF
 FREE RECORD nunit
 FREE RECORD output_rec
END GO
