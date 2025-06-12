CREATE PROGRAM bhs_rpt_sn_case_times_dtl:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Surgical Area" = 0,
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Enter Provider Last Name:" = "",
  "Select Provider(s):" = value(0.0)
  WITH outdev, mf_surgarea, ms_starttime,
  ms_endtime, s_prov_name_last, f_provider_id
 DECLARE mf_finnbr_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_snendorhold_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"SNENDORHOLDMIN")),
 protect
 DECLARE mf_snstartorhold_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"SNSTARTORHOLDMIN"
   )), protect
 DECLARE mf_snpacuout_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - PACU Acuity Stop Time")), protect
 DECLARE mf_snpacuin_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - PACU Acuity Start Time")), protect
 DECLARE mf_snorout_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,"SN - Out OR (min)")),
 protect
 DECLARE mf_snorin_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,"SN - In OR (min)")),
 protect
 DECLARE mf_snpreopout_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - Out Pre OP (min)")), protect
 DECLARE mf_snpreopin_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - In Pre OP (min)")), protect
 DECLARE mf_pacuext_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",10039,"PACUEXTENDEDRECOVERY")),
 protect
 DECLARE mf_pacuii_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",10039,"PACUII")), protect
 DECLARE mf_pacui_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",10039,"PACUI")), protect
 DECLARE ml_loc1 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc2 = i4 WITH protect, noconstant(0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 prov[*]
     2 f_prov_id = f8
     2 s_prov_name = vc
 )
 FREE RECORD m_case_time
 RECORD m_case_time(
   1 l_cnt = i4
   1 list[*]
     2 f_sched_dttm = f8
     2 s_sched_day = vc
     2 s_sched_rm = vc
     2 s_actual_rm = vc
     2 s_sched_area = vc
     2 s_case_nm = vc
     2 s_acct_nm = vc
     2 s_specialty = vc
     2 f_checkin_dttm = f8
     2 f_preopin_dttm = f8
     2 f_preopout_dttm = f8
     2 f_patinrm_dttm = f8
     2 f_procstart_dttm = f8
     2 f_procend_dttm = f8
     2 s_surgstart_day = vc
     2 f_surstart_dttm = f8
     2 f_surstop_dttm = f8
     2 f_patoutrm_dttm = f8
     2 f_orholdin_dttm = f8
     2 f_orholdout_dttm = f8
     2 f_pacu1in_dttm = f8
     2 f_pacu1out_dttm = f8
     2 f_pacu2in_dttm = f8
     2 f_pacu2out_dttm = f8
     2 f_pacu3in_dttm = f8
     2 f_pacu3out_dttm = f8
     2 s_cancel_ind = vc
     2 f_cancel_dttm = f8
     2 s_cancel_res = vc
     2 s_schproc_name = vc
     2 s_proc_name = vc
     2 s_proc_type = vc
     2 s_schsurgeon = vc
     2 s_procsurgeon = vc
     2 l_procdur_mins = i4
     2 f_proccode = f8
     2 s_schproc_type = vc
 ) WITH protect
 IF (( $F_PROVIDER_ID=0.0))
  SET ms_prov_parse = " 1=1"
 ELSE
  SELECT INTO "nl:"
   FROM prsnl pr
   WHERE (pr.person_id= $F_PROVIDER_ID)
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt += 1,
    CALL alterlist(m_rec->prov,pl_cnt), m_rec->prov[pl_cnt].f_prov_id = pr.person_id,
    m_rec->prov[pl_cnt].s_prov_name = trim(pr.name_full_formatted,3)
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(m_case_time)
 SELECT INTO "nl:"
  FROM surgical_case s,
   surg_case_procedure scp,
   prsnl prn,
   prsnl prn2,
   encntr_alias ea,
   prsnl_group png,
   dummyt d1,
   case_times c1,
   dummyt d2,
   sn_acuity_level sa1
  PLAN (s
   WHERE (s.surg_case_nbr_locn_cd= $MF_SURGAREA)
    AND s.sched_start_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $MS_STARTTIME,"mm/dd/yyyy"),0) AND
   cnvtdatetime(cnvtdate2( $MS_ENDTIME,"mm/dd/yyyy"),235959))
   JOIN (scp
   WHERE (scp.surg_case_id= Outerjoin(s.surg_case_id)) )
   JOIN (prn
   WHERE (prn.person_id= Outerjoin(scp.sched_primary_surgeon_id)) )
   JOIN (prn2
   WHERE (prn2.person_id= Outerjoin(scp.primary_surgeon_id)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(s.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_finnbr_cd))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (png
   WHERE (png.prsnl_group_id= Outerjoin(scp.surg_specialty_id)) )
   JOIN (d1)
   JOIN (c1
   WHERE c1.surg_case_id=s.surg_case_id
    AND c1.task_assay_cd IN (mf_snpreopin_cd, mf_snpreopout_cd, mf_snorin_cd, mf_snorout_cd,
   mf_snstartorhold_cd,
   mf_snendorhold_cd))
   JOIN (d2)
   JOIN (sa1
   WHERE sa1.surg_case_id=s.surg_case_id
    AND sa1.acuity_level_cd IN (mf_pacui_cd, mf_pacuii_cd, mf_pacuext_cd))
  ORDER BY scp.surg_case_proc_id, s.surg_case_nbr_formatted
  HEAD REPORT
   m_case_time->l_cnt = 0, pl_add_ind = 0
  HEAD scp.surg_case_proc_id
   IF (((( $F_PROVIDER_ID=0.0)) OR (((locateval(ml_loc1,1,size(m_rec->prov,5),prn.person_id,m_rec->
    prov[ml_loc1].f_prov_id) > 0) OR (locateval(ml_loc2,1,size(m_rec->prov,5),prn2.person_id,m_rec->
    prov[ml_loc2].f_prov_id) > 0)) )) )
    pl_add_ind = 1, m_case_time->l_cnt += 1, stat = alterlist(m_case_time->list,m_case_time->l_cnt),
    m_case_time->list[m_case_time->l_cnt].f_sched_dttm = s.sched_start_dt_tm, m_case_time->list[
    m_case_time->l_cnt].s_sched_day = evaluate(cnvtstring(s.sched_start_day),"0","SUNDAY","1",
     "MONDAY",
     "2","TUESDAY","3","WEDNESDAY","4",
     "THURSDAY","5","FRIDAY","6","SATURDAY",
     "-"), m_case_time->list[m_case_time->l_cnt].s_sched_rm = uar_get_code_display(s.sched_op_loc_cd),
    m_case_time->list[m_case_time->l_cnt].s_actual_rm = uar_get_code_display(s.surg_op_loc_cd),
    m_case_time->list[m_case_time->l_cnt].s_sched_area = uar_get_code_display(s.surg_case_nbr_locn_cd
     ), m_case_time->list[m_case_time->l_cnt].s_case_nm = s.surg_case_nbr_formatted,
    m_case_time->list[m_case_time->l_cnt].s_acct_nm = ea.alias, m_case_time->list[m_case_time->l_cnt]
    .f_checkin_dttm = s.checkin_dt_tm, m_case_time->list[m_case_time->l_cnt].s_surgstart_day =
    evaluate(cnvtstring(s.surg_start_day),"0","SUNDAY","1","MONDAY",
     "2","TUESDAY","3","WEDNESDAY","4",
     "THURSDAY","5","FRIDAY","6","SATURDAY",
     "-"),
    m_case_time->list[m_case_time->l_cnt].f_surstart_dttm = s.surg_start_dt_tm, m_case_time->list[
    m_case_time->l_cnt].f_surstop_dttm = s.surg_stop_dt_tm, m_case_time->list[m_case_time->l_cnt].
    f_cancel_dttm = s.cancel_dt_tm,
    m_case_time->list[m_case_time->l_cnt].s_cancel_res = uar_get_code_display(s.cancel_reason_cd),
    m_case_time->list[m_case_time->l_cnt].s_cancel_ind = evaluate(s.cancel_reason_cd,null,"-",0,
     "Cancel"), m_case_time->list[m_case_time->l_cnt].f_procstart_dttm = scp.proc_start_dt_tm,
    m_case_time->list[m_case_time->l_cnt].f_procend_dttm = scp.proc_end_dt_tm, m_case_time->list[
    m_case_time->l_cnt].s_schproc_name = uar_get_code_description(scp.sched_surg_proc_cd),
    m_case_time->list[m_case_time->l_cnt].s_proc_name = uar_get_code_description(scp.surg_proc_cd),
    m_case_time->list[m_case_time->l_cnt].s_proc_type = evaluate(scp.primary_proc_ind,1,"PRIMARY",0,
     "SECONDARY"), m_case_time->list[m_case_time->l_cnt].s_schsurgeon = prn.name_full_formatted,
    m_case_time->list[m_case_time->l_cnt].s_procsurgeon = prn2.name_full_formatted,
    m_case_time->list[m_case_time->l_cnt].l_procdur_mins = scp.proc_dur_min, m_case_time->list[
    m_case_time->l_cnt].f_proccode = scp.sched_ud5_cd, m_case_time->list[m_case_time->l_cnt].
    s_specialty = png.prsnl_group_name,
    m_case_time->list[m_case_time->l_cnt].s_schproc_type = evaluate(scp.sched_primary_ind,1,"PRIMARY",
     0,"SECONDARY")
   ENDIF
  DETAIL
   IF (pl_add_ind=1)
    CASE (c1.task_assay_cd)
     OF mf_snpreopin_cd:
      m_case_time->list[m_case_time->l_cnt].f_preopin_dttm = c1.case_time_dt_tm
     OF mf_snpreopout_cd:
      m_case_time->list[m_case_time->l_cnt].f_preopout_dttm = c1.case_time_dt_tm
     OF mf_snorin_cd:
      m_case_time->list[m_case_time->l_cnt].f_patinrm_dttm = c1.case_time_dt_tm
     OF mf_snorout_cd:
      m_case_time->list[m_case_time->l_cnt].f_patoutrm_dttm = c1.case_time_dt_tm
     OF mf_snstartorhold_cd:
      m_case_time->list[m_case_time->l_cnt].f_orholdin_dttm = c1.case_time_dt_tm
     OF mf_snendorhold_cd:
      m_case_time->list[m_case_time->l_cnt].f_orholdout_dttm = c1.case_time_dt_tm
    ENDCASE
    CASE (sa1.acuity_level_cd)
     OF mf_pacui_cd:
      m_case_time->list[m_case_time->l_cnt].f_pacu1in_dttm = sa1.acuity_start_dt_tm,m_case_time->
      list[m_case_time->l_cnt].f_pacu1out_dttm = sa1.acuity_stop_dt_tm
     OF mf_pacuii_cd:
      m_case_time->list[m_case_time->l_cnt].f_pacu2in_dttm = sa1.acuity_start_dt_tm,m_case_time->
      list[m_case_time->l_cnt].f_pacu2out_dttm = sa1.acuity_stop_dt_tm
     OF mf_pacuext_cd:
      m_case_time->list[m_case_time->l_cnt].f_pacu3in_dttm = sa1.acuity_start_dt_tm,m_case_time->
      list[m_case_time->l_cnt].f_pacu3out_dttm = sa1.acuity_stop_dt_tm
    ENDCASE
   ENDIF
  FOOT  scp.surg_case_proc_id
   pl_add_ind = 0
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 CALL echorecord(m_case_time)
 SELECT INTO  $OUTDEV
  date_of_surgery = trim(format(cnvtdatetime(m_case_time->list[d.seq].f_sched_dttm),"MM/DD/YYYY;;q"),
   3), day_of_week = trim(substring(1,20,m_case_time->list[d.seq].s_sched_day),3), sched_or_rm = trim
  (substring(1,50,m_case_time->list[d.seq].s_sched_rm),3),
  actual_or_rm = trim(substring(1,50,m_case_time->list[d.seq].s_actual_rm),3), or_case_# = trim(
   substring(1,50,m_case_time->list[d.seq].s_case_nm),3), surgical_area = trim(substring(1,100,
    m_case_time->list[d.seq].s_sched_area),3),
  pat_acct# = trim(substring(1,50,m_case_time->list[d.seq].s_acct_nm),3), sched_start_dt =
  m_case_time->list[d.seq].f_sched_dttm"@SHORTDATETIME", cancel_flag = m_case_time->list[d.seq].
  s_cancel_ind,
  checkin_dt = m_case_time->list[d.seq].f_checkin_dttm"@SHORTDATETIME", preop_in_dt = m_case_time->
  list[d.seq].f_preopin_dttm"@SHORTDATETIME", preop_out_dt = m_case_time->list[d.seq].f_preopout_dttm
  "@SHORTDATETIME",
  preop_tmins = datetimediff(cnvtdatetime(m_case_time->list[d.seq].f_preopout_dttm),cnvtdatetime(
    m_case_time->list[d.seq].f_preopin_dttm),4), pat_inrm_dt = m_case_time->list[d.seq].
  f_patinrm_dttm"@SHORTDATETIME", surgery_start_dt = m_case_time->list[d.seq].f_surstart_dttm
  "@SHORTDATETIME",
  surgery_stop_dt = m_case_time->list[d.seq].f_surstop_dttm"@SHORTDATETIME", pat_outrm_dt =
  m_case_time->list[d.seq].f_patoutrm_dttm"@SHORTDATETIME", orhold_start_dt = m_case_time->list[d.seq
  ].f_orholdin_dttm"@SHORTDATETIME",
  orhold_end_dt = m_case_time->list[d.seq].f_orholdout_dttm"@SHORTDATETIME", surgery_tmins =
  datetimediff(cnvtdatetime(m_case_time->list[d.seq].f_surstop_dttm),cnvtdatetime(m_case_time->list[d
    .seq].f_surstart_dttm),4), orroom_tmins = datetimediff(cnvtdatetime(m_case_time->list[d.seq].
    f_patoutrm_dttm),cnvtdatetime(m_case_time->list[d.seq].f_patinrm_dttm),4),
  orhold_tmins = datetimediff(cnvtdatetime(m_case_time->list[d.seq].f_orholdout_dttm),cnvtdatetime(
    m_case_time->list[d.seq].f_orholdin_dttm),4), pacu1_in_dt = m_case_time->list[d.seq].
  f_pacu1in_dttm"@SHORTDATETIME", pacu1_out_dt = m_case_time->list[d.seq].f_pacu1out_dttm
  "@SHORTDATETIME",
  pacu1_tmins = datetimediff(cnvtdatetime(m_case_time->list[d.seq].f_pacu1out_dttm),cnvtdatetime(
    m_case_time->list[d.seq].f_pacu1in_dttm),4), pacu2_in_dt = m_case_time->list[d.seq].
  f_pacu2in_dttm"@SHORTDATETIME", pacu2_out_dt = m_case_time->list[d.seq].f_pacu2out_dttm
  "@SHORTDATETIME",
  pacu2_tmins = datetimediff(cnvtdatetime(m_case_time->list[d.seq].f_pacu2out_dttm),cnvtdatetime(
    m_case_time->list[d.seq].f_pacu2in_dttm),4), pacu3_in_dt = m_case_time->list[d.seq].
  f_pacu3in_dttm"@SHORTDATETIME", pacu3_out_dt = m_case_time->list[d.seq].f_pacu3out_dttm
  "@SHORTDATETIME",
  pacu3_tmins = datetimediff(cnvtdatetime(m_case_time->list[d.seq].f_pacu3out_dttm),cnvtdatetime(
    m_case_time->list[d.seq].f_pacu3in_dttm),4), pacu_tmins = ((datetimediff(cnvtdatetime(m_case_time
    ->list[d.seq].f_pacu1out_dttm),cnvtdatetime(m_case_time->list[d.seq].f_pacu1in_dttm),4)+
  datetimediff(cnvtdatetime(m_case_time->list[d.seq].f_pacu2out_dttm),cnvtdatetime(m_case_time->list[
    d.seq].f_pacu2in_dttm),4))+ datetimediff(cnvtdatetime(m_case_time->list[d.seq].f_pacu3out_dttm),
   cnvtdatetime(m_case_time->list[d.seq].f_pacu3in_dttm),4)), sch_proc_code = m_case_time->list[d.seq
  ].f_proccode,
  sch_proc_name = m_case_time->list[d.seq].s_schproc_name, sch_proc_type = m_case_time->list[d.seq].
  s_schproc_type, sch_surgeon = m_case_time->list[d.seq].s_schsurgeon,
  preform_proc_name = m_case_time->list[d.seq].s_proc_name, preform_proc_type = m_case_time->list[d
  .seq].s_proc_type, preform_proc_specialty = m_case_time->list[d.seq].s_specialty,
  preform_proc_surgeon = m_case_time->list[d.seq].s_procsurgeon, proc_start_dt = m_case_time->list[d
  .seq].f_procstart_dttm"@SHORTDATETIME", proc_end_dt = m_case_time->list[d.seq].f_procend_dttm
  "@SHORTDATETIME",
  proc_mins = m_case_time->list[d.seq].l_procdur_mins, cancel_date = m_case_time->list[d.seq].
  f_cancel_dttm"@SHORTDATETIME", cancel_reason = m_case_time->list[d.seq].s_cancel_res
  FROM (dummyt d  WITH seq = m_case_time->l_cnt)
  ORDER BY surgical_area, date_of_surgery, sched_start_dt
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
END GO
