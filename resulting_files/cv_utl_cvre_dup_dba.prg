CREATE PROGRAM cv_utl_cvre_dup:dba
 SET count = 0
 SET totdelrows = 0
 SELECT INTO "CER_TEMP:cv_utl_cvre_dup.tmp"
  FROM cv_registry_event reg
  ORDER BY reg.event_id
  HEAD reg.event_id
   count = 0
  DETAIL
   count = (count+ 1)
   IF (count > 1)
    "delete from cv_registry_event c where c.registry_event_id = ", reg.registry_event_id, " go",
    row + 1, totdelrows = (totdelrows+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (totdelrows > 0)
  CALL echo(build("The file CER_TEMP:cv_utl_cvre_dup.tmp has commands to delete ",totdelrows,
    " rows from cv_registry_event that are multiple instances of an event_id."))
  CALL echo("At the CCL prompt, run the command: %i CER_TEMP:cv_utl_cvre_dup.tmp go")
  CALL echo("Follow that by the command: commit go")
 ELSE
  CALL echo("No multiple rows with the same event_id were found in cv_registry_event table")
 ENDIF
END GO
