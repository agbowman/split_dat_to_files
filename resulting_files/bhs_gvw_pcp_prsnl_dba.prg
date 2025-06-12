CREATE PROGRAM bhs_gvw_pcp_prsnl:dba
 DECLARE mf_cs333_pcpdoc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "PRIMARYCAREPHYSICIAN"))
 DECLARE mf_cs331_pcp_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4593"))
 DECLARE ms_pcp_phys = vc WITH protect, noconstant("")
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
    AND epr.encntr_prsnl_r_cd=mf_cs333_pcpdoc_cd)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id
    AND p.active_ind=1)
  ORDER BY e.encntr_id, epr.beg_effective_dt_tm DESC
  HEAD e.encntr_id
   ms_pcp_phys = trim(p.name_full_formatted,3)
  WITH nocounter
 ;end select
 IF (size(trim(ms_pcp_phys,3))=0)
  SELECT INTO "nl:"
   FROM person_prsnl_reltn ppr,
    prsnl p
   PLAN (ppr
    WHERE (ppr.person_id=request->person[1].person_id)
     AND ppr.active_ind=1
     AND ppr.person_prsnl_r_cd=mf_cs331_pcp_cd)
    JOIN (p
    WHERE p.person_id=ppr.prsnl_person_id)
   ORDER BY ppr.person_id, ppr.beg_effective_dt_tm DESC
   HEAD ppr.person_id
    ms_pcp_phys = trim(p.name_full_formatted,3)
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (size(trim(ms_pcp_phys,3)) > 0)
  SET reply->text = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}","\fs18 ",ms_pcp_phys,
   " \par}")
 ENDIF
 CALL echorecord(reply)
#exit_script
END GO
