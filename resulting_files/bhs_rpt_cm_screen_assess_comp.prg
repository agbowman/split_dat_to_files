CREATE PROGRAM bhs_rpt_cm_screen_assess_comp
 PROMPT
  "Email List:" = ""
  WITH s_email_list
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cs69_inpatient = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_cs69_observation = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,
   "OBSERVATION"))
 DECLARE mf_cs72_cm_highrisk_status = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CASEMANAGEMENTHIGHRISKSTATUS"))
 DECLARE ms_output_dest = vc WITH protect, constant("cmscreen.csv")
 DECLARE mf_start_admit_dt_tm = f8 WITH protect, constant(cnvtdatetime((curdate - 1),0))
 DECLARE mf_end_admit_dt_tm = f8 WITH protect, constant(cnvtdatetime((curdate - 1),235959))
 DECLARE ms_rpt_line = vc WITH protect, noconstant(" ")
 DECLARE ml_indx = i4 WITH protect, noconstant(0)
 DECLARE ml_indx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_abrv_risk_status = vc WITH protect, noconstant("")
 DECLARE mn_ops_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_subject_line = vc WITH protect, noconstant(curprog)
 DECLARE ml_business_days = i4 WITH protect, noconstant(0)
 SUBROUTINE (calculate_business_days(start_dt_tm=dq8(val),end_dt_tm=dq8(val)) =i4)
   DECLARE ml_daysdif = i4 WITH protect, noconstant(0)
   DECLARE ml_weekend = i4 WITH protect, noconstant(0)
   SET ml_daysdif = datetimediff(end_dt_tm,start_dt_tm,1)
   SET ml_weekend = 0
   FOR (x = 0 TO ml_daysdif)
    SET dow = weekday(datetimeadd(start_dt_tm,x))
    IF (dow IN (0, 6))
     SET ml_weekend += 1
    ENDIF
   ENDFOR
   SET ml_daysdif -= ml_weekend
   RETURN(ml_daysdif)
 END ;Subroutine
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE RECORD cm_data
 RECORD cm_data(
   1 cm_cnt = i4
   1 list[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 n_high_risk_ind = i2
     2 s_full_risk_status = vc
     2 d_admit_dt_tm = dq8
     2 s_screen_status = vc
     2 s_assess_completed_dt_tm = vc
     2 s_screen_completed_dt_tm = vc
     2 s_assess_status = vc
     2 s_name = vc
     2 s_assess_case_manager = vc
     2 s_screen_case_manager = vc
     2 s_account_number = vc
     2 s_location = vc
     2 s_nurse_unit = vc
     2 s_room = vc
     2 s_most_recent_assessment_dt_tm = vc
     2 s_most_recent_screen_dt_tm = vc
     2 n_has_completed_screen = i2
     2 n_has_completed_assessment = i2
 ) WITH protect
 FREE RECORD nurs_loc
 RECORD nurs_loc(
   1 loc_cnt = i4
   1 list[*]
     2 f_code_val = f8
 ) WITH protect
 FREE RECORD fac_loc
 RECORD fac_loc(
   1 loc_cnt = i4
   1 list[*]
     2 f_code_val = f8
 ) WITH protect
 IF (validate(request->batch_selection)
  AND ( $S_EMAIL_LIST > ""))
  SET mn_ops_ind = 1
  SET reply->status_data[1].status = "F"
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
   AND ((cv.display_key="*PACU*") OR (((cv.display_key="*CHESTNUT*") OR (((cv.display_key="PANU") OR
  (cv.display_key="CARE")) )) ))
   AND cv.active_ind=1
  DETAIL
   nurs_loc->loc_cnt += 1, stat = alterlist(nurs_loc->list,nurs_loc->loc_cnt), nurs_loc->list[
   nurs_loc->loc_cnt].f_code_val = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="FACILITY"
   AND cv.display_key IN ("BFMC", "BMC", "BMCINPTPSYCH", "BNH", "BAYSTATEVASCULARSERVICES",
  "BWH", "HEARTANDVASCULARGREENFIELD", "NOEDGEADULTPED", "NORTHERNEDGEADULTANDPEDI")
   AND cv.active_ind=1
  DETAIL
   fac_loc->loc_cnt += 1, stat = alterlist(fac_loc->list,fac_loc->loc_cnt), fac_loc->list[fac_loc->
   loc_cnt].f_code_val = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   person p
  PLAN (e
   WHERE e.encntr_type_class_cd IN (mf_cs69_inpatient, mf_cs69_observation)
    AND e.reg_dt_tm >= cnvtdatetime(mf_start_admit_dt_tm)
    AND e.reg_dt_tm <= cnvtdatetime(mf_end_admit_dt_tm)
    AND expand(ml_indx,1,fac_loc->loc_cnt,e.loc_facility_cd,fac_loc->list[ml_indx].f_code_val)
    AND  NOT (expand(ml_indx2,1,nurs_loc->loc_cnt,e.loc_nurse_unit_cd,nurs_loc->list[ml_indx2].
    f_code_val))
    AND e.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   cm_data->cm_cnt += 1, stat = alterlist(cm_data->list,cm_data->cm_cnt), cm_data->list[cm_data->
   cm_cnt].f_encntr_id = e.encntr_id,
   cm_data->list[cm_data->cm_cnt].f_person_id = e.person_id, cm_data->list[cm_data->cm_cnt].
   d_admit_dt_tm = e.reg_dt_tm, cm_data->list[cm_data->cm_cnt].s_account_number = trim(ea.alias,3),
   cm_data->list[cm_data->cm_cnt].s_name = trim(replace(p.name_full_formatted,","," ",0),3), cm_data
   ->list[cm_data->cm_cnt].s_room = trim(replace(uar_get_code_display(e.loc_room_cd),","," ",0),3),
   cm_data->list[cm_data->cm_cnt].s_location = trim(replace(uar_get_code_display(e.loc_facility_cd),
     ","," ",0),3),
   cm_data->list[cm_data->cm_cnt].s_nurse_unit = trim(replace(uar_get_code_display(e
      .loc_nurse_unit_cd),","," ",0),3)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa,
   dcp_forms_ref dfr,
   encntr_alias ea,
   code_value cv,
   clinical_event ce,
   prsnl pr,
   dummyt d
  PLAN (dfa
   WHERE expand(ml_indx,1,cm_data->cm_cnt,dfa.encntr_id,cm_data->list[ml_indx].f_encntr_id))
   JOIN (cv
   WHERE cv.code_value=dfa.form_status_cd
    AND  NOT (cv.display_key IN ("INERROR", "CANCELED")))
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND ((dfr.description="Case Management Assessment") OR (dfr.description=
   "Case Management Screening"))
    AND dfr.beg_effective_dt_tm <= dfa.version_dt_tm
    AND dfr.end_effective_dt_tm > dfa.version_dt_tm)
   JOIN (ea
   WHERE ea.encntr_id=dfa.encntr_id
    AND ea.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (d)
   JOIN (ce
   WHERE ce.encntr_id=dfa.encntr_id
    AND cnvtreal(substring(1,(findstring(".00",ce.reference_nbr) - 1),ce.reference_nbr))=dfa
   .dcp_forms_activity_id
    AND cnvtupper(ce.event_title_text)="CASE MANAGEMENT *")
   JOIN (pr
   WHERE pr.person_id=ce.updt_id)
  ORDER BY dfa.encntr_id, dfa.description DESC, dfa.form_dt_tm
  DETAIL
   ml_pos = locateval(ml_indx,1,cm_data->cm_cnt,dfa.encntr_id,cm_data->list[ml_indx].f_encntr_id)
   IF (ml_pos > 0)
    IF (dfa.form_dt_tm != null)
     ml_business_days = calculate_business_days(cm_data->list[ml_pos].d_admit_dt_tm,dfa.form_dt_tm)
    ELSE
     ml_business_days = calculate_business_days(cm_data->list[ml_pos].d_admit_dt_tm,cnvtdatetime(
       sysdate))
    ENDIF
    IF (trim(ce.result_val,3)="High risk criteria met")
     cm_data->list[ml_pos].n_high_risk_ind = 1
    ENDIF
    IF ((cm_data->list[ml_pos].n_high_risk_ind=1))
     ms_abrv_risk_status = ""
    ELSE
     ms_abrv_risk_status = "NOT NEEDED. NOT HIGH RISK FOR CM -- "
    ENDIF
    IF (ce.event_cd=mf_cs72_cm_highrisk_status
     AND ce.result_val > "")
     cm_data->list[ml_pos].s_full_risk_status = trim(ce.result_val)
    ENDIF
    CASE (dfa.description)
     OF "Case Management Screening":
      cm_data->list[ml_pos].s_screen_case_manager = trim(replace(pr.name_full_formatted,","," ",0),3),
      IF (ml_business_days <= 1)
       cm_data->list[ml_pos].s_screen_completed_dt_tm = trim(format(dfa.form_dt_tm,
         "dd-mmm-yyyy hh:mm:ss;;d"),3), cm_data->list[ml_pos].s_screen_status = "COMPLETED", cm_data
       ->list[ml_pos].n_has_completed_screen = 1
      ELSE
       IF ((cm_data->list[ml_pos].n_has_completed_screen=1))
        cm_data->list[ml_pos].s_most_recent_screen_dt_tm = trim(format(dfa.form_dt_tm,
          "dd-mmm-yyyy hh:mm:ss;;d"),3), cm_data->list[ml_pos].s_screen_status =
        "COMPLETED SCREEN WITH REVISIONS"
       ELSE
        cm_data->list[ml_pos].s_screen_status = "LATE", cm_data->list[ml_pos].
        s_screen_completed_dt_tm = trim(format(dfa.form_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),3)
       ENDIF
      ENDIF
     OF "Case Management Assessment":
      cm_data->list[ml_pos].s_assess_case_manager = trim(replace(pr.name_full_formatted,","," ",0),3),
      IF (ml_business_days <= 2)
       IF ((cm_data->list[ml_pos].s_screen_status=""))
        cm_data->list[ml_pos].s_assess_status = "COMPLETED. NO SCREEN ASSOCIATED TO THIS assessmENT"
       ELSE
        cm_data->list[ml_pos].s_assess_status = concat(ms_abrv_risk_status,"COMPLETED")
       ENDIF
       cm_data->list[ml_pos].s_assess_completed_dt_tm = trim(format(dfa.form_dt_tm,
         "dd-mmm-yyyy hh:mm:ss;;d"),3), cm_data->list[ml_pos].n_has_completed_assessment = 1
      ELSE
       IF ((cm_data->list[ml_pos].n_high_risk_ind=1)
        AND (cm_data->list[ml_pos].n_has_completed_assessment != 1))
        cm_data->list[ml_pos].s_assess_status = concat(ms_abrv_risk_status,"LATE"), cm_data->list[
        ml_pos].s_assess_completed_dt_tm = trim(format(dfa.form_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),3)
       ELSEIF ((cm_data->list[ml_pos].n_has_completed_assessment=1))
        cm_data->list[ml_pos].s_most_recent_assessment_dt_tm = trim(format(dfa.form_dt_tm,
          "dd-mmm-yyyy hh:mm:ss;;d"),3), cm_data->list[ml_pos].s_assess_status = concat(
         ms_abrv_risk_status,"COMPLETED assessmENT WITH REVISIONS")
       ELSE
        cm_data->list[ml_pos].s_most_recent_assessment_dt_tm = trim(format(dfa.form_dt_tm,
          "dd-mmm-yyyy hh:mm:ss;;d"),3), cm_data->list[ml_pos].s_assess_completed_dt_tm = concat(
         ms_abrv_risk_status,"LATE")
       ENDIF
      ENDIF
    ENDCASE
   ENDIF
  WITH nocounter, expand = 1, outerjoin = d
 ;end select
 IF (curqual=0)
  CALL echo("here")
  CALL echorecord(fac_loc)
  GO TO exit_script
 ENDIF
 SELECT INTO value(ms_output_dest)
  sort_order =
  IF ((cm_data->list[d.seq].s_full_risk_status="")) 1
  ELSEIF ((cm_data->list[d.seq].s_full_risk_status="High risk criteria met")) 2
  ELSEIF ((cm_data->list[d.seq].s_full_risk_status=
  "High risk criteria met.- no case management services needed")) 3
  ELSE 4
  ENDIF
  FROM (dummyt d  WITH seq = value(cm_data->cm_cnt))
  PLAN (d)
  ORDER BY sort_order, cm_data->list[d.seq].d_admit_dt_tm DESC
  HEAD REPORT
   ms_rpt_line = build2("Admission Date",",","Name",",","Account Number",
    ",","Facility",",","Nurse Unit",",",
    "Room Number",",","Screen Status",",","Screen Completion Date/Time",
    ",","Most Recent Screen Date/Time",",","Screen Case Manager",",",
    "Assessment Status",",","Assessment Completion Date/Time",",","Most Recent assessment Date/Time",
    ",","Assessment Case Manager",",","Is Patient High Risk?",","), col 0, ms_rpt_line,
   row + 1
  HEAD d.seq
   IF ((((cm_data->list[d.seq].s_screen_status != "")) OR ((cm_data->list[d.seq].s_assess_status !=
   ""))) )
    IF ((cm_data->list[d.seq].s_screen_status=""))
     cm_data->list[d.seq].s_screen_status = "NO CM SCREEN ON RECORD"
    ENDIF
    IF ((cm_data->list[d.seq].s_assess_status=""))
     cm_data->list[d.seq].s_assess_status = "NO CM ASSESSMENT ON RECORD"
    ENDIF
    ms_rpt_line = build2(trim(format(cm_data->list[d.seq].d_admit_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),3),
     ",",cm_data->list[d.seq].s_name,",",cm_data->list[d.seq].s_account_number,
     ",",cm_data->list[d.seq].s_location,",",cm_data->list[d.seq].s_nurse_unit,",",
     cm_data->list[d.seq].s_room,",",cm_data->list[d.seq].s_screen_status,",",cm_data->list[d.seq].
     s_screen_completed_dt_tm,
     ",",cm_data->list[d.seq].s_most_recent_screen_dt_tm,",",cm_data->list[d.seq].
     s_screen_case_manager,",",
     cm_data->list[d.seq].s_assess_status,",",cm_data->list[d.seq].s_assess_completed_dt_tm,",",
     cm_data->list[d.seq].s_most_recent_assessment_dt_tm,
     ",",cm_data->list[d.seq].s_assess_case_manager,",",cm_data->list[d.seq].s_full_risk_status,","),
    col 0, ms_rpt_line,
    row + 1,
    CALL echo(cm_data->list[d.seq].s_full_risk_status)
   ENDIF
  WITH nocounter, maxcol = 3000, formfeed = none
 ;end select
 CALL echorecord(cm_data->list)
 SET reply->status_data[1].status = "S"
 EXECUTE bhs_sys_stand_subroutine
 CALL emailfile(ms_output_dest,ms_output_dest, $S_EMAIL_LIST,ms_subject_line,1)
#exit_script
END GO
