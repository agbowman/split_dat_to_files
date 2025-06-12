CREATE PROGRAM bhs_ma_rpt_big1_ord:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Order Date Start:" = "CURDATE",
  "Order Date End:" = "CURDATE",
  "Facility" = 0,
  "Nurse Unit:" = 0
  WITH outdev, s_start_dt, s_stop_dt,
  f_facility_cd, f_nu_cd
 DECLARE mf_cs200_big1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "BRAININJURYBIG1NEUROCHECKS"))
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE ms_loc_ind = c1 WITH protect, constant(substring(1,1,reflect(parameter(5,0))))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_order_id = f8
     2 s_fin = vc
     2 s_mrn = vc
     2 s_reg_dt = vc
     2 s_order_dt = vc
     2 s_disch_dt = vc
     2 s_pat_name = vc
     2 s_disch_disp = vc
     2 s_admit_type = vc
     2 s_admit_source = vc
     2 s_order_mnemonic = vc
     2 s_order_status = vc
     2 s_facility = vc
     2 s_nurse_unit = vc
     2 f_los = f8
 )
 FREE RECORD m_unit
 RECORD m_unit(
   1 l_cnt = i4
   1 qual[*]
     2 f_unit_cd = f8
 ) WITH protect
 IF (ms_loc_ind="C")
  SELECT INTO "nl:"
   FROM nurse_unit n,
    code_value cv
   PLAN (n
    WHERE (n.loc_facility_cd= $F_FACILITY_CD)
     AND n.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=n.location_cd
     AND cv.code_set=220
     AND cv.active_ind=1
     AND cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT"))
   DETAIL
    m_unit->l_cnt += 1, stat = alterlist(m_unit->qual,m_unit->l_cnt), m_unit->qual[m_unit->l_cnt].
    f_unit_cd = cv.code_value
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value= $F_NU_CD)
    AND cv.code_set=220
    AND cv.active_ind=1
    AND cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
   DETAIL
    m_unit->l_cnt += 1, stat = alterlist(m_unit->qual,m_unit->l_cnt), m_unit->qual[m_unit->l_cnt].
    f_unit_cd = cv.code_value
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (o
   WHERE o.catalog_cd=mf_cs200_big1_cd
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND o.active_ind=1
    AND o.template_order_flag=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND (e.loc_facility_cd= $F_FACILITY_CD)
    AND expand(ml_idx1,1,m_unit->l_cnt,e.loc_nurse_unit_cd,m_unit->qual[ml_idx1].f_unit_cd))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND e.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea1.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn_cd)
  ORDER BY e.encntr_id, o.order_id
  HEAD e.encntr_id
   null
  HEAD o.order_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_order_id = o.order_id, m_rec->qual[m_rec->l_cnt].s_fin = trim(ea1
    .alias,3), m_rec->qual[m_rec->l_cnt].s_mrn = trim(ea2.alias,3),
   m_rec->qual[m_rec->l_cnt].s_reg_dt = format(e.reg_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->qual[m_rec
   ->l_cnt].s_order_dt = format(o.orig_order_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->qual[m_rec->l_cnt].
   s_disch_dt = format(e.disch_dt_tm,"MM/DD/YYYY HH:mm;;q")
   IF (e.disch_dt_tm > 0)
    m_rec->qual[m_rec->l_cnt].f_los = datetimediff(e.disch_dt_tm,e.reg_dt_tm,3)
   ELSE
    m_rec->qual[m_rec->l_cnt].f_los = datetimediff(cnvtdatetime(sysdate),e.reg_dt_tm,3)
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].
   s_disch_disp = trim(uar_get_code_display(e.disch_disposition_cd),3), m_rec->qual[m_rec->l_cnt].
   s_admit_type = trim(uar_get_code_display(e.admit_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_admit_source = trim(uar_get_code_display(e.admit_src_cd),3), m_rec->
   qual[m_rec->l_cnt].s_order_mnemonic = trim(o.ordered_as_mnemonic,3), m_rec->qual[m_rec->l_cnt].
   s_order_status = trim(uar_get_code_display(o.order_status_cd),3),
   m_rec->qual[m_rec->l_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->
   qual[m_rec->l_cnt].s_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3)
  WITH nocounter
 ;end select
 IF ((m_rec->l_cnt > 0))
  SELECT INTO  $OUTDEV
   facility = trim(substring(1,150,m_rec->qual[d.seq].s_facility),3), nurse_unit = trim(substring(1,
     150,m_rec->qual[d.seq].s_nurse_unit),3), fin = trim(substring(1,50,m_rec->qual[d.seq].s_fin),3),
   mrn = trim(substring(1,50,m_rec->qual[d.seq].s_mrn),3), patient = trim(substring(1,150,m_rec->
     qual[d.seq].s_pat_name),3), reg_dt = trim(substring(1,30,m_rec->qual[d.seq].s_reg_dt),3),
   disch_dt = trim(substring(1,30,m_rec->qual[d.seq].s_disch_dt),3), los_hours = trim(substring(1,20,
     trim(cnvtstring(m_rec->qual[d.seq].f_los,20,2),3)),3), admit_source = trim(substring(1,50,m_rec
     ->qual[d.seq].s_admit_source),3),
   admit_type = trim(substring(1,50,m_rec->qual[d.seq].s_admit_type),3), disch_disposition = trim(
    substring(1,50,m_rec->qual[d.seq].s_disch_disp),3), order_date = trim(substring(1,20,m_rec->qual[
     d.seq].s_order_dt),3),
   ordered_as_mnemonic = trim(substring(1,125,m_rec->qual[d.seq].s_order_mnemonic),3), order_status
    = trim(substring(1,25,m_rec->qual[d.seq].s_order_status),3)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   ORDER BY facility, nurse_unit, patient
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    "{CPI/9}{FONT/4}", row 0, col 0,
    CALL print(build2("PROGRAM:  ",cnvtlower(curprog),"       NODE:  ",curnode)), row + 1, row 3,
    col 0,
    CALL print("Report completed. No qualifying data found."), row + 1,
    row 6, col 0,
    CALL print(build2("Execution Date/Time:",format(cnvtdatetime(curdate,curtime),
      "mm/dd/yyyy hh:mm:ss;;q")))
   WITH nocounter, nullreport, maxcol = 300,
    dio = 08
  ;end select
 ENDIF
#exit_script
END GO
