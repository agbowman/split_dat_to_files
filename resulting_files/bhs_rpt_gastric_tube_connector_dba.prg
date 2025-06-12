CREATE PROGRAM bhs_rpt_gastric_tube_connector:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 673936.00,
  "Unit" = value(0.0),
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Date Range" = "",
  "Enter Emails" = ""
  WITH outdev, f_fname, f_unit,
  s_start_date, s_end_date, s_range,
  s_emails
 DECLARE mf_cs71_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_cs71_expireddaystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDDAYSTAY")),
 protect
 DECLARE mf_cs71_expiredobv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV")),
 protect
 DECLARE mf_cs71_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE mf_cs71_dischdaystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHDAYSTAY")),
 protect
 DECLARE mf_cs71_dischobv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV")), protect
 DECLARE mf_cs71_expiredip = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP")), protect
 DECLARE mf_cs71_dischip = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP")), protect
 DECLARE mf_cs71_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")),
 protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mf_cs72_gastrictubeunexpfollowup = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "GASTRICTUBEUNEXPECTEDEVENTFOLLOWUP")), protect
 DECLARE mf_cs72_gastrictubeactivity = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "GASTRICTUBEACTIVITY")), protect
 DECLARE mf_cs72_gastrictubetype = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"GASTRICTUBETYPE"
   )), protect
 DECLARE mf_cs72_gastrictubeinsertiondate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "GASTRICTUBEINSERTIONDATE")), protect
 DECLARE mf_cs72_gastrictubeunexp = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "GASTRICTUBEUNEXPECTEDEVENT")), protect
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE patient_name = vc WITH protect, noconstant("              ")
 DECLARE mrn = vc WITH protect, noconstant("              ")
 DECLARE ms_subject = vc WITH protect, noconstant("              ")
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_emails = vc WITH protect, noconstant(trim( $S_EMAILS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_filename = vc WITH noconstant(concat("bhs_gastric_connect_",cnvtlower(trim( $S_RANGE,3)))
  ), protect
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),format(sysdate,"MMDDYYYY;;q"),
   ".csv")), protect
 IF (( $S_RANGE="DAILY"))
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0)),"D","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0)),"D","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ELSEIF (( $S_RANGE="WEEKLY"))
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(curdate,0)),"W","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ELSEIF (( $S_RANGE="MONTHLY"))
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD gastro
 RECORD gastro(
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
 CALL echo(build("days = ",datetimediff(cnvtdatetime(ms_end_date),cnvtdatetime(ms_start_date))))
 IF (cnvtdatetime(ms_start_date) > cnvtdatetime(ms_end_date))
  SET ms_error = "Start date must be less than end date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(ms_end_date),cnvtdatetime(ms_start_date)) > 31)
  SET ms_error = "Date range exceeds 31 day."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  facility = uar_get_code_display(e.loc_facility_cd), unit = uar_get_code_display(e.loc_nurse_unit_cd
   ), ce.encntr_id
  FROM clinical_event ce,
   clinical_event ce1,
   encounter e,
   encntr_alias mrn,
   encntr_alias fin,
   person p,
   ce_date_result cdr
  PLAN (ce1
   WHERE ce1.event_cd IN (mf_cs72_gastrictubeunexpfollowup, mf_cs72_gastrictubetype,
   mf_cs72_gastrictubeinsertiondate, mf_cs72_gastrictubeunexp, mf_cs72_gastrictubeactivity)
    AND ce1.event_end_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce1.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active
   )
    AND (ce1.event_end_dt_tm=
   (SELECT
    max(ce2.event_end_dt_tm)
    FROM clinical_event ce2
    WHERE ce2.event_cd=ce1.event_cd
     AND ce2.encntr_id=ce1.encntr_id
     AND ce2.person_id=ce1.person_id)))
   JOIN (e
   WHERE (e.loc_facility_cd= $F_FNAME)
    AND operator(e.loc_nurse_unit_cd,ms_opr_var1, $F_UNIT)
    AND e.active_ind=1
    AND e.active_status_cd=mf_cs48_active
    AND e.encntr_id=ce1.encntr_id
    AND e.person_id=ce1.person_id
    AND e.encntr_type_cd IN (mf_cs71_expireddaystay, mf_cs71_expiredobv, mf_cs71_expiredip,
   mf_cs71_daystay, mf_cs71_observation,
   mf_cs71_inpatient, mf_cs71_dischdaystay, mf_cs71_dischobv, mf_cs71_dischip))
   JOIN (ce
   WHERE ((ce.event_cd IN (mf_cs72_gastrictubeunexpfollowup, mf_cs72_gastrictubetype,
   mf_cs72_gastrictubeinsertiondate, mf_cs72_gastrictubeunexp, mf_cs72_gastrictubeactivity)) OR (ce
   .event_cd=mf_cs72_gastrictubeactivity
    AND ((cnvtupper(ce.result_val)="*IRRIGATE*") OR (cnvtupper(ce.result_val)="*CONNECTOR CLEANED*"
   )) ))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active)
    AND ce.person_id=e.person_id
    AND ce.encntr_id=e.encntr_id)
   JOIN (cdr
   WHERE (cdr.event_id= Outerjoin(ce.event_id))
    AND (cdr.valid_until_dt_tm> Outerjoin(sysdate)) )
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_status_cd=mf_cs48_active
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND fin.active_ind=1)
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.active_status_cd=mf_cs48_active
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND mrn.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND mrn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND mrn.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  ORDER BY facility, unit, ce.encntr_id,
   p.name_full_formatted, ce.event_end_dt_tm DESC
  HEAD REPORT
   stat = alterlist(gastro->elst,10)
  HEAD ce.encntr_id
   gastro->l_ecnt += 1
   IF (mod(gastro->l_ecnt,10)=1
    AND (gastro->l_ecnt > 1))
    stat = alterlist(gastro->elst,(gastro->l_ecnt+ 9))
   ENDIF
   gastro->elst[gastro->l_ecnt].s_patient_lname = trim(p.name_full_formatted,3), gastro->elst[gastro
   ->l_ecnt].s_admit_date = format(e.reg_dt_tm,"@SHORTDATE4YR"), gastro->elst[gastro->l_ecnt].s_fin
    = trim(fin.alias,3),
   gastro->elst[gastro->l_ecnt].s_mrn = trim(mrn.alias,3), gastro->elst[gastro->l_ecnt].f_encntr_id
    = ce.encntr_id, gastro->elst[gastro->l_ecnt].f_person_id = ce.person_id,
   gastro->elst[gastro->l_ecnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3), gastro
   ->elst[gastro->l_ecnt].s_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3)
  DETAIL
   IF (ce.event_cd=mf_cs72_gastrictubetype)
    gastro->elst[gastro->l_ecnt].field1_dt = format(ce.event_end_dt_tm,"@SHORTDATE4YR"), gastro->
    elst[gastro->l_ecnt].field1 = trim(ce.result_val,3), gastro->elst[gastro->l_ecnt].field1_name =
    trim(uar_get_code_display(ce.event_cd),3)
   ELSEIF (ce.event_cd=mf_cs72_gastrictubeinsertiondate)
    gastro->elst[gastro->l_ecnt].field2_dt = format(cdr.result_dt_tm,"@SHORTDATE4YR"), gastro->elst[
    gastro->l_ecnt].field2 = trim(ce.result_val,3), gastro->elst[gastro->l_ecnt].field2_name = trim(
     uar_get_code_display(ce.event_cd),3)
   ELSEIF (ce.event_cd=mf_cs72_gastrictubeactivity
    AND cnvtupper(ce.result_val)="*CONNECTOR CLEANED*")
    gastro->elst[gastro->l_ecnt].field3_dt = format(ce.event_end_dt_tm,"@SHORTDATE4YR"), gastro->
    elst[gastro->l_ecnt].field3 = trim(ce.result_val,3), gastro->elst[gastro->l_ecnt].field3_name =
    trim(uar_get_code_display(ce.event_cd),3)
   ELSEIF (ce.event_cd=mf_cs72_gastrictubeactivity
    AND cnvtupper(ce.result_val)="*IRRIGATE*")
    gastro->elst[gastro->l_ecnt].field4_dt = format(ce.event_end_dt_tm,"@SHORTDATE4YR"), gastro->
    elst[gastro->l_ecnt].field4 = trim(ce.result_val,3), gastro->elst[gastro->l_ecnt].field4_name =
    trim(uar_get_code_display(ce.event_cd),3)
   ELSEIF (ce.event_cd=mf_cs72_gastrictubeunexp)
    gastro->elst[gastro->l_ecnt].field5_dt = format(ce.event_end_dt_tm,"@SHORTDATE4YR"), gastro->
    elst[gastro->l_ecnt].field5 = trim(ce.result_val,3), gastro->elst[gastro->l_ecnt].field5_name =
    trim(uar_get_code_display(ce.event_cd),3)
   ELSEIF (ce.event_cd=mf_cs72_gastrictubeunexpfollowup)
    gastro->elst[gastro->l_ecnt].field6_dt = format(ce.event_end_dt_tm,"@SHORTDATE4YR"), gastro->
    elst[gastro->l_ecnt].field6 = trim(ce.result_val,3), gastro->elst[gastro->l_ecnt].field6_name =
    trim(uar_get_code_display(ce.event_cd),3)
   ENDIF
  FOOT  e.encntr_id
   null
  FOOT REPORT
   stat = alterlist(gastro->elst,gastro->l_ecnt)
  WITH nocounter
 ;end select
 IF (( $S_RANGE="SCREEN"))
  SET gastro->header1 = "Gastric Tube Type"
  SET gastro->header2 = "Gastric Tube Insertion Date"
  SET gastro->header3 = "Date/Time Connector Cleaned"
  SET gastro->header4 = "Date/Time Connector Irrigated"
  SET gastro->header5 = "Gastric Tube Unexpected Event"
  SET gastro->header6 = "Gastric Tube Unexpected Event Follow-up"
  SELECT INTO  $OUTDEV
   patient_name = substring(1,60,"Patient_Name"), finx = substring(1,20,"MRN"), mrnx = substring(1,20,
    "Account_Number"),
   unit = substring(1,10,"Unit"), head1 = substring(1,100,trim(replace(gastro->header1," ","_"),3)),
   head2 = substring(1,100,trim(replace(gastro->header2," ","_"),3)),
   head3 = substring(1,100,trim(replace(gastro->header3," ","_"),3)), head4 = substring(1,100,trim(
     replace(gastro->header4," ","_"),3)), head5 = substring(1,100,trim(replace(gastro->header5," ",
      "_"),3)),
   head6 = substring(1,100,trim(replace(gastro->header6," ","_"),3))
   FROM dummyt d
   WITH nocounter, separator = " ", format,
    noheading
  ;end select
  SELECT INTO  $OUTDEV
   patient_lastname = substring(1,60,trim(gastro->elst[d1.seq].s_patient_lname,3)), fins = substring(
    1,20,trim(gastro->elst[d1.seq].s_fin,3)), mrns = substring(1,20,trim(gastro->elst[d1.seq].s_mrn,3
     )),
   unit = substring(1,10,trim(gastro->elst[d1.seq].s_unit,3)), field1 = substring(1,100,trim(gastro->
     elst[d1.seq].field1,3)), field2 = substring(1,100,trim(gastro->elst[d1.seq].field2_dt,3)),
   field3 = substring(1,100,trim(gastro->elst[d1.seq].field3_dt,3)), field4 = substring(1,100,trim(
     gastro->elst[d1.seq].field4_dt,3)), field5 = substring(1,100,trim(gastro->elst[d1.seq].field5,3)
    ),
   field6 = substring(1,100,trim(gastro->elst[d1.seq].field6,3))
   FROM (dummyt d1  WITH seq = size(gastro->elst,5))
   PLAN (d1)
   ORDER BY unit, patient_lastname
   WITH nocounter, separator = " ", format,
    noheading, append
  ;end select
 ELSEIF (( $S_RANGE != "SCREEN"))
  IF (findstring("@",ms_emails)=0
   AND textlen(ms_emails) > 0)
   SET ms_error = "Recipient email is invalid."
   GO TO exit_script
  ENDIF
  SET gastro->header1 = "Gastric_Tube_Type"
  SET gastro->header2 = "Gastric_Tube_Insertion_Date"
  SET gastro->header3 = "Date/Time_Connector_Cleaned"
  SET gastro->header4 = "Date/Time_Connector_Irrigated"
  SET gastro->header5 = "Gastric_Tube_Unexpected_Event"
  SET gastro->header6 = "Gastric_Tube_Unexpected_Event_Follow-up"
  SET frec->file_name = ms_output_file
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"MRN",','"FIN",','"UNIT",','"',
   trim(gastro->header1,3),'","',trim(gastro->header2,3),'","',trim(gastro->header3,3),
   '","',trim(gastro->header4,3),'","',trim(gastro->header5,3),'","',
   trim(gastro->header6,3),'"',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO size(gastro->elst,5))
   SET frec->file_buf = build('"',trim(gastro->elst[ml_cnt].s_patient_lname,3),'","',trim(gastro->
     elst[ml_cnt].s_fin,3),'","',
    trim(gastro->elst[ml_cnt].s_mrn,3),'","',trim(gastro->elst[ml_cnt].s_unit,3),'","',trim(gastro->
     elst[ml_cnt].field1,3),
    '","',trim(gastro->elst[ml_cnt].field2_dt,3),'","',trim(gastro->elst[ml_cnt].field3_dt,3),'","',
    trim(gastro->elst[ml_cnt].field4_dt,3),'","',trim(gastro->elst[ml_cnt].field5,3),'","',trim(
     gastro->elst[ml_cnt].field6,3),
    '"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  SET ms_subject = build2("Gastric Tube Connector Care Report ",trim(format(cnvtdatetime(
      ms_start_date),"mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),
     "mmm-dd-yyyy hh:mm;;d"),3))
  CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
 ENDIF
#exit_script
 FREE RECORD frec
 IF (textlen(trim( $S_EMAILS,3)) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
 ENDIF
END GO
