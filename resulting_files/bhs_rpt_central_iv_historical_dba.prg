CREATE PROGRAM bhs_rpt_central_iv_historical:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Time:" = "CURTIME",
  "Facility:" = 673936.00,
  "Email recipient(s):" = ""
  WITH outdev, ms_beg_dt, ms_end_dt,
  ms_time, mf_facility, ms_recipients
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD m_refs
 RECORD m_refs(
   1 refs[*]
     2 s_reference_nbr = vc
 ) WITH protect
 FREE RECORD m_ivs
 RECORD m_ivs(
   1 ivs[*]
     2 s_reference_nbr = vc
     2 f_encntr_id = f8
     2 s_catheter_type = vc
     2 s_catheter_num = vc
     2 f_person_id = f8
     2 s_loc_unit = vc
     2 s_loc_room = vc
     2 s_loc_bed = vc
     2 s_mrn_nbr = vc
     2 s_fin_nbr = vc
     2 s_patient_name = vc
     2 s_start_dt_tm = vc
     2 n_discontinue_ind = i2
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_i_insertion_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEOFINSERTIONACCESSI"))
 DECLARE mf_ii_insertion_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEOFINSERTIONACCESSII"))
 DECLARE mf_iii_insertion_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEOFINSERTIONACCESSIII"))
 DECLARE mf_iv_insertion_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEOFINSERTIONACCESSIV"))
 DECLARE ms_output = vc WITH protect, noconstant(trim( $OUTDEV))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $MS_RECIPIENTS))
 DECLARE ms_log = vc WITH protect, noconstant("")
 DECLARE ms_data_type = vc WITH protect, noconstant("")
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE ms_fac_p = vc WITH protect, noconstant("")
 DECLARE ms_line = vc WITH protect, noconstant("")
 DECLARE ms_prev_line = vc WITH protect, noconstant("")
 DECLARE mf_dcp_forms_ref_id = f8 WITH protect, noconstant(0)
 DECLARE mn_error_status = f8 WITH protect, noconstant(0)
 DECLARE mn_email_ind = f8 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_date = i4 WITH protect, noconstant(0)
 DECLARE md_beg_dt = dq8 WITH protect, noconstant(cnvtdatetime(concat( $MS_BEG_DT," ", $MS_TIME)))
 DECLARE md_end_dt = dq8 WITH protect, noconstant(cnvtdatetime(concat( $MS_END_DT," ", $MS_TIME)))
 DECLARE md_search_date = dq8 WITH protect, noconstant(null)
 IF (size(ms_recipients) > 0)
  SET mn_email_ind = 1
 ENDIF
 SET ms_data_type = reflect(parameter(5,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(5,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_fac_p = concat(" e.loc_facility_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_fac_p = concat(ms_fac_p,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_fac_p = concat(ms_fac_p,")")
 ELSEIF (parameter(5,1)=0.0)
  SELECT
   cv.code_value
   FROM code_value cv,
    location l
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="FACILITY"
     AND cv.active_ind=1
     AND cv.active_type_cd=mf_active_cd
     AND cv.data_status_cd=mf_auth_cd
     AND cv.display IN ("BFMC", "BFMC INPT PSYCH", "BMC", "BMC INPTPSYCH", "BMLH",
    "MOCK", "BWH", "BWH INPT PSYCH", "BNH", "BNH INPT PSYCH",
    "BNH REHAB"))
    JOIN (l
    WHERE l.location_cd=cv.code_value
     AND l.active_ind=1)
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt = (ml_cnt+ 1)
    IF (ml_cnt=1)
     ms_fac_p = concat(" e.loc_facility_cd in (",cnvtstring(cv.code_value))
    ELSE
     ms_fac_p = concat(ms_fac_p,", ",cnvtstring(cv.code_value))
    ENDIF
   FOOT REPORT
    ms_fac_p = concat(ms_fac_p,")")
   WITH nocounter
  ;end select
 ELSE
  SET ms_fac_p = cnvtstring(parameter(5,1),20)
  SET ms_fac_p = concat(" e.loc_facility_cd = ",trim(ms_fac_p))
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  PLAN (dfr
   WHERE dfr.description="IV Assessment (v001)"
    AND dfr.active_ind=1
    AND dfr.end_effective_dt_tm >= sysdate)
  HEAD REPORT
   mf_dcp_forms_ref_id = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 FOR (ml_date = 0 TO datetimecmp(cnvtdatetime(md_end_dt),cnvtdatetime(md_beg_dt)))
   SET ms_log = "ERROR"
   SET mn_error_status = 0
   SET md_search_date = datetimeadd(md_beg_dt,ml_date)
   IF (mn_email_ind=1)
    SET ms_output = concat("bhs_rpt_central_iv_historical_",format(md_search_date,"dd_mm_yy;;d"),
     ".csv")
   ENDIF
   CALL echo("Get activity_ids and reference numbers")
   SELECT INTO "nl:"
    dfa.encntr_id, dfa.last_activity_dt_tm
    FROM dcp_forms_activity dfa,
     encounter e
    PLAN (dfa
     WHERE dfa.dcp_forms_ref_id=mf_dcp_forms_ref_id
      AND dfa.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=dfa.encntr_id
      AND e.active_ind=1
      AND e.arrive_dt_tm < cnvtdatetime(md_search_date)
      AND e.disch_dt_tm > cnvtdatetime(md_search_date)
      AND e.encntr_type_class_cd=mf_inpatient_cd)
    ORDER BY dfa.encntr_id, dfa.last_activity_dt_tm DESC
    HEAD REPORT
     ml_cnt = 0
    HEAD dfa.dcp_forms_activity_id
     ml_cnt = (ml_cnt+ 1)
     IF (mod(ml_cnt,100)=1)
      CALL alterlist(m_refs->refs,(ml_cnt+ 99))
     ENDIF
     m_refs->refs[ml_cnt].s_reference_nbr = trim(concat(trim(cnvtstring(dfa.dcp_forms_activity_id)),
       "*"))
    FOOT REPORT
     CALL alterlist(m_refs->refs,ml_cnt)
    WITH nocounter
   ;end select
   CALL echo(concat(trim(cnvtstring(ml_cnt))," activity_ids found"))
   IF (size(m_refs->refs,5)=0)
    CALL echo(
     "No data found. There is no IV Assesment forms in this date range under Inpatient encounters.")
    SET ms_log =
    "No data found. There is no IV Assesment forms in this date range under Inpatient encounters."
    SET mn_error_status = 1
   ENDIF
   IF (mn_error_status=0)
    CALL echo("Get clinical_event information")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(m_refs->refs,5))),
      clinical_event ce,
      encounter e,
      encntr_loc_hist elh,
      encntr_alias ea1,
      encntr_alias ea2,
      person p
     PLAN (d)
      JOIN (ce
      WHERE operator(ce.reference_nbr,"LIKE",patstring(m_refs->refs[d.seq].s_reference_nbr,1))
       AND trim(cnvtupper(ce.event_title_text)) IN ("CATHETER TYPE I", "CATHETER TYPE II",
      "CATHETER TYPE III", "CATHETER TYPE IV")
       AND  NOT (trim(cnvtupper(ce.result_val)) IN ("PERIPHERAL", "MIDLINE PERIPHERAL CATHETER")))
      JOIN (e
      WHERE e.encntr_id=ce.encntr_id
       AND parser(ms_fac_p)
       AND e.arrive_dt_tm < cnvtdatetime(md_search_date)
       AND e.disch_dt_tm > cnvtdatetime(md_search_date)
       AND e.encntr_type_class_cd=mf_inpatient_cd)
      JOIN (elh
      WHERE elh.encntr_id=outerjoin(e.encntr_id)
       AND elh.beg_effective_dt_tm <= cnvtdatetime(md_search_date)
       AND elh.end_effective_dt_tm >= cnvtdatetime(md_search_date))
      JOIN (ea1
      WHERE ea1.encntr_id=ce.encntr_id
       AND ea1.encntr_alias_type_cd=mf_mrn_cd)
      JOIN (ea2
      WHERE ea2.encntr_id=ce.encntr_id
       AND ea2.encntr_alias_type_cd=mf_fin_cd)
      JOIN (p
      WHERE p.person_id=e.person_id)
     HEAD REPORT
      ml_cnt = 0
     DETAIL
      ml_cnt = (ml_cnt+ 1)
      IF (mod(ml_cnt,100)=1)
       CALL alterlist(m_ivs->ivs,(ml_cnt+ 99))
      ENDIF
      m_ivs->ivs[ml_cnt].s_reference_nbr = trim(m_refs->refs[d.seq].s_reference_nbr), m_ivs->ivs[
      ml_cnt].f_encntr_id = ce.encntr_id, m_ivs->ivs[ml_cnt].s_catheter_type = trim(ce.result_val),
      m_ivs->ivs[ml_cnt].s_catheter_num = substring(findstring("I",ce.event_title_text),(size(ce
        .event_title_text,1) - findstring("I",ce.event_title_text)),ce.event_title_text), m_ivs->ivs[
      ml_cnt].f_person_id = ce.person_id, m_ivs->ivs[ml_cnt].s_loc_unit = trim(uar_get_code_display(
        elh.loc_nurse_unit_cd)),
      m_ivs->ivs[ml_cnt].s_loc_room = trim(uar_get_code_display(elh.loc_room_cd)), m_ivs->ivs[ml_cnt]
      .s_loc_bed = trim(uar_get_code_display(elh.loc_bed_cd)), m_ivs->ivs[ml_cnt].s_fin_nbr = trim(
       ea2.alias),
      m_ivs->ivs[ml_cnt].s_mrn_nbr = trim(ea1.alias), m_ivs->ivs[ml_cnt].s_patient_name = trim(p
       .name_full_formatted)
     FOOT REPORT
      CALL alterlist(m_ivs->ivs,ml_cnt)
     WITH nocounter
    ;end select
    CALL echo(build2("found ",ml_cnt," iv rows"))
    IF (size(m_ivs->ivs,5)=0)
     CALL echo(
      "No data found. No IV Assesment forms with Peripheral or Midline Peripheral Catheter found.")
     SET ms_log =
     "No data found. No IV Assesment forms with Peripheral or Midline Peripheral Catheter found."
     SET mn_error_status = 1
    ENDIF
    IF (mn_error_status=0)
     CALL echo("Get insertion date/time")
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(m_ivs->ivs,5))),
       clinical_event ce,
       ce_date_result cdr
      PLAN (d)
       JOIN (ce
       WHERE operator(ce.reference_nbr,"LIKE",patstring(m_ivs->ivs[d.seq].s_reference_nbr,1))
        AND ce.event_cd IN (mf_i_insertion_cd, mf_ii_insertion_cd, mf_iii_insertion_cd,
       mf_iv_insertion_cd))
       JOIN (cdr
       WHERE cdr.event_id=outerjoin(ce.event_id)
        AND cdr.result_dt_tm < cnvtdatetime(md_search_date))
      ORDER BY cdr.result_dt_tm
      DETAIL
       m_ivs->ivs[d.seq].s_start_dt_tm = format(cdr.result_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
      WITH nocounter
     ;end select
     CALL echo("Filter out discontinued records")
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(m_ivs->ivs,5))),
       clinical_event ce
      PLAN (d)
       JOIN (ce
       WHERE (ce.encntr_id=m_ivs->ivs[d.seq].f_encntr_id)
        AND ce.performed_dt_tm > cnvtdatetime(m_ivs->ivs[d.seq].s_start_dt_tm)
        AND ce.performed_dt_tm <= cnvtdatetime(md_search_date)
        AND trim(cnvtupper(ce.event_title_text)) IN (concat("DISCONTINUE REASON ",m_ivs->ivs[d.seq].
        s_catheter_num), concat("CENTRAL LINE ",m_ivs->ivs[d.seq].s_catheter_num)))
      DETAIL
       m_ivs->ivs[d.seq].n_discontinue_ind = 1
      WITH nocounter
     ;end select
     CALL echo("Display to the screen or print to the file")
     SELECT INTO value(ms_output)
      ps_patient = m_ivs->ivs[d.seq].s_patient_name, ps_loc_unit = m_ivs->ivs[d.seq].s_loc_unit,
      ps_loc_room = m_ivs->ivs[d.seq].s_loc_room,
      ps_loc_bed = m_ivs->ivs[d.seq].s_loc_bed, ps_mrn = m_ivs->ivs[d.seq].s_mrn_nbr, ps_fin = m_ivs
      ->ivs[d.seq].s_fin_nbr,
      ps_start_date = m_ivs->ivs[d.seq].s_start_dt_tm, ps_catheter = m_ivs->ivs[d.seq].
      s_catheter_type
      FROM (dummyt d  WITH seq = value(size(m_ivs->ivs,5)))
      PLAN (d
       WHERE (m_ivs->ivs[d.seq].n_discontinue_ind=0)
        AND (m_ivs->ivs[d.seq].s_start_dt_tm > ""))
      ORDER BY ps_patient, ps_mrn, ps_fin,
       ps_start_date
      HEAD REPORT
       ms_prev_line = "", ms_line = "PATIENT,LOCATION,MRN #,ACCOUNT #,CATHETER TYPE,INSERTION DATE",
       col 0,
       row 0, ms_line
      DETAIL
       pos = 0, ms_line = concat('"',trim(m_ivs->ivs[d.seq].s_patient_name),'",'), ms_line = concat(
        ms_line,'"',trim(m_ivs->ivs[d.seq].s_loc_unit),";",trim(m_ivs->ivs[d.seq].s_loc_room),
        ";",trim(m_ivs->ivs[d.seq].s_loc_bed),'",'),
       ms_line = concat(ms_line,'"',trim(m_ivs->ivs[d.seq].s_mrn_nbr),'",'), ms_line = concat(ms_line,
        '"',trim(m_ivs->ivs[d.seq].s_fin_nbr),'",'), ms_line = concat(ms_line,'"',trim(m_ivs->ivs[d
         .seq].s_catheter_type),'",'),
       ms_line = concat(ms_line,'"',trim(m_ivs->ivs[d.seq].s_start_dt_tm),'"'), pos = findstring(
        "Powerglide peripheral",ms_line)
       IF (((trim(ms_line)=trim(ms_prev_line)) OR (ms_prev_line="")) )
        CALL echo("duplicate line")
       ELSEIF (pos > 0)
        CALL echo("powerglide peripheral found, not adding to report")
       ELSEIF (findstring("Intraosseus",ms_line))
        CALL echo("Intraosseus found, not adding to report")
       ELSE
        col 0, row + 1, ms_line
       ENDIF
       ms_prev_line = ms_line
      WITH nocounter
     ;end select
     IF (mn_email_ind > 0
      AND findfile(ms_output) > 0)
      SET ms_line = concat("Central IV Report - selected date: ",format(md_search_date,
        "dd-mmm-yyyy hh:mm:ss;;d"))
      CALL emailfile(ms_output,ms_output,ms_recipients,ms_line,1)
      SET ms_log = concat("Email was sent to ",ms_recipients,".")
     ENDIF
    ENDIF
   ENDIF
   IF (((mn_error_status > 0) OR (mn_email_ind > 0)) )
    SELECT INTO  $OUTDEV
     FROM dummyt
     HEAD REPORT
      col 0, "{PS/792 0 translate 90 rotate/}", "{F/1}{CPI/7}",
      CALL print(calcpos(10,10)), "Central IV Report Historical", "{F/1}{CPI/14}",
      CALL print(calcpos(10,30)), ms_log
     WITH dio = postscript, maxrow = 300, maxcol = 300
    ;end select
   ENDIF
   IF (mn_error_status > 0
    AND mn_email_ind > 0)
    SET ms_dclcom_str = concat('echo "',ms_log,
     '" | mailx -s "Error - Central IV Historical Report - selected date: ',format(md_search_date,
      "dd-mmm-yyyy hh:mm:ss;;d"),'" ',
     ms_recipients)
    CALL echo(concat("dclcom_str: ",ms_dclcom_str))
    CALL dcl(ms_dclcom_str,size(trim(ms_dclcom_str)),0)
   ENDIF
   SET stat = initrec(m_ivs)
   SET stat = initrec(m_refs)
 ENDFOR
END GO
