CREATE PROGRAM edw_create_osrc_file:dba
 DECLARE iservrescontainer_count = i4 WITH protect, constant(size(edw_osrc->qual,5))
 SELECT INTO value(osrc_extractfile)
  FROM (dummyt d  WITH seq = iservrescontainer_count)
  WHERE iservrescontainer_count > 0
  DETAIL
   col 0, health_system_id, v_bar,
   health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].order_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].container_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].service_resource_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].location_ref,16))),
   v_bar,
   CALL print(trim(edw_osrc->qual[d.seq].status_flg)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_osrc->qual[d.seq].in_lab_dt_tm,0,
      cnvtdatetimeutc(edw_osrc->qual[d.seq].in_lab_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].current_location_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].av_ind))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_osrc->qual[d.seq].display_dt_tm,0,
      cnvtdatetimeutc(edw_osrc->qual[d.seq].display_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))
   ), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_osrc->qual[d.seq].warning_dt_tm,0,
      cnvtdatetimeutc(edw_osrc->qual[d.seq].warning_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))
   ),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_osrc->qual[d.seq].alert_dt_tm,0,
      cnvtdatetimeutc(edw_osrc->qual[d.seq].alert_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_osrc->qual[d.seq].spec_warning_dt_tm,0,
      cnvtdatetimeutc(edw_osrc->qual[d.seq].spec_warning_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_osrc->qual[d.seq].spec_expire_dt_tm,0,
      cnvtdatetimeutc(edw_osrc->qual[d.seq].spec_expire_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].in_lab_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].display_tm_zn))),
   v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].warning_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].alert_storage_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].spec_warning_discard_tm_zn))),
   v_bar,
   CALL print(trim(cnvtstring(edw_osrc->qual[d.seq].spec_expire_tm_zn))), v_bar,
   row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1
 ;end select
 SET script_version = "005 05/25/07 JW014069"
END GO
