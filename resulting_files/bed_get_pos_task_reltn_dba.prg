CREATE PROGRAM bed_get_pos_task_reltn:dba
 FREE SET reply
 RECORD reply(
   1 reltns[*]
     2 position_code_value = f8
     2 task_number = i4
     2 task_exists_ind = i2
     2 granted_ind = i2
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
 SET pcnt = size(request->reltns,5)
 IF (pcnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->reltns,pcnt)
 FOR (x = 1 TO pcnt)
  SET reply->reltns[x].position_code_value = request->reltns[x].position_code_value
  SET reply->reltns[x].task_number = request->reltns[x].task_number
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pcnt)),
   application_group a,
   code_value c,
   task_access t
  PLAN (d)
   JOIN (a
   WHERE (a.position_cd=request->reltns[d.seq].position_code_value)
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (c
   WHERE c.code_value=a.app_group_cd
    AND c.active_ind=1)
   JOIN (t
   WHERE t.app_group_cd=a.app_group_cd
    AND (t.task_number=request->reltns[d.seq].task_number))
  ORDER BY d.seq
  HEAD d.seq
   reply->reltns[d.seq].granted_ind = 1, reply->reltns[d.seq].task_exists_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pcnt)),
   application_task a
  PLAN (d
   WHERE (reply->reltns[d.seq].task_exists_ind=0))
   JOIN (a
   WHERE (a.task_number=request->reltns[d.seq].task_number)
    AND a.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   reply->reltns[d.seq].task_exists_ind = 1
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
