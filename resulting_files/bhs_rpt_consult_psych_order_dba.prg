CREATE PROGRAM bhs_rpt_consult_psych_order:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 0,
  "Unit" = value(0.0),
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Enter Emails" = "",
  "Date Range" = ""
  WITH outdev, f_fname, f_unit,
  s_start_date, s_end_date, s_emails,
  s_range
 DECLARE mf_cs6004_deleted = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED")), protect
 DECLARE mf_cs200_addictionconsultbfmc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ADDICTIONCONSULTBFMC")), protect
 DECLARE mf_cs200_addictionconsult = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ADDICTIONCONSULT")), protect
 DECLARE mf_cs4038_usermanualdc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4038,"USERMANUALDC")),
 protect
 DECLARE ms_cs200_psychconsultchild = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "PSYCHCONSULTCHILD")), protect
 DECLARE ms_cs200_psychconsultadult = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "PSYCHCONSULTADULT")), protect
 DECLARE mf_cs6004_discontinued = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED")),
 protect
 DECLARE mf_cs6004_ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE mf_cs72_consultation_note = f8 WITH constant(150226293.00), protect
 DECLARE mf_cs6004_inprocess = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS")),
 protect
 DECLARE mf_cs6004_completed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED")),
 protect
 DECLARE mf_cs100106_other = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100106,"OTHER")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mf_cs6003_complete = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"COMPLETE")),
 protect
 DECLARE ms_start_date = vc WITH protect
 DECLARE ms_end_date = vc WITH protect
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_subject = vc WITH protect, noconstant("              ")
 DECLARE ml1_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_filename = vc WITH noconstant("pscyh_consult_orders"), protect
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),"_",trim(cnvtlower( $S_RANGE),
    3),"_",format(sysdate,"MMDDYYYY;;q"),
   ".csv")), protect
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
     2 s_age = vc
     2 s_dob = vc
     2 s_sex = vc
     2 s_patient_lname = vc
     2 s_patient_lname = vc
     2 s_patient_fname = vc
     2 s_location = vc
     2 s_date_ordered = vc
     2 s_order_name = vc
     2 f_order_code = f8
     2 s_order_status = vc
     2 d_date_ordered = f8
     2 s_admit_date = vc
     2 s_consultant = vc
     2 s_facility = vc
     2 s_unit = vc
     2 s_detail1 = vc
     2 s_detail2 = vc
     2 s_note_title = vc
     2 s_reg_date = vc
     2 s_note_date = vc
     2 d_note_date = f8
     2 d_duedate = f8
     2 s_ontime = vc
     2 s_discontinue_type = vc
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
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0000)),"D","B",
    "B"),"DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0000),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,235959)),"D","E",
    "E"),"DD-MMM-YYYY;;D")
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
 ELSEIF (datetimediff(cnvtdatetime(ms_end_date),cnvtdatetime(ms_start_date)) > 9300000)
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
    WHERE o.catalog_cd=value(ms_cs200_psychconsultchild,ms_cs200_psychconsultadult)
     AND o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date))
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
     AND cnvtupper(oef.description) IN ("REASON FOR EXAM", "LEVEL OF CONSULT"))
   ORDER BY facility, unit, p.name_last,
    p.name_first, o.person_id, o.encntr_id,
    o.order_id, oef.description
   HEAD REPORT
    stat = alterlist(orders->list,10)
   HEAD o.order_id
    orders->l_cnt_ord += 1
    IF (mod(orders->l_cnt_ord,10)=1
     AND (orders->l_cnt_ord > 1))
     stat = alterlist(orders->list,(orders->l_cnt_ord+ 9))
    ENDIF
   DETAIL
    orders->list[orders->l_cnt_ord].f_encntr_id = e.encntr_id, orders->list[orders->l_cnt_ord].
    f_person_id = e.person_id, orders->list[orders->l_cnt_ord].s_mrn = trim(mrn.alias,3),
    orders->list[orders->l_cnt_ord].s_fin = trim(fin.alias,3), orders->list[orders->l_cnt_ord].s_age
     = trim(cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)),3), orders->list[
    orders->l_cnt_ord].s_order_name = trim(o.ordered_as_mnemonic,3),
    orders->list[orders->l_cnt_ord].f_order_code = o.catalog_cd, orders->list[orders->l_cnt_ord].
    s_sex = uar_get_code_display(p.sex_cd), orders->list[orders->l_cnt_ord].s_discontinue_type =
    uar_get_code_display(o.discontinue_type_cd),
    orders->list[orders->l_cnt_ord].s_dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
       .birth_tz),1),"@SHORTDATE4YR"), orders->list[orders->l_cnt_ord].s_patient_fname = trim(p
     .name_full_formatted,3), orders->list[orders->l_cnt_ord].s_facility = uar_get_code_display(e
     .loc_facility_cd),
    orders->list[orders->l_cnt_ord].s_order_status = uar_get_code_display(o.order_status_cd), orders
    ->list[orders->l_cnt_ord].s_unit = uar_get_code_display(e.loc_nurse_unit_cd), orders->list[orders
    ->l_cnt_ord].s_location = concat(trim(uar_get_code_display(e.loc_facility_cd),3),"-",trim(
      uar_get_code_display(e.loc_nurse_unit_cd),3)),
    orders->list[orders->l_cnt_ord].s_fin = trim(fin.alias,3), orders->list[orders->l_cnt_ord].
    s_admit_date = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"), orders->list[orders->l_cnt_ord].
    s_date_ordered = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;D")
    IF (cnvtupper(oef.description)="REASON FOR EXAM")
     orders->list[orders->l_cnt_ord].s_detail1 = trim(od.oe_field_display_value,3)
    ENDIF
    IF (cnvtupper(oef.description)="LEVEL OF CONSULT")
     orders->list[orders->l_cnt_ord].s_detail2 = trim(od.oe_field_display_value,3)
    ENDIF
    IF (o.orig_order_dt_tm <= cnvtdatetime(cnvtdate(o.orig_order_dt_tm),120000))
     orders->list[orders->l_cnt_ord].d_duedate = cnvtdatetime((cnvtdate(o.orig_order_dt_tm)+ 1),
      000000)
    ELSE
     orders->list[orders->l_cnt_ord].d_duedate = datetimeadd(o.orig_order_dt_tm,1,0)
    ENDIF
    IF ( NOT (o.order_status_cd IN (mf_cs6004_ordered, mf_cs6004_inprocess, mf_cs6004_completed))
     AND ((o.order_status_cd=mf_cs6004_discontinued
     AND o.discontinue_type_cd=mf_cs4038_usermanualdc) OR (o.order_status_cd=mf_cs6004_deleted)) )
     orders->list[orders->l_cnt_ord].s_ontime = "Discontinued/Canceled"
    ENDIF
   FOOT REPORT
    stat = alterlist(orders->list,orders->l_cnt_ord)
   WITH nocounter, outerjoin = d1
  ;end select
  SELECT INTO "nl:"
   list_f_person_id = orders->list[d1.seq].f_person_id, list_f_encntr_id = orders->list[d1.seq].
   f_encntr_id
   FROM (dummyt d1  WITH seq = size(orders->list,5)),
    clinical_event ce,
    prsnl p
   PLAN (d1)
    JOIN (ce
    WHERE (ce.encntr_id=orders->list[d1.seq].f_encntr_id)
     AND (ce.person_id=orders->list[d1.seq].f_person_id)
     AND ce.encntr_id > 0
     AND ce.event_cd=mf_cs72_consultation_note
     AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd, mf_cs8_active
    )
     AND ce.valid_until_dt_tm > sysdate
     AND ce.view_level=1
     AND  NOT ((orders->list[d1.seq].f_order_code IN (mf_cs200_addictionconsult,
    mf_cs200_addictionconsultbfmc)))
     AND cnvtupper(ce.event_title_text)="*PSYCH*")
    JOIN (p
    WHERE p.person_id=ce.performed_prsnl_id)
   ORDER BY d1.seq, ce.event_end_dt_tm
   HEAD d1.seq
    orders->list[d1.seq].s_note_date = format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"), orders->
    list[d1.seq].s_note_title = trim(ce.event_title_text,3), orders->list[d1.seq].s_consultant = trim
    (p.name_full_formatted,3)
    IF (ce.event_end_dt_tm <= cnvtdatetime(orders->list[d1.seq].d_duedate)
     AND ce.event_end_dt_tm != null)
     orders->list[d1.seq].s_ontime = "Y"
    ELSE
     orders->list[d1.seq].s_ontime = "N"
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = size(orders->list,5))
   PLAN (d1
    WHERE (orders->list[d1.seq].s_ontime=null))
   HEAD d1.seq
    IF (cnvtdatetime(sysdate) < cnvtdatetime(orders->list[d1.seq].d_duedate))
     orders->list[d1.seq].s_ontime = "Not Due"
    ELSE
     orders->list[d1.seq].s_ontime = "N"
    ENDIF
   WITH nocounter, separator = " ", format
  ;end select
  IF (( $S_RANGE="SCREEN"))
   SELECT INTO  $OUTDEV
    admit_date = substring(1,30,orders->list[d1.seq].s_admit_date), patient_name = substring(1,30,
     orders->list[d1.seq].s_patient_fname), mrn = substring(1,30,orders->list[d1.seq].s_mrn),
    acct = substring(1,30,orders->list[d1.seq].s_fin), location = substring(1,30,orders->list[d1.seq]
     .s_location), dob = substring(1,30,orders->list[d1.seq].s_dob),
    age = substring(1,30,orders->list[d1.seq].s_age), type_of_consult = substring(1,50,orders->list[
     d1.seq].s_order_name), reason_for_consult = substring(1,200,orders->list[d1.seq].s_detail1),
    date_ordered = substring(1,30,orders->list[d1.seq].s_date_ordered), date_consult_complete =
    substring(1,40,orders->list[d1.seq].s_note_date), access_metric = substring(1,30,orders->list[d1
     .seq].s_ontime),
    note_type = substring(1,100,orders->list[d1.seq].s_note_title), consultant = substring(1,100,
     orders->list[d1.seq].s_consultant)
    FROM (dummyt d1  WITH seq = size(orders->list,5))
    PLAN (d1)
    WITH nocounter, format, separator = " "
   ;end select
  ELSEIF (( $S_RANGE != "SCREEN"))
   SET frec->file_name = ms_output_file
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"Admit Date",','"Patient Name",','"MRN",','"Acct",','"Location",',
    '"DOB",','"Age",','"Type of Consult Ordered",','"Reason for Consult",',
    '"Date time-consult ordered",',
    '"Date time-consult completed",','"Access Metric",','"Note Type",','"Consultant",',char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml1_cnt = 1 TO size(orders->list,5))
    SET frec->file_buf = build('"',trim(orders->list[ml1_cnt].s_admit_date,3),'","',trim(orders->
      list[ml1_cnt].s_patient_fname,3),'","',
     trim(orders->list[ml1_cnt].s_mrn,3),'","',trim(orders->list[ml1_cnt].s_fin,3),'","',trim(orders
      ->list[ml1_cnt].s_location,3),
     '","',trim(orders->list[ml1_cnt].s_dob,3),'","',trim(orders->list[ml1_cnt].s_age,3),'","',
     trim(orders->list[ml1_cnt].s_order_name,3),'","',trim(orders->list[ml1_cnt].s_detail1,3),'","',
     trim(orders->list[ml1_cnt].s_date_ordered,3),
     '","',trim(orders->list[ml1_cnt].s_note_date,3),'","',trim(orders->list[ml1_cnt].s_ontime,3),
     '","',
     trim(orders->list[ml1_cnt].s_note_title,3),'","',trim(orders->list[ml1_cnt].s_consultant,3),'"',
     char(13))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   IF (textlen(trim( $S_EMAILS,3)) > 1
    AND textlen(trim(ms_error,3))=0)
    EXECUTE bhs_ma_email_file
    SET ms_subject = build2("Psych Consult Orders Report ",trim(format(cnvtdatetime(ms_start_date),
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
