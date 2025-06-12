CREATE PROGRAM bhs_gnw_sc_case_attend_enc:dba
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
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
     2 f_surg_case_id = f8
     2 s_case_nbr = vc
     2 s_surg_dt = vc
     2 l_pcnt = i4
     2 pqual[*]
       3 f_proc_cd = f8
       3 s_proc = vc
     2 l_tcnt = i4
     2 tqual[*]
       3 f_position_type = f8
       3 s_position_type = vc
       3 l_acnt = i4
       3 aqual[*]
         4 f_person_id = f8
         4 s_person = vc
 )
 SELECT INTO "nl:"
  FROM surgical_case sc,
   surg_case_procedure scp
  PLAN (sc
   WHERE (sc.encntr_id=request->visit[1].encntr_id)
    AND sc.active_ind=1
    AND sc.cancel_dt_tm = null
    AND sc.surg_start_dt_tm IS NOT null
    AND sc.surg_stop_dt_tm IS NOT null)
   JOIN (scp
   WHERE (scp.surg_case_id= Outerjoin(sc.surg_case_id))
    AND (scp.active_ind= Outerjoin(1)) )
  ORDER BY sc.surg_start_dt_tm, sc.surg_case_id, scp.surg_proc_cd
  HEAD sc.surg_start_dt_tm
   null
  HEAD sc.surg_case_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_surg_case_id = sc.surg_case_id,
   m_rec->qual[m_rec->l_cnt].s_case_nbr = trim(sc.surg_case_nbr_formatted), m_rec->qual[m_rec->l_cnt]
   .s_surg_dt = trim(format(sc.surg_start_dt_tm,"MM/DD/YYYY;;q"),3)
  HEAD scp.surg_proc_cd
   IF (scp.surg_proc_cd > 0)
    m_rec->qual[m_rec->l_cnt].l_pcnt += 1, stat = alterlist(m_rec->qual[m_rec->l_cnt].pqual,m_rec->
     qual[m_rec->l_cnt].l_pcnt), m_rec->qual[m_rec->l_cnt].pqual[m_rec->qual[m_rec->l_cnt].l_pcnt].
    f_proc_cd = scp.surg_proc_cd,
    m_rec->qual[m_rec->l_cnt].pqual[m_rec->qual[m_rec->l_cnt].l_pcnt].s_proc = trim(
     uar_get_code_display(scp.surg_proc_cd),3)
   ENDIF
  WITH nocounter
 ;end select
 IF ((m_rec->l_cnt > 0))
  SELECT INTO "nl:"
   FROM case_attendance ca,
    code_value cv,
    prsnl p
   PLAN (ca
    WHERE expand(ml_idx1,1,m_rec->l_cnt,ca.surg_case_id,m_rec->qual[ml_idx1].f_surg_case_id)
     AND ca.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ca.role_perf_cd
     AND cv.code_set=10170
     AND cv.display_key IN ("DENTALASSISTANT", "CARDINTERVENTIONALIST", "FELLOW", "ORGANPROCUREMENT",
    "LITHOTRIPSYTECH",
    "PHYSICIAN", "IRRADIOLOGIST", "RADIOLOGIST", "PROCTOR", "NURSEPRACTITIONER",
    "RESIDENT", "SECONDSURGEON", "PERFUSIONIST", "VEINHARVESTER", "PERFUSIONASSISTANT",
    "SURGEONASSIST", "PHYSICIANASSISTANT", "FIRSTASSISTANT", "PRIMARYSURGEON"))
    JOIN (p
    WHERE p.person_id=ca.case_attendee_id)
   ORDER BY ca.surg_case_id, uar_get_code_display(ca.role_perf_cd), ca.role_perf_cd,
    p.person_id
   HEAD ca.surg_case_id
    ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,ca.surg_case_id,m_rec->qual[ml_idx1].f_surg_case_id)
   HEAD ca.role_perf_cd
    IF (ml_idx2 > 0)
     m_rec->qual[ml_idx2].l_tcnt += 1, stat = alterlist(m_rec->qual[ml_idx2].tqual,m_rec->qual[
      ml_idx2].l_tcnt), m_rec->qual[ml_idx2].tqual[m_rec->qual[ml_idx2].l_tcnt].f_position_type = ca
     .role_perf_cd,
     m_rec->qual[ml_idx2].tqual[m_rec->qual[ml_idx2].l_tcnt].s_position_type = trim(
      uar_get_code_display(ca.role_perf_cd),3)
    ENDIF
   HEAD p.person_id
    IF (ml_idx2 > 0)
     m_rec->qual[ml_idx2].tqual[m_rec->qual[ml_idx2].l_tcnt].l_acnt += 1, stat = alterlist(m_rec->
      qual[ml_idx2].tqual[m_rec->qual[ml_idx2].l_tcnt].aqual,m_rec->qual[ml_idx2].tqual[m_rec->qual[
      ml_idx2].l_tcnt].l_acnt), m_rec->qual[ml_idx2].tqual[m_rec->qual[ml_idx2].l_tcnt].aqual[m_rec->
     qual[ml_idx2].tqual[m_rec->qual[ml_idx2].l_tcnt].l_acnt].f_person_id = p.person_id,
     m_rec->qual[ml_idx2].tqual[m_rec->qual[ml_idx2].l_tcnt].aqual[m_rec->qual[ml_idx2].tqual[m_rec->
     qual[ml_idx2].l_tcnt].l_acnt].s_person = trim(p.name_full_formatted,3)
    ENDIF
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF ((m_rec->l_cnt > 0))
  SET reply->text = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}\fs18"
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    SET reply->text = concat(reply->text,"\par\b ","Date of Surgery"," \b0\par ")
    SET reply->text = concat(reply->text," ",m_rec->qual[ml_idx1].s_surg_dt," \par")
    SET reply->text = concat(reply->text,"\b ","Case Number"," \b0\par ")
    SET reply->text = concat(reply->text," ",m_rec->qual[ml_idx1].s_case_nbr," \par")
    IF ((m_rec->qual[ml_idx1].l_pcnt > 0))
     SET reply->text = concat(reply->text,"\b ","Procedure(s) Performed"," \b0\par ")
     FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_pcnt)
       SET reply->text = concat(reply->text," ",m_rec->qual[ml_idx1].pqual[ml_idx2].s_proc," \par")
     ENDFOR
    ENDIF
    IF ((m_rec->qual[ml_idx1].l_tcnt > 0))
     SET reply->text = concat(reply->text,"\b ","Procedure Participants"," \b0\par ")
     FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_tcnt)
      SET reply->text = concat(reply->text,"\b ",m_rec->qual[ml_idx1].tqual[ml_idx2].s_position_type,
       " \b0\par")
      FOR (ml_idx3 = 1 TO m_rec->qual[ml_idx1].tqual[ml_idx2].l_acnt)
        SET reply->text = concat(reply->text," ",m_rec->qual[ml_idx1].tqual[ml_idx2].aqual[ml_idx3].
         s_person," \par")
      ENDFOR
     ENDFOR
    ENDIF
  ENDFOR
  SET reply->text = build2(reply->text,"}")
 ENDIF
 CALL echorecord(reply)
#exit_script
END GO
