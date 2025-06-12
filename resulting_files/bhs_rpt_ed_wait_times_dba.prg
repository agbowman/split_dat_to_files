CREATE PROGRAM bhs_rpt_ed_wait_times:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date/Time:" = "SYSDATE",
  "End Date/Time:" = "SYSDATE"
  WITH outdev, s_beg_dt_tm, s_end_dt_tm
 EXECUTE bhs_sys_stand_subroutine
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_acuity_level_id = f8
     2 s_esi_acuity = vc
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 s_service_dt_tm = vc
     2 s_ed_provider = vc
     2 s_reg_dt_tm = vc
     2 s_triage_dt_tm = vc
     2 s_docassign_dt_tm = vc
     2 l_wait_time_mins = i4
     2 s_address = vc
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ms_xml_file = vc WITH protect, constant("bmlh_ed_avg_wait.xml")
 DECLARE mf_bmlh_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16370,
   "BMLHEDTRACKINGGROUP"))
 DECLARE ms_filename = vc WITH protect, constant("bhs_bmlh_wait_times.csv")
 DECLARE mf_home_adr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",212,"HOME"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant( $S_BEG_DT_TM)
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant( $S_END_DT_TM)
 DECLARE ms_doc_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_triage_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mf_avg_wait = f8 WITH protect, noconstant(0.0)
 DECLARE ms_recipients = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE ml_dclcom_len = i4 WITH protect, noconstant(0)
 DECLARE mn_dclcom_stat = i2 WITH protect, noconstant(0)
 IF (validate(request->batch_selection))
  SET ms_end_dt_tm = concat(trim(format(sysdate,"dd-mmm-yyyy;;d"))," 00:00:00")
  SET ms_beg_dt_tm = concat(trim(format(cnvtlookbehind("7,D",cnvtdatetime(ms_end_dt_tm)),
     "dd-mmm-yyyy;;d"))," 00:00:00")
  SET ms_recipients = concat("kimberly.davis@baystatehealth.org, rick.gerstein@bhs.org,",
   "eric.shores@bhs.org, nancy.melanson@baystatehealth.org")
 ENDIF
 CALL echo(concat("ms_beg_dt_tm: ",ms_beg_dt_tm))
 CALL echo(concat("ms_end_dt_tm: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  tc.checkin_dt_tm, tracking_event_type = uar_get_code_display(tc.tracking_event_type_cd), tre
  .display
  FROM tracking_checkin tc,
   tracking_event te,
   track_event tre,
   tracking_item ti,
   encounter e,
   encntr_alias ea,
   person p,
   prsnl pr1,
   prsnl pr2,
   address a,
   dummyt d1
  PLAN (tc
   WHERE tc.checkin_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND tc.tracking_group_cd=mf_bmlh_cd
    AND tc.active_ind=1)
   JOIN (te
   WHERE te.tracking_id=tc.tracking_id
    AND te.active_ind=1)
   JOIN (tre
   WHERE tre.track_event_id=te.track_event_id
    AND tre.tracking_group_cd=tc.tracking_group_cd
    AND tre.active_ind=1
    AND tre.display_key IN ("DOCASSIGN", "TRIAGEFORMMLH"))
   JOIN (ti
   WHERE ti.tracking_id=te.tracking_id)
   JOIN (e
   WHERE e.encntr_id=ti.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (pr1
   WHERE pr1.person_id=outerjoin(tc.primary_doc_id)
    AND pr1.active_ind=outerjoin(1))
   JOIN (pr2
   WHERE pr2.person_id=outerjoin(tc.secondary_doc_id)
    AND pr2.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (d1)
   JOIN (a
   WHERE a.parent_entity_id=p.person_id
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=mf_home_adr_cd
    AND a.seq=1
    AND a.active_ind=1
    AND a.end_effective_dt_tm > sysdate)
  ORDER BY tc.tracking_checkin_id, tc.tracking_id, ea.alias,
   te.complete_dt_tm
  HEAD REPORT
   pl_cur_wait = 0, pl_tot_mins = 0, pl_cnt = 0
  HEAD tc.tracking_id
   ms_doc_dt_tm = "", ms_triage_dt_tm = ""
  DETAIL
   IF (tre.display_key="DOCASSIGN")
    IF (ms_doc_dt_tm <= " ")
     ms_doc_dt_tm = trim(format(te.complete_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
    ELSEIF (cnvtdatetime(ms_doc_dt_tm) > te.complete_dt_tm)
     ms_doc_dt_tm = trim(format(te.complete_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
    ENDIF
   ELSEIF (tre.display_key="TRIAGEFORMMLH")
    IF (ms_triage_dt_tm <= " ")
     ms_triage_dt_tm = trim(format(te.complete_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
    ELSEIF (cnvtdatetime(ms_triage_dt_tm) > te.complete_dt_tm)
     ms_triage_dt_tm = trim(format(te.complete_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
    ENDIF
   ENDIF
  FOOT  tc.tracking_id
   pl_cur_wait = datetimediff(cnvtdatetime(ms_doc_dt_tm),tc.checkin_dt_tm,4)
   IF (pl_cur_wait > 0)
    pl_cnt = (pl_cnt+ 1), pl_tot_mins = (pl_tot_mins+ pl_cur_wait)
    IF (pl_cnt > size(m_rec->pat,5))
     stat = alterlist(m_rec->pat,(pl_cnt+ 10))
    ENDIF
    m_rec->pat[pl_cnt].f_encntr_id = ti.encntr_id, m_rec->pat[pl_cnt].f_person_id = ti.person_id,
    m_rec->pat[pl_cnt].s_pat_name = trim(p.name_full_formatted),
    m_rec->pat[pl_cnt].l_wait_time_mins = pl_cur_wait, m_rec->pat[pl_cnt].s_reg_dt_tm = trim(format(e
      .reg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")), m_rec->pat[pl_cnt].s_service_dt_tm = trim(format(tc
      .checkin_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")),
    m_rec->pat[pl_cnt].s_triage_dt_tm = ms_triage_dt_tm, m_rec->pat[pl_cnt].s_docassign_dt_tm =
    ms_doc_dt_tm, m_rec->pat[pl_cnt].f_acuity_level_id = tc.acuity_level_id
    IF (tc.primary_doc_id > 0)
     m_rec->pat[pl_cnt].s_ed_provider = trim(pr1.name_full_formatted)
    ELSE
     m_rec->pat[pl_cnt].s_ed_provider = trim(pr2.name_full_formatted)
    ENDIF
    ms_tmp = concat(trim(a.street_addr),trim(concat(" ",trim(a.street_addr2))),trim(concat(" ",trim(a
        .street_addr3))),trim(concat(" ",trim(a.street_addr4))),trim(concat(" ",trim(a.city))),
     trim(concat(" ",trim(a.state))),trim(concat(" ",trim(a.zipcode)))), m_rec->pat[pl_cnt].s_address
     = ms_tmp
   ENDIF
  FOOT REPORT
   stat = alterlist(m_rec->pat,pl_cnt),
   CALL echo(concat("count: ",trim(cnvtstring(pl_cnt))," tot mins: ",trim(cnvtstring(pl_tot_mins)))),
   mf_avg_wait = (cnvtreal(pl_tot_mins)/ cnvtreal(pl_cnt)),
   CALL echo(concat("avg wait: ",trim(cnvtstring(mf_avg_wait))," mins"))
  WITH nocounter, outerjoin = d1
 ;end select
 IF (size(m_rec->pat,5))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
    track_reference tr
   PLAN (d)
    JOIN (tr
    WHERE (tr.tracking_ref_id=m_rec->pat[d.seq].f_acuity_level_id))
   DETAIL
    m_rec->pat[d.seq].s_esi_acuity = tr.display
   WITH nocounter
  ;end select
  SELECT INTO value(concat("bhscust:",ms_filename))
   FROM (dummyt d  WITH seq = value(size(m_rec->pat,5)))
   PLAN (d)
   HEAD REPORT
    ms_tmp = concat("DATE_OF_SERVICE,NAME,ADDRESS,QUICK_REG_DT_TM,","TRIAGE_DT_TM,",
     "DOC_ASSIGN_DT_TM,WAIT_TIME_MINS,ESI_SCORE"), col 0, row + 0,
    ms_tmp
   DETAIL
    ms_tmp = concat('"',m_rec->pat[d.seq].s_service_dt_tm,'",','"',m_rec->pat[d.seq].s_pat_name,
     '",','"',m_rec->pat[d.seq].s_address,'",','"',
     m_rec->pat[d.seq].s_reg_dt_tm,'",','"',m_rec->pat[d.seq].s_triage_dt_tm,'",',
     '"',m_rec->pat[d.seq].s_docassign_dt_tm,'",','"',trim(cnvtstring(m_rec->pat[d.seq].
       l_wait_time_mins)),
     '",','"',m_rec->pat[d.seq].s_esi_acuity,'"'), col 0, row + 1,
    ms_tmp
   WITH nocounter, maxcol = 2000
  ;end select
  IF (findfile(concat("bhscust:",ms_filename)) > 0)
   SET ms_tmp = concat("BMLH 30 Min Pledge Report ",format(sysdate,"dd-mmm-yyyy hh:mm;;d"))
   CALL emailfile(concat("$bhscust/",ms_filename),concat("$bhscust/",ms_filename),ms_recipients,
    ms_tmp,1)
   IF (findfile(concat("bhscust:",ms_filename))=1)
    CALL echo("Unable to delete email file")
   ELSE
    CALL echo("Email File Deleted")
   ENDIF
  ELSE
   CALL echo("email file not found")
  ENDIF
 ELSE
  SET ms_dclcom_str = concat('"no data" | mail -s "NO DATA FOUND - BMLH 30 Minute Pledge Report ',
   trim(format(sysdate,"dd-mmm-yyyy hh:mm;;d")),'" ',ms_recipients)
  CALL echo(concat("dclcom_str: ",ms_dclcom_str))
  SET ml_dclcom_len = size(trim(ms_dclcom_str))
  SET mn_dclcom_stat = 0
  SET stat = dcl(ms_dclcom_str,ml_dclcom_len,mn_dclcom_stat)
  IF (stat=0)
   CALL echo("error sending email")
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data[1].status = "S"
END GO
