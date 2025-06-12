CREATE PROGRAM cps_t_hm_set_series_ref_help:dba
 FREE SET sched_meaning
 SET sched_meaning = trim( $1)
 SELECT
  disp = trim(h2.expect_series_name), _hidden = h2.series_meaning
  FROM hm_expect_sched h1,
   hm_expect_series h2
  PLAN (h1
   WHERE h1.expect_sched_meaning=sched_meaning
    AND h1.active_ind=1)
   JOIN (h2
   WHERE h2.expect_sched_id=h1.expect_sched_id
    AND h2.active_ind=1)
  HEAD REPORT
   cnt = 0, reply->fieldname = concat(reportinfo(1),"^"), reply->fieldsize = size(reply->fieldname)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].result = concat(reportinfo(2),"^")
  FOOT REPORT
   reply->cnt = cnt, stat = alterlist(reply->qual,cnt)
  WITH nocounter, maxrow = 1, reporthelp,
   check
 ;end select
END GO
