CREATE PROGRAM bhs_gvw_encntr_fac_phone:dba
 DECLARE mf_cs43_business_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!9598"))
 DECLARE ms_phone = vc WITH protect, noconstant("")
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
   phone p
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.parent_entity_id=e.loc_facility_cd
    AND p.parent_entity_name="LOCATION"
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND p.phone_type_cd=mf_cs43_business_cd)
  ORDER BY p.phone_type_seq
  HEAD REPORT
   ms_phone = trim(p.phone_num,3)
  WITH nocounter
 ;end select
 IF (size(trim(ms_phone,3)) > 0)
  SET reply->text = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}","\fs18 ",ms_phone,
   " \par}")
 ENDIF
 CALL echorecord(reply)
#exit_script
END GO
