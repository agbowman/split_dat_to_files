CREATE PROGRAM bhs_rpt_daily_disch_disp:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Disposition Type" = 0,
  "Encounter Type:" = 0,
  "Start Discharge Date (00:00:00)" = "CURDATE",
  "End Discharge Date (23:59:59)" = "CURDATE",
  "Facility:" = 0,
  "Unit" = 0,
  "Email/s (Space Seperated) :" = ""
  WITH outdev, f_disp_type, f_enc_type,
  s_disch_start_dt, s_disch_end_dt, f_fname,
  f_unit, email_list
 DECLARE ms_opr_disp = c2 WITH protect, constant(set_opr_var(2))
 DECLARE ms_opr_enc = c2 WITH protect, constant(set_opr_var(3))
 DECLARE ms_opr_fac = c2 WITH protect, constant(set_opr_var(6))
 DECLARE ms_opr_unit = c2 WITH protect, constant(set_opr_var(7))
 DECLARE mf_cs319_fin_nbr = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cs8_auth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs8_altered = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs72_dischargevnahospicehomecare = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"DISCHARGEVNAHOSPICEHOMECARE"))
 DECLARE mf_cs72_dischargenursingrehabfacilities = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGENURSINGHOMESREHABFACILITIES"))
 DECLARE mf_cs72_dischargenursingfacilities = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"DISCHARGENURSINGFACILITIES"))
 DECLARE mf_cs72_nameofreceivingshtrmgenhosp = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"NAMEOFRECEIVINGSHORTTERMGENHOSP"))
 DECLARE mf_cs72_dischargelevelofcareatdischarge = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGELEVELOFCAREATDISCHARGE"))
 DECLARE mf_cs72_dischargemedicalequipmentcompanies = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"DISCHARGEMEDICALEQUIPMENTCOMPANIES"))
 DECLARE mf_cs72_dischargechronichospital = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGECHRONICHOSPITAL"))
 DECLARE ms_rpt_line = vc WITH protect, noconstant(" ")
 DECLARE ml_exp_idx = i4 WITH protect, noconstant(0)
 DECLARE denominator = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_subject_line = vc WITH protect, noconstant("Daily discharge with disposition report")
 DECLARE ms_dischargevnahosphomecare = vc WITH protect, noconstant(" ")
 DECLARE ms_dischargenursingrehabfacilities = vc WITH protect, noconstant(" ")
 DECLARE ms_dischargelongtermcarefacility = vc WITH protect, noconstant(" ")
 DECLARE ms_dischargelevelofcareatdischarge = vc WITH protect, noconstant(" ")
 DECLARE ms_nameofreceivingshorttermgenhosp = vc WITH protect, noconstant(" ")
 DECLARE ms_dischargemedicalequipmentcompanies = vc WITH protect, noconstant(" ")
 DECLARE ms_dischargechronichospital = vc WITH protect, noconstant(" ")
 DECLARE mf_start_disch_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_disch_dt_tm = f8 WITH protect, noconstant(0.0)
 FREE RECORD discharge_forms
 RECORD discharge_forms(
   1 l_disch_form_cnt = i4
   1 disch_form_list[*]
     2 f_dcp_forms_ref_id = f8
   1 l_disch_form_activity_cnt = i4
   1 disch_form_activity_list[*]
     2 f_encntr_id = f8
     2 s_dfa_form_ref_nbr = vc
 ) WITH protect
 FREE RECORD disp_cv
 RECORD disp_cv(
   1 l_cv_cnt = i4
   1 list[*]
     2 f_cv = f8
     2 l_disp_cnt = i4
     2 s_disposition = vc
 ) WITH protect
 FREE RECORD reply
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 IF (validate(request->batch_selection))
  SET mf_start_disch_dt_tm = cnvtdatetime((curdate - 1),0)
  SET mf_end_disch_dt_tm = cnvtdatetime((curdate - 1),235959)
 ELSE
  SET mf_start_disch_dt_tm = cnvtdatetime(concat(trim( $S_DISCH_START_DT,3)," 00:00:00"))
  SET mf_end_disch_dt_tm = cnvtdatetime(concat(trim( $S_DISCH_END_DT,3)," 23:59:59"))
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "Email Check"
 SET reply->status_data.subeventstatus[1].targetobjectname = "Email Parameter"
 SET reply->status_data.subeventstatus[1].targetobjectvalue =  $EMAIL_LIST
 IF (textlen(trim( $EMAIL_LIST)) > 0
  AND findstring("@", $EMAIL_LIST) > 0)
  SET ms_email_lower = cnvtlower( $EMAIL_LIST)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("Lowercase email: ",
   ms_email_lower)
  IF (((findstring("@bhs.org",ms_email_lower) > 0) OR (findstring("@baystatehealth.org",
   ms_email_lower) > 0)) )
   SET mn_email_ind = 1
   SET ms_address_list =  $EMAIL_LIST
   SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtdatetime(sysdate),
      "MMDDYYYYHHMMSS;;D"),".csv"))
   SET reply->status_data.subeventstatus[1].operationstatus = "S"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("Valid email: ",
    ms_address_list)
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg = "PLEASE ENTER VALID BHS EMAIL/S", col 0, "{PS/792 0 translate 90 rotate/}",
     y_pos = 18, row + 1, "{F/1}{CPI/7}",
     CALL print(calcpos(20,(y_pos+ 0))), msg
    WITH dio = 08
   ;end select
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Script Terminated Early"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("Invalid email domain: ",
    ms_email_lower)
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg = "NEED TO SPECIFY EMAIL ADDRESS/ES", col 0, "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(20,(y_pos+ 0))), msg
   WITH dio = 08
  ;end select
  SET reply->status_data.status = "F"
  SET reply->ops_event = "Script Terminated Early"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("Invalid or missing email: ",
    $EMAIL_LIST)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cv1.code_value
  FROM code_value cv1
  WHERE cv1.code_set=19
   AND cv1.active_ind=1
  DETAIL
   disp_cv->l_cv_cnt += 1, stat = alterlist(disp_cv->list,disp_cv->l_cv_cnt), disp_cv->list[disp_cv->
   l_cv_cnt].f_cv = cv1.code_value,
   disp_cv->list[disp_cv->l_cv_cnt].l_disp_cnt = 0, disp_cv->list[disp_cv->l_cv_cnt].s_disposition =
   trim(replace(cv1.display,","," ",0),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dfr.dcp_forms_ref_id
  FROM dcp_forms_ref dfr
  WHERE dfr.active_ind=1
   AND cnvtupper(dfr.description)="*DISCHARGE*NOTE*"
  DETAIL
   discharge_forms->l_disch_form_cnt += 1, stat = alterlist(discharge_forms->disch_form_list,
    discharge_forms->l_disch_form_cnt), discharge_forms->disch_form_list[discharge_forms->
   l_disch_form_cnt].f_dcp_forms_ref_id = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dfa.encntr_id, dfa.dcp_forms_activity_id
  FROM encounter e,
   dcp_forms_activity dfa,
   dcp_forms_ref dfr,
   code_value cv
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_disch_dt_tm) AND cnvtdatetime(mf_end_disch_dt_tm
    )
    AND operator(e.loc_facility_cd,ms_opr_fac, $F_FNAME)
    AND operator(e.encntr_type_cd,ms_opr_enc, $F_ENC_TYPE)
    AND operator(e.loc_nurse_unit_cd,ms_opr_unit, $F_UNIT)
    AND operator(e.disch_disposition_cd,ms_opr_disp, $F_DISP_TYPE))
   JOIN (dfa
   WHERE expand(ml_exp_idx,1,discharge_forms->l_disch_form_cnt,dfa.dcp_forms_ref_id,discharge_forms->
    disch_form_list[ml_exp_idx].f_dcp_forms_ref_id)
    AND dfa.encntr_id=e.encntr_id
    AND dfa.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dfa.form_status_cd
    AND  NOT (cv.display_key IN ("INERROR", "NOTDONE", "CANCELED")))
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND dfr.beg_effective_dt_tm <= dfa.version_dt_tm
    AND dfr.end_effective_dt_tm > dfa.version_dt_tm)
  ORDER BY dfa.dcp_forms_activity_id DESC
  DETAIL
   discharge_forms->l_disch_form_activity_cnt += 1, stat = alterlist(discharge_forms->
    disch_form_activity_list,discharge_forms->l_disch_form_activity_cnt), discharge_forms->
   disch_form_activity_list[discharge_forms->l_disch_form_activity_cnt].s_dfa_form_ref_nbr = concat(
    trim(cnvtstring(dfa.dcp_forms_activity_id)),"*"),
   discharge_forms->disch_form_activity_list[discharge_forms->l_disch_form_activity_cnt].f_encntr_id
    = dfa.encntr_id
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO value(ms_output_dest)
  FROM encounter e,
   encntr_alias ea,
   encntr_alias ea2,
   person p,
   clinical_event ce,
   dummyt d,
   (dummyt d1  WITH seq = value(discharge_forms->l_disch_form_activity_cnt))
  PLAN (d1)
   JOIN (e
   WHERE (e.encntr_id=discharge_forms->disch_form_activity_list[d1.seq].f_encntr_id)
    AND  NOT (e.disch_disposition_cd IN (0.0, null)))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_cs319_fin_nbr)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn)
   JOIN (d)
   JOIN (ce
   WHERE operator(ce.reference_nbr,"LIKE",patstring(discharge_forms->disch_form_activity_list[d1.seq]
     .s_dfa_form_ref_nbr,1))
    AND ce.encntr_id=e.encntr_id
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_status_cd IN (mf_cs8_auth, mf_cs8_modified, mf_cs8_altered)
    AND ce.event_cd IN (mf_cs72_dischargevnahospicehomecare, mf_cs72_dischargenursingfacilities,
   mf_cs72_dischargenursingrehabfacilities, mf_cs72_dischargelevelofcareatdischarge,
   mf_cs72_nameofreceivingshtrmgenhosp,
   mf_cs72_dischargemedicalequipmentcompanies, mf_cs72_dischargechronichospital))
  ORDER BY e.disch_dt_tm DESC, e.encntr_id, ce.event_cd,
   ce.event_end_dt_tm
  HEAD REPORT
   ms_rpt_line = build2("Admission Date",",","Discharge Date",",","Facility",
    ",","Nurse Unit",",","Name",",",
    "Account Number",",","Discharge Disposition",",","MRN",
    ",","Date of Birth",",","Encounter Type",",",
    "Level of Care at Discharge",",","Name of Receiving Short Term General Hospital",",",
    "Long Term Care Facility",
    ",","Nurse Facilities",",","VNA/Home Care",",",
    "Medical Equipment Companies",","), col 0, ms_rpt_line,
   row + 1
  HEAD e.encntr_id
   denominator += 1, pos = locateval(idx,1,disp_cv->l_cv_cnt,e.disch_disposition_cd,disp_cv->list[idx
    ].f_cv)
   IF (pos > 0)
    disp_cv->list[pos].l_disp_cnt += 1
   ENDIF
   ms_dischargevnahosphomecare = "", ms_dischargelevelofcareatdischarge = "",
   ms_nameofreceivingshorttermgenhosp = "",
   ms_dischargemedicalequipmentcompanies = "", ms_dischargenursingrehabfacilities = "",
   ms_dischargechronichospital = ""
  HEAD ce.event_cd
   CASE (ce.event_cd)
    OF mf_cs72_dischargevnahospicehomecare:
     ms_dischargevnahosphomecare = trim(replace(ce.result_val,","," ",0),3)
    OF mf_cs72_dischargenursingrehabfacilities:
     ms_dischargenursingrehabfacilities = trim(replace(ce.result_val,","," ",0),3)
    OF mf_cs72_dischargelevelofcareatdischarge:
     ms_dischargelevelofcareatdischarge = trim(replace(ce.result_val,","," ",0),3)
    OF mf_cs72_nameofreceivingshtrmgenhosp:
     ms_nameofreceivingshorttermgenhosp = trim(replace(ce.result_val,","," ",0),3)
    OF mf_cs72_dischargemedicalequipmentcompanies:
     ms_dischargemedicalequipmentcompanies = trim(replace(ce.result_val,","," ",0),3)
    OF mf_cs72_dischargechronichospital:
     ms_dischargechronichospital = trim(replace(ce.result_val,","," ",0),3)
   ENDCASE
  FOOT  e.encntr_id
   ms_rpt_line = build2(trim(format(cnvtdatetime(e.reg_dt_tm),"mm/dd/yyyy hh:mm;;d"),3),",",trim(
     format(cnvtdatetime(e.disch_dt_tm),"mm/dd/yyyy hh:mm;;d"),3),",",trim(uar_get_code_display(e
      .loc_facility_cd),3),
    ",",trim(uar_get_code_display(e.loc_nurse_unit_cd),3),",",trim(replace(p.name_full_formatted,",",
      " ",0),3),",",
    trim(ea.alias,3),",",trim(replace(uar_get_code_display(e.disch_disposition_cd),","," ",0),3),",",
    trim(ea2.alias,3),
    ",",trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"mm/dd/yy;;d"),3),",",
    trim(uar_get_code_display(e.encntr_type_cd),3),",",
    ms_dischargelevelofcareatdischarge,",",ms_nameofreceivingshorttermgenhosp,",",
    ms_dischargechronichospital,
    ",",ms_dischargenursingrehabfacilities,",",ms_dischargevnahosphomecare,",",
    ms_dischargemedicalequipmentcompanies,","), col 0, ms_rpt_line,
   row + 1
  FOOT REPORT
   col 0, "", row + 1,
   ms_rpt_line = build2(
    "Total Discharged Encounters From Selected Facility(ies)/ Unit(s)/ Encounter-Type(s)/ Disposition(s):  ",
    cnvtstring(denominator)), col 0, ms_rpt_line,
   row + 1, col 0, "",
   row + 1, ms_rpt_line = "Disposition Counts:", col 0,
   ms_rpt_line, row + 1
   FOR (idx = 1 TO disp_cv->l_cv_cnt)
     IF ((disp_cv->list[idx].l_disp_cnt > 0))
      ms_rpt_line = build2(disp_cv->list[idx].s_disposition,": ",cnvtstring(disp_cv->list[idx].
        l_disp_cnt)), col 0, ms_rpt_line,
      row + 1
     ENDIF
   ENDFOR
  WITH nocounter, maxcol = 3000, format,
   maxrow = 1, outerjoin = d
 ;end select
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg = "NO DATA FOUND.", msg1 = "CHECK DATE RANGE AND OTHER SEARCH CRITERIA", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(20,(y_pos+ 0))), msg,
    row + 1,
    CALL print(calcpos(20,(y_pos+ 15))), msg1
   WITH dio = 08
  ;end select
  SET reply->status_data.status = "S"
  SET reply->ops_event = "Ops Job completed successfully"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO DATA FOUND."
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  GO TO exit_script
 ENDIF
 SUBROUTINE (set_opr_var(param_number=i4) =vc WITH protect, copy)
   DECLARE ml_check = c1 WITH protect, noconstant("")
   DECLARE mc_return_var = c2 WITH protect, noconstant("")
   SET ml_check = substring(1,1,reflect(parameter(param_number,0)))
   CALL echo(build("ml_check: ",ml_check))
   IF (ml_check="L")
    SET mc_return_var = "IN"
   ELSEIF (ml_check="I")
    SET mc_return_var = "NA"
   ELSE
    IF (cnvtreal(parameter(param_number,0))=0.0)
     SET mc_return_var = "!="
    ELSE
     SET mc_return_var = "="
    ENDIF
   ENDIF
   RETURN(mc_return_var)
 END ;Subroutine
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(ms_output_dest,3)
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_in,ms_address_list,ms_subject_line,1)
  SET reply->status_data.status = "S"
  SET reply->ops_event = "Ops Job completed successfully"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
 ENDIF
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   msg = ms_output_dest, msg1 = "sent to specified emails ", col 0,
   "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
   "{F/1}{CPI/7}",
   CALL print(calcpos(20,(y_pos+ 0))), msg,
   row + 1,
   CALL print(calcpos(20,(y_pos+ 15))), msg1
  WITH dio = 08
 ;end select
#exit_script
END GO
