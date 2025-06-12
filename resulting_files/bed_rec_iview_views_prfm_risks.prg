CREATE PROGRAM bed_rec_iview_views_prfm_risks
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
  FROM working_view wv,
   working_view_section wvs,
   working_view_item wvi
  PLAN (wv
   WHERE wv.active_ind=1)
   JOIN (wvs
   WHERE wvs.working_view_id=wv.working_view_id
    AND wvs.display_name > " ")
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
  ORDER BY wv.working_view_id
  HEAD wv.working_view_id
   pecnt = 0
  DETAIL
   pecnt = (pecnt+ 1)
  FOOT  wv.working_view_id
   IF (pecnt > 1000)
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
