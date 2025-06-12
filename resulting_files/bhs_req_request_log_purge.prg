CREATE PROGRAM bhs_req_request_log_purge
 PROMPT
  "Days to keep? " = 90
 DECLARE date_qual = dq8
 SET date_qual = cnvtlookbehind(build( $1,",D"),cnvtdatetime(curdate,0))
 CALL echo(format(date_qual,"MM/DD/YYYY ;;D"))
 CALL echo(format(cnvtdatetime(date_qual),"MM/DD/YYYY HH:MM:SS;;D"))
 DELETE  FROM bhs_req_request_ord_hx bh
  PLAN (bh
   WHERE bh.req_request_hx_id IN (
   (SELECT
    b.req_request_hx_id
    FROM bhs_req_request_hx b
    WHERE b.execute_dt_tm < cnvtdatetime(date_qual))))
  WITH counter
 ;end delete
 DELETE  FROM bhs_req_request_hx b
  PLAN (b
   WHERE b.execute_dt_tm < cnvtdatetime(date_qual))
  WITH counter
 ;end delete
 COMMIT
END GO
