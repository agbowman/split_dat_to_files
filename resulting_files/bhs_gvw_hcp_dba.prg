CREATE PROGRAM bhs_gvw_hcp:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
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
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 hcp[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_event_id = f8
     2 s_event_end_dt_tm = vc
     2 f_event_cd = f8
     2 s_event_disp = vc
     2 s_note_type = vc
     2 s_author = vc
     2 s_last_updt_dt_tm = vc
     2 s_last_updt_by = vc
 ) WITH protect
 DECLARE mf_hcp_scanned = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEALTHCAREPROXYSCANNEDFORM"))
 CALL echo(build2("mf_HCP_SCANNED: ",mf_hcp_scanned))
 DECLARE mf_inerror1_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE mf_inerror2_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE mf_inerror3_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE mf_inerror4_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mf_inprogress_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_unauth_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE mf_notdone_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_cancelled_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"CANCELLED"))
 DECLARE mf_inlab_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"IN LAB"))
 DECLARE mf_rejected_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"REJECTED"))
 DECLARE mf_unknown_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"UNKNOWN"))
 DECLARE mf_placeholder_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE ms_rhead = vc WITH protect, constant(
  "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}}\plain \f0 \fs18 ")
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE ms_rh2b = vc WITH protect, constant("\pard\plain\f0\fs18\b ")
 DECLARE ms_wr = vc WITH protect, constant("\plain\f0\fs18 ")
 DECLARE ms_wb = vc WITH protect, constant("\plain\f0\fs18\b ")
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 DECLARE ms_rtab = vc WITH protect, constant("\tab ")
 SELECT INTO "nl:"
  FROM clinical_event ce,
   prsnl pr1,
   prsnl pr2
  PLAN (ce
   WHERE (ce.person_id=request->person[1].person_id)
    AND ce.event_cd=mf_hcp_scanned
    AND  NOT (ce.result_status_cd IN (mf_inerror1_cd, mf_inerror2_cd, mf_inerror3_cd, mf_inerror4_cd,
   mf_inprogress_cd,
   mf_unauth_cd, mf_notdone_cd, mf_cancelled_cd, mf_inlab_cd, mf_rejected_cd,
   mf_unknown_cd))
    AND ce.event_class_cd != mf_placeholder_cd
    AND ce.view_level=1
    AND ce.valid_from_dt_tm <= sysdate
    AND ce.valid_until_dt_tm >= sysdate)
   JOIN (pr1
   WHERE pr1.person_id=ce.performed_prsnl_id)
   JOIN (pr2
   WHERE pr2.person_id=ce.updt_id)
  ORDER BY ce.valid_from_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->hcp,pl_cnt), m_rec->hcp[pl_cnt].f_person_id = ce.person_id,
   m_rec->hcp[pl_cnt].f_encntr_id = ce.encntr_id, m_rec->hcp[pl_cnt].f_event_id = ce.event_id, m_rec
   ->hcp[pl_cnt].f_event_cd = ce.event_cd,
   m_rec->hcp[pl_cnt].s_event_disp = trim(uar_get_code_display(ce.event_cd),3), m_rec->hcp[pl_cnt].
   s_event_end_dt_tm = trim(format(ce.event_end_dt_tm,"mmm dd, yyyy hh:mm;;d"),3), m_rec->hcp[pl_cnt]
   .s_author = trim(pr1.name_full_formatted,3),
   m_rec->hcp[pl_cnt].s_note_type = trim(ce.event_title_text,3), m_rec->hcp[pl_cnt].s_last_updt_dt_tm
    = trim(format(ce.updt_dt_tm,"mmm dd, yyyy hh:mm;;d"),3), m_rec->hcp[pl_cnt].s_last_updt_by = trim
   (pr2.name_full_formatted,3)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET reply->text = concat(ms_rhead," No data found",ms_reol,ms_rtfeof)
  GO TO exit_script
 ENDIF
 DECLARE ms_tabstops = vc WITH protect, noconstant("\tx1750\tx4500\tx6000\tx8000\tx10000 ")
 SET reply->text = ms_rhead
 FOR (ml_loop = 1 TO size(m_rec->hcp,5))
  IF (ml_loop=1)
   SET reply->text = concat(reply->text,ms_tabstops,ms_wb," Time of Service ",ms_rtab,
    " Subject ",ms_rtab," Note Type ",ms_rtab," Author ",
    ms_rtab," Last Updated ",ms_rtab," Last Updated By ",ms_reol)
  ENDIF
  SET reply->text = concat(reply->text,ms_wr,ms_tabstops," ",m_rec->hcp[ml_loop].s_event_end_dt_tm,
   " ",ms_rtab," ",m_rec->hcp[ml_loop].s_event_disp," ",
   ms_rtab," ",m_rec->hcp[ml_loop].s_note_type," ",ms_rtab,
   " ",m_rec->hcp[ml_loop].s_author," ",ms_rtab," ",
   m_rec->hcp[ml_loop].s_last_updt_dt_tm," ",ms_rtab," ",m_rec->hcp[ml_loop].s_last_updt_by,
   " ",ms_reol)
 ENDFOR
 SET reply->text = concat(reply->text,ms_rtfeof)
#exit_script
 CALL echo(reply->text)
END GO
