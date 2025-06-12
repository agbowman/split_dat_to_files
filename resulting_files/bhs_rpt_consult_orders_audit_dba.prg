CREATE PROGRAM bhs_rpt_consult_orders_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = value(673936.00),
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Report Name" = 0,
  "Select Orders" = 0,
  "Select Output" = "",
  "Create Files" = 0,
  "Date Range" = "",
  "Enter Email" = ""
  WITH outdev, f_facility, s_start_date,
  s_end_date, s_rpt_name, f_orders,
  output_type, s_create_files, s_range,
  s_emails
 EXECUTE bhs_check_domain
 DECLARE mf_neuro_type = f8 WITH noconstant(0), protect
 DECLARE ml_ordcnt = i4 WITH noconstant(0), protect
 DECLARE mf_cs6000_consults = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"CONSULTS")),
 protect
 DECLARE mf_cs200_consultneurologyadult = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTNEUROLOGYADULT")), protect
 DECLARE md_start_date = dq8 WITH protect
 DECLARE md_end_date = dq8 WITH protect
 DECLARE ms_start_date = vc WITH protect
 DECLARE ms_end_date = vc WITH protect
 DECLARE ms_year = vc WITH protect
 DECLARE ms_day = i4 WITH protect
 DECLARE ms_name_fac = vc WITH protect
 DECLARE ms_month = i4 WITH protect
 DECLARE d_prt = i4 WITH protect
 DECLARE ms_time = vc WITH protect
 DECLARE ms_var_out_consult = vc WITH noconstant( $OUTDEV), protect
 DECLARE ms_fileprefix = vc WITH noconstant("consulting_orders"), protect
 DECLARE mf_per_ontime = vc WITH protect
 DECLARE mf_per_disch = vc WITH protect
 DECLARE mf_per_due = vc WITH protect
 DECLARE mf_per_notdone = vc WITH protect
 DECLARE mf_per_inprogress = vc WITH protect
 DECLARE mf_page_size = f8 WITH noconstant(0), protect
 DECLARE mf_remain_space = f8 WITH noconstant(0), protect
 DECLARE mi_ord = i4 WITH noconstant(0), protect
 DECLARE ml_loop1 = i4 WITH noconstant(0), protect
 DECLARE ml_loop2 = i4 WITH noconstant(0), protect
 DECLARE ms_name_id = vc WITH noconstant(" "), protect
 DECLARE ms_report_name = vc WITH noconstant("Selected Consult Orders Report"), protect
 DECLARE ms_report_orders = vc WITH noconstant(" "), protect
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_subject = vc WITH protect, noconstant("              ")
 DECLARE mi_valid_email = i4 WITH noconstant(1), protect
 DECLARE mf_cs6003_complete = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"COMPLETE")),
 protect
 DECLARE mf_cs6003_order = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER")), protect
 DECLARE mf_cs4038_systemdcondischarge = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4038,
   "SYSTEMDCONDISCHARGE")), protect
 DECLARE mf_cs_6004_discontinued = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED")
  ), protect
 DECLARE mf_cs_6004_completed = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED")),
 protect
 DECLARE mf_cs_6004_ordered = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs100060_general = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100060,"GENERAL")),
 protect
 DECLARE mf_cs100060_seizureepilepsy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100060,
   "SEIZUREEPILEPSY")), protect
 DECLARE mf_cs100060_stroketia = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100060,"STROKETIA")),
 protect
 DECLARE mf_cs200_consultrehabmed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTREHABILITATIONMEDICINE")), protect
 DECLARE mf_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",15750,"ACTIVE")), protect
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_opr_var = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 FREE RECORD consult
 RECORD consult(
   1 total_done_24hrs = i4
   1 print_requested_by = vc
   1 date_range = vc
   1 total_orders = i4
   1 total_comp = i4
   1 on_time1 = i4
   1 per_on_time1 = vc
   1 per_on_time2 = vc
   1 not_on_time1 = i4
   1 on_time2 = i4
   1 not_on_time2 = i4
   1 cnt_p = i4
   1 discharge_before = i4
   1 prsnl[*]
     2 total_orders = i4
     2 total_comp = i4
     2 toton_time1 = i4
     2 toton_time2 = i4
     2 per_on_time1 = vc
     2 per_on_time2 = vc
     2 totnot_on_time1 = i4
     2 totnot_on_time2 = i4
     2 completed_name = vc
     2 consult_order[*]
       3 encntr_id = f8
       3 order_id = f8
       3 order_status = vc
       3 order_name = vc
       3 encntr_type = vc
       3 comp_prsnl_id = f8
       3 fin = vc
       3 completed_dt_tm = dq8
       3 order_dtttm = dq8
       3 order_status_dt_tm = dq8
       3 due_date1 = dq8
       3 due_date2 = dq8
       3 before_4pm = vc
       3 before_12pm = vc
       3 pat_reg_dttm = dq8
       3 pat_disch_dttm = dq8
       3 done_on_time1 = vc
       3 done_on_time2 = vc
       3 discharge_b4_due1 = vc
       3 discharge_b4_due2 = vc
       3 status = vc
 )
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD grec
 RECORD grec(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_FACILITY),0)))
 SET ml_gcnt = 0
 IF (ms_lcheck="L")
  SET ms_opr_var = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_FACILITY),ml_gcnt)))
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec->list,(ml_gcnt+ 4))
     ENDIF
     SET grec->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_FACILITY),ml_gcnt))
     SET grec->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_FACILITY),ml_gcnt
       ))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec->list,1)
  SET ml_gcnt = 1
  SET grec->list[1].f_cv =  $F_FACILITY
  IF ((grec->list[1].f_cv=0.0))
   SET grec->list[1].s_disp = "All Facilities"
   SET ms_opr_var = "!="
  ELSE
   SET grec->list[1].s_disp = uar_get_code_display(grec->list[1].f_cv)
   SET ms_opr_var = "="
  ENDIF
 ENDIF
 FREE RECORD grec1
 RECORD grec1(
   1 list[*]
     2 f_cv = f8
     2 s_disp = vc
 )
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_ORDERS),0)))
 SET ml_gcnt = 0
 IF (ms_lcheck="L")
  SET ms_opr_var1 = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_ORDERS),ml_gcnt)))
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gcnt+ 4))
     ENDIF
     SET grec1->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_ORDERS),ml_gcnt))
     SET grec1->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_ORDERS),ml_gcnt)
      )
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec1->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gcnt = 1
  SET grec1->list[1].f_cv =  $F_ORDERS
  IF ((grec1->list[1].f_cv=0.0))
   SET grec1->list[1].s_disp = "All Orders"
   SET ms_opr_var1 = "!="
  ELSE
   SET grec1->list[1].s_disp = uar_get_code_display(grec1->list[1].f_cv)
   SET ms_opr_var1 = "="
  ENDIF
 ENDIF
 IF (findstring("@", $S_EMAILS)=0
  AND textlen( $S_EMAILS) > 0)
  SET ms_error = "Recipient email is invalid."
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
  SET mi_valid_email = 0
 ENDIF
 EXECUTE bhs_ma_email_file
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  ORDER BY p.person_id
  HEAD p.person_id
   consult->print_requested_by = concat(trim(p.name_first,3)," ",trim(p.name_last,3))
  FOOT  p.person_id
   null
  WITH nocounter
 ;end select
 CALL echo(build("$s_rpt_name = ", $S_RPT_NAME))
 IF (( $S_RPT_NAME=7))
  SET ms_report_name = "Neurology Consult Report"
 ELSEIF (( $S_RPT_NAME=2))
  SET ms_report_name = "Behavioral Health Consult Report"
 ELSEIF (( $S_RPT_NAME=6))
  SET ms_report_name = "Infectious Disease Consult Report"
 ELSEIF (( $S_RPT_NAME=3))
  SET ms_report_name = "Women Health Consult Report"
 ELSEIF (( $S_RPT_NAME=4))
  SET ms_report_name = "PM&R Consult Report"
 ELSEIF (( $S_RPT_NAME=8))
  SET ms_report_name = "Neurology Stroke Consult Report"
 ELSEIF (( $S_RPT_NAME=9))
  SET ms_report_name = "Neurology General Consult Report"
 ELSEIF (( $S_RPT_NAME=10))
  SET ms_report_name = "Neurology Seizure/Epilepsy Consult Report"
 ELSEIF (( $S_RPT_NAME=5))
  SET ms_report_name = "Heart and Vascular Consult Report"
 ENDIF
 CALL echo(build("$ms_report_name = ",ms_report_name))
 IF (( $S_CREATE_FILES=1))
  SET ms_year = substring(3,2,build(year(cnvtdatetime(sysdate))))
  SET ms_day = day(curdate)
  SET ms_month = month(curdate)
  SET ms_time = format(curtime,"HHMMSS;;M")
  IF (( $S_RPT_NAME=7))
   SET ms_fileprefix = "neuro_consult"
  ELSEIF (( $S_RPT_NAME=2))
   SET ms_fileprefix = "behavioral_consult"
  ELSEIF (( $S_RPT_NAME=6))
   SET ms_fileprefix = "infections_consult"
  ELSEIF (( $S_RPT_NAME=3))
   SET ms_fileprefix = "womens_health_consult"
  ELSEIF (( $S_RPT_NAME=4))
   SET ms_fileprefix = "pmr_consult"
  ELSEIF (( $S_RPT_NAME=8))
   SET ms_fileprefix = "neuro_stroke_consult"
  ELSEIF (( $S_RPT_NAME=9))
   SET ms_fileprefix = "neurogeneral_consult"
  ELSEIF (( $S_RPT_NAME=10))
   SET ms_fileprefix = "neuro_seizure_consult"
  ELSEIF (( $S_RPT_NAME=5))
   SET ms_fileprefix = "heart_vascular_consult"
  ENDIF
  IF (( $OUTPUT_TYPE="CSV"))
   SET ms_var_out_consult = build(ms_fileprefix,"_",cnvtlower( $S_RANGE),"_",ms_year,
    ms_month,ms_day,ms_time,".csv")
  ELSEIF (( $OUTPUT_TYPE != "CSV"))
   IF (( $OUTPUT_TYPE IN ("DETAIL", "DETSUM")))
    SET ms_fileprefix = concat(ms_fileprefix,"_det")
   ELSEIF (( $OUTPUT_TYPE IN ("SUMMARY")))
    SET ms_fileprefix = concat(ms_fileprefix,"_summ")
   ELSEIF (( $OUTPUT_TYPE="MDSUMMARY"))
    SET ms_fileprefix = concat(ms_fileprefix,"_mdsum")
   ELSEIF (( $OUTPUT_TYPE="MDSUMTOT"))
    SET ms_fileprefix = concat(ms_fileprefix,"_md_tot")
   ENDIF
   SET ms_var_out_consult = build(ms_fileprefix,"_",cnvtlower( $S_RANGE),"_",ms_year,
    ms_month,ms_day,ms_time,".pdf")
   CALL echo(build("ms_var_out_consult - ",ms_var_out_consult))
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
 ELSEIF (cnvtupper(trim( $S_RANGE,3)) IN ("ADHOC", "SCREEN"))
  SET ms_start_date = format(cnvtdatetime(cnvtdate2( $S_START_DATE,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2( $S_END_DATE,"DD-MMM-YYYY"),235959),";;Q")
 ENDIF
 SET consult->date_range = concat(trim(substring(1,11,ms_start_date),3),"...",substring(1,11,
   ms_end_date))
 SELECT INTO "nl:"
  oc_catalog_disp = uar_get_code_display(oc.catalog_cd), oc.catalog_cd
  FROM order_catalog oc
  WHERE oc.catalog_type_cd=mf_cs6000_consults
   AND operator(oc.catalog_cd,ms_opr_var1, $F_ORDERS)
   AND oc.active_ind=1
  ORDER BY oc_catalog_disp
  DETAIL
   ml_ordcnt += 1
   IF (ml_ordcnt=1)
    ms_report_orders = trim(uar_get_code_display(oc.catalog_cd),3)
   ELSEIF (ml_ordcnt > 1)
    ms_report_orders = concat(ms_report_orders,", ",trim(uar_get_code_display(oc.catalog_cd),3))
   ENDIF
  WITH nocounter, time = 60
 ;end select
 IF ( NOT (( $S_RPT_NAME IN (8, 9, 10))))
  SELECT INTO "nl:"
   ms_name_id = trim(build(p.name_last,p.name_first,p.person_id),3), o.encntr_id, o.orig_order_dt_tm
   FROM orders o,
    order_action oa,
    encounter e,
    encntr_alias fin,
    person p,
    prsnl pr
   PLAN (o
    WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
     AND operator(o.catalog_cd,ms_opr_var1, $F_ORDERS)
     AND o.person_id > 0
     AND o.order_status_cd IN (mf_cs_6004_completed, mf_cs_6004_ordered, mf_cs_6004_discontinued))
    JOIN (oa
    WHERE (oa.order_id= Outerjoin(o.order_id))
     AND (oa.action_type_cd= Outerjoin(mf_cs6003_complete)) )
    JOIN (pr
    WHERE (pr.person_id= Outerjoin(oa.action_personnel_id)) )
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND operator(e.loc_facility_cd,ms_opr_var, $F_FACILITY))
    JOIN (p
    WHERE p.person_id=o.person_id)
    JOIN (fin
    WHERE fin.encntr_id=o.encntr_id
     AND fin.active_status_cd=mf_cs48_active
     AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
     AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND fin.active_ind=1)
   ORDER BY pr.name_full_formatted, oa.action_personnel_id, o.order_id
   HEAD REPORT
    stat = alterlist(consult->prsnl,10)
   HEAD oa.action_personnel_id
    consult->cnt_p += 1
    IF (mod(consult->cnt_p,10)=1
     AND (consult->cnt_p > 1))
     stat = alterlist(consult->prsnl,(consult->cnt_p+ 9))
    ENDIF
    IF (oa.action_personnel_id != null)
     consult->prsnl[consult->cnt_p].completed_name = trim(pr.name_full_formatted,3)
    ELSE
     consult->prsnl[consult->cnt_p].completed_name = "Order Not Completed"
    ENDIF
    stat = alterlist(consult->prsnl[consult->cnt_p].consult_order,10)
   HEAD o.order_id
    mi_ord += 1
    IF (mod(mi_ord,10)=1
     AND mi_ord > 1)
     stat = alterlist(consult->prsnl[consult->cnt_p].consult_order,(mi_ord+ 9))
    ENDIF
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].fin = fin.alias, consult->prsnl[consult->
    cnt_p].consult_order[mi_ord].order_id = o.order_id, consult->prsnl[consult->cnt_p].consult_order[
    mi_ord].order_status = trim(uar_get_code_display(o.order_status_cd),3),
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].order_dtttm = o.orig_order_dt_tm, consult->
    prsnl[consult->cnt_p].consult_order[mi_ord].order_name = trim(uar_get_code_display(o.catalog_cd),
     3), consult->prsnl[consult->cnt_p].consult_order[mi_ord].encntr_type = trim(uar_get_code_display
     (e.encntr_type_cd),3),
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].before_12pm = "N"
    IF (o.orig_order_dt_tm < cnvtdatetime(cnvtdate(o.orig_order_dt_tm),120000))
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].due_date1 = cnvtdatetime((cnvtdate(o
       .orig_order_dt_tm)+ 1),000000), consult->prsnl[consult->cnt_p].consult_order[mi_ord].
     before_12pm = "Y"
    ELSE
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].due_date1 = cnvtdatetime((cnvtdate(o
       .orig_order_dt_tm)+ 2),000000)
    ENDIF
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].done_on_time1 = "Not Over Due"
    IF (oa.action_dt_tm <= cnvtdatetime(consult->prsnl[consult->cnt_p].consult_order[mi_ord].
     due_date1)
     AND oa.action_dt_tm != null)
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].done_on_time1 = "Y", consult->on_time1 += 1,
     consult->prsnl[consult->cnt_p].toton_time1 += 1
    ELSEIF (((oa.action_dt_tm > cnvtdatetime(consult->prsnl[consult->cnt_p].consult_order[mi_ord].
     due_date1)) OR (oa.action_dt_tm=null)) )
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].done_on_time1 = "N", consult->not_on_time1
      += 1, consult->prsnl[consult->cnt_p].totnot_on_time1 += 1
    ENDIF
    consult->prsnl[consult->cnt_p].total_orders += 1, consult->total_orders += 1
    IF (e.disch_dt_tm <= cnvtdatetime(consult->prsnl[consult->cnt_p].consult_order[mi_ord].due_date1)
     AND e.disch_dt_tm != null)
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].discharge_b4_due1 = "Y"
     IF (oa.action_personnel_id=null)
      consult->prsnl[consult->cnt_p].total_orders -= 1, consult->total_orders -= 1
     ENDIF
    ELSE
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].discharge_b4_due1 = "N"
    ENDIF
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].completed_dt_tm = oa.action_dt_tm, consult->
    prsnl[consult->cnt_p].consult_order[mi_ord].pat_disch_dttm = e.disch_dt_tm, consult->prsnl[
    consult->cnt_p].consult_order[mi_ord].pat_reg_dttm = e.reg_dt_tm,
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].status = uar_get_code_display(o
     .order_status_cd)
    IF (oa.action_personnel_id != null)
     consult->prsnl[consult->cnt_p].total_comp += 1, consult->total_comp += 1
    ENDIF
    consult->per_on_time1 = format(round(((cnvtreal(consult->on_time1)/ cnvtreal(consult->total_comp)
      ) * 100),2),"###.##;p0"), consult->prsnl[consult->cnt_p].per_on_time1 = format(round(((cnvtreal
      (consult->prsnl[consult->cnt_p].toton_time1)/ cnvtreal(consult->prsnl[consult->cnt_p].
       total_comp)) * 100),2),"###.##;p0")
   FOOT  oa.action_personnel_id
    stat = alterlist(consult->prsnl[consult->cnt_p].consult_order,mi_ord), mi_ord = 0
   FOOT REPORT
    stat = alterlist(consult->prsnl,consult->cnt_p)
   WITH nocounter
  ;end select
 ELSEIF (( $S_RPT_NAME IN (8, 9, 10)))
  IF (( $S_RPT_NAME=8))
   SET mf_neuro_type = mf_cs100060_stroketia
  ELSEIF (( $S_RPT_NAME=9))
   SET mf_neuro_type = mf_cs100060_general
  ELSEIF (( $S_RPT_NAME=10))
   SET mf_neuro_type = mf_cs100060_seizureepilepsy
  ENDIF
  SELECT INTO "nl:"
   ms_name_id = trim(build(p.name_last,p.name_first,p.person_id),3), o.encntr_id, o.orig_order_dt_tm
   FROM orders o,
    order_action oa,
    encounter e,
    encntr_alias fin,
    order_detail od,
    order_entry_fields oef,
    person p,
    prsnl pr
   PLAN (o
    WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
     AND operator(o.catalog_cd,ms_opr_var1, $F_ORDERS)
     AND o.person_id > 0
     AND o.order_status_cd IN (mf_cs_6004_completed, mf_cs_6004_ordered, mf_cs_6004_discontinued))
    JOIN (oa
    WHERE (oa.order_id= Outerjoin(o.order_id))
     AND (oa.action_type_cd= Outerjoin(mf_cs6003_complete)) )
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_value=mf_neuro_type
     AND od.action_sequence IN (
    (SELECT
     max(action_sequence)
     FROM order_detail od1
     WHERE od1.order_id=od.order_id
      AND od1.oe_field_id=od.oe_field_id)))
    JOIN (oef
    WHERE oef.oe_field_id=od.oe_field_id
     AND oef.description="Consult Type Neuro")
    JOIN (pr
    WHERE (pr.person_id= Outerjoin(oa.action_personnel_id)) )
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND operator(e.loc_facility_cd,ms_opr_var, $F_FACILITY))
    JOIN (p
    WHERE p.person_id=o.person_id)
    JOIN (fin
    WHERE fin.encntr_id=o.encntr_id
     AND fin.active_status_cd=mf_cs48_active
     AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
     AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND fin.active_ind=1)
   ORDER BY pr.name_full_formatted, oa.action_personnel_id, o.order_id
   HEAD REPORT
    stat = alterlist(consult->prsnl,10)
   HEAD oa.action_personnel_id
    consult->cnt_p += 1
    IF (mod(consult->cnt_p,10)=1
     AND (consult->cnt_p > 1))
     stat = alterlist(consult->prsnl,(consult->cnt_p+ 9))
    ENDIF
    IF (oa.action_personnel_id != null)
     consult->prsnl[consult->cnt_p].completed_name = trim(pr.name_full_formatted,3)
    ELSE
     consult->prsnl[consult->cnt_p].completed_name = "Order Not Completed"
    ENDIF
    stat = alterlist(consult->prsnl[consult->cnt_p].consult_order,10)
   HEAD o.order_id
    mi_ord += 1
    IF (mod(mi_ord,10)=1
     AND mi_ord > 1)
     stat = alterlist(consult->prsnl[consult->cnt_p].consult_order,(mi_ord+ 9))
    ENDIF
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].fin = fin.alias, consult->prsnl[consult->
    cnt_p].consult_order[mi_ord].order_id = o.order_id, consult->prsnl[consult->cnt_p].consult_order[
    mi_ord].order_status = trim(uar_get_code_display(o.order_status_cd),3),
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].order_dtttm = o.orig_order_dt_tm, consult->
    prsnl[consult->cnt_p].consult_order[mi_ord].order_name = concat(trim(uar_get_code_display(o
       .catalog_cd),3),", ",trim(uar_get_code_display(od.oe_field_value),3)), consult->prsnl[consult
    ->cnt_p].consult_order[mi_ord].encntr_type = trim(uar_get_code_display(e.encntr_type_cd),3),
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].before_12pm = "N"
    IF (o.orig_order_dt_tm < cnvtdatetime(cnvtdate(o.orig_order_dt_tm),120000))
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].due_date1 = cnvtdatetime((cnvtdate(o
       .orig_order_dt_tm)+ 1),000000), consult->prsnl[consult->cnt_p].consult_order[mi_ord].
     before_12pm = "Y"
    ELSE
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].due_date1 = cnvtdatetime((cnvtdate(o
       .orig_order_dt_tm)+ 2),000000)
    ENDIF
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].done_on_time1 = "Not Over Due"
    IF (oa.action_dt_tm <= cnvtdatetime(consult->prsnl[consult->cnt_p].consult_order[mi_ord].
     due_date1)
     AND oa.action_dt_tm != null)
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].done_on_time1 = "Y", consult->on_time1 += 1,
     consult->prsnl[consult->cnt_p].toton_time1 += 1
    ELSEIF (((oa.action_dt_tm > cnvtdatetime(consult->prsnl[consult->cnt_p].consult_order[mi_ord].
     due_date1)) OR (oa.action_dt_tm=null)) )
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].done_on_time1 = "N", consult->not_on_time1
      += 1, consult->prsnl[consult->cnt_p].totnot_on_time1 += 1
    ENDIF
    consult->prsnl[consult->cnt_p].total_orders += 1, consult->total_orders += 1
    IF (e.disch_dt_tm <= cnvtdatetime(consult->prsnl[consult->cnt_p].consult_order[mi_ord].due_date1)
     AND e.disch_dt_tm != null)
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].discharge_b4_due1 = "Y"
     IF (oa.action_personnel_id=null)
      consult->prsnl[consult->cnt_p].total_orders -= 1, consult->total_orders -= 1
     ENDIF
    ELSE
     consult->prsnl[consult->cnt_p].consult_order[mi_ord].discharge_b4_due1 = "N"
    ENDIF
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].completed_dt_tm = oa.action_dt_tm, consult->
    prsnl[consult->cnt_p].consult_order[mi_ord].pat_disch_dttm = e.disch_dt_tm, consult->prsnl[
    consult->cnt_p].consult_order[mi_ord].pat_reg_dttm = e.reg_dt_tm,
    consult->prsnl[consult->cnt_p].consult_order[mi_ord].status = uar_get_code_display(o
     .order_status_cd)
    IF (oa.action_personnel_id != null)
     consult->prsnl[consult->cnt_p].total_comp += 1, consult->total_comp += 1
    ENDIF
    consult->per_on_time1 = format(round(((cnvtreal(consult->on_time1)/ cnvtreal(consult->total_comp)
      ) * 100),2),"###.##;p0"), consult->prsnl[consult->cnt_p].per_on_time1 = format(round(((cnvtreal
      (consult->prsnl[consult->cnt_p].toton_time1)/ cnvtreal(consult->prsnl[consult->cnt_p].
       total_comp)) * 100),2),"###.##;p0")
   FOOT  oa.action_personnel_id
    stat = alterlist(consult->prsnl[consult->cnt_p].consult_order,mi_ord), mi_ord = 0
   FOOT REPORT
    stat = alterlist(consult->prsnl,consult->cnt_p)
   WITH nocounter
  ;end select
 ENDIF
 IF (( $OUTPUT_TYPE="CSV"))
  IF (( $S_CREATE_FILES=1))
   SET frec->file_name = ms_var_out_consult
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"Order Completed by",','"FIN",','"Admit Date",','"Order Name",',
    '"Ordered Date Time",',
    '"Completed Date Time",','"Due Date",','"Discharge Date Time",','"Status",','"Done On Time",',
    char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml_loop1 = 1 TO size(consult->prsnl,5))
     FOR (ml_loop2 = 1 TO size(consult->prsnl[ml_loop1].consult_order,5))
      SET frec->file_buf = build('"',substring(1,100,consult->prsnl[ml_loop1].completed_name),'","',
       substring(1,30,consult->prsnl[ml_loop1].consult_order[ml_loop2].fin),'","',
       format(consult->prsnl[ml_loop1].consult_order[ml_loop2].pat_reg_dttm,"mm/dd/yyyy hh:mm;;d"),
       '","',substring(1,90,consult->prsnl[ml_loop1].consult_order[ml_loop2].order_name),'","',format
       (consult->prsnl[ml_loop1].consult_order[ml_loop2].order_dtttm,"mm/dd/yyyy hh:mm;;d"),
       '","',format(consult->prsnl[ml_loop1].consult_order[ml_loop2].completed_dt_tm,
        "mm/dd/yyyy hh:mm;;d"),'","',format(consult->prsnl[ml_loop1].consult_order[ml_loop2].
        due_date1,"mm/dd/yyyy hh:mm;;d"),'","',
       format(consult->prsnl[ml_loop1].consult_order[ml_loop2].pat_disch_dttm,"mm/dd/yyyy hh:mm;;d"),
       '","',substring(1,30,consult->prsnl[ml_loop1].consult_order[ml_loop2].status),'","',substring(
        1,30,consult->prsnl[ml_loop1].consult_order[ml_loop2].done_on_time1),
       '"',char(13))
      SET stat = cclio("WRITE",frec)
     ENDFOR
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   IF (textlen(trim( $S_EMAILS,3)) > 1
    AND textlen(trim(ms_error,3))=0
    AND ( $S_CREATE_FILES=1)
    AND mi_valid_email=1)
    EXECUTE bhs_ma_email_file
    SET ms_subject = build2(ms_report_name," ",trim(format(cnvtdatetime(ms_start_date),
       "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),
       "mmm-dd-yyyy hh:mm;;d"),3))
    CALL emailfile(ms_var_out_consult,ms_var_out_consult, $S_EMAILS,ms_subject,1)
    SELECT INTO  $OUTDEV
     FROM dummyt d
     HEAD REPORT
      msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
      CALL print(calcpos(36,18)),
      msg1, row + 2, msg2
     WITH dio = 08
    ;end select
   ENDIF
  ELSE
   SELECT INTO value(ms_var_out_consult)
    prsnl_completed_name = substring(1,100,consult->prsnl[d1.seq].completed_name), fin = substring(1,
     30,consult->prsnl[d1.seq].consult_order[d2.seq].fin), admit_date = format(consult->prsnl[d1.seq]
     .consult_order[d2.seq].pat_reg_dttm,"mm/dd/yyyy hh:mm;;d"),
    order_name = substring(1,90,consult->prsnl[d1.seq].consult_order[d2.seq].order_name),
    ordered_date_time = format(consult->prsnl[d1.seq].consult_order[d2.seq].order_dtttm,
     "mm/dd/yyyy hh:mm;;d"), completed_date_time = format(consult->prsnl[d1.seq].consult_order[d2.seq
     ].completed_dt_tm,"mm/dd/yyyy hh:mm;;d"),
    due_date = format(consult->prsnl[d1.seq].consult_order[d2.seq].due_date1,"mm/dd/yyyy hh:mm;;d"),
    discharge_date_time = format(consult->prsnl[d1.seq].consult_order[d2.seq].due_date1,
     "mm/dd/yyyy hh:mm;;d"), status = substring(1,30,consult->prsnl[d1.seq].consult_order[d2.seq].
     status),
    done_on_time = substring(1,30,consult->prsnl[d1.seq].consult_order[d2.seq].done_on_time1)
    FROM (dummyt d1  WITH seq = size(consult->prsnl,5)),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(consult->prsnl[d1.seq].consult_order,5)))
     JOIN (d2)
    WITH nocounter, separator = " ", format
   ;end select
  ENDIF
 ELSEIF (( $OUTPUT_TYPE="DETAIL"))
  EXECUTE bhs_rpt_consult_orders_lo value(ms_var_out_consult),  $F_FACILITY,  $S_START_DATE,
   $S_END_DATE,  $F_ORDERS,  $OUTPUT_TYPE,
   $S_CREATE_FILES,  $S_RANGE,  $S_RPT_NAME
  IF (textlen(trim( $S_EMAILS,3)) > 1
   AND textlen(trim(ms_error,3))=0
   AND ( $S_CREATE_FILES=1))
   EXECUTE bhs_ma_email_file
   SET ms_subject = build2(ms_report_name," ",trim(format(cnvtdatetime(ms_start_date),
      "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),"mmm-dd-yyyy hh:mm;;d"
      ),3))
   CALL emailfile(ms_var_out_consult,ms_var_out_consult, $S_EMAILS,ms_subject,1)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
     CALL print(calcpos(36,18)),
     msg1, row + 2, msg2
    WITH dio = 08
   ;end select
  ENDIF
 ELSEIF (( $OUTPUT_TYPE="SUMMARY"))
  EXECUTE bhs_rpt_consult_orders_lo value(ms_var_out_consult),  $F_FACILITY,  $S_START_DATE,
   $S_END_DATE,  $F_ORDERS,  $OUTPUT_TYPE,
   $S_CREATE_FILES,  $S_RANGE,  $S_RPT_NAME,
   $S_EMAILS
  EXECUTE bhs_ma_email_file
  SET ms_subject = build2(ms_report_name," ",trim(format(cnvtdatetime(ms_start_date),
     "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),"mmm-dd-yyyy hh:mm;;d"),
    3))
  IF (textlen(trim( $S_EMAILS,3)) > 1
   AND textlen(trim(ms_error,3))=0
   AND ( $S_CREATE_FILES=1))
   EXECUTE bhs_ma_email_file
   CALL emailfile(ms_var_out_consult,ms_var_out_consult, $S_EMAILS,ms_subject,1)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
     CALL print(calcpos(36,18)),
     msg1, row + 2, msg2
    WITH dio = 08
   ;end select
  ENDIF
 ELSEIF (( $OUTPUT_TYPE="DETSUM"))
  EXECUTE bhs_rpt_consult_orders_lo value(ms_var_out_consult),  $F_FACILITY,  $S_START_DATE,
   $S_END_DATE,  $F_ORDERS,  $OUTPUT_TYPE,
   $S_CREATE_FILES,  $S_RANGE,  $S_RPT_NAME,
   $S_EMAILS
  EXECUTE bhs_ma_email_file
  SET ms_subject = build2(ms_report_name," ",trim(format(cnvtdatetime(ms_start_date),
     "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),"mmm-dd-yyyy hh:mm;;d"),
    3))
  IF (textlen(trim( $S_EMAILS,3)) > 1
   AND textlen(trim(ms_error,3))=0
   AND ( $S_CREATE_FILES=1))
   EXECUTE bhs_ma_email_file
   CALL emailfile(ms_var_out_consult,ms_var_out_consult, $S_EMAILS,ms_subject,1)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
     CALL print(calcpos(36,18)),
     msg1, row + 2, msg2
    WITH dio = 08
   ;end select
  ENDIF
 ELSEIF (( $OUTPUT_TYPE="MDSUMMARY"))
  EXECUTE bhs_rpt_consult_ordersmd_lo value(ms_var_out_consult),  $F_FACILITY,  $S_START_DATE,
   $S_END_DATE,  $F_ORDERS,  $OUTPUT_TYPE,
   $S_CREATE_FILES,  $S_RANGE,  $S_RPT_NAME,
   $S_EMAILS
  SET ms_subject = build2(ms_report_name," ",trim(format(cnvtdatetime(ms_start_date),
     "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),"mmm-dd-yyyy hh:mm;;d"),
    3))
  IF (textlen(trim( $S_EMAILS,3)) > 1
   AND textlen(trim(ms_error,3))=0
   AND ( $S_CREATE_FILES=1))
   EXECUTE bhs_ma_email_file
   CALL emailfile(ms_var_out_consult,ms_var_out_consult, $S_EMAILS,ms_subject,1)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
     CALL print(calcpos(36,18)),
     msg1, row + 2, msg2
    WITH dio = 08
   ;end select
  ENDIF
 ELSEIF (( $OUTPUT_TYPE="MDSUMTOT"))
  EXECUTE bhs_rpt_consult_ordersmd_lo value(ms_var_out_consult),  $F_FACILITY,  $S_START_DATE,
   $S_END_DATE,  $F_ORDERS,  $OUTPUT_TYPE,
   $S_CREATE_FILES,  $S_RANGE,  $S_RPT_NAME,
   $S_EMAILS
  SET ms_subject = build2(ms_report_name," ",trim(format(cnvtdatetime(ms_start_date),
     "mmm-dd-yyyy hh:mm ;;d"),3)," to ",trim(format(cnvtdatetime(ms_end_date),"mmm-dd-yyyy hh:mm;;d"),
    3))
  IF (textlen(trim( $S_EMAILS,3)) > 1
   AND textlen(trim(ms_error,3))=0
   AND ( $S_CREATE_FILES=1))
   EXECUTE bhs_ma_email_file
   CALL emailfile(ms_var_out_consult,ms_var_out_consult, $S_EMAILS,ms_subject,1)
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
#exit_script
END GO
