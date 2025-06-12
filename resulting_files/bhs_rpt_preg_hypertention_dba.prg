CREATE PROGRAM bhs_rpt_preg_hypertention:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Email Operations" = 0,
  "Enter Emails" = ""
  WITH outdev, s_start_date, s_end_date,
  f_email_ops, s_emails
 DECLARE mf_cs69_observation_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION")),
 protect
 DECLARE mf_cs69_inpatient_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT")),
 protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mf_cs72_systolicbloodpressure_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE")), protect
 DECLARE mf_cs72_diastolicbloodpressure_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE")), protect
 DECLARE mf_cs72_datetimebirth = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DATETIMEOFBIRTH")),
 protect
 DECLARE mf_cs355_user_def_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",355,
   "USERDEFINED"))
 DECLARE mf_cs356_race1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE mf_cs356_race2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE2"))
 DECLARE mf_cs356_race3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE3"))
 DECLARE mf_cs356_race4 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE4"))
 DECLARE mf_cs356_race5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE5"))
 DECLARE mf_cs220_bmc = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE md_spprevdate = dq8 WITH noconstant(cnvtdatetime("31-DEC-2100 00:00:00")), protect
 DECLARE md_dpprevdate = dq8 WITH noconstant(cnvtdatetime("31-DEC-2100 00:00:00")), protect
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_ops = i4 WITH protect, noconstant(0)
 DECLARE account_number = vc WITH noconstant(
  '"                                                                      "'), protect
 DECLARE ml_cnt2 = i4 WITH noconstant(0), protect
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_filename = vc WITH noconstant(concat("bhs_pregnancy_hypertension_")), protect
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),format(sysdate,"MMDDYYYY;;q"),
   ".csv")), protect
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD hyperten
 RECORD hyperten(
   1 cnt_pat = i4
   1 pats[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 d_delivery_date = dq8
     2 d_birth_date_time = dq8
     2 s_fin = vc
     2 s_sbp_result1 = vc
     2 f_sbp_event_id1 = f8
     2 s_sbp_result2 = vc
     2 f_sbp_event_id2 = f8
     2 d_sbp_date1 = dq8
     2 d_sbp_date2 = dq8
     2 f_sbp_diff = f8
     2 m_sbp_1hr = i4
     2 s_dbp_result1 = vc
     2 s_dbp_result2 = vc
     2 d_dbp_date1 = dq8
     2 d_dbp_date2 = dq8
     2 f_dbp_diff = f8
     2 m_dbp_1hr = i4
     2 m_found = i4
     2 d_disch_date = dq8
     2 d_admit_date = dq8
     2 s_age = vc
     2 s_race = vc
     2 s_ethnicity = vc
     2 s_hispanic_ind = vc
 )
 IF (( $F_EMAIL_OPS=1))
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ENDIF
 SELECT INTO "nl:"
  f_eid = ce.encntr_id, eventcd = sdp.event_cd, ce_date_time = sdp.event_end_dt_tm,
  event_id = sdp.event_id, result = sdp.result_val, pid = ce.person_id,
  delivery_date = cdr.result_dt_tm, birth_date = cdr.result_dt_tm, disch_date = e.disch_dt_tm,
  dob = p.birth_dt_tm, eregdate = e.reg_dt_tm, s_fin = fin.alias
  FROM clinical_event ce,
   clinical_event sdp,
   ce_date_result cdr,
   person p,
   encntr_alias fin,
   encounter e
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)
    AND e.active_status_cd=mf_cs48_active
    AND e.loc_facility_cd=mf_cs220_bmc
    AND e.encntr_type_class_cd IN (mf_cs69_inpatient_cd, mf_cs69_observation_cd))
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND ce.encntr_id=e.encntr_id
    AND ce.event_cd=mf_cs72_datetimebirth
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd))
   JOIN (cdr
   WHERE cdr.event_id=ce.event_id)
   JOIN (sdp
   WHERE sdp.person_id=ce.person_id
    AND sdp.encntr_id=ce.encntr_id
    AND sdp.valid_until_dt_tm > sysdate
    AND sdp.event_cd=mf_cs72_systolicbloodpressure_cd
    AND sdp.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd))
   JOIN (p
   WHERE p.person_id=ce.person_id)
   JOIN (fin
   WHERE fin.encntr_id=ce.encntr_id
    AND fin.active_ind=1
    AND sysdate BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm
    AND ((fin.encntr_alias_type_cd=mf_cs319_fin_cd) UNION (
   (SELECT
    f_eid = ce2.encntr_id, eventcd = dbp.event_cd, ce_date_time = dbp.event_end_dt_tm,
    event_id = dbp.event_id, result = dbp.result_val, pid = ce2.person_id,
    delivery_date = cdr2.result_dt_tm, birth_date = cdr2.result_dt_tm, disch_date = e2.disch_dt_tm,
    dob = p2.birth_dt_tm, eregdate = e2.reg_dt_tm, s_fin = fin2.alias
    FROM clinical_event ce2,
     clinical_event dbp,
     ce_date_result cdr2,
     person p2,
     encntr_alias fin2,
     encounter e2
    WHERE e2.disch_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
    cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)
     AND e2.active_status_cd=mf_cs48_active
     AND e2.loc_facility_cd=mf_cs220_bmc
     AND e2.encntr_type_class_cd IN (mf_cs69_inpatient_cd, mf_cs69_observation_cd)
     AND ce2.encntr_id=e2.encntr_id
     AND ce2.person_id=e2.person_id
     AND ce2.event_cd=mf_cs72_datetimebirth
     AND ce2.valid_until_dt_tm > sysdate
     AND ce2.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
    mf_cs8_active_cd)
     AND cdr2.event_id=ce2.event_id
     AND dbp.person_id=ce2.person_id
     AND dbp.encntr_id=ce2.encntr_id
     AND dbp.valid_until_dt_tm > sysdate
     AND dbp.event_cd=mf_cs72_diastolicbloodpressure_cd
     AND dbp.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
    mf_cs8_active_cd)
     AND p2.person_id=ce2.person_id
     AND fin2.encntr_id=ce2.encntr_id
     AND fin2.active_ind=1
     AND sysdate BETWEEN fin2.beg_effective_dt_tm AND fin2.end_effective_dt_tm
     AND fin2.encntr_alias_type_cd=mf_cs319_fin_cd))) )
  ORDER BY 1, 2, 3
  HEAD REPORT
   stat = alterlist(hyperten->pats,10), md_spprevdate = cnvtdatetime("31-DEC-2100 00:00:00"),
   md_dpprevdate = cnvtdatetime("31-DEC-2100 00:00:00")
  HEAD f_eid
   hyperten->cnt_pat += 1
   IF (mod(hyperten->cnt_pat,10)=1
    AND (hyperten->cnt_pat > 1))
    stat = alterlist(hyperten->pats,(hyperten->cnt_pat+ 9))
   ENDIF
   hyperten->pats[hyperten->cnt_pat].f_encntr_id = f_eid, hyperten->pats[hyperten->cnt_pat].
   f_person_id = pid, hyperten->pats[hyperten->cnt_pat].s_fin = trim(s_fin,3),
   hyperten->pats[hyperten->cnt_pat].d_birth_date_time = cdr.result_dt_tm, hyperten->pats[hyperten->
   cnt_pat].d_disch_date = cnvtdatetime(disch_date), hyperten->pats[hyperten->cnt_pat].d_admit_date
    = cnvtdatetime(eregdate),
   hyperten->pats[hyperten->cnt_pat].s_age = cnvtage(dob,eregdate,0), hyperten->pats[hyperten->
   cnt_pat].d_delivery_date = delivery_date, md_spprevdate = cnvtdatetime("31-DEC-2100 00:00:00"),
   md_dpprevdate = cnvtdatetime("31-DEC-2100 00:00:00")
  HEAD event_id
   IF (isnumeric(result) >= 1)
    IF (eventcd=mf_cs72_systolicbloodpressure_cd
     AND cnvtreal(result) >= 160.0
     AND ((md_spprevdate=cnvtdatetime("31-DEC-2100 00:00:00")) OR (datetimediff(cnvtdatetime(
      ce_date_time),hyperten->pats[hyperten->cnt_pat].d_sbp_date1,3) >= 1
     AND (hyperten->pats[hyperten->cnt_pat].d_sbp_date1 != null)))
     AND (hyperten->pats[hyperten->cnt_pat].m_sbp_1hr != 1))
     md_spprevdate = cnvtdatetime(ce_date_time), hyperten->pats[hyperten->cnt_pat].s_sbp_result1 =
     result, hyperten->pats[hyperten->cnt_pat].f_sbp_event_id1 = event_id,
     hyperten->pats[hyperten->cnt_pat].d_sbp_date1 = cnvtdatetime(ce_date_time)
    ELSEIF (eventcd=mf_cs72_systolicbloodpressure_cd
     AND cnvtreal(result) >= 160.0
     AND (hyperten->pats[hyperten->cnt_pat].m_sbp_1hr != 1)
     AND datetimediff(ce_date_time,md_spprevdate,3) <= 1)
     hyperten->pats[hyperten->cnt_pat].m_sbp_1hr = 1, hyperten->pats[hyperten->cnt_pat].s_sbp_result2
      = result, hyperten->pats[hyperten->cnt_pat].f_sbp_event_id2 = event_id,
     hyperten->pats[hyperten->cnt_pat].d_sbp_date2 = ce_date_time, hyperten->pats[hyperten->cnt_pat].
     f_sbp_diff = datetimediff(ce_date_time,md_spprevdate,4)
    ELSEIF (eventcd=mf_cs72_diastolicbloodpressure_cd
     AND cnvtreal(result) >= 110.0
     AND ((md_dpprevdate=cnvtdatetime("31-DEC-2100 00:00:00")) OR (datetimediff(cnvtdatetime(
      ce_date_time),hyperten->pats[hyperten->cnt_pat].d_dbp_date1,3) >= 1
     AND (hyperten->pats[hyperten->cnt_pat].d_dbp_date1 != null)))
     AND (hyperten->pats[hyperten->cnt_pat].m_dbp_1hr != 1))
     md_dpprevdate = cnvtdatetime(ce_date_time), hyperten->pats[hyperten->cnt_pat].s_dbp_result1 =
     result, hyperten->pats[hyperten->cnt_pat].d_dbp_date1 = cnvtdatetime(ce_date_time)
    ELSEIF (eventcd=mf_cs72_diastolicbloodpressure_cd
     AND cnvtreal(result) >= 110.0
     AND (hyperten->pats[hyperten->cnt_pat].m_dbp_1hr != 1)
     AND datetimediff(ce_date_time,md_dpprevdate,3) <= 1)
     hyperten->pats[hyperten->cnt_pat].m_dbp_1hr = 1, hyperten->pats[hyperten->cnt_pat].s_dbp_result2
      = result, hyperten->pats[hyperten->cnt_pat].d_dbp_date2 = ce_date_time,
     hyperten->pats[hyperten->cnt_pat].f_dbp_diff = datetimediff(ce_date_time,md_dpprevdate,4)
    ENDIF
   ENDIF
  FOOT  f_eid
   md_spprevdate = cnvtdatetime("31-DEC-2100 00:00:00"), md_dpprevdate = cnvtdatetime(
    "31-DEC-2100 00:00:00")
  FOOT REPORT
   stat = alterlist(hyperten->pats,hyperten->cnt_pat)
  WITH nocounter, rdbunion
 ;end select
 SELECT INTO "nl:"
  pl_sort =
  IF (pi.info_sub_type_cd=mf_cs356_race1) 1
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race2) 2
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race3) 3
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race4) 4
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race5) 5
  ENDIF
  FROM person_info pi
  PLAN (pi
   WHERE expand(ml_idx,1,size(hyperten->pats,5),pi.person_id,hyperten->pats[ml_idx].f_person_id)
    AND pi.active_ind=1
    AND pi.end_effective_dt_tm > sysdate
    AND pi.info_type_cd=mf_cs355_user_def_cd
    AND pi.info_sub_type_cd IN (mf_cs356_race1, mf_cs356_race2, mf_cs356_race3, mf_cs356_race4,
   mf_cs356_race5))
  ORDER BY pi.person_id, pl_sort
  HEAD pi.person_id
   ml_pos = locateval(ml_idx,1,size(hyperten->pats,5),pi.person_id,hyperten->pats[ml_idx].f_person_id
    )
  DETAIL
   IF (ml_pos > 0)
    IF (textlen(trim(hyperten->pats[ml_pos].s_race,3))=0)
     hyperten->pats[ml_pos].s_race = trim(uar_get_code_display(pi.value_cd),3)
    ELSEIF (pi.value_cd > 0.0)
     hyperten->pats[ml_pos].s_race = concat(hyperten->pats[ml_pos].s_race,", ",trim(
       uar_get_code_display(pi.value_cd),3))
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  pl_sort =
  IF (trim(bd.description,3)="ethnicity 1") 1
  ELSE 2
  ENDIF
  FROM bhs_demographics bd
  PLAN (bd
   WHERE expand(ml_idx,1,size(hyperten->pats,5),bd.person_id,hyperten->pats[ml_idx].f_person_id)
    AND bd.active_ind=1
    AND bd.end_effective_dt_tm > sysdate)
  ORDER BY bd.person_id, pl_sort
  HEAD bd.person_id
   ml_pos = locateval(ml_idx,1,size(hyperten->pats,5),bd.person_id,hyperten->pats[ml_idx].f_person_id
    )
  DETAIL
   IF (ml_pos > 0)
    IF (trim(bd.description,3)="ethnicity 1")
     hyperten->pats[ml_pos].s_ethnicity = trim(uar_get_code_display(bd.code_value),3)
    ELSEIF (trim(bd.description,3)="ethnicity 2")
     IF (textlen(trim(hyperten->pats[ml_pos].s_ethnicity,3))=0)
      hyperten->pats[ml_pos].s_ethnicity = trim(uar_get_code_display(bd.code_value),3)
     ELSE
      hyperten->pats[ml_pos].s_ethnicity = concat(hyperten->pats[ml_pos].s_ethnicity,", ",trim(
        uar_get_code_display(bd.code_value),3))
     ENDIF
    ELSEIF (trim(bd.description,3)="hispanic ind")
     hyperten->pats[ml_pos].s_hispanic_ind = trim(bd.display,3)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (( $F_EMAIL_OPS=0))
  SELECT INTO  $OUTDEV
   account_number = substring(1,100,hyperten->pats[d1.seq].s_fin), admit_date = format(hyperten->
    pats[d1.seq].d_admit_date,"mm/dd/yyyy;;D"), discharge_date = format(hyperten->pats[d1.seq].
    d_disch_date,"mm/dd/yyyy;;D"),
   age = hyperten->pats[d1.seq].s_age, race = substring(1,30,hyperten->pats[d1.seq].s_race),
   ethnicity = substring(1,30,hyperten->pats[d1.seq].s_ethnicity),
   hispanic = substring(1,30,hyperten->pats[d1.seq].s_hispanic_ind)
   FROM (dummyt d1  WITH seq = size(hyperten->pats,5))
   PLAN (d1
    WHERE (((hyperten->pats[d1.seq].m_sbp_1hr=1)) OR ((hyperten->pats[d1.seq].m_dbp_1hr=1))) )
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (( $F_EMAIL_OPS=1))
  SET frec->file_name = trim(ms_output_file,3)
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"Account Number",','"Admit Date",','"Discharge Date",','"Age",',
   '"Race",',
   '"Ethnicity",','"Hispanic",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO size(hyperten->pats,5))
    IF ((((hyperten->pats[ml_cnt].m_sbp_1hr=1)) OR ((hyperten->pats[ml_cnt].m_dbp_1hr=1))) )
     SET frec->file_buf = build('"',trim(hyperten->pats[ml_cnt].s_fin,3),'","',trim(format(hyperten->
        pats[ml_cnt].d_admit_date,"mm/dd/yyyy;;D"),3),'","',
      trim(format(hyperten->pats[ml_cnt].d_disch_date,"mm/dd/yyyy;;D"),3),'","',trim(hyperten->pats[
       ml_cnt].s_age,3),'","',trim(hyperten->pats[ml_cnt].s_race,3),
      '","',trim(hyperten->pats[ml_cnt].s_ethnicity,3),'","',trim(hyperten->pats[ml_cnt].
       s_hispanic_ind,3),'"',
      char(13))
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  SET ms_subject = build2("BMC Pregnancy Hypertension Report ",trim(format(cnvtdatetime(ms_start_date
      ),"mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),
     "mmm-dd-yyyy hh:mm;;d"),3))
  CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
 ENDIF
END GO
