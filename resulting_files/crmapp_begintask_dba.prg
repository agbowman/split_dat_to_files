CREATE PROGRAM crmapp_begintask:dba
 CALL echo(build("crmapp_begintask called...",format(curtime3,"hh:mm:ss.cc;;m")))
 CALL echo(build("Checking Autorization for Task Number:",request->task_number))
 SET reply->status = "F"
 CALL echo(build("position_cd: ",cnvtstring(request->position_cd)))
 IF ((request->position_cd=0))
  CALL echo("request->position_cd = 0")
  SET reply->status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ta.task_number, ta.app_group_cd
  FROM application_group ag,
   task_access ta
  PLAN (ta
   WHERE (ta.task_number=request->task_number))
   JOIN (ag
   WHERE (ag.position_cd=request->position_cd)
    AND ag.app_group_cd=ta.app_group_cd)
  DETAIL
   reply->status = "S"
  WITH nocounter, maxqual(ta,1)
 ;end select
 IF (curqual=0)
  CALL echo("looking for tasks in application 5000")
  SELECT INTO "nl:"
   FROM application_task_r atr
   WHERE (atr.task_number=request->task_number)
    AND atr.application_number=5000
   DETAIL
    reply->status = "S",
    CALL echo(atr.task_number)
  ;end select
 ENDIF
#exit_script
 CALL echo(build("Authorization Status:",reply->status))
 CALL echo(build("crmapp_begintask completed...",format(curtime3,"hh:mm:ss.cc;;m")))
END GO
