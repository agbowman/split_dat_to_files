CREATE PROGRAM bhs_gvw_enc_consult_doc:dba
 DECLARE mf_cs333_consultdoc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4595")
  )
 DECLARE ms_consult_phys = vc WITH protect, noconstant("")
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
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_prsnl_reltn epr,
   person p
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.active_ind=1
    AND epr.encntr_prsnl_r_cd=mf_cs333_consultdoc_cd)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id
    AND p.active_ind=1)
  ORDER BY e.encntr_id, epr.beg_effective_dt_tm DESC
  HEAD e.encntr_id
   ms_consult_phys = trim(p.name_full_formatted,3)
  WITH nocounter
 ;end select
 IF (size(trim(ms_consult_phys,3)) > 0)
  SET reply->text = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}","\fs18 ",
   ms_consult_phys," \par}")
 ENDIF
#exit_script
END GO
