CREATE PROGRAM bhs_gvw_per_home_cell_ph:dba
 DECLARE s_text = vc WITH protect, noconstant("")
 DECLARE ms_home_ph = vc WITH protect, noconstant("")
 DECLARE ms_cell_ph = vc WITH protect, noconstant("")
 DECLARE mf_cs43_home_phone_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4017"))
 DECLARE mf_cs43_cell_phone_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!2510010055"))
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
  FROM phone p
  WHERE (p.parent_entity_id=request->person[1].person_id)
   AND p.parent_entity_name="PERSON"
   AND p.active_ind=1
   AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND p.phone_type_cd IN (mf_cs43_home_phone_cd, mf_cs43_cell_phone_cd)
  ORDER BY p.phone_type_cd, p.phone_type_seq
  HEAD p.phone_type_cd
   IF (p.phone_type_cd=mf_cs43_home_phone_cd)
    ms_home_ph = trim(cnvtphone(p.phone_num_key,874),3)
   ELSEIF (p.phone_type_cd=mf_cs43_cell_phone_cd)
    ms_cell_ph = trim(cnvtphone(p.phone_num_key,874),3)
   ENDIF
  WITH nocounter
 ;end select
 SET s_text = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}\fs18"
 IF (size(trim(ms_home_ph,3)) > 0)
  SET s_text = concat(s_text," Home Phone: ",ms_home_ph," \par ")
 ENDIF
 IF (size(trim(ms_cell_ph,3)) > 0)
  SET s_text = concat(s_text," Cell Phone: ",ms_cell_ph," \par ")
 ENDIF
 SET s_text = concat(s_text,"}")
 SET reply->text = s_text
 CALL echorecord(reply)
#exit_script
END GO
