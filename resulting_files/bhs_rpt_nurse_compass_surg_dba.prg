CREATE PROGRAM bhs_rpt_nurse_compass_surg:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Begin CARE Charge Form DT/TM:" = "SYSDATE",
  "Enter End CARE Charge Form DT/TM:" = "SYSDATE"
  WITH outdev, s_begindate, s_enddate
 FREE RECORD m_form
 RECORD m_form(
   1 l_fcnt = i4
   1 form[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_encntr_type_disp = vc
     2 s_unit_desc = vc
     2 f_unit_cd = f8
     2 s_f_desc = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 f_dcp_forms_activity_id = f8
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 pat[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_dcp_forms_activity_id = f8
     2 f_dcp_forms_ref_id = f8
     2 d_version_dt_tm = dq8
     2 s_fin = vc
     2 s_mrn = vc
     2 s_dob = vc
     2 s_encntr_type_disp = vc
     2 s_unit_desc = vc
     2 s_f_desc = vc
     2 f_unit_cd = f8
     2 s_asa_rating = vc
     2 s_surgical_case_number = vc
     2 s_case_date = vc
     2 s_scheduled_case_date = vc
     2 s_date_case_added_to_schedule = vc
     2 s_cancellation_date = vc
     2 s_cancellation_code = vc
     2 s_delay_code = vc
     2 s_delay_reason = vc
     2 s_patient_start_in_preop = vc
     2 s_patient_finished_in_preop = vc
     2 s_patient_in_room_actual = vc
     2 s_patient_out_of_room_actual = vc
     2 s_arrival_in_pacu = vc
     2 s_discharge_from_pacu = vc
     2 f_dcp_forms_activity_id = f8
 ) WITH protect
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = vc
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_rpt_nurse_compass_surg/"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_primary_event_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",18189,
   "PRIMARYEVENTID"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"
   ))
 DECLARE mf_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_final_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"FINAL"))
 DECLARE mf_inerror_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"INERROR"))
 DECLARE mf_notdone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"NOTDONE"))
 DECLARE mf_date_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"DATE"))
 DECLARE mf_grp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"GRP"))
 DECLARE mf_txt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"TXT"))
 DECLARE mf_care_pacuunit_timein_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREPACUUNITTIMEIN"))
 DECLARE mf_care_pacuunit_timeout_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREPACUUNITTIMEOUT"))
 DECLARE mf_care_preproc_timein_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREPREPROCEDURETIMEIN"))
 DECLARE mf_care_preproc_timeout_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREPREPROCEDURETIMEOUT"))
 DECLARE mf_care_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"CARE"))
 DECLARE mf_heartvascpreadm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "HEARTVASCPREADM"))
 DECLARE mf_carepostinterventionrecoverytimein_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"CAREPOSTINTERVENTIONRECOVERYTIMEIN"))
 DECLARE mf_carepostinterventionrecoverytimeout_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"CAREPOSTINTERVENTIONRECOVERYTIMEOUT"))
 DECLARE mf_careprimaryrecoverytimein_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREPRIMARYRECOVERYTIMEIN"))
 DECLARE mf_caresecondaryrecoverytimein_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"CARESECONDARYRECOVERYTIMEIN"))
 DECLARE mf_carepreadmissionevaltimeinchg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"CAREPREADMISSIONEVALTIMEINCHG"))
 DECLARE mf_carepreadmissionevaltimeoutchg_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"CAREPREADMISSIONEVALTIMEOUTCHG"))
 DECLARE mf_careunitreasonforvisitchg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CAREUNITREASONFORVISITCHG"))
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_output2 = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(trim( $S_BEGINDATE))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(trim( $S_ENDDATE))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE mf_bmc_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bfmc_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_dcl_cmd = vc WITH protect, noconstant(" ")
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_pidx = i4 WITH protect, noconstant(0)
 IF (((validate(request->batch_selection)=1) OR (mn_ops=1)) )
  SET mn_ops = 1
  SET ms_output = concat(ms_loc_dir,"compassedsnap/","cis_surgcases_",trim(format(sysdate,"mmddyy;;d"
     )),".txt")
  SET ms_output2 = concat(ms_loc_dir,"compass/","cis_surgcases_",trim(format(sysdate,"yyyymmdd;;d")),
   ".txt")
  CALL echo(ms_output)
  CALL echo(ms_output2)
  SET ms_end_dt_tm = trim(format(datetimefind(sysdate,"D","B","B"),"dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_beg_dt_tm = trim(format(cnvtlookbehind("72,H",cnvtdatetime(ms_end_dt_tm)),
    "dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_end_dt_tm = trim(format(cnvtlookbehind("1,S",cnvtdatetime(ms_end_dt_tm)),
    "dd-mmm-yyyy hh:mm:ss;;d"))
  CALL echo(concat("beg dt: ",ms_beg_dt_tm))
  CALL echo(concat("end dt: ",ms_end_dt_tm))
 ELSE
  IF (((textlen(ms_beg_dt_tm)=0) OR (textlen(ms_end_dt_tm)=0)) )
   CALL echo("invalid dates - exit")
   GO TO exit_script
  ENDIF
  IF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
   CALL echo("beg date must be < end date - exit")
   GO TO exit_script
  ENDIF
  IF (cnvtdatetime(ms_beg_dt_tm)=cnvtdatetime(ms_end_dt_tm))
   CALL echo("beg date must be < end date - exit")
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.display_key="BMC"
   AND cv.cdf_meaning="FACILITY"
  DETAIL
   mf_bmc_facility_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.display_key="BFMC"
   AND cv.cdf_meaning="FACILITY"
  DETAIL
   mf_bfmc_facility_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (dfr
   WHERE dfr.definition="*CARE Unit Charge Guide - BHS*"
    AND dfr.active_ind=1)
   JOIN (dfa
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND dfa.version_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND dfa.form_status_cd IN (mf_authverified_cd, mf_mod_cd, mf_final_cd))
   JOIN (e
   WHERE e.encntr_id=dfa.encntr_id
    AND e.loc_facility_cd IN (mf_bmc_facility_cd, mf_bfmc_facility_cd)
    AND e.active_ind=1
    AND e.reg_dt_tm IS NOT null)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm> Outerjoin(sysdate))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_cd)) )
  ORDER BY dfa.encntr_id, cnvtdatetime(dfa.version_dt_tm) DESC
  DETAIL
   m_form->l_fcnt += 1, stat = alterlist(m_form->form,m_form->l_fcnt), m_form->form[m_form->l_fcnt].
   f_encntr_id = e.encntr_id,
   m_form->form[m_form->l_fcnt].f_person_id = e.person_id, m_form->form[m_form->l_fcnt].s_f_desc =
   trim(uar_get_code_display(e.loc_facility_cd)), m_form->form[m_form->l_fcnt].s_fin = trim(ea1.alias
    ),
   m_form->form[m_form->l_fcnt].s_mrn = trim(ea2.alias), m_form->form[m_form->l_fcnt].
   f_dcp_forms_activity_id = dfa.dcp_forms_activity_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dfa.dcp_forms_activity_id, dfa.encntr_id, ce2.event_cd,
  dfa.version_dt_tm, ps_event_type_sort =
  IF (ce2.event_cd=mf_care_pacuunit_timein_cd) "A"
  ELSEIF (ce2.event_cd=mf_care_pacuunit_timeout_cd) "B"
  ELSEIF (ce2.event_cd=mf_care_preproc_timein_cd) "C"
  ELSEIF (ce2.event_cd=mf_care_preproc_timeout_cd) "D"
  ELSEIF (ce2.event_cd=mf_carepostinterventionrecoverytimein_cd) "E"
  ELSEIF (ce2.event_cd=mf_carepostinterventionrecoverytimeout_cd) "F"
  ELSEIF (ce2.event_cd=mf_careprimaryrecoverytimein_cd) "G"
  ELSEIF (ce2.event_cd=mf_caresecondaryrecoverytimein_cd) "H"
  ELSEIF (ce2.event_cd=mf_carepreadmissionevaltimeinchg_cd) "I"
  ELSEIF (ce2.event_cd=mf_carepreadmissionevaltimeoutchg_cd) "J"
  ELSE "Z"
  ENDIF
  FROM dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   ce_date_result cdr
  PLAN (dfa
   WHERE expand(ml_pidx,1,size(m_form->form,5),dfa.dcp_forms_activity_id,m_form->form[ml_pidx].
    f_dcp_forms_activity_id))
   JOIN (dfac
   WHERE dfa.dcp_forms_activity_id=dfac.dcp_forms_activity_id
    AND dfac.component_cd=mf_primary_event_cd
    AND dfac.parent_entity_name="CLINICAL_EVENT")
   JOIN (ce
   WHERE ce.event_id=dfac.parent_entity_id
    AND  NOT (ce.result_status_cd IN (mf_inerror_cd, mf_notdone_cd))
    AND ce.result_status_cd=mf_authverified_cd
    AND ce.event_class_cd=mf_grp_cd
    AND ce.authentic_flag=1
    AND ce.view_level=1
    AND ce.publish_flag=1)
   JOIN (ce1
   WHERE ce.event_id=ce1.parent_event_id
    AND ce1.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND  NOT (ce1.result_status_cd IN (mf_inerror_cd, mf_notdone_cd))
    AND ce1.event_class_cd=mf_grp_cd
    AND ce1.authentic_flag=1
    AND ce1.view_level=0
    AND ce1.publish_flag=1)
   JOIN (ce2
   WHERE ce1.event_id=ce2.parent_event_id
    AND ce2.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND ce2.event_class_cd IN (mf_date_cd, mf_txt_cd)
    AND  NOT (ce2.result_status_cd IN (mf_inerror_cd, mf_notdone_cd))
    AND ce2.view_level=1
    AND ce2.publish_flag=1
    AND ce2.authentic_flag=1
    AND ce2.event_cd IN (mf_care_pacuunit_timein_cd, mf_care_pacuunit_timeout_cd,
   mf_care_preproc_timein_cd, mf_care_preproc_timeout_cd, mf_carepostinterventionrecoverytimein_cd,
   mf_carepreadmissionevaltimeinchg_cd, mf_carepreadmissionevaltimeoutchg_cd,
   mf_carepostinterventionrecoverytimeout_cd, mf_careunitreasonforvisitchg_cd))
   JOIN (cdr
   WHERE (cdr.event_id= Outerjoin(ce2.event_id))
    AND (cdr.valid_until_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY dfa.dcp_forms_activity_id, dfa.encntr_id, ps_event_type_sort,
   cnvtdatetime(dfa.version_dt_tm) DESC
  HEAD REPORT
   ml_pos = 0, ml_idx = 0
  HEAD dfa.encntr_id
   ml_idx = 0, ml_pos = locateval(ml_idx,1,size(m_form->form,5),dfa.dcp_forms_activity_id,m_form->
    form[ml_idx].f_dcp_forms_activity_id), m_rec->l_cnt += 1,
   stat = alterlist(m_rec->pat,m_rec->l_cnt), m_rec->pat[m_rec->l_cnt].s_surgical_case_number = "",
   m_rec->pat[m_rec->l_cnt].s_scheduled_case_date = "",
   m_rec->pat[m_rec->l_cnt].s_date_case_added_to_schedule = "", m_rec->pat[m_rec->l_cnt].
   s_cancellation_date = "", m_rec->pat[m_rec->l_cnt].s_cancellation_code = "",
   m_rec->pat[m_rec->l_cnt].s_delay_code = "", m_rec->pat[m_rec->l_cnt].s_delay_reason = "", m_rec->
   pat[m_rec->l_cnt].f_encntr_id = dfa.encntr_id,
   m_rec->pat[m_rec->l_cnt].f_person_id = dfa.person_id, m_rec->pat[m_rec->l_cnt].
   f_dcp_forms_activity_id = dfa.dcp_forms_activity_id, m_rec->pat[m_rec->l_cnt].s_f_desc = m_form->
   form[ml_pos].s_f_desc,
   m_rec->pat[m_rec->l_cnt].s_fin = m_form->form[ml_pos].s_fin, m_rec->pat[m_rec->l_cnt].s_mrn =
   m_form->form[ml_pos].s_mrn, m_rec->pat[m_rec->l_cnt].s_unit_desc = "CARE",
   m_rec->pat[m_rec->l_cnt].s_asa_rating = trim(ce2.result_val,3)
  HEAD ps_event_type_sort
   CASE (ce2.event_cd)
    OF mf_carepreadmissionevaltimeinchg_cd:
     m_rec->pat[m_rec->l_cnt].s_patient_start_in_preop = format(cdr.result_dt_tm,
      "yyyy-MM-dd hh:mm:ss")
    OF mf_carepreadmissionevaltimeoutchg_cd:
     m_rec->pat[m_rec->l_cnt].s_patient_finished_in_preop = format(cdr.result_dt_tm,
      "yyyy-MM-dd hh:mm:ss")
    OF mf_care_preproc_timein_cd:
     m_rec->pat[m_rec->l_cnt].s_patient_start_in_preop = format(cdr.result_dt_tm,
      "yyyy-MM-dd hh:mm:ss")
    OF mf_care_preproc_timeout_cd:
     m_rec->pat[m_rec->l_cnt].s_patient_finished_in_preop = format(cdr.result_dt_tm,
      "yyyy-MM-dd hh:mm:ss")
    OF mf_carepostinterventionrecoverytimein_cd:
     m_rec->pat[m_rec->l_cnt].s_arrival_in_pacu = format(cdr.result_dt_tm,"yyyy-MM-dd hh:mm:ss")
    OF mf_carepostinterventionrecoverytimeout_cd:
     m_rec->pat[m_rec->l_cnt].s_discharge_from_pacu = format(cdr.result_dt_tm,"yyyy-MM-dd hh:mm:ss")
    OF mf_care_pacuunit_timein_cd:
     m_rec->pat[m_rec->l_cnt].s_arrival_in_pacu = format(cdr.result_dt_tm,"yyyy-MM-dd hh:mm:ss")
    OF mf_care_pacuunit_timeout_cd:
     m_rec->pat[m_rec->l_cnt].s_discharge_from_pacu = format(cdr.result_dt_tm,"yyyy-MM-dd hh:mm:ss")
   ENDCASE
   IF (ce2.event_cd=mf_careunitreasonforvisitchg_cd)
    m_rec->pat[m_rec->l_cnt].s_asa_rating = trim(ce2.result_val,3)
   ENDIF
   m_rec->pat[m_rec->l_cnt].s_case_date = format(dfa.version_dt_tm,"yyyy-MM-dd hh:mm:ss")
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  elh.encntr_id
  FROM dcp_forms_activity dfa,
   encntr_loc_hist elh
  PLAN (dfa
   WHERE expand(ml_pidx,1,size(m_rec->pat,5),dfa.dcp_forms_activity_id,m_rec->pat[ml_pidx].
    f_dcp_forms_activity_id))
   JOIN (elh
   WHERE elh.encntr_id=dfa.encntr_id
    AND elh.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND elh.loc_nurse_unit_cd IN (mf_heartvascpreadm_cd)
    AND elh.active_ind=1)
  ORDER BY dfa.dcp_forms_activity_id
  HEAD REPORT
   ml_pos = 0, ml_idx = 0
  DETAIL
   ml_idx = 0, ml_pos = locateval(ml_idx,1,size(m_rec->pat,5),dfa.dcp_forms_activity_id,m_rec->pat[
    ml_idx].f_dcp_forms_activity_id), m_rec->pat[ml_pos].s_unit_desc = trim(uar_get_code_display(elh
     .loc_nurse_unit_cd)),
   m_rec->pat[ml_pos].f_unit_cd = elh.loc_nurse_unit_cd, m_rec->pat[ml_pos].s_encntr_type_disp = trim
   (uar_get_code_display(elh.encntr_type_cd))
  WITH nocounter, expand = 1
 ;end select
 IF (size(m_rec->pat,5) > 0)
  IF (mn_ops=0)
   SELECT INTO value(ms_output)
    facility_name = substring(1,100,m_rec->pat[d.seq].s_f_desc), surgical_case_number = substring(1,
     100,m_rec->pat[d.seq].s_surgical_case_number), patient_account_identifier = substring(1,100,
     m_rec->pat[d.seq].s_fin),
    medical_record_number = substring(1,100,m_rec->pat[d.seq].s_mrn), case_date = substring(1,100,
     m_rec->pat[d.seq].s_case_date), case_unit = substring(1,100,m_rec->pat[d.seq].s_unit_desc),
    asa_rating = substring(1,100,m_rec->pat[d.seq].s_asa_rating), patient_type = substring(1,100,
     m_rec->pat[d.seq].s_encntr_type_disp), scheduled_case_date = substring(1,100,m_rec->pat[d.seq].
     s_scheduled_case_date),
    date_case_added_to_schedule = substring(1,100,m_rec->pat[d.seq].s_date_case_added_to_schedule),
    cancellation_date = substring(1,100,m_rec->pat[d.seq].s_cancellation_date), cancellation_code =
    substring(1,100,m_rec->pat[d.seq].s_cancellation_code),
    delay_code = substring(1,100,m_rec->pat[d.seq].s_delay_code), delay_reason = substring(1,100,
     m_rec->pat[d.seq].s_delay_reason), patient_start_in_preop = substring(1,100,m_rec->pat[d.seq].
     s_patient_start_in_preop),
    patient_finished_in_preop = substring(1,100,m_rec->pat[d.seq].s_patient_finished_in_preop),
    patient_in_room_actual = substring(1,100,m_rec->pat[d.seq].s_patient_in_room_actual),
    patient_out_of_room_actual = substring(1,100,m_rec->pat[d.seq].s_patient_out_of_room_actual),
    arrival_in_pacu = substring(1,100,m_rec->pat[d.seq].s_arrival_in_pacu), discharge_from_pacu =
    substring(1,100,m_rec->pat[d.seq].s_discharge_from_pacu), encntr_id = substring(1,100,cnvtstring(
      m_rec->pat[d.seq].f_encntr_id)),
    forms_id = m_rec->pat[d.seq].f_dcp_forms_activity_id
    FROM (dummyt d  WITH seq = value(size(m_rec->pat,5)))
    PLAN (d
     WHERE (m_rec->pat[d.seq].f_dcp_forms_activity_id > 0))
    ORDER BY case_unit
    WITH nocounter, format, separator = " ",
     maxcol = 5000
   ;end select
  ELSEIF (mn_ops=1)
   SELECT INTO value(ms_output)
    FROM (dummyt d  WITH seq = value(size(m_rec->pat,5)))
    PLAN (d
     WHERE (m_rec->pat[d.seq].f_dcp_forms_activity_id > 0))
    HEAD REPORT
     ms_tmp = concat("Facility_Name","|","Surgical_Case_Number","|","Patient_Account_Identifier",
      "|","Medical_Record_Number","|","Case_Date","|",
      "Case_Unit","|","ASA_Rating","|","Patient_Type",
      "|","Scheduled_Case_Date","|","Date_Case_Added_to_Schedule","|",
      "Cancellation_Date","|","Cancellation_Code","|","Delay_Code",
      "|","Delay_Reason","|","Patient_Start_In_PreOp","|",
      "Patient_Finished_In_PreOp","|","Patient_In_Room_Actual","|","Patient_Out_Of_Room_Actual",
      "|","Arrival_in_PACU","|","Discharge_from_PACU","|"), col 0, ms_tmp
    DETAIL
     row + 1, ms_tmp = concat(trim(m_rec->pat[d.seq].s_f_desc,3),"|",trim(m_rec->pat[d.seq].
       s_surgical_case_number,3),"|",trim(m_rec->pat[d.seq].s_fin,3),
      "|",trim(m_rec->pat[d.seq].s_mrn,3),"|",trim(m_rec->pat[d.seq].s_case_date,3),"|",
      trim(m_rec->pat[d.seq].s_unit_desc,3),"|",trim(m_rec->pat[d.seq].s_asa_rating,3),"|",trim(m_rec
       ->pat[d.seq].s_encntr_type_disp,3),
      "|",trim(m_rec->pat[d.seq].s_scheduled_case_date,3),"|",trim(m_rec->pat[d.seq].
       s_date_case_added_to_schedule,3),"|",
      trim(m_rec->pat[d.seq].s_cancellation_date,3),"|",trim(m_rec->pat[d.seq].s_cancellation_code,3),
      "|",trim(m_rec->pat[d.seq].s_delay_code,3),
      "|",trim(m_rec->pat[d.seq].s_delay_reason,3),"|",trim(m_rec->pat[d.seq].
       s_patient_start_in_preop,3),"|",
      trim(m_rec->pat[d.seq].s_patient_finished_in_preop,3),"|",trim(m_rec->pat[d.seq].
       s_patient_in_room_actual,3),"|",trim(m_rec->pat[d.seq].s_patient_out_of_room_actual,3),
      "|",trim(m_rec->pat[d.seq].s_arrival_in_pacu,3),"|",trim(m_rec->pat[d.seq].
       s_discharge_from_pacu,3),"|"), col 0,
     ms_tmp
    WITH nocounter, format = variable, maxrow = 1,
     maxcol = 5000
   ;end select
   SET ms_dcl_cmd = concat("cp -f ",ms_output," ",ms_output2)
   CALL echo(ms_dcl_cmd)
   CALL dcl(ms_dcl_cmd,size(ms_dcl_cmd),ml_dcl_stat)
  ENDIF
 ELSE
  CALL echo("no records found")
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 FREE RECORD m_rec
 FREE RECORD m_form
END GO
