CREATE PROGRAM bhs_sys_chart_request_updt:dba
 UPDATE  FROM chart_request c
  SET c.chart_status_cd = 10974.00
  WHERE c.chart_status_cd=10967
   AND (c.request_dt_tm < (sysdate - 1))
 ;end update
 COMMIT
END GO
