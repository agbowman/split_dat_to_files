CREATE PROGRAM cr:dba
 SELECT INTO mine
  cr.begin_dt_tm";;q", cr.end_dt_tm";;q", cr.*
  FROM chart_request cr
  WHERE (cr.chart_request_id= $1)
  WITH nocounter
 ;end select
END GO
