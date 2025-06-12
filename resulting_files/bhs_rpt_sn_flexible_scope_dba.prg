CREATE PROGRAM bhs_rpt_sn_flexible_scope:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Please select the start date." = "CURDATE",
  "Please select the end date." = "CURDATE"
  WITH s_outdev, s_start_date, s_end_date
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 data[*]
     2 f_peron_id = f8
     2 f_encntr_id = f8
     2 d_event_dt_tm = dq8
     2 s_surg_case_num = vc
     2 f_event_id = f8
     2 s_flexible_scope = vc
     2 s_scope_model = vc
     2 s_scope_serial_num = vc
     2 s_ready_for_use = vc
     2 s_used_by = vc
     2 s_mrn = vc
 ) WITH protect
 DECLARE mf_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_snfsverifiedscopeready = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SNFSVERIFIEDSCOPEREADY")), protect
 DECLARE mf_snfsflexiblescope = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SNFSFLEXIBLESCOPE")
  ), protect
 DECLARE mf_snfsusedby = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SNFSUSEDBY")), protect
 DECLARE mf_snfsmodelnumber = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SNFSMODELNUMBER")),
 protect
 DECLARE mf_snfsserialnumber = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SNFSSERIALNUMBER")),
 protect
 DECLARE mf_mrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_ocfcompression = f8 WITH constant(uar_get_code_by("DISPLAYKEY",120,"OCFCOMPRESSION")),
 protect
 DECLARE mf_assist = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"ASSIST")), protect
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE ml_acnt = i4 WITH noconstant(0), protect
 DECLARE ml_bcnt = i4 WITH noconstant(0), protect
 DECLARE ml_num = i4 WITH noconstant(0), protect
 DECLARE ml_pos = i4 WITH noconstant(0), protect
 DECLARE mf_event_id = f8 WITH noconstant(0.0), protect
 DECLARE ms_last_mod = vc WITH noconstant(""), protect
 DECLARE ms_start_date = vc WITH noconstant(""), protect
 DECLARE ms_end_date = vc WITH noconstant(""), protect
 DECLARE ms_ready_for_use = vc WITH noconstant(""), protect
 DECLARE ms_flexible_scope = vc WITH noconstant(""), protect
 DECLARE ms_used_by = vc WITH noconstant(""), protect
 DECLARE ms_scope_model = vc WITH noconstant(""), protect
 DECLARE ms_scope_serial_num = vc WITH noconstant(""), protect
 DECLARE ml_blob_ret_len = i4 WITH noconstant(0), protect
 DECLARE ml_blob_len = i4 WITH noconstant(0), protect
 DECLARE mc_blob_out = c32000 WITH noconstant(fillstring(32000," ")), protect
 DECLARE mc_blob_out2 = c32000 WITH noconstant(fillstring(32000," ")), protect
 DECLARE ms_last_mod = vc WITH noconstant(""), protect
 SET ms_start_date = concat( $S_START_DATE," 00:00:00")
 SET ms_end_date = concat( $S_END_DATE," 23:59:59")
 SELECT INTO "nl:"
  FROM surgical_case s,
   encounter e,
   person p,
   encntr_alias mrn,
   clinical_event c
  PLAN (s
   WHERE s.surg_start_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
    AND s.cancel_dt_tm=null
    AND s.encntr_id > 0.0
    AND s.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=s.encntr_id
    AND e.active_ind=1
    AND e.active_status_cd=mf_active
    AND e.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.active_status_cd=mf_active
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.encntr_alias_type_cd=mf_mrn_cd
    AND mrn.active_ind=1
    AND mrn.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (c
   WHERE c.encntr_id=e.encntr_id
    AND c.event_cd IN (mf_snfsverifiedscopeready, mf_snfsflexiblescope, mf_snfsusedby,
   mf_snfsmodelnumber, mf_snfsserialnumber)
    AND c.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND c.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd)
    AND c.view_level=1)
  ORDER BY p.person_id, e.encntr_id, s.surg_case_nbr_formatted,
   c.event_cd, c.event_end_dt_tm DESC
  HEAD REPORT
   ml_cnt = 0
  HEAD s.surg_case_nbr_formatted
   ml_cnt += 1, m_rec->l_cnt = ml_cnt, stat = alterlist(m_rec->data,ml_cnt),
   m_rec->data[ml_cnt].f_peron_id = p.person_id, m_rec->data[ml_cnt].f_encntr_id = e.encntr_id, m_rec
   ->data[ml_cnt].s_surg_case_num = trim(s.surg_case_nbr_formatted,3),
   m_rec->data[ml_cnt].s_mrn = trim(mrn.alias,3), m_rec->data[ml_cnt].s_used_by = ""
  HEAD c.event_cd
   mf_event_id = 0.0, m_rec->data[ml_cnt].d_event_dt_tm = c.event_end_dt_tm
   CASE (c.event_cd)
    OF mf_snfsverifiedscopeready:
     m_rec->data[ml_cnt].s_ready_for_use = c.result_val
    OF mf_snfsflexiblescope:
     m_rec->data[ml_cnt].s_flexible_scope = c.result_val
    OF mf_snfsusedby:
     m_rec->data[ml_cnt].f_event_id = c.event_id
    OF mf_snfsmodelnumber:
     m_rec->data[ml_cnt].s_scope_model = c.result_val
    OF mf_snfsserialnumber:
     m_rec->data[ml_cnt].s_scope_serial_num = c.result_val
   ENDCASE
  DETAIL
   null
  WITH nocounter
 ;end select
 IF (ml_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM ce_event_prsnl c,
   prsnl p
  PLAN (c
   WHERE expand(ml_num,1,size(m_rec->data,5),c.event_id,m_rec->data[ml_num].f_event_id)
    AND c.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND c.action_type_cd=mf_assist)
   JOIN (p
   WHERE p.person_id=c.action_prsnl_id)
  HEAD REPORT
   ml_pos = 0
  DETAIL
   ml_pos = locateval(ml_num,1,size(m_rec->data,5),c.event_id,m_rec->data[ml_num].f_event_id)
   WHILE (ml_pos > 0)
    m_rec->data[ml_pos].s_used_by = p.name_full_formatted,ml_pos = locateval(ml_num,(ml_pos+ 1),size(
      m_rec->data,5),c.event_id,m_rec->data[ml_num].f_event_id)
   ENDWHILE
  WITH expand = 1, nocounter
 ;end select
 SELECT INTO  $S_OUTDEV
  date = format(m_rec->data[d1.seq].d_event_dt_tm,"dd-mmm-yyyy;;d"), time = format(m_rec->data[d1.seq
   ].d_event_dt_tm,"hh:mm;;m"), surginet_case_num = trim(substring(1,100,m_rec->data[d1.seq].
    s_surg_case_num),3),
  scope_model = trim(substring(1,255,m_rec->data[d1.seq].s_scope_model),3), scope_serial_number =
  trim(substring(1,255,m_rec->data[d1.seq].s_scope_serial_num),3), ready_for_use = trim(substring(1,
    255,m_rec->data[d1.seq].s_ready_for_use),3),
  used_by = trim(substring(1,255,m_rec->data[d1.seq].s_used_by),3), mrn = trim(substring(1,255,m_rec
    ->data[d1.seq].s_mrn),3)
  FROM (dummyt d1  WITH seq = value(m_rec->l_cnt))
  PLAN (d1)
  WITH format, separator = " ", nocounter
 ;end select
 SET ms_last_mod = "000 - 24-Mar-2020 - Josh DeLeenheer/Matt Butler (HPG)"
#exit_script
 FREE RECORD data
END GO
