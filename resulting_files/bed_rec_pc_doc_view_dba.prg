CREATE PROGRAM bed_rec_pc_doc_view:dba
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
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM view_prefs vp
  PLAN (vp
   WHERE vp.application_number=4250111
    AND vp.prsnl_id=0
    AND vp.view_name="PowerNote ED"
    AND vp.active_ind=1
    AND vp.position_cd=0)
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=3))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM view_prefs vp,
   code_value cv,
   prsnl p
  PLAN (vp
   WHERE vp.application_number=4250111
    AND vp.prsnl_id=0
    AND vp.view_name="PowerNote ED"
    AND vp.active_ind=1
    AND vp.position_cd > 0)
   JOIN (cv
   WHERE cv.code_value=vp.position_cd
    AND cv.active_ind=1)
   JOIN (p
   WHERE p.position_cd=cv.code_value
    AND p.active_ind=1)
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
