CREATE PROGRAM bed_rec_edept_trklst_icon:dba
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
  te.tracking_group_cd, count(te.track_event_id)
  FROM track_event te
  WHERE te.active_ind=1
   AND te.normal_icon > 0
  GROUP BY te.tracking_group_cd
  HAVING count(te.track_event_id) > 25
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
