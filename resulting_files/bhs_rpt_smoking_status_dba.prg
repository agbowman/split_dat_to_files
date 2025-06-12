CREATE PROGRAM bhs_rpt_smoking_status:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = "",
  "Send Email" = ""
  WITH outdev, s_facility, s_emails
 DECLARE mf_cs17_admitting = f8 WITH constant(uar_get_code_by("DISPLAYKEY",17,"ADMITTING")), protect
 DECLARE mf_cs72_smokingcessation = f8 WITH constant(uar_get_code_by_cki("CKI.EC!9514")), protect
 DECLARE mf_cs14003_tobaccouse = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"SHXTOBACCOUSE")
  ), protect
 DECLARE mf_cs71_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")),
 protect
 DECLARE mf_cs71_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY")), protect
 DECLARE mf_mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_cs71_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE mf_cs71_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs400_icd10cm = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!4101498946")),
 protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE md_start_date = dq8 WITH protect
 DECLARE md_end_date = dq8 WITH protect
 DECLARE md_age = dq8 WITH constant(cnvtagedatetime(18,0,0,0)), protect
 DECLARE ms_year = vc WITH protect
 DECLARE ms_day = i4 WITH protect
 DECLARE ms_name_fac = vc WITH protect
 DECLARE ms_month = i4 WITH protect
 DECLARE d_prt = i4 WITH protect
 DECLARE ms_time = vc WITH protect
 DECLARE ms_output_file = vc WITH protect
 DECLARE ms_fileprefix = vc WITH noconstant("tobacco_treatment_report_"), protect
 DECLARE ms_sender = vc WITH protect
 DECLARE ms_msgcls = vc WITH protect
 DECLARE ms_msg = vc WITH protect
 DECLARE ms_msgsubject = vc WITH protect
 DECLARE ms_sendto = vc WITH protect
 DECLARE ml_msgpriority = i4 WITH protect
 DECLARE ml_opsjob = i4 WITH noconstant(0), protect
 DECLARE ml_email = i4 WITH noconstant(0), protect
 DECLARE ml_chkemail = i4 WITH noconstant(0), protect
 DECLARE ml_cnt_pat = i4 WITH noconstant(0), protect
 DECLARE ml_attloc = i4 WITH protect
 DECLARE ml_num = i4 WITH protect
 DECLARE ml_loc = i4 WITH protect
 DECLARE ml_numres = i4 WITH protect
 SET ms_year = substring(3,2,build(year(cnvtdatetime(sysdate))))
 SET ms_day = day(curdate)
 SET ms_month = month(curdate)
 SET ms_time = format(curtime,"HHMM;;M")
 SET ms_output_file = build(ms_fileprefix,"det",ms_month,ms_day,ms_time,
  ms_year,".csv")
 RECORD tobacco_use(
   1 lpat_cnt = f8
   1 pat_list[*]
     2 s_facility = vc
     2 s_unit = vc
     2 s_patname = vc
     2 s_acct = vc
     2 s_mrn = vc
     2 s_sc_result = vc
     2 s_sc_dt_charted = vc
     2 s_sc_charted_by = vc
     2 s_tu_result = vc
     2 s_tu_dt_charted = vc
     2 s_tu_charted_by = vc
     2 s_admit_date = vc
     2 s_room_bed = vc
     2 s_sc_charted = vc
     2 a_age = vc
     2 s_visit_reason = vc
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_reason_for_visit = vc
 )
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 SELECT INTO "NL:"
  facility = uar_get_code_display(e.loc_facility_cd), nurse_unit = uar_get_code_display(e
   .loc_nurse_unit_cd), sort_name = build(p.name_full_formatted,p.person_id)
  FROM encntr_domain ed,
   encounter e,
   encntr_alias fin,
   encntr_alias mrn,
   clinical_event ce,
   person p,
   prsnl chtd
  PLAN (ed
   WHERE ed.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ed.loc_facility_cd IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE (cv.display_key= $S_FACILITY)
     AND cv.code_set=220
     AND cv.cdf_meaning IN ("FACILITY")))
    AND ed.loc_building_cd > 0
    AND ed.loc_nurse_unit_cd > 0)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_cs71_daystay, mf_cs71_inpatient, mf_cs71_emergency,
   mf_cs71_observation)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND e.disch_dt_tm=null)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=mf_finnbr)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.birth_dt_tm <= cnvtdatetime(md_age))
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.encntr_alias_type_cd=mf_mrn)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.person_id=e.person_id
    AND ce.event_cd=mf_cs72_smokingcessation
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd)
    AND trim(ce.result_val,3) IN ("Patient has smoked in the last 30 days"))
   JOIN (chtd
   WHERE chtd.person_id=ce.verified_prsnl_id)
  ORDER BY facility, nurse_unit, sort_name
  HEAD REPORT
   stat = alterlist(tobacco_use->pat_list,10)
  HEAD sort_name
   ml_cnt_pat += 1
   IF (mod(ml_cnt_pat,10)=1
    AND ml_cnt_pat > 1)
    stat = alterlist(tobacco_use->pat_list,(ml_cnt_pat+ 9))
   ENDIF
   tobacco_use->pat_list[ml_cnt_pat].s_facility = trim(uar_get_code_display(ed.loc_building_cd),3),
   tobacco_use->pat_list[ml_cnt_pat].s_unit = trim(uar_get_code_display(ed.loc_nurse_unit_cd),3),
   tobacco_use->pat_list[ml_cnt_pat].s_acct = trim(fin.alias,3),
   tobacco_use->pat_list[ml_cnt_pat].s_mrn = trim(mrn.alias,3), tobacco_use->pat_list[ml_cnt_pat].
   s_admit_date = substring(1,30,format(e.reg_dt_tm,"DD-MMM-YYYY;;D")), tobacco_use->pat_list[
   ml_cnt_pat].s_sc_dt_charted = substring(1,30,format(ce.verified_dt_tm,"DD-MMM-YYYY;;D")),
   tobacco_use->pat_list[ml_cnt_pat].s_patname = p.name_full_formatted, tobacco_use->pat_list[
   ml_cnt_pat].s_sc_charted_by = chtd.name_full_formatted, tobacco_use->pat_list[ml_cnt_pat].
   s_sc_result = uar_get_code_display(ce.event_cd),
   tobacco_use->pat_list[ml_cnt_pat].s_room_bed = build(uar_get_code_display(ed.loc_room_cd),"-",
    uar_get_code_display(ed.loc_bed_cd)), tobacco_use->pat_list[ml_cnt_pat].s_sc_charted = trim(ce
    .result_val,3), tobacco_use->pat_list[ml_cnt_pat].a_age = cnvtage(p.birth_dt_tm),
   tobacco_use->pat_list[ml_cnt_pat].f_encntr_id = e.encntr_id, tobacco_use->pat_list[ml_cnt_pat].
   f_person_id = e.person_id, tobacco_use->pat_list[ml_cnt_pat].s_reason_for_visit = trim(e
    .reason_for_visit,3)
  FOOT REPORT
   stat = alterlist(tobacco_use->pat_list,ml_cnt_pat), tobacco_use->lpat_cnt = ml_cnt_pat, ml_cnt_pat
    = 0
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM shx_activity sa,
   shx_response sr,
   shx_alpha_response sar,
   prsnl chtd,
   nomenclature n
  PLAN (sa
   WHERE expand(ml_num,1,size(tobacco_use->pat_list,5),sa.person_id,tobacco_use->pat_list[ml_num].
    f_person_id)
    AND sa.active_ind=1
    AND sa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (chtd
   WHERE chtd.person_id=sa.updt_id)
   JOIN (sr
   WHERE sr.shx_activity_id=sa.shx_activity_id
    AND sr.active_ind=1
    AND sr.task_assay_cd IN (mf_cs14003_tobaccouse))
   JOIN (sar
   WHERE sar.shx_response_id=sr.shx_response_id)
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(sar.nomenclature_id))
    AND n.source_string_keycap IN ("4 OR LESS CIGARETTES(LESS THAN 1/4 PACK)/DAY IN LAST 30 DAYS",
   "5-9 CIGARETTES (BETWEEN 1/4 TO 1/2 PACK)/DAY IN LAST 30 DAYS",
   "10 OR MORE CIGARETTES (1/2 PACK OR MORE)/DAY IN LAST 30 DAYS",
   "CIGARS OR PIPES DAILY WITHIN LAST 30 DAYS", "SMOKER, CURRENT STATUS UNKNOWN"))
  ORDER BY sa.person_id, sr.task_assay_cd, sa.perform_dt_tm DESC
  HEAD sa.person_id
   ml_loc = 0, ml_loc = locateval(ml_numres,1,size(tobacco_use->pat_list,5),sa.person_id,tobacco_use
    ->pat_list[ml_numres].f_person_id)
  HEAD sr.task_assay_cd
   IF (ml_loc != 0)
    IF (sr.task_assay_cd=mf_cs14003_tobaccouse)
     tobacco_use->pat_list[ml_loc].s_tu_result = trim(n.short_string,3), tobacco_use->pat_list[ml_loc
     ].s_tu_charted_by = chtd.name_full_formatted, tobacco_use->pat_list[ml_loc].s_tu_dt_charted =
     format(sa.perform_dt_tm,"mm/dd/yyyy;;D")
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "NL:"
  facility = uar_get_code_display(e.loc_facility_cd), nurse_unit = uar_get_code_display(e
   .loc_nurse_unit_cd), sort_name = build(p.name_full_formatted,p.person_id)
  FROM encntr_domain ed,
   encounter e,
   encntr_alias fin,
   encntr_alias mrn,
   shx_activity sa,
   shx_response sr,
   shx_alpha_response sar,
   person p,
   nomenclature n,
   prsnl chtd
  PLAN (ed
   WHERE ed.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ed.loc_facility_cd IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE (cv.display_key= $S_FACILITY)
     AND cv.code_set=220
     AND cv.cdf_meaning IN ("FACILITY")))
    AND ed.loc_building_cd > 0
    AND ed.loc_nurse_unit_cd > 0)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm=null
    AND e.encntr_type_cd IN (mf_cs71_daystay, mf_cs71_inpatient, mf_cs71_emergency,
   mf_cs71_observation)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND  NOT (e.person_id IN (
   (SELECT
    ce.person_id
    FROM clinical_event ce
    WHERE ce.encntr_id=e.encntr_id
     AND ce.person_id=e.person_id
     AND ce.event_cd=mf_cs72_smokingcessation
     AND ce.valid_until_dt_tm > sysdate
     AND ce.view_level=1
     AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
    mf_cs8_active_cd)))))
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=mf_finnbr)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.birth_dt_tm <= cnvtdatetime(md_age))
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.encntr_alias_type_cd=mf_mrn)
   JOIN (sa
   WHERE sa.person_id=e.person_id
    AND sa.active_ind=1
    AND sa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (chtd
   WHERE chtd.person_id=sa.updt_id)
   JOIN (sr
   WHERE sr.shx_activity_id=sa.shx_activity_id
    AND sr.active_ind=1
    AND sr.task_assay_cd IN (mf_cs14003_tobaccouse))
   JOIN (sar
   WHERE sar.shx_response_id=sr.shx_response_id)
   JOIN (n
   WHERE n.nomenclature_id=sar.nomenclature_id
    AND n.source_string_keycap IN ("4 OR LESS CIGARETTES(LESS THAN 1/4 PACK)/DAY IN LAST 30 DAYS",
   "5-9 CIGARETTES (BETWEEN 1/4 TO 1/2 PACK)/DAY IN LAST 30 DAYS",
   "10 OR MORE CIGARETTES (1/2 PACK OR MORE)/DAY IN LAST 30 DAYS",
   "CIGARS OR PIPES DAILY WITHIN LAST 30 DAYS", "SMOKER, CURRENT STATUS UNKNOWN"))
  ORDER BY facility, nurse_unit, sort_name,
   sr.task_assay_cd, sa.perform_dt_tm DESC
  HEAD REPORT
   IF ((tobacco_use->lpat_cnt=0))
    stat = alterlist(tobacco_use->pat_list,10), ml_cnt_pat = 0
   ELSEIF ((tobacco_use->lpat_cnt > 0))
    ml_cnt_pat = tobacco_use->lpat_cnt, stat = alterlist(tobacco_use->pat_list,(ml_cnt_pat+ 9))
   ENDIF
  HEAD sort_name
   ml_cnt_pat += 1
   IF (mod(ml_cnt_pat,10)=1
    AND ml_cnt_pat > 1)
    stat = alterlist(tobacco_use->pat_list,(ml_cnt_pat+ 9))
   ENDIF
   tobacco_use->pat_list[ml_cnt_pat].s_facility = trim(uar_get_code_display(ed.loc_building_cd),3),
   tobacco_use->pat_list[ml_cnt_pat].s_unit = trim(uar_get_code_display(ed.loc_nurse_unit_cd),3),
   tobacco_use->pat_list[ml_cnt_pat].s_acct = trim(fin.alias,3),
   tobacco_use->pat_list[ml_cnt_pat].s_mrn = trim(mrn.alias,3), tobacco_use->pat_list[ml_cnt_pat].
   s_admit_date = substring(1,30,format(e.reg_dt_tm,"DD-MMM-YYYY;;D")), tobacco_use->pat_list[
   ml_cnt_pat].s_patname = p.name_full_formatted,
   tobacco_use->pat_list[ml_cnt_pat].s_room_bed = build(uar_get_code_display(ed.loc_room_cd),"-",
    uar_get_code_display(ed.loc_bed_cd)), tobacco_use->pat_list[ml_cnt_pat].a_age = cnvtage(p
    .birth_dt_tm), tobacco_use->pat_list[ml_cnt_pat].f_encntr_id = e.encntr_id,
   tobacco_use->pat_list[ml_cnt_pat].f_person_id = e.person_id, tobacco_use->pat_list[ml_cnt_pat].
   s_reason_for_visit = trim(e.reason_for_visit,3)
  HEAD sr.task_assay_cd
   IF (sr.task_assay_cd=mf_cs14003_tobaccouse)
    tobacco_use->pat_list[ml_cnt_pat].s_tu_result = trim(n.short_string,3), tobacco_use->pat_list[
    ml_cnt_pat].s_tu_charted_by = chtd.name_full_formatted, tobacco_use->pat_list[ml_cnt_pat].
    s_tu_dt_charted = format(sa.perform_dt_tm,"mm/dd/yyyy;;D")
   ENDIF
  FOOT REPORT
   stat = alterlist(tobacco_use->pat_list,ml_cnt_pat), tobacco_use->lpat_cnt = ml_cnt_pat, ml_cnt_pat
    = 0
  WITH nocounter
 ;end select
 SET ml_email = findstring("@", $S_EMAILS,1,0)
 IF (ml_email=0)
  SELECT INTO  $OUTDEV
   facility = substring(1,30,tobacco_use->pat_list[d1.seq].s_facility), unit = substring(1,30,
    tobacco_use->pat_list[d1.seq].s_unit), acct = substring(1,30,tobacco_use->pat_list[d1.seq].s_acct
    ),
   mrn = substring(1,30,tobacco_use->pat_list[d1.seq].s_mrn), patname = substring(1,30,tobacco_use->
    pat_list[d1.seq].s_patname), admit_date = substring(1,30,tobacco_use->pat_list[d1.seq].
    s_admit_date),
   room_bed = substring(1,30,tobacco_use->pat_list[d1.seq].s_room_bed), patient_age = substring(1,30,
    tobacco_use->pat_list[d1.seq].a_age), reason_for_visit = substring(1,30,tobacco_use->pat_list[d1
    .seq].s_reason_for_visit),
   smoking_cessation = substring(1,100,tobacco_use->pat_list[d1.seq].s_sc_charted), charted_by =
   substring(1,30,tobacco_use->pat_list[d1.seq].s_sc_charted_by), date_charted = substring(1,30,
    tobacco_use->pat_list[d1.seq].s_sc_dt_charted),
   tobacco_use = substring(1,100,tobacco_use->pat_list[d1.seq].s_tu_result), charted_by = substring(1,
    30,tobacco_use->pat_list[d1.seq].s_tu_charted_by), date_charted = substring(1,30,tobacco_use->
    pat_list[d1.seq].s_tu_dt_charted)
   FROM (dummyt d1  WITH seq = size(tobacco_use->pat_list,5))
   PLAN (d1)
   ORDER BY facility, unit, room_bed
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (ml_email > 0)
  SET ml_chkemail = findstring("@BAYSTATEHEALTH.ORG",cnvtupper( $S_EMAILS),1,0)
  IF (ml_chkemail > 0)
   SET ml_cnt_pat = 0
   SET frec->file_name = ms_output_file
   IF (size(tobacco_use->pat_list,5) > 0)
    SET frec->file_buf = "w"
    SET stat = cclio("OPEN",frec)
    SET frec->file_buf = build('"Facility",','"Unit",','"Acct Number",','"MRN",','"Patient Name",',
     '"Admit Date",','"Room/Bed",','"Age",','"Reason For Visit",','"Smoking Cessation",',
     '"Charted By",','"Date Charted",','"Tobacco Use",','"Charted By",','"Date Charted",',
     char(13))
    SET stat = cclio("WRITE",frec)
    SELECT INTO  $OUTDEV
     facility = substring(1,30,tobacco_use->pat_list[d1.seq].s_facility), unit = substring(1,30,
      tobacco_use->pat_list[d1.seq].s_unit), room_bed = substring(1,30,tobacco_use->pat_list[d1.seq].
      s_room_bed),
     patient_age = substring(1,30,tobacco_use->pat_list[d1.seq].a_age)
     FROM (dummyt d1  WITH seq = size(tobacco_use->pat_list,5))
     PLAN (d1)
     ORDER BY facility, unit, room_bed
     DETAIL
      frec->file_buf = build('"',trim(tobacco_use->pat_list[d1.seq].s_facility,3),'","',trim(
        tobacco_use->pat_list[d1.seq].s_unit,3),'","',
       trim(tobacco_use->pat_list[d1.seq].s_acct,3),'","',trim(tobacco_use->pat_list[d1.seq].s_mrn,3),
       '","',trim(tobacco_use->pat_list[d1.seq].s_patname,3),
       '","',trim(tobacco_use->pat_list[d1.seq].s_admit_date,3),'","',trim(tobacco_use->pat_list[d1
        .seq].s_room_bed,3),'","',
       trim(tobacco_use->pat_list[d1.seq].a_age,3),'","',trim(tobacco_use->pat_list[d1.seq].
        s_reason_for_visit,3),'","',trim(tobacco_use->pat_list[d1.seq].s_sc_charted,3),
       '","',trim(tobacco_use->pat_list[d1.seq].s_sc_charted_by,3),'","',trim(tobacco_use->pat_list[
        d1.seq].s_sc_dt_charted,3),'","',
       trim(tobacco_use->pat_list[d1.seq].s_tu_result,3),'","',trim(tobacco_use->pat_list[d1.seq].
        s_tu_charted_by,3),'","',trim(tobacco_use->pat_list[d1.seq].s_tu_dt_charted,3),
       '"',char(13)), stat = cclio("WRITE",frec)
     WITH nocounter
    ;end select
    SET stat = cclio("CLOSE",frec)
    SET ms_subject = build2("Patient Smokers in  Selected Location")
    EXECUTE bhs_ma_email_file
    CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
    SELECT INTO value( $OUTDEV)
     FROM dummyt d
     HEAD REPORT
      msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
      CALL print(calcpos(36,18)),
      msg1, row + 2, msg2
     WITH dio = 08
    ;end select
   ELSE
    SET ms_subject = build2("No Patient Smokers in Selected Location")
    SET ms_email_body = "No Patient Smokers in Selected Location"
    SET dclcom1 = concat("echo '",ms_email_body,"'"," | mailx -s '",ms_subject,
     "' ",ms_sendto)
    CALL echo(build("DCLCOM1>>>",dclcom1))
    SET dcllen1 = size(trim(dclcom1))
    SET dclstatus = 0
    CALL dcl(dclcom1,dcllen1,dclstatus)
    CALL echo(build("DCLSTATUS>>>",dclstatus))
    IF (dclstatus=1)
     CALL echo("emailed success")
    ELSE
     CALL echo("emailed failed")
    ENDIF
   ENDIF
  ELSE
   SELECT INTO value( $OUTDEV)
    FROM dummyt d
    HEAD REPORT
     msg1 = "Please Sent to Valid Baystate email:", msg2 = build2("     ", $S_EMAILS),
     CALL print(calcpos(36,18)),
     msg1, row + 2, msg2
    WITH dio = 08
   ;end select
  ENDIF
 ENDIF
END GO
