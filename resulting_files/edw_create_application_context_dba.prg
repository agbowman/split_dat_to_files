CREATE PROGRAM edw_create_application_context:dba
 SELECT INTO value(app_ctx_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_application_context->qual[d.seq].application_context_inst_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_application_context->qual[d.seq].application_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_application_context->qual[d.seq].activity_prsnl,16))), v_bar,
   CALL print(trim(replace(edw_application_context->qual[d.seq].application_username,str_find,
     str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(edw_application_context->qual[d.seq].activity_position_ref,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_application_context->qual[d.seq].
      start_dt_tm,0,cnvtdatetimeutc(edw_application_context->qual[d.seq].start_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_application_context->qual[d.seq].start_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_application_context->qual[d.seq].start_dt_tm,cnvtint(
      edw_application_context->qual[d.seq].start_dt_tm),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_application_context->qual[d.seq].
      end_dt_tm,0,cnvtdatetimeutc(edw_application_context->qual[d.seq].end_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_application_context->qual[d.seq].end_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_application_context->qual[d.seq].end_dt_tm,cnvtint(
      edw_application_context->qual[d.seq].end_dt_tm),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")),
   v_bar,
   CALL print(trim(replace(edw_application_context->qual[d.seq].application_image,str_find,
     str_replace,3),3)), v_bar,
   CALL print(trim(replace(edw_application_context->qual[d.seq].application_dir,str_find,str_replace,
     3),3)), v_bar,
   CALL print(trim(cnvtstring(edw_application_context->qual[d.seq].application_status,16))),
   v_bar,
   CALL print(trim(replace(edw_application_context->qual[d.seq].device_location,str_find,str_replace,
     3),3)), v_bar,
   CALL print(trim(cnvtstring(edw_application_context->qual[d.seq].authorization_ind,16))), v_bar,
   CALL print(trim(replace(edw_application_context->qual[d.seq].application_version,str_find,
     str_replace,3),3)),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_application_context->qual[d.seq].
      client_start_dt_tm,0,cnvtdatetimeutc(edw_application_context->qual[d.seq].end_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_application_context->qual[d.seq].client_start_dt_tm,
     cnvtint(edw_application_context->qual[d.seq].client_start_dt_tm),"MMddyyyyHHmmsscc"),
    "0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_application_context->qual[d.seq].client_tz))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "002 12/23/20 ss077455"
END GO
