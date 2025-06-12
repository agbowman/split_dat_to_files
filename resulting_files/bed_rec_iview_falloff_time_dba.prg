CREATE PROGRAM bed_rec_iview_falloff_time:dba
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
  FROM working_view wv,
   working_view_section wvs,
   working_view_item wvi,
   code_value pos,
   code_value loc
  PLAN (wvi
   WHERE wvi.falloff_view_minutes > 0)
   JOIN (wvs
   WHERE wvs.working_view_section_id=wvi.working_view_section_id)
   JOIN (wv
   WHERE wv.working_view_id=wvs.working_view_id
    AND wv.active_ind=1)
   JOIN (pos
   WHERE pos.code_value=outerjoin(wv.position_cd)
    AND pos.active_ind=outerjoin(1))
   JOIN (loc
   WHERE loc.code_value=outerjoin(wv.location_cd)
    AND loc.active_ind=outerjoin(1))
  DETAIL
   IF (((wv.position_cd > 0
    AND pos.code_value > 0) OR (wv.position_cd=0)) )
    IF (((wv.location_cd > 0
     AND loc.code_value > 0) OR (wv.location_cd=0)) )
     reply->run_status_flag = 3
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
