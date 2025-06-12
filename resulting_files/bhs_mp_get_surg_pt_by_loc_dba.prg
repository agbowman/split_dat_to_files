CREATE PROGRAM bhs_mp_get_surg_pt_by_loc:dba
 PROMPT
  "Surgery Arya:" = 0,
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH f_surg_area, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 surg[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_surg_case_id = f8
     2 f_surg_area_cd = f8
     2 s_surg_area = vc
     2 f_sched_surg_area_cd = f8
     2 s_sched_surg_area = vc
     2 s_case_nbr = vc
     2 s_name_first = vc
     2 s_name_last = vc
     2 s_proc_dt_tm = vc
     2 s_dob = vc
     2 s_gender = vc
     2 s_sched_dt_tm = vc
     2 s_proc_stat = vc
     2 s_proc_stat_dt_tm = vc
 ) WITH protect
 DECLARE mf_surg_area = f8 WITH protect, constant(cnvtreal( $F_SURG_AREA))
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 IF (((mf_surg_area=0.0) OR (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) ))
 )
  SET ms_tmp =
  '{"surg_status":"Error", "request_status":"S","patient_name_first":"","msg":"Inputs cannot be blank"}'
  GO TO exit_script
 ELSEIF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  SET ms_tmp =
  '{"surg_status":"Error", "request_status":"S","patient_name_first":"","msg":"End Date must be > Beg Date"}'
  GO TO exit_script
 ENDIF
 CALL echo(build2("surg area cd: ",mf_surg_area))
 CALL echo("select 1")
 SELECT INTO "nl:"
  FROM surgical_case sc,
   person p,
   encounter e
  PLAN (sc
   WHERE ((sc.sched_surg_area_cd=mf_surg_area) OR (sc.surg_area_cd=mf_surg_area))
    AND sc.sched_start_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND sc.active_ind=1)
   JOIN (p
   WHERE p.person_id=sc.person_id)
   JOIN (e
   WHERE (e.encntr_id= Outerjoin(sc.encntr_id))
    AND (e.active_ind= Outerjoin(1)) )
  ORDER BY p.person_id, sc.encntr_id, sc.surg_start_dt_tm
  HEAD REPORT
   pl_cnt = 0
  HEAD p.person_id
   null
  HEAD sc.surg_case_nbr_formatted
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->surg,5))
    CALL alterlist(m_rec->surg,(pl_cnt+ 10))
   ENDIF
   m_rec->surg[pl_cnt].f_person_id = e.person_id, m_rec->surg[pl_cnt].f_encntr_id = e.encntr_id,
   m_rec->surg[pl_cnt].f_surg_case_id = sc.surg_case_id,
   m_rec->surg[pl_cnt].f_surg_area_cd = sc.surg_area_cd
   IF (sc.surg_area_cd > 0.0)
    m_rec->surg[pl_cnt].s_surg_area = trim(uar_get_code_display(sc.surg_area_cd),3)
   ENDIF
   m_rec->surg[pl_cnt].f_sched_surg_area_cd = sc.sched_surg_area_cd
   IF (sc.sched_surg_area_cd > 0.0)
    m_rec->surg[pl_cnt].s_sched_surg_area = trim(uar_get_code_display(sc.sched_surg_area_cd),3)
   ENDIF
   m_rec->surg[pl_cnt].s_case_nbr = trim(sc.surg_case_nbr_formatted,3), m_rec->surg[pl_cnt].
   s_name_first = trim(p.name_first,3), m_rec->surg[pl_cnt].s_name_last = trim(p.name_last,3),
   m_rec->surg[pl_cnt].s_sched_dt_tm = trim(format(sc.sched_start_dt_tm,"mm/dd/yyyy hh:mm;;d"),3),
   m_rec->surg[pl_cnt].s_proc_dt_tm = trim(format(sc.surg_start_dt_tm,"mm/dd/yyyy hh:mm;;d"),3),
   m_rec->surg[pl_cnt].s_dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy hh:mm;;d"),3),
   m_rec->surg[pl_cnt].s_gender = trim(uar_get_code_display(p.sex_cd),3)
   IF (sc.surg_start_dt_tm=null)
    m_rec->surg[pl_cnt].s_proc_stat = "Procedure scheduled"
   ENDIF
   IF (sc.cancel_dt_tm != null)
    m_rec->surg[pl_cnt].s_proc_stat = "Canceled"
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->surg,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("select 2")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->surg,5))),
   tracking_item ti,
   tracking_event te,
   track_event tke
  PLAN (d)
   JOIN (ti
   WHERE (ti.parent_entity_id=m_rec->surg[d.seq].f_surg_case_id)
    AND ti.parent_entity_name="SURGICAL_CASE"
    AND ti.active_ind=1)
   JOIN (te
   WHERE te.tracking_id=ti.tracking_id
    AND te.active_ind=1)
   JOIN (tke
   WHERE tke.track_event_id=te.track_event_id
    AND tke.active_ind=1)
  ORDER BY d.seq, te.requested_dt_tm DESC
  HEAD d.seq
   m_rec->surg[d.seq].s_proc_stat = trim(tke.description,3), m_rec->surg[d.seq].s_proc_stat_dt_tm =
   trim(format(tke.updt_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
  WITH nocounter
 ;end select
 FOR (ml_cnt = 1 TO size(m_rec->surg,5))
   IF (ml_cnt=1)
    SET ms_tmp = "["
   ELSE
    SET ms_tmp = concat(ms_tmp,",")
   ENDIF
   SET ms_tmp = concat(ms_tmp,'{"surgAreaCodeValue":"',trim(cnvtstring(m_rec->surg[ml_cnt].
      f_surg_area_cd),3),'",','"surgArea":"',
    m_rec->surg[ml_cnt].s_surg_area,'",','"schedSurgAreaCodeValue":"',trim(cnvtstring(m_rec->surg[
      ml_cnt].f_sched_surg_area_cd),3),'",',
    '"schedSurgArea":"',m_rec->surg[ml_cnt].s_sched_surg_area,'",','"caseNumber":"',m_rec->surg[
    ml_cnt].s_case_nbr,
    '",','"firstName":"',m_rec->surg[ml_cnt].s_name_first,'",','"lastName":"',
    m_rec->surg[ml_cnt].s_name_last,'",','"procedureDateTime":"',m_rec->surg[ml_cnt].s_proc_dt_tm,
    '",',
    '"dob":"',m_rec->surg[ml_cnt].s_dob,'",','"gender":"',m_rec->surg[ml_cnt].s_gender,
    '",','"schedStartDateTime":"',m_rec->surg[ml_cnt].s_sched_dt_tm,'",','"procedureStatus":"',
    m_rec->surg[ml_cnt].s_proc_stat,'",','"procedureStatusDateTime":"',trim(m_rec->surg[ml_cnt].
     s_proc_stat_dt_tm,3),'"}')
   IF (ml_cnt=size(m_rec->surg,5))
    SET ms_tmp = concat(ms_tmp,"]")
   ENDIF
 ENDFOR
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
 SET _memory_reply_string = ms_tmp
 CALL echo(_memory_reply_string)
END GO
