CREATE PROGRAM bhs_gnw_cerv_cancer:dba
 DECLARE mf_cs72_gynecologichistoryformbhs_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"GYNECOLOGICHISTORYFORMBHS"))
 DECLARE mf_cs72_cervicalcancerscndate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CERVICALCANCERSCNDATE"))
 DECLARE mf_cs72_cervicalcancerscncomments_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"CERVICALCANCERSCNCOMMENTS"))
 DECLARE mf_cs72_cervicalcancerscnpap_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CERVICALCANCERSCNPAP"))
 DECLARE mf_cs72_cervicalcancerscnhpv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CERVICALCANCERSCNHPV"))
 DECLARE mf_cs72_cervicalcancerscncolpo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"CERVICALCANCERSCNCOLPO"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_alt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
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
     2 f_form_event_id = f8
     2 f_screen_date = f8
     2 s_comment = vc
     2 s_scnpap = vc
     2 s_scnhpv = vc
     2 s_scncolpo = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM clinical_event ce1,
   clinical_event ce2,
   clinical_event ce3,
   ce_date_result cdr
  PLAN (ce1
   WHERE (ce1.person_id=request->person[1].person_id)
    AND ce1.event_cd=mf_cs72_gynecologichistoryformbhs_cd
    AND ce1.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce1.result_status_cd IN (mf_auth_cd, mf_alt_cd, mf_mod_cd))
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ce3
   WHERE ce3.parent_event_id=ce2.event_id
    AND ce3.event_cd IN (mf_cs72_cervicalcancerscndate_cd, mf_cs72_cervicalcancerscncomments_cd,
   mf_cs72_cervicalcancerscnpap_cd, mf_cs72_cervicalcancerscnhpv_cd,
   mf_cs72_cervicalcancerscncolpo_cd)
    AND ce3.result_status_cd IN (mf_auth_cd, mf_alt_cd, mf_mod_cd)
    AND ce3.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cdr
   WHERE cdr.event_id=outerjoin(ce3.event_id)
    AND cdr.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY ce1.event_id DESC, ce3.event_cd, ce3.event_end_dt_tm DESC
  HEAD REPORT
   m_rec->l_cnt = 0
  HEAD ce1.event_id
   m_rec->l_cnt = (m_rec->l_cnt+ 1), stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->
   l_cnt].f_form_event_id = ce1.event_id
  HEAD ce3.event_cd
   CASE (ce3.event_cd)
    OF mf_cs72_cervicalcancerscndate_cd:
     m_rec->qual[m_rec->l_cnt].f_screen_date = cdr.result_dt_tm
    OF mf_cs72_cervicalcancerscncomments_cd:
     m_rec->qual[m_rec->l_cnt].s_comment = trim(ce3.result_val,3)
    OF mf_cs72_cervicalcancerscnpap_cd:
     m_rec->qual[m_rec->l_cnt].s_scnpap = trim(ce3.result_val,3)
    OF mf_cs72_cervicalcancerscnhpv_cd:
     m_rec->qual[m_rec->l_cnt].s_scnhpv = trim(ce3.result_val,3)
    OF mf_cs72_cervicalcancerscncolpo_cd:
     m_rec->qual[m_rec->l_cnt].s_scncolpo = trim(ce3.result_val,3)
   ENDCASE
  WITH nocounter
 ;end select
 SET reply->text = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 IF ((m_rec->l_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   PLAN (d)
   ORDER BY m_rec->qual[d.seq].f_screen_date DESC
   HEAD REPORT
    reply->text = concat(reply->text,"\trowd","\clbrdrb\brdrdot\clbrdrr\brdrdot\cellx1200",
     "\clbrdrb\brdrdot\cellx2600","\clbrdrb\brdrdot\cellx4000",
     "\clbrdrb\brdrdot\cellx6000","\clbrdrb\brdrdot\cellx20000","\fs18\b ","Screen Date",
     " \intbl\cell\",
     " ","PAP Result"," \intbl\cell\"," ","HPV Result",
     " \intbl\cell\"," ","Colposcopy Result"," \intbl\cell\"," ",
     "Cervical Cancer Screen Comments"," \b0\intbl\cell\row")
   DETAIL
    reply->text = concat(reply->text,"\trowd","\clbrdrb\brdrdot\clbrdrr\brdrdot\cellx1200",
     "\clbrdrb\brdrdot\cellx2600","\clbrdrb\brdrdot\cellx4000",
     "\clbrdrb\brdrdot\cellx6000","\clbrdrb\brdrdot\cellx20000","\fs18 ",format(m_rec->qual[d.seq].
      f_screen_date,"MM/DD/YYYY;;q")," \intbl\cell\",
     " ",m_rec->qual[d.seq].s_scnpap," \intbl\cell\"," ",m_rec->qual[d.seq].s_scnhpv,
     " \intbl\cell\"," ",m_rec->qual[d.seq].s_scncolpo," \intbl\cell\"," ",
     m_rec->qual[d.seq].s_comment," \intbl\cell\row")
   WITH nocounter
  ;end select
  SET reply->text = build2(reply->text,"}")
 ELSE
  SET reply->text = build2(reply->text,"No previous powerforms found}")
 ENDIF
#exit_script
END GO
