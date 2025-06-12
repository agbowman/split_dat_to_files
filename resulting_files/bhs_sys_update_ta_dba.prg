CREATE PROGRAM bhs_sys_update_ta:dba
 PROMPT
  "OutDev" = "MINE",
  "Enter Task_id" = 0
  WITH outdev, prompt1
 UPDATE  FROM task_activity ta
  SET ta.task_status_cd = 419
  WHERE (ta.task_id= $2)
  WITH nocounter
 ;end update
 COMMIT
 IF (curqual > 0)
  SELECT INTO  $1
   FROM dummyt t
   HEAD REPORT
    display_line = build2("Task ",cnvtstring( $2)," Has been completed."), col 10, display_line,
    row + 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO  $1
   FROM dummyt t
   HEAD REPORT
    display_line = build2("Task ", $2," Not Found. Please check the Task_id."), col 10, display_line,
    row + 1
   WITH nocounter
  ;end select
 ENDIF
END GO
