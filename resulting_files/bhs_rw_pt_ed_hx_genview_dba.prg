CREATE PROGRAM bhs_rw_pt_ed_hx_genview:dba
 FREE RECORD pt_ed_hx_req
 RECORD pt_ed_hx_req(
   1 person[1]
     2 person_id = f8
   1 visit[1]
     2 encntr_id = f8
 )
 RECORD pt_ed_hx_reply(
   1 text = vc
 )
 FREE RECORD work
 RECORD work(
   1 pf_cnt = i4
   1 powerforms[*]
     2 form_def = vc
     2 dcp_forms_ref_id = f8
     2 section_def = vc
     2 dcp_section_ref_id = f8
 )
 RECORD reply(
   1 text = vc
 )
 DECLARE var_output = vc
 DECLARE var_form_slot = i4
 DECLARE cs8_inerror_cd = f8
 SET cs8_inerror_cd = uar_get_code_by("DISPLAYKEY",8,"INERROR")
 IF (reflect(parameter(1,0)) > " ")
  SET var_output = trim(build( $1),3)
 ENDIF
 IF (reflect(parameter(2,0)) > " ")
  SET pt_ed_hx_req->visit[1].encntr_id = cnvtreal( $2)
 ELSEIF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET pt_ed_hx_req->visit[1].encntr_id = request->visit[1].encntr_id
 ELSE
  CALL echo("No ENCNTR_ID given. Exitting Script")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  e.person_id
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=pt_ed_hx_req->visit[1].encntr_id))
  DETAIL
   pt_ed_hx_req->person[1].person_id = e.person_id
  WITH nocounter
 ;end select
 SET work->pf_cnt = 8
 SET stat = alterlist(work->powerforms,8)
 SET work->powerforms[1].form_def = "Admission Assessment - BHS"
 SET work->powerforms[1].section_def = "Education - BHS"
 SET work->powerforms[2].form_def = "Admission Assessment Adolescent - BHS"
 SET work->powerforms[2].section_def = "Education Pedi- BHS"
 SET work->powerforms[3].form_def = "Admission Assessment Infant/Toddler - BHS"
 SET work->powerforms[3].section_def = "Education Pedi- BHS"
 SET work->powerforms[4].form_def = "Admission Assessment Newborn - BHS"
 SET work->powerforms[4].section_def = "Education/Discharge - Newborn (V2)"
 SET work->powerforms[5].form_def = "Admission Assessment Psychiatric - BHS"
 SET work->powerforms[5].section_def = "Education - BHS"
 SET work->powerforms[6].form_def = "Admit Assessment Child/Young Adol - BHS"
 SET work->powerforms[6].section_def = "Education Pedi- BHS"
 SET work->powerforms[7].form_def = "Learning Evaluation Form - BHS"
 SET work->powerforms[7].section_def = "Learning Evaluation - BHS"
 SET work->powerforms[8].form_def = "Admission Assessment OB - BHS"
 SET work->powerforms[8].section_def = "Birth Plan/Education-BHS"
 SELECT INTO "NL:"
  dfr.definition
  FROM (dummyt d  WITH seq = value(work->pf_cnt)),
   dcp_forms_activity dfa,
   dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr
  PLAN (d)
   JOIN (dfa
   WHERE (dfa.encntr_id=pt_ed_hx_req->visit[1].encntr_id)
    AND dfa.form_status_cd != cs8_inerror_cd)
   JOIN (dfr
   WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.version_dt_tm BETWEEN dfr.beg_effective_dt_tm AND dfr.end_effective_dt_tm
    AND (work->powerforms[d.seq].form_def=dfr.definition))
   JOIN (dfd
   WHERE dfr.dcp_form_instance_id=dfd.dcp_form_instance_id)
   JOIN (dsr
   WHERE dfd.dcp_section_ref_id=dsr.dcp_section_ref_id
    AND dfa.version_dt_tm BETWEEN dsr.beg_effective_dt_tm AND dsr.end_effective_dt_tm
    AND (work->powerforms[d.seq].section_def=dsr.definition))
  ORDER BY dfa.last_activity_dt_tm DESC, dfr.definition
  DETAIL
   IF (var_form_slot=0)
    FOR (pf = 1 TO work->pf_cnt)
      var_form_slot = d.seq, work->powerforms[d.seq].dcp_forms_ref_id = dfr.dcp_forms_ref_id, work->
      powerforms[d.seq].dcp_section_ref_id = dsr.dcp_section_ref_id
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE bhs_rw_get_powerform_data work->powerforms[var_form_slot].dcp_forms_ref_id, work->
 powerforms[var_form_slot].dcp_section_ref_id, 1,
 pt_ed_hx_req->person[1].person_id, pt_ed_hx_req->visit[1].encntr_id WITH replace(request,
  pt_ed_hx_req), replace(reply,pt_ed_hx_reply)
 SET reply->text = pt_ed_hx_reply->text
 IF (trim(var_output,3) > " ")
  SELECT INTO value(var_output)
   FROM dummyt d
   DETAIL
    reply->text
   WITH nocounter, maxcol = 32000, maxrow = 1,
    formfeed = none, format = variable
  ;end select
 ENDIF
#exit_script
END GO
