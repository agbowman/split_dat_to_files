CREATE PROGRAM bhs_gvw_leaflet_title:dba
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs72_patienteducationleaflets_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"PATIENTEDUCATIONLEAFLETS"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
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
   1 l_cnt = i4
   1 qual[*]
     2 f_event_id = f8
     2 s_result_title = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_auth_cd, mf_cs8_modified_cd)
    AND ce.event_cd=mf_cs72_patienteducationleaflets_cd
    AND ce.event_title_text != "Patient Education Leaflets")
  ORDER BY ce.performed_dt_tm DESC
  DETAIL
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_event_id = ce.event_id,
   CALL echo(ce.event_title_text), m_rec->qual[m_rec->l_cnt].s_result_title = replace(trim(ce
     .event_title_text,3),"Krames Patient Education - ","")
  WITH nocounter
 ;end select
 IF ((m_rec->l_cnt > 0))
  SET reply->text = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}"
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    SET reply->text = concat(reply->text,"\fs18 ",m_rec->qual[ml_idx1].s_result_title," \par")
  ENDFOR
  SET reply->text = build2(reply->text,"}")
 ENDIF
 CALL echo(reply->text)
#exit_script
END GO
