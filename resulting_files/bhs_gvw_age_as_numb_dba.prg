CREATE PROGRAM bhs_gvw_age_as_numb:dba
 DECLARE ms_age = vc WITH protect, noconstant("")
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
  FROM person p
  WHERE (p.person_id=request->person[1].person_id)
  DETAIL
   ms_age = cnvtstring(cnvtint(datetimediff(sysdate,cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
        .birth_tz),1),10)))
  WITH nocounter
 ;end select
 IF (size(trim(ms_age,3)) > 0)
  SET reply->text = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}","\fs18 ",ms_age,
   " \par}")
 ENDIF
 CALL echorecord(reply)
#exit_script
END GO
