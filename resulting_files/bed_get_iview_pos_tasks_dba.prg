CREATE PROGRAM bed_get_iview_pos_tasks:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 tasks[*]
       3 number = i4
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
 SET pcnt = size(request->positions,5)
 SET stat = alterlist(reply->positions,pcnt)
 FOR (x = 1 TO pcnt)
  SET reply->positions[x].code_value = request->positions[x].code_value
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
     AND t.task_number IN (600154, 1000001, 1000090))
   HEAD t.task_number
    tcnt = (tcnt+ 1), stat = alterlist(reply->positions[x].tasks,tcnt), reply->positions[x].tasks[
    tcnt].number = t.task_number
   WITH nocounter
  ;end select
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
