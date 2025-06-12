CREATE PROGRAM bhs_gvw_pat_recent_notes:dba
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
    1 format = i4
  )
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_event_id = f8
     2 s_result_title = vc
     2 s_result_dt = vc
     2 s_event_cd = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value cv1,
   v500_event_set_explode vese,
   code_value cv2,
   clinical_event ce
  PLAN (cv1
   WHERE cv1.display IN ("ADMISSION/HISTORY AND PHYSICAL", "Anesthesiology Note Office",
   "Anticoagulation Note Office", "Cardiac Surgery Note Office", "Cardiology Note Office",
   "Cardiopulmonary Rehab Note Office", "Colorectal Office Note", "Discharge/Transfer Note Hospital",
   "Discharge/Transfer Note Hospital HIM", "Emergency Medicine Note",
   "ENT Note Office", "Gastroenterology Note Office", "General Medicine Note Office",
   "General Surg/Trauma Surg Office Note", "General Surgery Note Office",
   "Genetics Note Office", "Geriatric Note Office", "Hematology/Oncology Note Office",
   "Nephrology Note Office", "Non BH Office Note",
   "NonBH Office Notes before Sept 2013", "PROCEDURE NOTES", "Pulmonary Note Office",
   "Thoracic Surgery Note Office", "Transplant Services Note Office",
   "Vascular Surgery Note Office", "Wing Office Note")
    AND cv1.code_set=93)
   JOIN (vese
   WHERE vese.event_set_cd=cv1.code_value)
   JOIN (cv2
   WHERE cv2.code_value=vese.event_cd
    AND cv2.active_ind=1
    AND cv2.code_set=72
    AND cv2.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ce
   WHERE (ce.person_id=request->person_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_auth_cd, mf_cs8_modified_cd)
    AND ce.event_cd=cv2.code_value)
  ORDER BY ce.performed_dt_tm DESC
  DETAIL
   IF ((m_rec->l_cnt < 25))
    m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
    f_event_id = ce.event_id,
    m_rec->qual[m_rec->l_cnt].s_result_dt = trim(format(ce.performed_dt_tm,"MMM/DD/YYYY HH:mm;;q"),3),
    m_rec->qual[m_rec->l_cnt].s_result_title = trim(ce.event_title_text,3), m_rec->qual[m_rec->l_cnt]
    .s_event_cd = trim(uar_get_code_display(ce.event_cd),3)
   ENDIF
  WITH nocounter
 ;end select
 IF ((m_rec->l_cnt > 0))
  SET reply->text = "<html> <body> "
  SET reply->text = concat(reply->text,
   " <table border=1 cellspacing=0 cellpadding=0 width=100%> <tr> ")
  SET reply->text = concat(reply->text," <td><p><b><span> Note </span></b></p></td> ")
  SET reply->text = concat(reply->text," <td><p><b><span> Note Type </span></b></p></td> ")
  SET reply->text = concat(reply->text," <td><p><b><span> Note Date </span></b></p></td> ")
  SET reply->text = concat(reply->text," </tr> ")
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    SET reply->text = concat(reply->text," <tr> ")
    SET reply->text = concat(reply->text," <td><p><span> ",m_rec->qual[ml_idx1].s_result_title,
     " </span></p></td> ")
    SET reply->text = concat(reply->text," <td><p><span> ",m_rec->qual[ml_idx1].s_event_cd,
     " </span></p></td> ")
    SET reply->text = concat(reply->text," <td><p><span> ",m_rec->qual[ml_idx1].s_result_dt,
     " </span></p></td> ")
    SET reply->text = concat(reply->text," </tr> ")
  ENDFOR
  SET reply->text = concat(reply->text," </table> ")
  SET reply->text = concat(reply->text,"</body></html>")
 ENDIF
 SET reply->format = 1
 CALL echorecord(reply)
#exit_script
END GO
