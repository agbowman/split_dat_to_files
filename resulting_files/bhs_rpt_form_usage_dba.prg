CREATE PROGRAM bhs_rpt_form_usage:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 673936.00,
  "Unit" = value(0.0),
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Enter Form Name" = "*",
  "Select Form" = 0,
  "Enter Emails" = "",
  "Date Range" = ""
  WITH outdev, f_fname, f_unit,
  s_start_date, s_end_date, s_searh,
  f_form, s_emails, s_range
 DECLARE mf_cs4_crmn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"CORPORATEMEDICALRECORDNUMBER"
   )), protect
 DECLARE mf_cs72_dcpgenericcode = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DCPGENERICCODE")),
 protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE impella_date_charted = vc WITH protect, noconstant("              ")
 DECLARE location = vc WITH protect, noconstant("              ")
 DECLARE patient_name = vc WITH protect, noconstant("              ")
 DECLARE mrn = vc WITH protect, noconstant("              ")
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_subject = vc WITH protect, noconstant("              ")
 DECLARE ml_cnt2 = i4 WITH noconstant(0), protect
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE event_code_1 = f8 WITH protect
 DECLARE event_code_2 = f8 WITH protect
 DECLARE event_code_3 = f8 WITH protect
 DECLARE event_code_4 = f8 WITH protect
 DECLARE event_code_5 = f8 WITH protect
 DECLARE event_code_6 = f8 WITH protect
 DECLARE col_x = i4 WITH noconstant(0), protect
 DECLARE result_name = vc WITH noconstant(fillstring(100," ")), protect
 DECLARE result = vc WITH noconstant(fillstring(100," ")), protect
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_opr_var2 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_filename = vc WITH noconstant(concat("bhs_",replace(trim(check(trim(cnvtlower(
        uar_get_code_display( $F_FORM)),3),char(97),char(122)),3)," ","_"))), protect
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),"_",trim(cnvtlower( $S_RANGE),
    3),format(sysdate,"MMDDYYYY;;q"),".csv")), protect
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD forms
 RECORD forms(
   1 l_ecnt = i4
   1 header1 = vc
   1 header2 = vc
   1 header3 = vc
   1 header4 = vc
   1 header5 = vc
   1 header6 = vc
   1 elst[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_mrn = vc
     2 s_fin = vc
     2 s_cmrn = vc
     2 s_patient_lname = vc
     2 s_patient_fname = vc
     2 s_location = vc
     2 l_chtd = i4
     2 s_date_charted = vc
     2 s_admit_date = vc
     2 s_facility = vc
     2 s_unit = vc
     2 s_form_name = vc
     2 s_charted_by = vc
     2 s_form_date = vc
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field5 = vc
     2 field6 = vc
     2 field1_dt = vc
     2 field2_dt = vc
     2 field3_dt = vc
     2 field4_dt = vc
     2 field5_dt = vc
     2 field6_dt = vc
     2 field1_name = vc
     2 field2_name = vc
     2 field3_name = vc
     2 field4_name = vc
     2 field5_name = vc
     2 field6_name = vc
 ) WITH protect
 FREE RECORD grec
 RECORD grec(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 FREE RECORD grec1
 RECORD grec1(
   1 list[*]
     2 f_cv = f8
     2 s_disp = vc
 )
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),0)))
 SET ml_gcnt = 0
 IF (ms_lcheck="L")
  SET ms_opr_var1 = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),ml_gcnt)))
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec->list,(ml_gcnt+ 4))
     ENDIF
     SET grec->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_UNIT),ml_gcnt))
     SET grec->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_UNIT),ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec->list,1)
  SET ml_gcnt = 1
  SET grec->list[1].f_cv =  $F_UNIT
  IF ((grec->list[1].f_cv=0.0))
   SET grec->list[1].s_disp = "All Units"
   SET ms_opr_var1 = "!="
  ELSE
   SET grec->list[1].s_disp = uar_get_code_display(grec->list[1].f_cv)
   SET ms_opr_var1 = "="
  ENDIF
 ENDIF
 IF (cnvtupper(trim( $S_RANGE,3))="DAILY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0)),"D","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0)),"D","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ELSEIF (cnvtupper(trim( $S_RANGE,3))="WEEKLY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ELSEIF (cnvtupper(trim( $S_RANGE,3))="MONTHLY")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ENDIF
 IF (cnvtdatetime(ms_start_date) > cnvtdatetime(ms_end_date))
  SET ms_error = "Start date must be less than end date."
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(ms_end_date),cnvtdatetime(ms_start_date)) > 993)
  SET ms_error = "Date range exceeds 93 days."
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
  GO TO exit_script
 ELSEIF (findstring("@", $S_EMAILS)=0
  AND textlen( $S_EMAILS) > 0
  AND ( $S_RANGE != "SCREEN"))
  SET ms_error = "Recipient email is invalid."
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
  GO TO exit_script
 ELSEIF (size(grec1->list,5) <= 6)
  SELECT INTO "nl:"
   facility = uar_get_code_display(e.loc_facility_cd), unit = uar_get_code_display(e
    .loc_nurse_unit_cd)
   FROM clinical_event ce,
    prsnl pr,
    encounter e,
    encntr_alias mrn,
    encntr_alias fin,
    person p
   PLAN (ce
    WHERE ce.view_level=1
     AND (ce.event_cd= $F_FORM)
     AND ce.event_end_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
    cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active
    ))
    JOIN (e
    WHERE (e.loc_facility_cd= $F_FNAME)
     AND operator(e.loc_nurse_unit_cd,ms_opr_var1, $F_UNIT)
     AND e.active_ind=1
     AND e.active_status_cd=mf_cs48_active
     AND e.encntr_id=ce.encntr_id
     AND e.person_id=ce.person_id)
    JOIN (mrn
    WHERE mrn.encntr_id=e.encntr_id
     AND mrn.active_status_cd=mf_cs48_active
     AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
     AND mrn.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND mrn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND mrn.active_ind=1)
    JOIN (fin
    WHERE fin.encntr_id=e.encntr_id
     AND fin.active_status_cd=mf_cs48_active
     AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
     AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND fin.active_ind=1)
    JOIN (pr
    WHERE pr.person_id=ce.verified_prsnl_id)
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.active_ind=1)
   ORDER BY ce.event_cd, e.encntr_id
   HEAD REPORT
    stat = alterlist(forms->elst,10)
   HEAD ce.encntr_id
    forms->l_ecnt += 1
    IF (mod(forms->l_ecnt,10)=1
     AND (forms->l_ecnt > 1))
     stat = alterlist(forms->elst,(forms->l_ecnt+ 9))
    ENDIF
    forms->elst[forms->l_ecnt].s_fin = trim(fin.alias,3), forms->elst[forms->l_ecnt].s_form_date =
    format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;Q"), forms->elst[forms->l_ecnt].s_charted_by = trim(
     pr.name_full_formatted,3),
    forms->elst[forms->l_ecnt].s_form_name = trim(uar_get_code_display(ce.event_cd),3)
   FOOT  e.encntr_id
    null
   FOOT REPORT
    stat = alterlist(forms->elst,forms->l_ecnt)
   WITH nocounter, time = 60
  ;end select
  IF (( $S_RANGE="SCREEN"))
   SELECT INTO  $OUTDEV
    fin = substring(1,20,"FIN#"), charted_by = substring(1,50,"Charted_By"), form_name = substring(1,
     50,"Form_name"),
    date_charted = substring(1,30,"Date_Form_Completed")
    FROM dummyt d
    WITH nocounter, separator = " ", format,
     noheading
   ;end select
   SELECT INTO  $OUTDEV
    fins = substring(1,20,trim(forms->elst[d1.seq].s_fin,3)), charted_by = substring(1,50,trim(forms
      ->elst[d1.seq].s_charted_by,3)), form_name = substring(1,50,trim(forms->elst[d1.seq].
      s_form_name,3)),
    date_charted = substring(1,20,trim(forms->elst[d1.seq].s_form_date,3))
    FROM (dummyt d1  WITH seq = size(forms->elst,5))
    PLAN (d1)
    WITH nocounter, separator = " ", format,
     noheading, append
   ;end select
  ELSEIF (( $S_RANGE != "SCREEN"))
   IF (textlen(trim( $S_EMAILS,3)) > 1
    AND textlen(trim(ms_error,3))=0)
    SET frec->file_name = ms_output_file
    SET frec->file_buf = "w"
    SET stat = cclio("OPEN",frec)
    SET frec->file_buf = build('"Reg_Date",','"Facility",','"Unit",','"Patient_Last_Name",',
     '"Patient_First_Name",',
     '"CMRN",','"FIN#",','"Date_Form_Completed",','"',trim(replace(forms->header1," ","_"),3),
     '","',trim(replace(forms->header2," ","_"),3),'","',trim(replace(forms->header3," ","_"),3),
     '","',
     trim(replace(forms->header4," ","_"),3),'","',trim(replace(forms->header5," ","_"),3),'","',trim
     (replace(forms->header6," ","_"),3),
     '"',char(13))
    SET stat = cclio("WRITE",frec)
    FOR (ml_cnt = 1 TO size(forms->elst,5))
     SET frec->file_buf = build('"',trim(forms->elst[ml_cnt].s_admit_date,3),'","',trim(forms->elst[
       ml_cnt].s_facility,3),'","',
      trim(forms->elst[ml_cnt].s_unit,3),'","',trim(forms->elst[ml_cnt].s_patient_lname,3),'","',trim
      (forms->elst[ml_cnt].s_patient_fname,3),
      '","',trim(forms->elst[ml_cnt].s_cmrn,3),'","',trim(forms->elst[ml_cnt].s_fin,3),'","',
      trim(forms->elst[ml_cnt].s_form_date,3),'","',trim(forms->elst[ml_cnt].field1,3),'","',trim(
       forms->elst[ml_cnt].field2,3),
      '","',trim(forms->elst[ml_cnt].field3,3),'","',trim(forms->elst[ml_cnt].field4,3),'","',
      trim(forms->elst[ml_cnt].field5,3),'","',trim(forms->elst[ml_cnt].field6,3),'"',char(13))
     SET stat = cclio("WRITE",frec)
    ENDFOR
    SET stat = cclio("CLOSE",frec)
    EXECUTE bhs_ma_email_file
    SET ms_subject = build2(trim(uar_get_code_display( $F_FORM),3)," ",trim(format(cnvtdatetime(
        ms_start_date),"mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),
       "mmm-dd-yyyy hh:mm;;d"),3))
    CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
    SELECT INTO value( $OUTDEV)
     FROM dummyt d
     HEAD REPORT
      msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
      CALL print(calcpos(36,18)),
      msg1, row + 2, msg2
     WITH dio = 08
    ;end select
   ENDIF
  ENDIF
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "You can only select a MAXIMUM of 6 dta's",
    CALL print(calcpos(36,18)), msg1,
    row + 2
   WITH dio = 08
  ;end select
 ENDIF
 FREE RECORD frec
#exit_script
END GO
