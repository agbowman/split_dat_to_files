CREATE PROGRAM bed_rec_iv_ce_missing
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
    AND vesc.display_association_ind=0
    AND  NOT ( EXISTS (
   (SELECT
    parent_event_set_cd
    FROM v500_event_set_canon
    WHERE parent_event_set_cd=vesc.event_set_cd))))
   JOIN (vese
   WHERE vese.event_set_cd=outerjoin(vesc.event_set_cd)
    AND vese.event_set_level=outerjoin(0))
   JOIN (vec
   WHERE vec.event_cd=outerjoin(vese.event_cd))
   JOIN (cv
   WHERE cv.code_value=outerjoin(vec.event_cd))
  ORDER BY wvs.display_name, wvi.primitive_event_set_name
  HEAD wvs.display_name
   sectioncnt = (sectioncnt+ 1)
  HEAD wvi.primitive_event_set_name
   IF (vese.event_set_cd=0)
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
