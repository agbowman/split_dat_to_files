CREATE PROGRAM bhs_inbox_fix_by_username:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "UserName:" = 0
  WITH outdev, f_person_id
 FREE RECORD m_info
 RECORD m_info(
   1 ids[*]
     2 clin_event_id = f8
     2 clin_event_disp = vc
 ) WITH protect
 DECLARE mf_pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"PENDING"))
 DECLARE mf_opened_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"OPENED"))
 DECLARE mf_onhold_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"ONHOLD"))
 DECLARE mf_a_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",52,"A"))
 DECLARE mf_abn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",52,"ABN"))
 CALL echo(build2(mf_pending_cd," ",mf_opened_cd," ",mf_onhold_cd,
   " ",mf_a_cd," ",mf_abn_cd))
 CALL echo("65539905 429 427 426 201")
 DECLARE mf_person_id = f8 WITH protect, noconstant(cnvtreal( $F_PERSON_ID))
 DECLARE ms_log_msg = vc WITH protect, noconstant(" ")
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_beg_date = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SET ms_output = "nl:"
 SET ms_beg_date = trim(format(datetimeadd(sysdate,- (1)),"dd-mmm-yyyy;;d"))
 SELECT DISTINCT
  ce.clinical_event_id
  FROM task_activity_assignment taa,
   task_activity ta,
   clinical_event ce
  PLAN (taa
   WHERE taa.assign_prsnl_id=mf_person_id
    AND taa.end_eff_dt_tm=cnvtdatetime("31-DEC-2100")
    AND taa.beg_eff_dt_tm >= cnvtdatetime(ms_beg_date)
    AND taa.task_status_cd IN (mf_pending_cd, mf_opened_cd, mf_onhold_cd))
   JOIN (ta
   WHERE ta.task_id=taa.task_id)
   JOIN (ce
   WHERE ce.event_id=ta.event_id
    AND ce.valid_until_dt_tm > sysdate
    AND ce.normalcy_cd=mf_a_cd)
  HEAD REPORT
   pn_cnt = 0
  DETAIL
   pn_cnt = (pn_cnt+ 1)
   IF (pn_cnt > size(m_info->ids,5))
    stat = alterlist(m_info->ids,(pn_cnt+ 5))
   ENDIF
   m_info->ids[pn_cnt].clin_event_id = ce.clinical_event_id, m_info->ids[pn_cnt].clin_event_disp =
   trim(uar_get_code_display(ce.event_cd))
  FOOT REPORT
   stat = alterlist(m_info->ids,pn_cnt)
  WITH nocounter, time = 120
 ;end select
 IF (curqual < 1)
  SET ms_log_msg = "No clinical_event_ids found for this person."
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(size(m_info->ids,5))),
   clinical_event ce
  SET ce.normalcy_cd = mf_abn_cd, ce.updt_dt_tm = sysdate, ce.updt_cnt = (ce.updt_cnt+ 1),
   ce.updt_task = 0
  PLAN (d)
   JOIN (ce
   WHERE (ce.clinical_event_id=m_info->ids[d.seq].clin_event_id))
  WITH nocounter
 ;end update
 COMMIT
#exit_script
 SELECT INTO value( $OUTDEV)
  HEAD REPORT
   pn_cnt = 0
  DETAIL
   IF (size(m_info->ids,5) < 1)
    row 0, col 0, ms_log_msg
   ELSE
    FOR (pn_cnt = 1 TO size(m_info->ids,5))
      ms_tmp = build2("clinical_event_id: ",trim(cnvtstring(m_info->ids[pn_cnt].clin_event_id)),
       " event_cd disp: ",m_info->ids[pn_cnt].clin_event_id), row + 1, col 0,
      ms_tmp
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
END GO
