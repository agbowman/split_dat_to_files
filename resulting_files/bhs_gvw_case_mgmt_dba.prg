CREATE PROGRAM bhs_gvw_case_mgmt:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 IF (validate(request)=0)
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
  SET request->person[1].person_id = 23473664
  SET request->visit[1].encntr_id = 67760755
  SET request->output_device = "MINE"
  SET request->visit_cnt = 1
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_risk_dt_tm = vc
   1 s_risk_by_name = vc
   1 s_risk_result = vc
   1 s_dir_dt_tm = vc
   1 s_dir_by_name = vc
   1 s_dir_result = vc
   1 s_mgmt_dt_tm = vc
   1 s_mgmt_by_name = vc
   1 s_mgmt_result = vc
 )
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE ms_pard = vc WITH protect, constant("\pard ")
 DECLARE ms_rtab = vc WITH protect, constant("\tab ")
 DECLARE ms_wr = vc WITH protect, constant("\f0 \fs18 \cb2 ")
 DECLARE ms_beg_tbl_row = vc WITH protect, constant("\trowd ")
 DECLARE ms_cell_padding = vc WITH protect, constant("\trgaph108 ")
 DECLARE ms_cell_margin = vc WITH protect, constant("\trleft108 ")
 DECLARE ms_left_align = vc WITH protect, constant("\ql ")
 DECLARE ms_cell_1_size = vc WITH protect, constant("\cellx2000 ")
 DECLARE ms_cell_2_size = vc WITH protect, constant("\cellx2000 ")
 DECLARE ms_cell_3_size = vc WITH protect, constant("\cellx2000 ")
 DECLARE ms_cell_4_size = vc WITH protect, constant("\cellx2000 ")
 DECLARE ms_beg_tbl_text = vc WITH protect, constant("\intbl ")
 DECLARE ms_end_cell = vc WITH protect, constant("\cell ")
 DECLARE ms_end_row = vc WITH protect, constant("\row ")
 DECLARE ms_newline = vc WITH protect, constant(concat(char(10),char(13)))
 DECLARE ms_wb = vc WITH protect, constant("{\b\cb2")
 DECLARE ms_uf = vc WITH protect, constant(" }")
 DECLARE ms_tmp = vc WITH protect, noconstant("")
 DECLARE mf_person_id = f8 WITH protect, noconstant(request->person[1].person_id)
 DECLARE mf_encntr_id = f8 WITH protect, constant(request->visit[1].encntr_id)
 DECLARE mf_high_risk_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HIGHRISKCRITERIASCREEN"))
 DECLARE mf_adv_dir_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADVANCEDIRECTIVETYPE"))
 DECLARE mf_case_mgmt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CASEMANAGEMENTFOLLOWUPNEEDED"))
 IF (mf_encntr_id > 0.0
  AND mf_person_id=0.0)
  SELECT INTO "nl:"
   FROM encounter e
   WHERE e.encntr_id=mf_encntr_id
    AND e.active_ind=1
   HEAD REPORT
    mf_person_id = e.person_id
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  ps_res = trim(ce.result_val), ps_event_end_dt_tm = trim(format(ce.event_end_dt_tm,
    "dd-mmm-yyyy hh:mm;;d"))
  FROM clinical_event ce,
   prsnl p
  PLAN (ce
   WHERE ce.person_id=mf_person_id
    AND ((ce.encntr_id+ 0)=mf_encntr_id)
    AND ce.event_cd IN (mf_high_risk_cd, mf_adv_dir_cd, mf_case_mgmt_cd)
    AND ce.valid_until_dt_tm >= sysdate
    AND ce.event_end_dt_tm <= sysdate)
   JOIN (p
   WHERE p.person_id=ce.performed_prsnl_id
    AND p.active_ind=1)
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   IF (ce.event_cd=mf_high_risk_cd)
    m_rec->s_risk_dt_tm = ps_event_end_dt_tm, m_rec->s_risk_result = ps_res, m_rec->s_risk_by_name =
    trim(p.name_full_formatted)
   ELSEIF (ce.event_cd=mf_adv_dir_cd)
    m_rec->s_dir_dt_tm = ps_event_end_dt_tm, m_rec->s_dir_result = ps_res, m_rec->s_dir_by_name =
    trim(p.name_full_formatted)
   ELSEIF (ce.event_cd=mf_case_mgmt_cd)
    m_rec->s_mgmt_dt_tm = ps_event_end_dt_tm, m_rec->s_mgmt_result = ps_res, m_rec->s_mgmt_by_name =
    trim(p.name_full_formatted)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(m_rec)
 SET ms_tmp = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 SET ms_tmp = concat(ms_tmp,"\fs20\b\ul High Risk Criteria Screen\b0\ul0\par","\trowd\trgaph144",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx3000",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx12200",
  "\fs20\b Data Documented \b0\intbl\cell"," ",m_rec->s_risk_result,"\intbl\cell","\row",
  "\trowd\trgaph144","\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx3000",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx12200",
  "\fs20\b Date/time of charting \b0\intbl\cell"," ",
  m_rec->s_risk_dt_tm,"\intbl\cell","\row","\trowd\trgaph144",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx3000",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx12200",
  "\fs20\b Performed by \b0\intbl\cell"," ",m_rec->s_risk_by_name,"\intbl\cell",
  "\row\pard\par","\fs20\b\ul Advance Directive Type\b0\ul0\par","\trowd\trgaph144",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx3000",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx12200",
  "\fs20\b Data Documented \b0\intbl\cell"," ",m_rec->s_dir_result,"\intbl\cell","\row",
  "\trowd\trgaph144","\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx3000",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx12200",
  "\fs20\b Date/time of charting \b0\intbl\cell"," ",
  m_rec->s_dir_dt_tm,"\intbl\cell","\row","\trowd\trgaph144",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx3000",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx12200",
  "\fs20\b Performed by \b0\intbl\cell"," ",m_rec->s_dir_by_name,"\intbl\cell",
  "\row\pard\par","\fs20\b\ul Case Management Follow-Up Needed\b0\ul0\par","\trowd\trgaph144",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx3000",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx12200",
  "\fs20\b Data Documented \b0\intbl\cell"," ",m_rec->s_mgmt_result,"\intbl\cell","\row",
  "\trowd\trgaph144","\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx3000",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx12200",
  "\fs20\b Date/time of charting \b0\intbl\cell"," ",
  m_rec->s_mgmt_dt_tm,"\intbl\cell","\row","\trowd\trgaph144",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx3000",
  "\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx12200",
  "\fs20\b Performed by \b0\intbl\cell"," ",m_rec->s_mgmt_by_name,"\intbl\cell",
  "\row")
 SET reply->text = build2(ms_tmp,"}}")
 CALL echorecord(reply)
#exit_script
END GO
