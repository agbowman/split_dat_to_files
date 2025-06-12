CREATE PROGRAM bhs_rpt_preop_tot_joint:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Scheduled Start Date (range start):" = "CURDATE",
  "Scheduled Start Date (range end):" = "CURDATE",
  "Surigcal Area" = 0,
  "Surgeon Search (Last Name):" = "",
  "Primary Surgeon:" = 0
  WITH outdev, s_start_dt, s_stop_dt,
  f_surg_area, s_surg_lname, f_surg_id
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_ins_cnt = i4 WITH protect, noconstant(0)
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = datetimeadd(cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W",
      "B","B"),"DD-MMM-YYYY HH:MM:SS;;d")),1)
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
  SET mf_stop_dt = datetimeadd(cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E",
      "E"),"DD-MMM-YYYY HH:MM:SS;;d")),1)
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
     2 f_surg_case_id = f8
     2 f_enc_id = f8
     2 s_surg_area = vc
     2 s_op_room = vc
     2 s_case_create_dt_tm = vc
     2 s_sched_start_dt = vc
     2 s_sched_start_tm = vc
     2 s_add_on = vc
     2 s_pat_type = vc
     2 s_pat_name = vc
     2 s_pat_dob = vc
     2 s_pat_age = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_primary_surgeon = vc
     2 s_primary_proc = vc
     2 s_sched_duration = vc
     2 s_ins1 = vc
     2 s_ins2 = vc
     2 s_ins3 = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM surgical_case sc,
   surg_case_procedure scp,
   encounter e,
   person p,
   prsnl pr,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (sc
   WHERE sc.sched_start_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND (sc.sched_surg_area_cd= $F_SURG_AREA)
    AND sc.sched_qty=1
    AND sc.cancel_reason_cd=0
    AND sc.cancel_req_by_id=0)
   JOIN (scp
   WHERE scp.surg_case_id=sc.surg_case_id
    AND scp.sched_primary_ind=1
    AND (scp.sched_primary_surgeon_id= $F_SURG_ID)
    AND ((scp.active_ind=1
    AND scp.sched_surg_proc_cd > 0) OR (scp.active_ind=0
    AND scp.sched_surg_proc_cd > 0
    AND scp.surg_proc_cd > 0)) )
   JOIN (e
   WHERE e.encntr_id=sc.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pr
   WHERE pr.person_id=scp.sched_primary_surgeon_id)
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
  ORDER BY sc.surg_case_id
  HEAD sc.surg_case_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].f_enc_id
    = sc.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_surg_case_id = sc.surg_case_id, m_rec->qual[m_rec->l_cnt].s_surg_area
    = trim(uar_get_code_display(sc.sched_surg_area_cd),3), m_rec->qual[m_rec->l_cnt].s_op_room = trim
   (uar_get_code_display(sc.sched_op_loc_cd),3),
   m_rec->qual[m_rec->l_cnt].s_case_create_dt_tm = trim(format(sc.create_dt_tm,"MM/DD/YYYY HH:mm;;q"),
    3), m_rec->qual[m_rec->l_cnt].s_sched_start_dt = trim(format(sc.sched_start_dt_tm,"MM/DD/YYYY;;q"
     ),3), m_rec->qual[m_rec->l_cnt].s_sched_start_tm = trim(format(sc.sched_start_dt_tm,"HH:mm;;q"),
    3)
   IF (sc.add_on_ind=1)
    m_rec->qual[m_rec->l_cnt].s_add_on = "Yes"
   ELSE
    m_rec->qual[m_rec->l_cnt].s_add_on = "No"
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_pat_type = trim(uar_get_code_display(sc.sched_pat_type_cd),3), m_rec->
   qual[m_rec->l_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].s_pat_dob
    = trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_pat_age = cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
      .birth_tz),1),sc.sched_start_dt_tm,0), m_rec->qual[m_rec->l_cnt].s_mrn = trim(ea2.alias,3),
   m_rec->qual[m_rec->l_cnt].s_fin = trim(ea1.alias,3),
   m_rec->qual[m_rec->l_cnt].s_primary_proc = trim(uar_get_code_display(scp.sched_surg_proc_cd),3),
   m_rec->qual[m_rec->l_cnt].s_primary_surgeon = trim(pr.name_full_formatted,3), m_rec->qual[m_rec->
   l_cnt].s_sched_duration = trim(cnvtstring(sc.sched_dur,20,0),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case sc,
   encntr_plan_reltn epr,
   health_plan hp
  PLAN (sc
   WHERE expand(ml_idx1,1,m_rec->l_cnt,sc.surg_case_id,m_rec->qual[ml_idx1].f_surg_case_id))
   JOIN (epr
   WHERE epr.encntr_id=sc.encntr_id
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id)
  ORDER BY sc.surg_case_id, epr.priority_seq
  HEAD sc.surg_case_id
   ml_ins_cnt = 0, ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,sc.surg_case_id,m_rec->qual[ml_idx1
    ].f_surg_case_id)
  DETAIL
   IF (ml_idx2 > 0)
    ml_ins_cnt += 1
    IF (ml_ins_cnt=1)
     m_rec->qual[ml_idx2].s_ins1 = trim(hp.plan_name,3)
    ELSEIF (ml_ins_cnt=2)
     m_rec->qual[ml_idx2].s_ins2 = trim(hp.plan_name,3)
    ELSEIF (ml_ins_cnt=3)
     m_rec->qual[ml_idx2].s_ins3 = trim(hp.plan_name,3)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF ((m_rec->l_cnt > 0))
  SELECT INTO  $OUTDEV
   surgical_area = trim(substring(1,100,m_rec->qual[d.seq].s_surg_area),3), operating_room = trim(
    substring(1,60,m_rec->qual[d.seq].s_op_room),3), scheduled_start_time = trim(substring(1,10,m_rec
     ->qual[d.seq].s_sched_start_tm),3),
   scheduled_start_date = trim(substring(1,12,m_rec->qual[d.seq].s_sched_start_dt),3),
   add_on_indicator = trim(substring(1,5,m_rec->qual[d.seq].s_add_on),3), patient_name = trim(
    substring(1,150,m_rec->qual[d.seq].s_pat_name),3),
   patient_date_of_birth = trim(substring(1,12,m_rec->qual[d.seq].s_pat_dob),3), mrn = trim(substring
    (1,30,m_rec->qual[d.seq].s_mrn),3), fin = trim(substring(1,30,m_rec->qual[d.seq].s_fin),3),
   primary_surgeon = trim(substring(1,120,m_rec->qual[d.seq].s_primary_surgeon),3), primary_procedure
    = trim(substring(1,200,m_rec->qual[d.seq].s_primary_proc),3), scheduled_case_duration = trim(
    substring(1,10,m_rec->qual[d.seq].s_sched_duration),3),
   patient_type = trim(substring(1,100,m_rec->qual[d.seq].s_pat_type),3), patient_age = trim(
    substring(1,20,m_rec->qual[d.seq].s_pat_age),3), case_created_dt_tm = trim(substring(1,20,m_rec->
     qual[d.seq].s_case_create_dt_tm),3),
   primary_insurance = trim(substring(1,200,m_rec->qual[d.seq].s_ins1),3), secondary_insurance = trim
   (substring(1,200,m_rec->qual[d.seq].s_ins2),3), tertiary_insurance = trim(substring(1,200,m_rec->
     qual[d.seq].s_ins3),3)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   PLAN (d)
   ORDER BY surgical_area, operating_room, scheduled_start_time,
    scheduled_start_date
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
