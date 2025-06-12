CREATE PROGRAM bhs_pp_mu_export:dba
 PROMPT
  "Extract File Name" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, ms_start_dt, ms_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_status = vc
   1 msg[*]
     2 s_phys_npi = vc
     2 f_phys_person_id = f8
     2 s_phys_name = vc
     2 s_patient_cmrn = vc
     2 s_patient_name = vc
     2 f_encntr_id = f8
     2 s_msg_dt_tm = vc
     2 f_person_id = f8
     2 s_pool_name = vc
     2 f_pool_id = f8
 ) WITH protect
 FREE RECORD m_rec2
 RECORD m_rec2(
   1 msg[*]
     2 f_pool_id = f8
     2 s_pool_name = vc
     2 s_provider_name = vc
     2 f_provider_person_id = f8
     2 s_provider_npi = vc
 )
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_bhs_ext_id_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,
   "BHSEXTERNALID"))
 DECLARE mf_org_nbr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BHSORGNUMBER"))
 DECLARE mf_child_rel_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",24,"C"))
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mf_npi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "NATIONALPROVIDERIDENTIFIER"))
 DECLARE mf_start_dt = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DT,"DD-MMM-YYYY"),
   000000))
 DECLARE mf_end_dt = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_END_DT,"DD-MMM-YYYY"),
   235959))
 DECLARE mf_inbox_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop1 = i4 WITH protect, noconstant(0)
 DECLARE mf_tmp_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.name_last_key="MYHEALTH"
   AND p.name_first_key="PORTAL"
   AND p.active_ind=1
  DETAIL
   mf_inbox_id = p.person_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "Inbox ID is not valid"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   task_activity ta1,
   task_activity ta2,
   prsnl pr,
   prsnl_group pg,
   long_text lt
  PLAN (taa
   WHERE taa.assign_prsnl_id=mf_inbox_id
    AND taa.beg_eff_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_end_dt)
    AND taa.active_ind=1)
   JOIN (ta1
   WHERE ta1.task_id=taa.task_id
    AND ta1.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=ta1.msg_sender_id
    AND pr.active_ind=1)
   JOIN (pg
   WHERE pg.prsnl_group_id=outerjoin(ta1.msg_sender_prsnl_group_id)
    AND pg.active_ind=outerjoin(1))
   JOIN (ta2
   WHERE ta2.task_id=outerjoin(ta1.orig_pool_task_id))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(ta1.msg_text_id))
  ORDER BY taa.beg_eff_dt_tm, ta1.person_id, ta1.encntr_id,
   ta1.msg_sender_id
  HEAD REPORT
   pl_cnt = 0, pl_beg_pos = 0
  HEAD ta1.encntr_id
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->msg,pl_cnt), m_rec->msg[pl_cnt].f_phys_person_id =
   ta1.msg_sender_id,
   m_rec->msg[pl_cnt].f_person_id = ta1.person_id, m_rec->msg[pl_cnt].f_encntr_id = ta1.encntr_id,
   m_rec->msg[pl_cnt].s_phys_name = trim(pr.name_full_formatted),
   m_rec->msg[pl_cnt].s_msg_dt_tm = trim(format(taa.beg_eff_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")), m_rec
   ->msg[pl_cnt].s_pool_name = pg.prsnl_group_name, m_rec->msg[pl_cnt].f_pool_id = pg.prsnl_group_id
  WITH nocounter
 ;end select
 IF (size(m_rec->msg,5)=0)
  CALL echo("no messages found")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->msg,5))),
   prsnl_alias pa
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_id=m_rec->msg[d.seq].f_phys_person_id)
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.prsnl_alias_type_cd=mf_npi_cd)
  DETAIL
   m_rec->msg[d.seq].s_phys_npi = pa.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->msg,5))),
   person p,
   person_alias pa
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=m_rec->msg[d.seq].f_person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cmrn_cd)
  DETAIL
   m_rec->msg[d.seq].s_patient_cmrn = pa.alias, m_rec->msg[d.seq].s_patient_name = p
   .name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->msg,5))),
   prsnl_group_reltn pgr,
   prsnl p,
   prsnl_alias pa
  PLAN (d
   WHERE (m_rec->msg[d.seq].s_phys_npi <= " "))
   JOIN (pgr
   WHERE (pgr.prsnl_group_id=m_rec->msg[d.seq].f_pool_id)
    AND pgr.active_ind=1)
   JOIN (p
   WHERE p.person_id=pgr.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm > outerjoin(sysdate)
    AND pa.prsnl_alias_type_cd=outerjoin(mf_npi_cd))
  HEAD REPORT
   pl_cnt2 = 0
  DETAIL
   IF (size(m_rec->msg[d.seq].s_phys_npi)=0)
    pl_cnt2 = (pl_cnt2+ 1), stat = alterlist(m_rec2->msg,pl_cnt2), m_rec2->msg[pl_cnt2].f_pool_id =
    m_rec->msg[d.seq].f_pool_id,
    m_rec2->msg[pl_cnt2].s_pool_name = m_rec->msg[d.seq].s_pool_name, m_rec2->msg[pl_cnt2].
    s_provider_name = p.name_full_formatted, m_rec2->msg[pl_cnt2].f_provider_person_id = p.person_id,
    m_rec2->msg[pl_cnt2].s_provider_npi = pa.alias
   ENDIF
  WITH nocounter
 ;end select
 SET m_rec->s_status = "Success"
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = size(m_rec->msg,5))
  HEAD REPORT
   ms_temp = concat('"phys_NPI","phys_person_id","phys_name","pool","pool_id",',
    '"patient_CMRN","patient_name","encounter_id","msg_dt_tm"'), col 0, ms_temp
  DETAIL
   ms_temp = concat('"',trim(m_rec->msg[d.seq].s_phys_npi),'",','"',trim(cnvtstring(m_rec->msg[d.seq]
      .f_phys_person_id)),
    '",','"',trim(m_rec->msg[d.seq].s_phys_name),'",','"',
    trim(m_rec->msg[d.seq].s_pool_name),'",','"',trim(cnvtstring(m_rec->msg[d.seq].f_pool_id)),'",',
    '"',trim(m_rec->msg[d.seq].s_patient_cmrn),'",','"',trim(m_rec->msg[d.seq].s_patient_name),
    '",','"',trim(cnvtstring(m_rec->msg[d.seq].f_encntr_id)),'",','"',
    trim(m_rec->msg[d.seq].s_msg_dt_tm),'"'), row + 1, col 0,
   ms_temp, row + 1
  WITH format, separator = " ", maxrow = 1,
   maxcol = 300
 ;end select
#exit_script
 FREE RECORD m_rec
 FREE RECORD m_rec2
END GO
