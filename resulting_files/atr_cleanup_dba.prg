CREATE PROGRAM atr_cleanup:dba
 CALL echo("cleaning up ATR tables...")
 DELETE  FROM application_task_r atr
  WHERE ((atr.application_number BETWEEN 0 AND 99999) OR (((atr.application_number BETWEEN 200000
   AND 2100000) OR (atr.application_number > 2199999)) ))
 ;end delete
 COMMIT
 DELETE  FROM task_request_r trr
  WHERE ((trr.task_number BETWEEN 0 AND 99999) OR (((trr.task_number BETWEEN 200000 AND 2100000) OR (
  trr.task_number > 2199999)) ))
 ;end delete
 COMMIT
 DELETE  FROM request_processing rp
  WHERE rp.request_number >= 0
 ;end delete
 COMMIT
 DELETE  FROM application a
  WHERE ((a.application_number BETWEEN 0 AND 99999) OR (((a.application_number BETWEEN 200000 AND
  2100000) OR (a.application_number > 2199999)) ))
 ;end delete
 DELETE  FROM application_task a
  WHERE ((a.task_number BETWEEN 0 AND 99999) OR (((a.task_number BETWEEN 200000 AND 2100000) OR (a
  .task_number > 2199999)) ))
 ;end delete
 DELETE  FROM request r
  WHERE ((r.request_number BETWEEN 0 AND 99999) OR (((r.request_number BETWEEN 200000 AND 2100000)
   OR (r.request_number > 2199999)) ))
 ;end delete
 COMMIT
END GO
