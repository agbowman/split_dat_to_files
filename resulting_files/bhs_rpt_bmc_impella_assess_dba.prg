CREATE PROGRAM bhs_rpt_bmc_impella_assess:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 673936.00,
  "Unit" = 473916449.00,
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Email Operations" = 0,
  "Enter Emails" = ""
  WITH outdev, fname, f_unit,
  s_start_date, s_end_date, f_email_ops,
  s_emails
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cd72_impellaperformancelevel = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "IMPELLAPERFORMANCELEVEL")), protect
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
 DECLARE ms_filename = vc WITH noconstant(concat("bhs_impella_data_")), protect
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),format(sysdate,"MMDDYYYY;;q"),
   ".csv")), protect
 IF (( $F_EMAIL_OPS=1))
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ENDIF
 CALL echo(build("ms_start_date = ",ms_start_date,"ms_end_date = ",ms_end_date))
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD impella
 RECORD impella(
   1 l_ecnt = i4
   1 elst[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_mrn = vc
     2 s_patient_name = vc
     2 s_location = vc
     2 l_chtd = i4
     2 chartd[*]
       3 s_impellaperformancelevel = vc
       3 s_date_charted = vc
 ) WITH protect
 SELECT DISTINCT INTO "nl:"
  facility = uar_get_code_display(e.loc_facility_cd), ce.encntr_id, date_charted = format(ce
   .event_end_dt_tm,"YYYYMMDD;;Q")
  FROM clinical_event ce,
   encounter e,
   encntr_alias mrn,
   ce_date_result cdr,
   person p
  PLAN (ce
   WHERE ce.event_cd IN (mf_cd72_impellaperformancelevel)
    AND ce.view_level=1
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active)
   )
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.person_id=ce.person_id
    AND (e.loc_nurse_unit_cd= $F_UNIT)
    AND e.active_ind=1
    AND e.active_status_cd=mf_cs48_active)
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.active_status_cd=mf_cs48_active
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND mrn.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND mrn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND mrn.active_ind=1)
   JOIN (cdr
   WHERE (cdr.event_id= Outerjoin(ce.event_id)) )
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  ORDER BY ce.encntr_id, date_charted
  HEAD REPORT
   stat = alterlist(impella->elst,10)
  HEAD ce.encntr_id
   impella->l_ecnt += 1
   IF (mod(impella->l_ecnt,10)=1
    AND (impella->l_ecnt > 1))
    stat = alterlist(impella->elst,(impella->l_ecnt+ 9))
   ENDIF
   impella->elst[impella->l_ecnt].s_patient_name = trim(p.name_full_formatted,3), impella->elst[
   impella->l_ecnt].s_mrn = trim(mrn.alias,3), impella->elst[impella->l_ecnt].f_encntr_id = ce
   .encntr_id,
   impella->elst[impella->l_ecnt].f_person_id = ce.person_id, stat = alterlist(impella->elst[impella
    ->l_ecnt].chartd,10)
  HEAD date_charted
   impella->elst[impella->l_ecnt].l_chtd += 1
   IF (mod(impella->elst[impella->l_ecnt].l_chtd,10)=1
    AND (impella->elst[impella->l_ecnt].l_chtd > 1))
    stat = alterlist(impella->elst[impella->l_ecnt].chartd,(impella->elst[impella->l_ecnt].l_chtd+ 9)
     )
   ENDIF
   impella->elst[impella->l_ecnt].chartd[impella->elst[impella->l_ecnt].l_chtd].s_date_charted =
   format(ce.event_end_dt_tm,"@SHORTDATE4YR")
  FOOT  ce.encntr_id
   stat = alterlist(impella->elst[impella->l_ecnt].chartd,impella->elst[impella->l_ecnt].l_chtd)
  FOOT REPORT
   stat = alterlist(impella->elst,impella->l_ecnt)
  WITH nocounter
 ;end select
 IF (( $F_EMAIL_OPS=0))
  SELECT INTO  $OUTDEV
   patient_name = substring(1,100,impella->elst[d1.seq].s_patient_name), mrn = substring(1,20,impella
    ->elst[d1.seq].s_mrn), impella_performance_level_date_charted = substring(1,30,impella->elst[d1
    .seq].chartd[d2.seq].s_date_charted)
   FROM (dummyt d1  WITH seq = size(impella->elst,5)),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(impella->elst[d1.seq].chartd,5)))
    JOIN (d2)
   ORDER BY patient_name
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (( $F_EMAIL_OPS=1))
  SET frec->file_name = ms_output_file
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"MRN",','"Impella Performance Level Date Charted",',
   char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO size(impella->elst,5))
    FOR (ml_cnt2 = 1 TO size(impella->elst[ml_cnt].chartd,5))
     SET frec->file_buf = build('"',trim(impella->elst[ml_cnt].s_patient_name,3),'","',trim(impella->
       elst[ml_cnt].s_mrn,3),'","',
      trim(impella->elst[ml_cnt].chartd[ml_cnt2].s_date_charted,3),'"',char(13))
     SET stat = cclio("WRITE",frec)
    ENDFOR
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  SET ms_subject = build2("HVCC Impella Report ",trim(format(cnvtdatetime(ms_start_date),
     "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),"mmm-dd-yyyy hh:mm;;d"),
    3))
  CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
 ENDIF
END GO
