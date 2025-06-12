CREATE PROGRAM bhs_prax_get_minmaxvital_val
 DECLARE rcnt = i4
 SET age_mins =  $2
 SET where_params = build("D.EVENT_CD IN"," ", $3)
 DECLARE json = vc WITH protect, noconstant("")
 FREE RECORD get_range
 RECORD get_range(
   1 qual[*]
     2 event_cd = f8
     2 feasible_low = f8
     2 feasible_high = f8
 )
 SELECT DISTINCT INTO  $1
  event_desc = uar_get_code_display(d.event_cd), d.event_cd, age_from_min = r.age_from_minutes,
  age_to_min = r.age_to_minutes, r.feasible_low, r.feasible_high,
  r.feasible_ind
  FROM discrete_task_assay d,
   reference_range_factor r
  PLAN (d
   WHERE parser(where_params)
    AND d.active_ind=1)
   JOIN (r
   WHERE r.task_assay_cd=d.task_assay_cd
    AND r.active_ind=1
    AND r.age_from_minutes <= age_mins
    AND r.age_to_minutes > age_mins)
  ORDER BY d.event_cd
  HEAD REPORT
   rcnt = 0
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(get_range->qual,rcnt), get_range->qual[rcnt].event_cd = d
   .event_cd,
   get_range->qual[rcnt].feasible_low = r.feasible_low, get_range->qual[rcnt].feasible_high = r
   .feasible_high
  FOOT REPORT
   json = cnvtrectojson(get_range), col + 1, json
  WITH nocounter, nullreport, maxcol = 8000,
   maxrow = 0, time = 30
 ;end select
 FREE RECORD get_range
END GO
