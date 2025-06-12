CREATE PROGRAM bed_get_iview_pos_app_tasks:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 missing_app_ind = i2
     2 missing_task_ind = i2
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
 SET tcnt = 0
 SET acnt = 0
 SET pcnt = size(request->positions,5)
 SET stat = alterlist(reply->positions,pcnt)
 FOR (x = 1 TO pcnt)
   SET reply->positions[x].code_value = request->positions[x].code_value
   SET t4170153 = 0
   SET t4170154 = 0
   SET t600041 = 0
   SET t500199 = 0
   SET t1000300 = 0
   SET a4170100 = 0
   SET a1000300 = 0
   SELECT INTO "nl:"
    FROM application_group a,
     code_value c,
     task_access t
    PLAN (a
     WHERE (a.position_cd=reply->positions[x].code_value))
     JOIN (c
     WHERE c.code_value=a.app_group_cd
      AND c.active_ind=1)
     JOIN (t
     WHERE t.app_group_cd=a.app_group_cd
      AND t.task_number IN (4170153, 4170154, 600041, 500199, 1000300))
    HEAD t.task_number
     IF (t.task_number=4170153)
      t4170153 = 1
     ENDIF
     IF (t.task_number=4170154)
      t4170154 = 1
     ENDIF
     IF (t.task_number=600041)
      t600041 = 1
     ENDIF
     IF (t.task_number=500199)
      t500199 = 1
     ENDIF
     IF (t.task_number=1000300)
      t1000300 = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM application_group a,
     code_value c,
     application_access aa
    PLAN (a
     WHERE (a.position_cd=reply->positions[x].code_value))
     JOIN (c
     WHERE c.code_value=a.app_group_cd
      AND c.active_ind=1)
     JOIN (aa
     WHERE aa.app_group_cd=a.app_group_cd
      AND aa.application_number IN (4170100, 1000300)
      AND aa.active_ind=1)
    HEAD aa.application_number
     IF (aa.application_number=4170100)
      a4170100 = 1
     ENDIF
     IF (aa.application_number=1000300)
      a1000300 = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (((t4170153=0) OR (((t4170154=0) OR (((t600041=0) OR (((t500199=0) OR (t1000300=0)) )) )) )) )
    SET reply->positions[x].missing_task_ind = 1
   ENDIF
   IF (((a4170100=0) OR (a1000300=0)) )
    SET reply->positions[x].missing_app_ind = 1
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
