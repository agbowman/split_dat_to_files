CREATE PROGRAM bhs_rpt_tobacco_use:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = "",
  "File Prefix" = "bhs_tobac",
  "Send to Detail and Summary to MU directory" = 0,
  "Summary to Screen - Detail is default( Ignored if sendingto MU Directory)" = 0,
  "email operation reminder" = 0
  WITH outdev, opsfacilty, prefiix,
  ftpfiles, showsum, emailreminder
 EXECUTE bhs_check_domain
 DECLARE ml_tot_pat_fac = f8 WITH noconstant(0), protect
 DECLARE ml_tot_pat_facdone = f8 WITH noconstant(0), protect
 DECLARE ml_tot_pat_unit = f8 WITH noconstant(0), protect
 DECLARE ml_tot_pat_unit_done = f8 WITH noconstant(0), protect
 DECLARE ml_tot_pat_totaldone = f8 WITH noconstant(0), protect
 DECLARE ml_tot_pat_total = f8 WITH noconstant(0), protect
 DECLARE ms_prevunit = f8 WITH noconstant(9999999999.99), protect
 DECLARE mf_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")), protect
 DECLARE mf_unitcode = f8 WITH protect
 DECLARE ms_checkunitvar = vc WITH protect
 DECLARE mf_mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE mf_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_tobaccouse = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"SHXTOBACCOUSE")),
 protect
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),"/ftp/bhs_rpt_tobacco_use/")
  )
 DECLARE ml_done_pat = f8 WITH noconstant(0), protect
 DECLARE ml_tot_doneunit = f8 WITH noconstant(0), protect
 DECLARE ml_tot_donefac = f8 WITH noconstant(0), protect
 DECLARE ml_totaldone_rpt = f8 WITH noconstant(0), protect
 DECLARE md_start_date = dq8 WITH protect
 DECLARE md_end_date = dq8 WITH protect
 DECLARE md_age = dq8 WITH constant(cnvtagedatetime(13,0,0,0)), protect
 DECLARE ms_year = vc WITH protect
 DECLARE ms_day = i4 WITH protect
 DECLARE ms_name_fac = vc WITH protect
 DECLARE ms_month = i4 WITH protect
 DECLARE d_prt = i4 WITH protect
 DECLARE ms_time = vc WITH protect
 DECLARE ms_dettobacc = vc WITH protect
 DECLARE ms_sumtobacc = vc WITH protect
 DECLARE ms_fileprefix = vc WITH noconstant( $PREFIIX), protect
 DECLARE ms_delimiter1 = vc WITH protect
 DECLARE ms_delimiter2 = vc WITH protect
 DECLARE ms_sender = vc WITH protect
 DECLARE ms_msgcls = vc WITH protect
 DECLARE ms_msg = vc WITH protect
 DECLARE ms_msgsubject = vc WITH protect
 DECLARE ms_sendto = vc WITH protect
 DECLARE ml_msgpriority = i4 WITH protect
 DECLARE ml_opsjob = i4 WITH noconstant(0), protect
 SET ms_delimiter1 = '"'
 SET ms_delimiter2 = "	"
 SET ms_year = substring(3,2,build(year(cnvtdatetime(sysdate))))
 SET ms_day = day(curdate)
 SET ms_month = month(curdate)
 SET ms_time = format(curtime,"HHMM;;M")
 SET ms_dettobacc = build(ms_loc_dir,ms_fileprefix,"det",ms_month,ms_day,
  ms_time,ms_year,".xls")
 SET ms_year = substring(3,2,build(year(cnvtdatetime(sysdate))))
 SET ms_day = day(curdate)
 SET ms_month = month(curdate)
 SET ms_time = format(curtime,"HHMM;;M")
 SET ms_sumtobacc = build(ms_loc_dir,ms_fileprefix,"sum",ms_month,ms_day,
  ms_time,ms_year,".xls")
 RECORD tobacco_use(
   1 total_cnt = f8
   1 l_alldone = f8
   1 facility[*]
     2 l_total_facil = f8
     2 s_faciltiy = vc
     2 l_fac_done = f8
     2 unit[*]
       3 s_unit = vc
       3 l_total_unit = f8
       3 l_numdone = f8
       3 pat_list[*]
         4 s_patname = vc
         4 s_acct = vc
         4 s_mrn = vc
         4 c_dt_chartdone = vc
         4 s_admit_date = vc
         4 s_room_bed = vc
         4 s_charted = vc
         4 s_charted_by = vc
         4 a_age = vc
 )
 IF (validate(request->batch_selection))
  SET ml_opsjob = 1
 ENDIF
 SELECT INTO "NL:"
  facility = uar_get_code_display(e.loc_facility_cd), nurse_unit = uar_get_code_display(e
   .loc_nurse_unit_cd), sort_name = build(p.name_full_formatted,p.person_id),
  done =
  IF (sar.nomenclature_id > 0) 1
  ELSE 0
  ENDIF
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
    WHERE (cv.display_key= $OPSFACILTY)
     AND cv.code_set=220
     AND cv.cdf_meaning IN ("FACILITY")))
    AND ed.loc_building_cd > 0
    AND ed.loc_nurse_unit_cd > 0
    AND ed.loc_room_cd > 0)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_daystay, mf_inpatient, mf_observation)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
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
   WHERE (sa.person_id= Outerjoin(ed.person_id))
    AND (sa.active_ind= Outerjoin(1))
    AND (sa.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (chtd
   WHERE (chtd.person_id= Outerjoin(sa.updt_id)) )
   JOIN (sr
   WHERE (sr.shx_activity_id= Outerjoin(sa.shx_activity_id))
    AND (sr.active_ind= Outerjoin(1))
    AND (sr.task_assay_cd= Outerjoin(mf_tobaccouse)) )
   JOIN (sar
   WHERE (sar.shx_response_id= Outerjoin(sr.shx_response_id)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(sar.nomenclature_id)) )
  ORDER BY facility, nurse_unit, sort_name,
   done DESC, sar.updt_dt_tm DESC
  HEAD REPORT
   stat = alterlist(tobacco_use->facility,10), cnt_fac = 0
  HEAD facility
   cnt_unit = 0, cnt_fac += 1
   IF (mod(cnt_fac,10)=1)
    stat = alterlist(tobacco_use->facility,(cnt_fac+ 9))
   ENDIF
   tobacco_use->facility[cnt_fac].s_faciltiy = facility, tobacco_use->facility[cnt_fac].l_total_facil
    = cnt_fac, stat = alterlist(tobacco_use->facility[cnt_fac].unit,10),
   cnt_pat = 0
  HEAD nurse_unit
   cnt_unit += 1
   IF (mod(cnt_unit,10)=1
    AND cnt_unit != 1)
    stat = alterlist(tobacco_use->facility[cnt_fac].unit,(cnt_unit+ 9)),
    CALL echo("Increase Unit record size")
   ENDIF
   tobacco_use->facility[cnt_fac].unit[cnt_unit].s_unit = nurse_unit, tobacco_use->facility[cnt_fac].
   unit[cnt_unit].l_total_unit = cnt_unit
  HEAD sort_name
   IF (ms_prevunit != e.loc_nurse_unit_cd)
    cnt_pat = 0, stat = alterlist(tobacco_use->facility[cnt_fac].unit[cnt_unit].pat_list,10),
    ms_prevunit = e.loc_nurse_unit_cd
   ENDIF
   cnt_pat += 1
   IF (mod(cnt_pat,10)=1
    AND cnt_pat != 1)
    stat = alterlist(tobacco_use->facility[cnt_fac].unit[cnt_unit].pat_list,(cnt_pat+ 9))
   ENDIF
   tobacco_use->facility[cnt_fac].unit[cnt_unit].pat_list[cnt_pat].s_acct = trim(fin.alias,3),
   tobacco_use->facility[cnt_fac].unit[cnt_unit].pat_list[cnt_pat].s_mrn = trim(mrn.alias,3),
   tobacco_use->facility[cnt_fac].unit[cnt_unit].pat_list[cnt_pat].s_admit_date = substring(1,30,
    format(e.reg_dt_tm,"DD-MMM-YYYY;;D")),
   tobacco_use->facility[cnt_fac].unit[cnt_unit].pat_list[cnt_pat].c_dt_chartdone = substring(1,30,
    format(sa.perform_dt_tm,"DD-MMM-YYYY;;D")), tobacco_use->facility[cnt_fac].unit[cnt_unit].
   pat_list[cnt_pat].s_patname = p.name_full_formatted, tobacco_use->facility[cnt_fac].unit[cnt_unit]
   .pat_list[cnt_pat].s_charted_by = chtd.name_full_formatted,
   tobacco_use->facility[cnt_fac].unit[cnt_unit].pat_list[cnt_pat].s_room_bed = build(
    uar_get_code_display(ed.loc_room_cd),"-",uar_get_code_display(ed.loc_bed_cd)), tobacco_use->
   facility[cnt_fac].unit[cnt_unit].pat_list[cnt_pat].s_charted = n.source_string, tobacco_use->
   facility[cnt_fac].unit[cnt_unit].pat_list[cnt_pat].a_age = cnvtage(p.birth_dt_tm)
   IF (sar.nomenclature_id > 0)
    ml_done_pat += 1
   ENDIF
  FOOT  sort_name
   null
  FOOT  nurse_unit
   stat = alterlist(tobacco_use->facility[cnt_fac].unit[cnt_unit].pat_list,cnt_pat), ms_prevunit = e
   .loc_nurse_unit_cd, ml_tot_pat_unit += cnt_pat,
   ml_tot_doneunit += ml_done_pat, tobacco_use->facility[cnt_fac].unit[cnt_unit].l_total_unit =
   ml_tot_pat_unit, tobacco_use->facility[cnt_fac].unit[cnt_unit].l_numdone = ml_tot_doneunit,
   ml_tot_pat_fac += ml_tot_pat_unit, ml_tot_donefac += ml_tot_doneunit, ml_tot_doneunit = 0,
   ml_tot_pat_unit = 0, ml_done_pat = 0
  FOOT  facility
   stat = alterlist(tobacco_use->facility[cnt_fac].unit,cnt_unit), ml_tot_pat_total = (ml_tot_pat_fac
   + ml_tot_pat_total), ml_totaldone_rpt += ml_tot_donefac,
   tobacco_use->facility[cnt_fac].l_total_facil = ml_tot_pat_fac, tobacco_use->facility[cnt_fac].
   l_fac_done = ml_tot_donefac, ml_tot_pat_fac = 0,
   ml_tot_donefac = 0, cnt_unit = 0, cnt_pat = 0
  FOOT REPORT
   stat = alterlist(tobacco_use->facility,cnt_fac), cnt_fac = 0,
   CALL echo(build("total>>",ml_tot_pat_total)),
   tobacco_use->total_cnt = ml_tot_pat_total, tobacco_use->l_alldone = ml_totaldone_rpt
  WITH nocounter
 ;end select
 IF (( $FTPFILES=0))
  SET ms_delimiter1 = ""
  SET ms_delimiter2 = " "
  SET ms_sumtobacc =  $OUTDEV
  SET ms_dettobacc =  $OUTDEV
 ENDIF
 IF (( $SHOWSUM=0))
  SELECT INTO value(ms_dettobacc)
   faciltiy = substring(1,30,tobacco_use->facility[d1.seq].s_faciltiy), unit = substring(1,30,
    tobacco_use->facility[d1.seq].unit[d2.seq].s_unit), acct = substring(1,30,tobacco_use->facility[
    d1.seq].unit[d2.seq].pat_list[d3.seq].s_acct),
   mrn = substring(1,30,tobacco_use->facility[d1.seq].unit[d2.seq].pat_list[d3.seq].s_mrn),
   patient_name = substring(1,30,tobacco_use->facility[d1.seq].unit[d2.seq].pat_list[d3.seq].
    s_patname), admit_date = substring(1,30,tobacco_use->facility[d1.seq].unit[d2.seq].pat_list[d3
    .seq].s_admit_date),
   room_bed = substring(1,30,tobacco_use->facility[d1.seq].unit[d2.seq].pat_list[d3.seq].s_room_bed),
   charted = substring(1,30,tobacco_use->facility[d1.seq].unit[d2.seq].pat_list[d3.seq].s_charted),
   charted_by = substring(1,30,tobacco_use->facility[d1.seq].unit[d2.seq].pat_list[d3.seq].
    s_charted_by),
   chart_date = substring(1,30,tobacco_use->facility[d1.seq].unit[d2.seq].pat_list[d3.seq].
    c_dt_chartdone)
   FROM (dummyt d1  WITH seq = value(size(tobacco_use->facility,5))),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(tobacco_use->facility[d1.seq].unit,5)))
    JOIN (d2
    WHERE maxrec(d3,size(tobacco_use->facility[d1.seq].unit[d2.seq].pat_list,5)))
    JOIN (d3)
   WITH nocounter, format, pcformat(value(ms_delimiter1),value(ms_delimiter2))
  ;end select
 ENDIF
 IF (( $SHOWSUM=1))
  SELECT INTO value(ms_sumtobacc)
   total_patients = tobacco_use->total_cnt, total_completed = tobacco_use->l_alldone,
   total_percent_done = concat(format(((tobacco_use->l_alldone/ tobacco_use->total_cnt) * 100),
     "###.##;;f"),"%"),
   facility = substring(1,30,tobacco_use->facility[d1.seq].s_faciltiy), facilty_total_patients =
   tobacco_use->facility[d1.seq].l_total_facil, facilty_complete = tobacco_use->facility[d1.seq].
   l_fac_done,
   facilty_perent_done = concat(format(((tobacco_use->facility[d1.seq].l_fac_done/ tobacco_use->
     facility[d1.seq].l_total_facil) * 100),"###.##;;f"),"%"), unit_s_unit = substring(1,30,
    tobacco_use->facility[d1.seq].unit[d2.seq].s_unit), unit_total_patients = tobacco_use->facility[
   d1.seq].unit[d2.seq].l_total_unit,
   unit_total_done = tobacco_use->facility[d1.seq].unit[d2.seq].l_numdone, unti_percent_done = concat
   (format(((tobacco_use->facility[d1.seq].unit[d2.seq].l_numdone/ tobacco_use->facility[d1.seq].
     unit[d2.seq].l_total_unit) * 100),"###.##;;f"),"%")
   FROM (dummyt d1  WITH seq = value(size(tobacco_use->facility,5))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(tobacco_use->facility[d1.seq].unit,5)))
    JOIN (d2)
   WITH nocounter, format, pcformat(value(ms_delimiter1),value(ms_delimiter2))
  ;end select
 ENDIF
 CALL echorecord(tobacco_use)
 CALL echo(build("ms_dettobacc  =",ms_dettobacc))
#exit_prg
END GO
