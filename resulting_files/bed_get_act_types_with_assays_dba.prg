CREATE PROGRAM bed_get_act_types_with_assays:dba
 FREE SET reply
 RECORD reply(
   1 activity_types[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
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
 SET alterlist_tcnt = 0
 SET stat = alterlist(reply->activity_types,50)
 SELECT INTO "NL:"
  FROM code_value cv,
   discrete_task_assay dta
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.active_ind=1)
   JOIN (dta
   WHERE dta.activity_type_cd=cv.code_value
    AND dta.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   tcnt = (tcnt+ 1), alterlist_tcnt = (alterlist_tcnt+ 1)
   IF (alterlist_tcnt > 50)
    stat = alterlist(reply->activity_types,(tcnt+ 50)), alterlist_tcnt = 1
   ENDIF
   reply->activity_types[tcnt].code_value = cv.code_value, reply->activity_types[tcnt].display = cv
   .display, reply->activity_types[tcnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->activity_types,tcnt)
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
