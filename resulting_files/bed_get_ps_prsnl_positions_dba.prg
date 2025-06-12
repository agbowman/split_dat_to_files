CREATE PROGRAM bed_get_ps_prsnl_positions:dba
 FREE SET reply
 RECORD reply(
   1 position_list[*]
     2 position_code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM pm_sch_setup ps,
   prsnl p,
   code_value cv
  PLAN (ps
   WHERE ps.person_id > 0)
   JOIN (p
   WHERE p.person_id=ps.person_id
    AND p.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=p.position_cd
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->position_list,100)
  HEAD cv.code_value
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->position_list,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->position_list[tcnt].position_code_value = cv.code_value, reply->position_list[tcnt].display
    = cv.display
  FOOT REPORT
   stat = alterlist(reply->position_list,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
