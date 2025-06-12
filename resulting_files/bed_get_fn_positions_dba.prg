CREATE PROGRAM bed_get_fn_positions:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 display = c40
     2 description = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET alterlist_pcnt = 0
 SET pcnt = 0
 SET stat = alterlist(reply->positions,20)
 IF ((request->load_ind=1))
  SELECT INTO "NL:"
   FROM code_value cv,
    application_group ag,
    task_access ta1,
    task_access ta2
   PLAN (cv
    WHERE cv.code_set=88
     AND cv.active_ind=1)
    JOIN (ag
    WHERE ag.position_cd=cv.code_value)
    JOIN (ta1
    WHERE ta1.app_group_cd=ag.app_group_cd
     AND ta1.task_number=4250535)
    JOIN (ta2
    WHERE ta2.app_group_cd=ag.app_group_cd
     AND ta2.task_number=4250635)
   ORDER BY cv.code_value
   HEAD cv.code_value
    pcnt = (pcnt+ 1), alterlist_pcnt = (alterlist_pcnt+ 1)
    IF (alterlist_pcnt > 20)
     stat = alterlist(reply->positions,(pcnt+ 20)), alterlist_pcnt = 0
    ENDIF
    reply->positions[pcnt].code_value = cv.code_value, reply->positions[pcnt].display = cv.display,
    reply->positions[pcnt].description = cv.description
   WITH nocounter
  ;end select
 ELSEIF ((request->load_ind=2))
  SELECT INTO "NL:"
   FROM code_value cv,
    application_group ag,
    task_access ta
   PLAN (cv
    WHERE cv.code_set=88
     AND cv.active_ind=1)
    JOIN (ag
    WHERE ag.position_cd=cv.code_value)
    JOIN (ta
    WHERE ta.app_group_cd=ag.app_group_cd
     AND ta.task_number IN (4250610, 4250611, 4250612, 4250613, 4250614,
    4250615, 4250616, 4250617))
   ORDER BY cv.code_value
   HEAD cv.code_value
    pcnt = (pcnt+ 1), alterlist_pcnt = (alterlist_pcnt+ 1)
    IF (alterlist_pcnt > 20)
     stat = alterlist(reply->positions,(pcnt+ 20)), alterlist_pcnt = 0
    ENDIF
    reply->positions[pcnt].code_value = cv.code_value, reply->positions[pcnt].display = cv.display,
    reply->positions[pcnt].description = cv.description
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->positions,pcnt)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
