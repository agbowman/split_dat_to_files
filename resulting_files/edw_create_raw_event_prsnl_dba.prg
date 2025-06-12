CREATE PROGRAM edw_create_raw_event_prsnl:dba
 DECLARE ievent_prsnl_raw_count = i4 WITH protect, constant(size(edw_get_raw_event_prsnl->qual,5))
 SELECT INTO value(event_prsnl_extractfile)
  FROM (dummyt d  WITH seq = ievent_prsnl_raw_count)
  WHERE (edw_get_raw_event_prsnl->qual[d.seq].ce_event_prsnl_id > 0)
  DETAIL
   irecordcnt = (irecordcnt+ 1), col 0, health_system_id,
   v_bar, health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].ce_event_prsnl_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].event_prsnl_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].event_id,16))), v_bar,
   CALL print(trim(replace(edw_get_raw_event_prsnl->qual[d.seq].action_comment,str_find,str_replace,3
     ),3)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_get_raw_event_prsnl->qual[d.seq].
      action_dt_tm,0,cnvtdatetimeutc(edw_get_raw_event_prsnl->qual[d.seq].action_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].action_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].action_prsnl_id,16))), v_bar,
   CALL print(trim(replace(edw_get_raw_event_prsnl->qual[d.seq].action_prsnl_ft,str_find,str_replace,
     3),3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].action_status_cd,16))), v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].action_type_cd,16))), v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].linked_event_id,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].person_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].proxy_prsnl_id,16))), v_bar,
   CALL print(trim(replace(edw_get_raw_event_prsnl->qual[d.seq].proxy_prsnl_ft,str_find,str_replace,3
     ),3)),
   v_bar,
   CALL print(trim(replace(edw_get_raw_event_prsnl->qual[d.seq].request_comment,str_find,str_replace,
     3),3)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_get_raw_event_prsnl->qual[d.seq].
      request_dt_tm,0,cnvtdatetimeutc(edw_get_raw_event_prsnl->qual[d.seq].request_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].request_prsnl_id,16))),
   v_bar,
   CALL print(trim(replace(edw_get_raw_event_prsnl->qual[d.seq].request_prsnl_ft,str_find,str_replace,
     3),3)), v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].request_tm_zn))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_get_raw_event_prsnl->qual[d.seq].
      valid_until_dt_tm,0,cnvtdatetimeutc(edw_get_raw_event_prsnl->qual[d.seq].valid_until_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].valid_until_tm_zn))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_get_raw_event_prsnl->qual[d.seq].
      valid_from_dt_tm,0,cnvtdatetimeutc(edw_get_raw_event_prsnl->qual[d.seq].valid_from_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_get_raw_event_prsnl->qual[d.seq].valid_from_tm_zn))),
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "004 12/01/2020 BS074648"
END GO
