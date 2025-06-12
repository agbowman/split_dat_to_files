CREATE PROGRAM bhs_ma_rpt_weight_mngmt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Appt Date (Start):" = "CURDATE",
  "Appt Date (End):" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE mf_sc14230_metabolicreturn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14230,
   "METABOLICRETURN"))
 DECLARE mf_cs319_finnbr_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs212_home_addr_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4018"))
 DECLARE mf_cs331_pcp_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4593"))
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
     2 f_person_id = f8
     2 f_appt_id = f8
     2 f_encntr_id = f8
     2 s_appt_type = vc
     2 s_appt_dt = vc
     2 s_age = vc
     2 s_fin = vc
     2 s_pat_name = vc
     2 s_pcp = vc
     2 s_addr1 = vc
     2 s_addr2 = vc
     2 s_city = vc
     2 s_state = vc
     2 s_zip = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM sch_appt sa,
   sch_event se,
   encounter e,
   encntr_alias ea,
   person p,
   address a
  PLAN (sa
   WHERE sa.beg_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND sa.role_meaning="PATIENT"
    AND sa.active_ind=1
    AND sa.version_dt_tm > cnvtdatetime(sysdate)
    AND sa.state_meaning IN ("CHECKED IN", "CONFIRMED", "CHECKED OUT"))
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id
    AND se.active_ind=1
    AND se.appt_type_cd=mf_sc14230_metabolicreturn_cd)
   JOIN (e
   WHERE e.encntr_id=sa.encntr_id
    AND e.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_finnbr_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.address_type_cd= Outerjoin(mf_cs212_home_addr_cd))
    AND (a.parent_entity_name= Outerjoin("PERSON"))
    AND (a.active_ind= Outerjoin(1))
    AND (a.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY sa.sch_appt_id, a.address_type_seq
  HEAD sa.sch_appt_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].f_appt_id
    = sa.sch_appt_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = p.person_id, m_rec->qual[m_rec->l_cnt].f_encntr_id = e
   .encntr_id, m_rec->qual[m_rec->l_cnt].s_appt_type = trim(uar_get_code_display(se.appt_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_appt_dt = trim(format(sa.beg_dt_tm,"MM/DD/YYYY HH:mm;;q"),3), m_rec->
   qual[m_rec->l_cnt].s_fin = trim(ea.alias,3), m_rec->qual[m_rec->l_cnt].s_pat_name = trim(p
    .name_full_formatted,3),
   m_rec->qual[m_rec->l_cnt].s_age = trim(cnvtage(p.birth_dt_tm),3), m_rec->qual[m_rec->l_cnt].
   s_addr1 = trim(a.street_addr,3), m_rec->qual[m_rec->l_cnt].s_addr2 = trim(a.street_addr2,3),
   m_rec->qual[m_rec->l_cnt].s_city = trim(a.city,3), m_rec->qual[m_rec->l_cnt].s_state = trim(
    evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a.state_cd)),3), m_rec->qual[m_rec->l_cnt].
   s_zip = substring(1,5,trim(a.zipcode_key,3))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr,
   prsnl p
  PLAN (ppr
   WHERE expand(ml_idx1,1,m_rec->l_cnt,ppr.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND ppr.active_ind=1
    AND ppr.person_prsnl_r_cd=mf_cs331_pcp_cd)
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
  ORDER BY ppr.person_id, ppr.beg_effective_dt_tm DESC
  HEAD ppr.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,ppr.person_id,m_rec->qual[ml_idx1].f_person_id)
   WHILE (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_pcp = trim(p.name_full_formatted,3),ml_idx2 = locateval(ml_idx1,(ml_idx2+
     1),m_rec->l_cnt,ppr.person_id,m_rec->qual[ml_idx1].f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 CALL echorecord(m_rec)
 IF ((m_rec->l_cnt > 0))
  SELECT INTO  $OUTDEV
   appt_dt = trim(substring(1,10,m_rec->qual[d1.seq].s_appt_dt),3), appt_type = trim(substring(1,120,
     m_rec->qual[d1.seq].s_appt_type),3), fin = trim(substring(1,30,m_rec->qual[d1.seq].s_fin),3),
   pat_name = trim(substring(1,120,m_rec->qual[d1.seq].s_pat_name),3), pat_age = trim(substring(1,50,
     m_rec->qual[d1.seq].s_age),3), pcp = trim(substring(1,120,m_rec->qual[d1.seq].s_pcp),3),
   pat_address_1 = trim(substring(1,120,m_rec->qual[d1.seq].s_addr1),3), pat_address_2 = trim(
    substring(1,120,m_rec->qual[d1.seq].s_addr2),3), pat_city = trim(substring(1,120,m_rec->qual[d1
     .seq].s_city),3),
   pat_state = trim(substring(1,120,m_rec->qual[d1.seq].s_state),3), pat_zip = trim(substring(1,120,
     m_rec->qual[d1.seq].s_zip),3)
   FROM (dummyt d1  WITH seq = m_rec->l_cnt)
   PLAN (d1)
   ORDER BY pat_name, appt_dt
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
END GO
