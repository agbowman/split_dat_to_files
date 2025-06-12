CREATE PROGRAM edw_create_shx_activity:dba
 SELECT INTO value(shx_act_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].shx_activity_inst_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].shx_activity_group_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].person_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].shx_activity_org,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].long_text_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].shx_category_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_shx_activity->qual[d.seq].perform_dt_tm,0,
      cnvtdatetimeutc(edw_shx_activity->qual[d.seq].perform_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].perform_tm_zn,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_shx_activity->qual[d.seq].perform_dt_tm,cnvtint(
      edw_shx_activity->qual[d.seq].perform_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].assessment_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].status_ref,16))),
   v_bar,
   CALL print(trim(edw_shx_activity->qual[d.seq].type_mean)), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].unable_to_obtain_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].create_prsnl,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_shx_activity->qual[d.seq].create_dt_tm,0,
      cnvtdatetimeutc(edw_shx_activity->qual[d.seq].create_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].create_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_shx_activity->qual[d.seq].create_dt_tm,cnvtint(
      edw_shx_activity->qual[d.seq].create_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].error_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_shx_activity->qual[d.seq].error_dt_tm,0,
      cnvtdatetimeutc(edw_shx_activity->qual[d.seq].error_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].error_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_shx_activity->qual[d.seq].error_dt_tm,cnvtint(
      edw_shx_activity->qual[d.seq].error_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].last_modified_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_shx_activity->qual[d.seq].
      last_modified_dt_tm,0,cnvtdatetimeutc(edw_shx_activity->qual[d.seq].last_modified_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].last_modified_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_shx_activity->qual[d.seq].last_modified_dt_tm,cnvtint(
      edw_shx_activity->qual[d.seq].last_modified_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].last_review_prsnl,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_shx_activity->qual[d.seq].
      last_review_dt_tm,0,cnvtdatetimeutc(edw_shx_activity->qual[d.seq].last_review_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].last_review_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_shx_activity->qual[d.seq].last_review_dt_tm,cnvtint(
      edw_shx_activity->qual[d.seq].last_review_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")),
   v_bar, "3", v_bar,
   CALL print(trim(cnvtstring(edw_shx_activity->qual[d.seq].active_ind,16))), v_bar,
   extract_dt_tm_fmt,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
