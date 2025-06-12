CREATE PROGRAM bed_rec_fn_diag_prob_list:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM view_comp_prefs vcp,
   name_value_prefs nvp
  PLAN (vcp
   WHERE vcp.view_name="PROBLEM_DX"
    AND vcp.comp_name="PROBLEM_DX"
    AND vcp.position_cd=0
    AND vcp.prsnl_id=0
    AND vcp.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_name="VIEW_COMP_PREFS"
    AND nvp.parent_entity_id=vcp.view_comp_prefs_id
    AND nvp.pvc_name="COMP_DLLNAME"
    AND nvp.active_ind=1)
  DETAIL
   IF (cnvtupper(nvp.pvc_value) != "KIAPROBDX2.DLL")
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM view_comp_prefs vcp,
    code_value cv,
    prsnl p,
    name_value_prefs nvp
   PLAN (vcp
    WHERE vcp.view_name="PROBLEM_DX"
     AND vcp.comp_name="PROBLEM_DX"
     AND vcp.position_cd > 0
     AND vcp.prsnl_id=0
     AND vcp.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=vcp.position_cd
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.position_cd=vcp.position_cd
     AND p.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="VIEW_COMP_PREFS"
     AND nvp.parent_entity_id=vcp.view_comp_prefs_id
     AND nvp.pvc_name="COMP_DLLNAME"
     AND nvp.active_ind=1)
   DETAIL
    IF (cnvtupper(nvp.pvc_value) != "KIAPROBDX2.DLL")
     CALL echo(build("***** nvp.name_value_prefs_id = ",nvp.name_value_prefs_id)), reply->
     run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
