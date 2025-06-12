CREATE PROGRAM bhs_rpt_rte_time_to_sign:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 phy[*]
     2 f_prsnl_id = f8
     2 s_provider_name = vc
   1 rte[*]
     2 f_event_id = f8
     2 f_action_prsnl = f8
     2 s_performed_dt_tm = vc
     2 f_order_id = f8
     2 s_event_disp = vc
     2 s_provider = vc
     2 s_patient_name = vc
     2 s_encntr_type = vc
     2 s_mrn = vc
     2 s_received_dt_tm = vc
     2 s_endorsed_dt_tm = vc
     2 s_time_to_endorse = vc
 ) WITH protect
 DECLARE ml_num = i4 WITH noconstant(0), protect
 DECLARE ml_numres = i4 WITH noconstant(0), protect
 DECLARE ml_attloc = i4 WITH noconstant(0), protect
 CALL echo( $S_BEG_DT)
 CALL echo( $S_END_DT)
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat( $S_BEG_DT," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat( $S_END_DT," 23:59:59"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_perform_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
 DECLARE mf_endorse_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"ENDORSE"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 CALL echo(build2("perform_cd: ",mf_perform_cd))
 CALL echo(build2("endorse_cd: ",mf_endorse_cd))
 CALL echo(ms_beg_dt_tm)
 CALL echo(ms_end_dt_tm)
 DECLARE md_starttime = dq8 WITH protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 CALL echo("get physicians")
 SET md_starttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.active_ind=1
    AND p.end_effective_dt_tm > sysdate
    AND p.physician_ind=1
    AND p.username > " "
    AND  NOT (p.username IN ("SPN*")))
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_rec->phy,5))
    stat = alterlist(m_rec->phy,(pl_cnt+ 10))
   ENDIF
   m_rec->phy[pl_cnt].f_prsnl_id = p.person_id, m_rec->phy[pl_cnt].s_provider_name = trim(p
    .name_full_formatted)
  FOOT REPORT
   stat = alterlist(m_rec->phy,pl_cnt),
   CALL echo(concat("total physicians: ",trim(cnvtstring(pl_cnt))))
  WITH nocounter
 ;end select
 CALL echo(build("select prsnl = ",datetimediff(cnvtdatetime(curdate,curtime3),md_starttime,5)))
 SET md_starttime = cnvtdatetime(curdate,curtime3)
 CALL echo("get rtes endorsed in date range")
 SELECT INTO "nl:"
  FROM ce_event_prsnl cp1,
   ce_event_prsnl cp2
  PLAN (cp1
   WHERE expand(ml_num,1,size(m_rec->phy,5),cp1.action_prsnl_id,m_rec->phy[ml_num].f_prsnl_id)
    AND cp1.action_type_cd=mf_endorse_cd
    AND cp1.action_dt_tm > cnvtdatetime(ms_beg_dt_tm)
    AND cp1.action_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND cp1.action_status_cd=mf_completed_cd
    AND cp1.person_id > 0)
   JOIN (cp2
   WHERE cp2.event_id=cp1.event_id
    AND cp2.valid_until_dt_tm >= cnvtdatetime(ms_end_dt_tm)
    AND ((cp2.action_type_cd+ 0)=mf_perform_cd)
    AND ((cp2.action_status_cd+ 0)=mf_completed_cd))
  ORDER BY cp1.event_id, cp1.action_dt_tm
  HEAD REPORT
   pl_cnt = 0, pn_cont = 0
  HEAD cp1.event_id
   pn_cont = 0
   IF (datetimediff(cp1.action_dt_tm,cp2.action_dt_tm,3) > 96)
    pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->rte,pl_cnt), pn_cont = 1
   ENDIF
  DETAIL
   IF (pn_cont=1)
    m_rec->rte[pl_cnt].s_performed_dt_tm = trim(format(cp2.action_dt_tm,"dd-mmm-yyyy hh:mm;;d")),
    m_rec->rte[pl_cnt].s_endorsed_dt_tm = trim(format(cp1.action_dt_tm,"dd-mmm-yyyy hh:mm;;d")),
    m_rec->rte[pl_cnt].f_event_id = cp1.event_id,
    m_rec->rte[pl_cnt].s_time_to_endorse = cnvtstring(datetimediff(cp1.action_dt_tm,cp2.action_dt_tm,
      3)), m_rec->rte[pl_cnt].f_action_prsnl = cp1.action_prsnl_id, ml_attloc = 0,
    ml_attloc = locateval(ml_numres,1,size(m_rec->phy,5),cp1.action_prsnl_id,m_rec->phy[ml_numres].
     f_prsnl_id)
    IF (ml_attloc != 0)
     m_rec->rte[pl_cnt].s_provider = m_rec->phy[ml_attloc].s_provider_name
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 CALL echo(build("select ce event prsnl = ",datetimediff(cnvtdatetime(curdate,curtime3),md_starttime,
    5)))
 SET md_starttime = cnvtdatetime(curdate,curtime3)
 CALL echo("get MRN")
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encntr_alias ea,
   person p
  PLAN (ce
   WHERE expand(ml_num,1,size(m_rec->rte,5),ce.event_id,m_rec->rte[ml_num].f_event_id)
    AND ce.valid_from_dt_tm <= cnvtdatetime(ms_end_dt_tm)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (p
   WHERE p.person_id=ce.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ea.encntr_alias_type_cd=mf_mrn_cd)
  ORDER BY ce.event_id
  HEAD ce.event_id
   ml_attloc = 0, ml_attloc = locateval(ml_numres,1,size(m_rec->rte,5),ce.event_id,m_rec->rte[
    ml_numres].f_event_id)
   IF (ml_attloc != 0)
    m_rec->rte[ml_attloc].s_mrn = trim(ea.alias), m_rec->rte[ml_attloc].s_patient_name = p
    .name_full_formatted
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 CALL echo(build("cnvtdatetime(md_starttime) = ",cnvtdatetime(md_starttime)))
 CALL echo(build("select clinical_event = ",datetimediff(cnvtdatetime(curdate,curtime3),md_starttime,
    5)))
 SET md_starttime = cnvtdatetime(curdate,curtime3)
 IF (size(m_rec->rte,5) > 0)
  SELECT INTO value( $OUTDEV)
   provider = trim(substring(1,50,m_rec->rte[d.seq].s_provider),3), patient_name = trim(substring(1,
     50,m_rec->rte[d.seq].s_patient_name),3), mrn = m_rec->rte[d.seq].s_mrn,
   received_dt_tm = m_rec->rte[d.seq].s_performed_dt_tm, endorsed_dt_tm = m_rec->rte[d.seq].
   s_endorsed_dt_tm, time = m_rec->rte[d.seq].s_time_to_endorse
   FROM (dummyt d  WITH seq = value(size(m_rec->rte,5)))
   PLAN (d)
   WITH nocounter, maxrow = 1, maxcol = 2000,
    format, separator = " "
  ;end select
  CALL echo(build("cnvtdatetime(md_starttime) = ",md_starttime))
  CALL echo(build("select to ouput = ",datetimediff(cnvtdatetime(curdate,curtime3),md_starttime,5)))
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, "No records found"
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
