CREATE PROGRAM bed_get_qm_mpage_pos_by_app
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 position_code_value = f8
     2 display = vc
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM detail_prefs dp,
   code_value cv
  PLAN (dp
   WHERE dp.position_cd > 0
    AND (dp.application_number=request->application_number)
    AND dp.view_name="DISCERNRPT"
    AND dp.comp_name="DISCERNRPT"
    AND dp.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dp.position_cd
    AND cv.code_set=88
    AND cv.active_ind=1)
  ORDER BY dp.position_cd
  HEAD dp.position_cd
   tcnt = (tcnt+ 1), stat = alterlist(reply->positions,tcnt), reply->positions[tcnt].
   position_code_value = dp.position_cd,
   reply->positions[tcnt].display = cv.display, reply->positions[tcnt].description = cv.description
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
