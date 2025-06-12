CREATE PROGRAM bhs_rpt_pmr_ordersv1:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = value(673936.00),
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Select Output" = "",
  "Send file to file share" = 0,
  "Date Range" = ""
  WITH outdev, f_facility, s_start_date,
  s_end_date, output_type, ftpfiles,
  s_range
 EXECUTE bhs_check_domain
 EXECUTE bhs_hlp_ftp
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
 DECLARE ms_var_outpmr = vc WITH noconstant( $OUTDEV), protect
 DECLARE ms_fileprefix = vc WITH protect
 DECLARE mf_per_ontime = vc WITH protect
 DECLARE mf_per_disch = vc WITH protect
 DECLARE mf_per_due = vc WITH protect
 DECLARE mf_per_notdone = vc WITH protect
 DECLARE mf_per_inprogress = vc WITH protect
 DECLARE mf_page_size = f8 WITH noconstant(0), protect
 DECLARE mf_remain_space = f8 WITH noconstant(0), protect
 DECLARE mi_ord = i4 WITH noconstant(0), protect
 DECLARE ms_name_id = vc WITH noconstant(" "), protect
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_files_loc = vc WITH protect, constant(concat(trim(logical("bhscust"),3),
   "/ftp/bhs_rpt_pmr_orders/"))
 DECLARE mf_cs6003_complete = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"COMPLETE")),
 protect
 DECLARE mf_cs4038_systemdcondischarge = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4038,
   "SYSTEMDCONDISCHARGE")), protect
 DECLARE mf_cs_6004_discontinued = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED")
  ), protect
 DECLARE mf_cs_6004_completed = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED")),
 protect
 DECLARE mf_cs_6004_ordered = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs200_consultrehabmed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTREHABILITATIONMEDICINE")), protect
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ms_ftp_host = vc WITH protect, constant("172.17.10.5")
 DECLARE ms_ftp_username = vc WITH protect, constant('"bhs\cisftp"')
 DECLARE ms_ftp_password = vc WITH protect, constant("C!sftp01")
 DECLARE mf_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",15750,"ACTIVE")), protect
 RECORD pmr_consult(
   1 total_done_24hrs = i4
   1 print_requested_by = vc
   1 date_range = vc
   1 total_orders = i4
   1 total_comp = i4
   1 on_time1 = i4
   1 on_time2 = i4
   1 on_time3 = i4
   1 per_on_time1 = vc
   1 per_on_time2 = vc
   1 per_on_time3 = vc
   1 not_on_time1 = i4
   1 not_on_time2 = i4
   1 not_on_time3 = i4
   1 cnt_p = i4
   1 discharge_before = i4
   1 prsnl[*]
     2 total_orders = i4
     2 total_comp = i4
     2 toton_time1 = i4
     2 toton_time2 = i4
     2 toton_time3 = i4
     2 per_on_time1 = vc
     2 per_on_time2 = vc
     2 per_on_time3 = vc
     2 totnot_on_time1 = i4
     2 totnot_on_time2 = i4
     2 totnot_on_time3 = i4
     2 completed_name = vc
     2 pmr_order[*]
       3 encntr_id = f8
       3 order_id = f8
       3 order_status = vc
       3 comp_prsnl_id = f8
       3 fin = vc
       3 completed_dt_tm = dq8
       3 order_dtttm = dq8
       3 order_status_dt_tm = dq8
       3 due_date1 = dq8
       3 due_date2 = dq8
       3 due_date3 = dq8
       3 before_4pm = vc
       3 before_12pm = vc
       3 pat_reg_dttm = dq8
       3 pat_disch_dttm = dq8
       3 done_on_time1 = vc
       3 done_on_time2 = vc
       3 done_on_time3 = vc
       3 discharge_b4_due1 = vc
       3 discharge_b4_due2 = vc
       3 discharge_b4_due3 = vc
       3 status = vc
 )
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  ORDER BY p.person_id
  HEAD p.person_id
   pmr_consult->print_requested_by = concat(trim(p.name_first,3)," ",trim(p.name_last,3))
  FOOT  p.person_id
   null
  WITH nocounter
 ;end select
 IF (( $FTPFILES=1))
  SET ms_year = substring(3,2,build(year(cnvtdatetime(sysdate))))
  SET ms_day = day(curdate)
  SET ms_name_fac = cnvtlower(substring(1,6,replace(trim(uar_get_code_display(cnvtreal( $F_FACILITY))
      )," ","_",0)))
  SET ms_month = month(curdate)
  SET ms_time = format(curtime,"HHMM;;M")
  IF (( $OUTPUT_TYPE="CSV"))
   SET ms_fileprefix = "pmr_"
   SET ms_var_outpmr = build(ms_files_loc,ms_name_fac,"_",ms_fileprefix,"_",
    ms_month,"_",ms_day,"_",ms_time,
    "_",ms_year,".csv")
  ELSEIF (( $OUTPUT_TYPE != "CSV"))
   IF (( $OUTPUT_TYPE IN ("DETAIL", "DETSUM")))
    SET ms_fileprefix = "pmr_det"
   ELSEIF (( $OUTPUT_TYPE IN ("SUMMARY")))
    SET ms_fileprefix = "pmr_summ"
   ELSEIF (( $OUTPUT_TYPE="MDSUMMARY"))
    SET ms_fileprefix = "pmr_mdsum"
   ELSEIF (( $OUTPUT_TYPE="MDSUMTOT"))
    SET ms_fileprefix = "pmr_md_tot"
   ENDIF
   SET ms_var_outpmr = build(ms_files_loc,ms_name_fac,"_",ms_fileprefix,"_",
    ms_month,"_",ms_day,"_",ms_time,
    "_",ms_year,".pdf")
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
 SET pmr_consult->date_range = concat(trim(substring(1,11,ms_start_date),3),"...",substring(1,11,
   ms_end_date))
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
    AND o.catalog_cd=mf_cs200_consultrehabmed
    AND o.person_id > 0
    AND o.order_status_cd IN (mf_cs_6004_completed))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_cs6003_complete)
   JOIN (pr
   WHERE pr.person_id=oa.action_personnel_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND (e.loc_facility_cd= $F_FACILITY))
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
   stat = alterlist(pmr_consult->prsnl,10)
  HEAD oa.action_personnel_id
   pmr_consult->cnt_p += 1
   IF (mod(pmr_consult->cnt_p,10)=1
    AND (pmr_consult->cnt_p > 1))
    stat = alterlist(pmr_consult->prsnl,(pmr_consult->cnt_p+ 9))
   ENDIF
   pmr_consult->prsnl[pmr_consult->cnt_p].completed_name = trim(pr.name_full_formatted), stat =
   alterlist(pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order,10)
  HEAD o.order_id
   mi_ord += 1
   IF (mod(mi_ord,10)=1
    AND mi_ord > 1)
    stat = alterlist(pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order,(mi_ord+ 9))
   ENDIF
   pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].fin = fin.alias, pmr_consult->prsnl[
   pmr_consult->cnt_p].pmr_order[mi_ord].order_id = o.order_id, pmr_consult->prsnl[pmr_consult->cnt_p
   ].pmr_order[mi_ord].order_status = trim(uar_get_code_display(o.order_status_cd),3),
   pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].order_dtttm = o.orig_order_dt_tm
   IF (o.orig_order_dt_tm <= cnvtdatetime(cnvtdate(o.orig_order_dt_tm),120000))
    pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].due_date1 = cnvtdatetime((cnvtdate(o
      .orig_order_dt_tm)+ 1),000000), pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].
    before_12pm = "Y", pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].done_on_time1 =
    "Not Over Due"
    IF (oa.action_dt_tm <= cnvtdatetime(pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].
     due_date1)
     AND oa.action_dt_tm != null)
     pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].done_on_time1 = "Y", pmr_consult->
     on_time1 += 1, pmr_consult->prsnl[pmr_consult->cnt_p].toton_time1 += 1
    ELSEIF (((oa.action_dt_tm > cnvtdatetime(pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord]
     .due_date1)) OR (oa.action_dt_tm=null)) )
     pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].done_on_time1 = "N", pmr_consult->
     not_on_time1 += 1, pmr_consult->prsnl[pmr_consult->cnt_p].totnot_on_time1 += 1
    ENDIF
   ELSEIF (o.orig_order_dt_tm > cnvtdatetime(cnvtdate(o.orig_order_dt_tm),120000)
    AND o.orig_order_dt_tm <= cnvtdatetime(cnvtdate(o.orig_order_dt_tm),160000))
    pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].due_date2 = cnvtdatetime((cnvtdate(o
      .orig_order_dt_tm)+ 1),000000), pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].
    before_4pm = "Y"
    IF (oa.action_dt_tm <= cnvtdatetime(pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].
     due_date2)
     AND oa.action_dt_tm != null)
     pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].done_on_time2 = "Y", pmr_consult->
     on_time2 += 1, pmr_consult->prsnl[pmr_consult->cnt_p].toton_time2 += 1
    ELSEIF (((oa.action_dt_tm > cnvtdatetime(pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord]
     .due_date2)) OR (oa.action_dt_tm=null)) )
     pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].done_on_time2 = "N", pmr_consult->
     not_on_time2 += 1, pmr_consult->prsnl[pmr_consult->cnt_p].totnot_on_time2 += 1
    ENDIF
   ELSE
    pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].due_date3 = cnvtdatetime((cnvtdate(o
      .orig_order_dt_tm)+ 2),000000), pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].
    before_4pm = "A"
    IF (oa.action_dt_tm <= cnvtdatetime(pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].
     due_date3)
     AND oa.action_dt_tm != null)
     pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].done_on_time3 = "Y", pmr_consult->
     on_time3 += 1, pmr_consult->prsnl[pmr_consult->cnt_p].toton_time3 += 1
    ELSEIF (((oa.action_dt_tm > cnvtdatetime(pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord]
     .due_date3)) OR (oa.action_dt_tm=null)) )
     pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].done_on_time3 = "N", pmr_consult->
     not_on_time3 += 1, pmr_consult->prsnl[pmr_consult->cnt_p].totnot_on_time3 += 1
    ENDIF
   ENDIF
   IF (e.disch_dt_tm <= cnvtdatetime(pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].
    due_date1)
    AND e.disch_dt_tm != null)
    pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].discharge_b4_due1 = "Y"
   ELSE
    pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].discharge_b4_due1 = "N"
   ENDIF
   IF (e.disch_dt_tm <= cnvtdatetime(pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].
    due_date2)
    AND e.disch_dt_tm != null)
    pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].discharge_b4_due2 = "Y"
   ELSE
    pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].discharge_b4_due2 = "N"
   ENDIF
   pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].completed_dt_tm = oa.action_dt_tm,
   pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].pat_disch_dttm = e.disch_dt_tm,
   pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].pat_reg_dttm = e.reg_dt_tm,
   pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order[mi_ord].status = uar_get_code_display(o
    .order_status_cd), pmr_consult->prsnl[pmr_consult->cnt_p].total_orders += 1, pmr_consult->
   total_orders += 1,
   pmr_consult->prsnl[pmr_consult->cnt_p].total_comp += 1, pmr_consult->total_comp += 1, pmr_consult
   ->per_on_time1 = format(round(((cnvtreal(pmr_consult->on_time1)/ cnvtreal(pmr_consult->
      total_orders)) * 100),2),"###.##;p0"),
   pmr_consult->per_on_time2 = format(round(((cnvtreal(pmr_consult->on_time2)/ cnvtreal(pmr_consult->
      total_orders)) * 100),2),"###.##;p0"), pmr_consult->prsnl[pmr_consult->cnt_p].per_on_time1 =
   format(round(((cnvtreal(pmr_consult->prsnl[pmr_consult->cnt_p].toton_time1)/ cnvtreal(pmr_consult
      ->prsnl[pmr_consult->cnt_p].total_orders)) * 100),2),"###.##;p0"), pmr_consult->prsnl[
   pmr_consult->cnt_p].per_on_time2 = format(round(((cnvtreal(pmr_consult->prsnl[pmr_consult->cnt_p].
      toton_time2)/ cnvtreal(pmr_consult->prsnl[pmr_consult->cnt_p].total_orders)) * 100),2),
    "###.##;p0"),
   pmr_consult->prsnl[pmr_consult->cnt_p].per_on_time3 = format(round(((cnvtreal(pmr_consult->prsnl[
      pmr_consult->cnt_p].toton_time3)/ cnvtreal(pmr_consult->prsnl[pmr_consult->cnt_p].total_orders)
     ) * 100),2),"###.##;p0")
  FOOT  oa.action_personnel_id
   stat = alterlist(pmr_consult->prsnl[pmr_consult->cnt_p].pmr_order,mi_ord), mi_ord = 0
  FOOT REPORT
   stat = alterlist(pmr_consult->prsnl,pmr_consult->cnt_p)
  WITH nocounter, time = 800
 ;end select
 IF (( $OUTPUT_TYPE="CSV"))
  SELECT
   IF (( $FTPFILES=1))
    WITH nocounter, header, pcformat('"',","),
     format
   ELSE
   ENDIF
   INTO value(ms_var_outpmr)
   prsnl_completed_name = substring(1,30,pmr_consult->prsnl[d1.seq].completed_name), fin = substring(
    1,30,pmr_consult->prsnl[d1.seq].pmr_order[d2.seq].fin), pat_reg_dttm = format(pmr_consult->prsnl[
    d1.seq].pmr_order[d2.seq].pat_reg_dttm,"mm/dd/yyyy hh:mm;;d"),
   order_id = pmr_consult->prsnl[d1.seq].pmr_order[d2.seq].order_id, ordered_by_4pm = pmr_consult->
   prsnl[d1.seq].pmr_order[d2.seq].before_4pm, ordered_by_12pm = pmr_consult->prsnl[d1.seq].
   pmr_order[d2.seq].before_12pm,
   ordered_date_time = format(pmr_consult->prsnl[d1.seq].pmr_order[d2.seq].order_dtttm,
    "mm/dd/yyyy hh:mm;;d"), completed_date_time = format(pmr_consult->prsnl[d1.seq].pmr_order[d2.seq]
    .completed_dt_tm,"mm/dd/yyyy hh:mm;;d"), due_date_12pm_order = format(pmr_consult->prsnl[d1.seq].
    pmr_order[d2.seq].due_date1,"mm/dd/yyyy hh:mm;;d"),
   due_date_4pm_order = format(pmr_consult->prsnl[d1.seq].pmr_order[d2.seq].due_date2,
    "mm/dd/yyyy hh:mm;;d"), due_date_after4pm_order = format(pmr_consult->prsnl[d1.seq].pmr_order[d2
    .seq].due_date3,"mm/dd/yyyy hh:mm;;d"), discharge_date_time = format(pmr_consult->prsnl[d1.seq].
    pmr_order[d2.seq].due_date1,"mm/dd/yyyy hh:mm;;d"),
   status = substring(1,30,pmr_consult->prsnl[d1.seq].pmr_order[d2.seq].status), total_orders =
   pmr_consult->prsnl[d1.seq].total_orders, total_comp_by = pmr_consult->prsnl[d1.seq].total_comp,
   total_comp = pmr_consult->total_comp, toton_time1 = pmr_consult->prsnl[d1.seq].toton_time1,
   toton_time2 = pmr_consult->prsnl[d1.seq].toton_time2,
   toton_time3 = pmr_consult->prsnl[d1.seq].toton_time3, totnot_on_time1 = pmr_consult->prsnl[d1.seq]
   .totnot_on_time1, totnot_on_time2 = pmr_consult->prsnl[d1.seq].totnot_on_time2,
   totnot_on_time3 = pmr_consult->prsnl[d1.seq].totnot_on_time3, percent_on_time1 = substring(1,30,
    pmr_consult->per_on_time1), percent_on_time2 = substring(1,30,pmr_consult->per_on_time2),
   percent_on_time3 = substring(1,30,pmr_consult->per_on_time3), personnel_on_time1 = substring(1,30,
    pmr_consult->prsnl[d1.seq].per_on_time1), personnel_on_time2 = substring(1,30,pmr_consult->prsnl[
    d1.seq].per_on_time2),
   personnel_on_time3 = substring(1,30,pmr_consult->prsnl[d1.seq].per_on_time3)
   FROM (dummyt d1  WITH seq = size(pmr_consult->prsnl,5)),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(pmr_consult->prsnl[d1.seq].pmr_order,5)))
    JOIN (d2)
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (( $OUTPUT_TYPE="DETAIL"))
  EXECUTE bhs_rpt_pmr_orders_lo value(ms_var_outpmr),  $F_FACILITY,  $S_START_DATE,
   $S_END_DATE,  $OUTPUT_TYPE,  $FTPFILES,
   $S_RANGE
 ELSEIF (( $OUTPUT_TYPE="SUMMARY"))
  CALL echo(build("ms_var_outpmr = ",ms_var_outpmr))
  EXECUTE bhs_rpt_pmr_orders_lo value(ms_var_outpmr),  $F_FACILITY,  $S_START_DATE,
   $S_END_DATE,  $OUTPUT_TYPE,  $FTPFILES,
   $S_RANGE
 ELSEIF (( $OUTPUT_TYPE="DETSUM"))
  EXECUTE bhs_rpt_pmr_orders_lo value(ms_var_outpmr),  $F_FACILITY,  $S_START_DATE,
   $S_END_DATE,  $OUTPUT_TYPE,  $FTPFILES,
   $S_RANGE
 ELSEIF (( $OUTPUT_TYPE="MDSUMMARY"))
  EXECUTE bhs_rpt_pmr_ordersmd_lo value(ms_var_outpmr),  $F_FACILITY,  $S_START_DATE,
   $S_END_DATE,  $OUTPUT_TYPE,  $FTPFILES,
   $S_RANGE
 ELSEIF (( $OUTPUT_TYPE="MDSUMTOT"))
  EXECUTE bhs_rpt_pmr_ordersmd_lo value(ms_var_outpmr),  $F_FACILITY,  $S_START_DATE,
   $S_END_DATE,  $OUTPUT_TYPE,  $FTPFILES,
   $S_RANGE
 ENDIF
#exit_prg
END GO
