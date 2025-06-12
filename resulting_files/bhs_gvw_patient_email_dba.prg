CREATE PROGRAM bhs_gvw_patient_email:dba
 DECLARE mf_cs43_email_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4102349364")
  )
 DECLARE ms_email = vc WITH protect, noconstant("")
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
  FROM phone ph
  WHERE ph.parent_entity_name="PERSON"
   AND (ph.parent_entity_id=request->person[1].person_id)
   AND ph.phone_type_cd=mf_cs43_email_cd
   AND ph.active_ind=1
  ORDER BY ph.phone_type_seq
  HEAD REPORT
   ms_email = trim(ph.phone_num,3)
  WITH nocounter
 ;end select
 IF (size(trim(ms_email,3)) > 0)
  SET reply->text = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}","\fs18 ",ms_email,
   " \par}")
 ENDIF
#exit_script
END GO
