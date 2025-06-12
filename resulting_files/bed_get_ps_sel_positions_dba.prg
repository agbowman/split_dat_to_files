CREATE PROGRAM bed_get_ps_sel_positions:dba
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
  FROM pm_sch_setup p,
   code_value cv
  PLAN (p
   WHERE (p.application_number=request->application_number)
    AND (p.task_number=request->task_number)
    AND p.position_cd > 0)
   JOIN (cv
   WHERE cv.code_value=p.position_cd
    AND cv.active_ind=1)
  ORDER BY cv.display
  HEAD cv.display
   pcnt = (pcnt+ 1), stat = alterlist(reply->positions,pcnt), reply->positions[pcnt].code_value = cv
   .code_value,
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
