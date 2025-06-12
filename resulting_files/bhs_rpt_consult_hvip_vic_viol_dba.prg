CREATE PROGRAM bhs_rpt_consult_hvip_vic_viol:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 673936.00,
  "Unit" = value(0.0),
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Enter Emails" = "",
  "Date Range" = ""
  WITH outdev, f_fname, f_unit,
  s_start_date, s_end_date, s_emails,
  s_range
 DECLARE mf_cs6004_discontinued = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED")),
 protect
 DECLARE mf_cs6004_ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE mf_cs6004_inprocess = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS")),
 protect
 DECLARE mf_cs6004_completed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED")),
 protect
 DECLARE mf_cs100106_other = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100106,"OTHER")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE ms_start_date = vc WITH protect
 DECLARE ms_end_date = vc WITH protect
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_subject = vc WITH protect, noconstant("              ")
 DECLARE ml1_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_filename = vc WITH noconstant("bhs_hvip_orders"), protect
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
 FREE RECORD orders
 RECORD orders(
   1 l_cnt_ord = i4
   1 header1 = vc
   1 header2 = vc
   1 header3 = vc
   1 header4 = vc
   1 header5 = vc
   1 header6 = vc
   1 list[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_mrn = vc
     2 s_fin = vc
     2 s_patient_lname = vc
     2 s_patient_fname = vc
     2 s_location = vc
     2 s_date_ordered = vc
     2 s_admit_date = vc
     2 s_facility = vc
     2 s_unit = vc
     2 detail1 = vc
     2 detail2 = vc
     2 detail3 = vc
 ) WITH protect
 FREE RECORD grec
 RECORD grec(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),0)))
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
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0700)),"D","B",
    "B"),"DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0700),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("0,D",cnvtdatetime(curdate,0700)),"D","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),0700),";;Q")
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
 ELSEIF (cnvtupper(trim( $S_RANGE,3)) IN ("SCREEN", "ADHOC"))
  SET ms_start_date = format(cnvtdatetime(cnvtdate2( $S_START_DATE,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2( $S_END_DATE,"DD-MMM-YYYY"),235959),";;Q")
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
 ELSEIF (datetimediff(cnvtdatetime(ms_end_date),cnvtdatetime(ms_start_date)) > 93)
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
 ELSE
  SELECT INTO "nl:"
   facility = uar_get_code_display(e.loc_facility_cd), unit = uar_get_code_display(e
    .loc_nurse_unit_cd)
   FROM orders o,
    order_detail od,
    order_entry_fields oef,
    encounter e,
    encntr_alias mrn,
    encntr_alias fin,
    person p,
    dummyt d1
   PLAN (o
    WHERE o.catalog_cd=value(uar_get_code_by("DISPLAYKEY",200,"CONSULTHVIPVICTIMSOFVIOLENCE"))
     AND o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
     AND o.order_status_cd IN (mf_cs6004_discontinued, mf_cs6004_ordered, mf_cs6004_inprocess,
    mf_cs6004_completed))
    JOIN (e
    WHERE (e.loc_facility_cd= $F_FNAME)
     AND operator(e.loc_nurse_unit_cd,ms_opr_var1, $F_UNIT)
     AND e.active_ind=1
     AND e.active_status_cd=mf_cs48_active
     AND e.encntr_id=o.encntr_id
     AND e.person_id=o.person_id)
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
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.active_ind=1)
    JOIN (d1)
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.action_sequence IN (
    (SELECT
     max(action_sequence)
     FROM order_detail od1
     WHERE od1.order_id=od.order_id
      AND od1.oe_field_id=od.oe_field_id)))
    JOIN (oef
    WHERE oef.oe_field_id=od.oe_field_id
     AND cnvtupper(oef.description) IN ("MECHANISM OF INJURY", "HVIP PATIENT CONDITION",
    "OTHER MECHANISM OF INJURY:"))
   ORDER BY facility, unit, p.name_last,
    p.name_first, o.order_id, oef.description
   HEAD REPORT
    stat = alterlist(orders->list,10)
   HEAD o.order_id
    orders->l_cnt_ord += 1
    IF (mod(orders->l_cnt_ord,10)=1
     AND (orders->l_cnt_ord > 1))
     stat = alterlist(orders->list,(orders->l_cnt_ord+ 9))
    ENDIF
   DETAIL
    orders->list[orders->l_cnt_ord].s_patient_fname = trim(p.name_full_formatted,3), orders->list[
    orders->l_cnt_ord].s_facility = uar_get_code_display(e.loc_facility_cd), orders->list[orders->
    l_cnt_ord].s_unit = uar_get_code_display(e.loc_nurse_unit_cd),
    orders->list[orders->l_cnt_ord].s_mrn = trim(mrn.alias,3), orders->list[orders->l_cnt_ord].s_fin
     = trim(fin.alias,3), orders->list[orders->l_cnt_ord].s_admit_date = format(e.reg_dt_tm,
     "mm/dd/yyyy hh:mm;;d"),
    orders->list[orders->l_cnt_ord].s_date_ordered = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;D")
    IF (cnvtupper(oef.description)="MECHANISM OF INJURY")
     orders->list[orders->l_cnt_ord].detail1 = trim(od.oe_field_display_value,3)
    ENDIF
    IF (cnvtupper(oef.description)="OTHER MECHANISM OF INJURY:")
     orders->list[orders->l_cnt_ord].detail2 = trim(od.oe_field_display_value,3)
    ENDIF
    IF (cnvtupper(oef.description)="HVIP PATIENT CONDITION")
     orders->list[orders->l_cnt_ord].detail3 = trim(od.oe_field_display_value,3)
    ENDIF
   FOOT REPORT
    stat = alterlist(orders->list,orders->l_cnt_ord)
   WITH nocounter, outerjoin = d1
  ;end select
  IF (( $S_RANGE="SCREEN"))
   SELECT INTO  $OUTDEV
    facility = substring(1,30,orders->list[d1.seq].s_facility), patient_name = substring(1,30,orders
     ->list[d1.seq].s_patient_fname), unit = substring(1,30,orders->list[d1.seq].s_unit),
    mrn = substring(1,30,orders->list[d1.seq].s_mrn), fin = substring(1,30,orders->list[d1.seq].s_fin
     ), admit_date = substring(1,30,orders->list[d1.seq].s_admit_date),
    date_ordered = substring(1,30,orders->list[d1.seq].s_date_ordered), mechanism_of_injury =
    substring(1,30,orders->list[d1.seq].detail1), other_mechanism_of_injury = substring(1,30,orders->
     list[d1.seq].detail2),
    patient_condition = substring(1,30,orders->list[d1.seq].detail3)
    FROM (dummyt d1  WITH seq = size(orders->list,5))
    PLAN (d1)
    WITH nocounter, format, separator = " "
   ;end select
  ELSEIF (( $S_RANGE != "SCREEN"))
   SET frec->file_name = ms_output_file
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"Facility",','"Patient Name",','"Unit",','"MRN",','"Account Number",',
    '"Admit Date",','"Date Ordered ",','"Mechanism of Injury",','"Other Mechanism of Injury",',
    '"Patient Condition",',
    char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml1_cnt = 1 TO size(orders->list,5))
    SET frec->file_buf = build('"',trim(orders->list[ml1_cnt].s_facility,3),'","',trim(orders->list[
      ml1_cnt].s_patient_fname,3),'","',
     trim(orders->list[ml1_cnt].s_unit,3),'","',trim(orders->list[ml1_cnt].s_mrn,3),'","',trim(orders
      ->list[ml1_cnt].s_fin,3),
     '","',trim(orders->list[ml1_cnt].s_admit_date,3),'","',trim(orders->list[ml1_cnt].s_date_ordered,
      3),'","',
     trim(orders->list[ml1_cnt].detail1,3),'","',trim(orders->list[ml1_cnt].detail2,3),'","',trim(
      orders->list[ml1_cnt].detail3,3),
     '"',char(13))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   IF (textlen(trim( $S_EMAILS,3)) > 1
    AND textlen(trim(ms_error,3))=0)
    EXECUTE bhs_ma_email_file
    SET ms_subject = build2("HVIP Consult Orders Report ",trim(format(cnvtdatetime(ms_start_date),
       "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),
       "mmm-dd-yyyy hh:mm;;d"),3))
    CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
    SELECT INTO  $OUTDEV
     FROM dummyt d
     HEAD REPORT
      msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
      CALL print(calcpos(36,18)),
      msg1, row + 2, msg2
     WITH dio = 08
    ;end select
   ENDIF
  ENDIF
 ENDIF
 FREE RECORD frec
#exit_script
END GO
