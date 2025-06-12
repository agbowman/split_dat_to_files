CREATE PROGRAM bed_rec_iv_ce_more_active
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
 SET active_cd = get_code_value(48,"ACTIVE")
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SET sectioncnt = 0
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM working_view_section wvs,
   working_view_item wvi,
   v500_event_set_code vesc,
   v500_event_set_explode vese,
   v500_event_code vec,
   code_value cv
  PLAN (wvs
   WHERE wvs.display_name > " ")
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
   JOIN (vesc
   WHERE vesc.event_set_name=wvi.primitive_event_set_name
    AND vesc.display_association_ind=0)
   JOIN (vese
   WHERE vese.event_set_cd=vesc.event_set_cd
    AND vese.event_set_level=0)
   JOIN (vec
   WHERE vec.event_cd=vese.event_cd)
   JOIN (cv
   WHERE cv.code_value=vec.event_cd)
  ORDER BY wvs.display_name, wvi.primitive_event_set_name
  HEAD wvs.display_name
   sectioncnt = (sectioncnt+ 1)
  HEAD wvi.primitive_event_set_name
   active_cnt = 0
  HEAD vec.event_cd
   IF (vec.code_status_cd=active_cd
    AND cv.active_ind=1)
    active_cnt = (active_cnt+ 1)
   ENDIF
  FOOT  wvi.primitive_event_set_name
   IF (active_cnt > 1)
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
