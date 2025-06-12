CREATE PROGRAM bed_get_ps_avail_positions:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pcnt = 0
 SELECT INTO "nl:"
  FROM application_access aa,
   application_group ag,
   code_value cv
  PLAN (aa
   WHERE (aa.application_number=request->application_number)
    AND aa.active_ind=1)
   JOIN (ag
   WHERE ag.app_group_cd=aa.app_group_cd
    AND ag.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND ag.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (cv
   WHERE cv.code_value=ag.position_cd)
  ORDER BY cv.display
  HEAD cv.display
   pcnt = (pcnt+ 1), stat = alterlist(reply->positions,pcnt), reply->positions[pcnt].code_value = ag
   .position_cd,
   reply->positions[pcnt].display = cv.display
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (pcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
