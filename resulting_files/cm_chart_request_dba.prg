CREATE PROGRAM cm_chart_request:dba
 RECORD reply(
   1 request_list[*]
     2 status = vc
     2 reqtype = i2
     2 reqcount = i2
     2 oldest_dt_tm = dq8
   1 distribution_list[*]
     2 diststatus = vc
     2 distid = f8
     2 distcount = i2
     2 distrun_dt_tm = dq8
   1 error_list[*]
     2 err_reqtype = i2
     2 err_reqcount = i2
   1 cvstag = vc
 )
 SET reply->cvstag = "$Name: ver4_1_20030314 $"
 SELECT INTO noforms
  cv.cdf_meaning, cr.request_type, chart_count = count(cr.chart_request_id),
  dt_tm = min(cr.updt_dt_tm)
  FROM code_value cv,
   chart_request cr
  WHERE cv.code_set=18609
   AND cv.active_ind=1
   AND cr.chart_status_cd=cv.code_value
   AND cr.request_type != 0
   AND cr.active_ind=1
   AND cv.cdf_meaning IN ("INPROCESS", "INRECOVERY", "UNPROCESSED")
  GROUP BY cr.request_type, cv.cdf_meaning
  HEAD REPORT
   counter = 0
  DETAIL
   counter = (counter+ 1), stat = alterlist(reply->request_list,counter), reply->request_list[counter
   ].reqtype = cr.request_type,
   reply->request_list[counter].status = cv.cdf_meaning, reply->request_list[counter].reqcount =
   chart_count, reply->request_list[counter].oldest_dt_tm = cnvtdatetimeutc(dt_tm,2)
 ;end select
 SELECT INTO noforms
  cv.cdf_meaning, cr.distribution_id, chart_count = count(cr.chart_request_id),
  dt_tm = min(cr.dist_run_dt_tm)
  FROM code_value cv,
   chart_request cr
  WHERE cv.code_set=18609
   AND cv.active_ind=1
   AND ((cr.request_type=4) OR (cr.request_type=2
   AND cr.mcis_ind=1))
   AND cr.active_ind=1
   AND cr.chart_status_cd=cv.code_value
   AND cv.cdf_meaning IN ("INPROCESS", "INRECOVERY", "UNPROCESSED")
  GROUP BY cv.cdf_meaning, cr.distribution_id
  HEAD REPORT
   counter = 0
  DETAIL
   counter = (counter+ 1), stat = alterlist(reply->distribution_list,counter), reply->
   distribution_list[counter].diststatus = cv.cdf_meaning,
   reply->distribution_list[counter].distid = cr.distribution_id, reply->distribution_list[counter].
   distcount = chart_count, reply->distribution_list[counter].distrun_dt_tm = cnvtdatetimeutc(dt_tm,2
    )
 ;end select
 SELECT INTO noforms
  cr.request_type, chart_count = count(cr.chart_request_id)
  FROM code_value cv,
   chart_request cr
  WHERE cv.code_set=18609
   AND cr.active_ind=1
   AND cr.request_type != 0
   AND cr.updt_dt_tm > cnvtdatetimeutc(request->lastcycle,1)
   AND cv.active_ind=1
   AND cr.chart_status_cd=cv.code_value
   AND  NOT (cv.cdf_meaning IN ("INPROCESS", "INRECOVERY", "SKIPPED", "SUCCESSFUL", "UNPROCESSED",
  "QUEUED"))
  GROUP BY cr.request_type
  HEAD REPORT
   counter = 0
  DETAIL
   counter = (counter+ 1), stat = alterlist(reply->error_list,counter), reply->error_list[counter].
   err_reqtype = cr.request_type,
   reply->error_list[counter].err_reqcount = chart_count
 ;end select
END GO
