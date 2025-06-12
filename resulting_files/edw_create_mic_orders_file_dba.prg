CREATE PROGRAM edw_create_mic_orders_file:dba
 DECLARE imicorder_count = i4 WITH protect, constant(size(edw_mic_orders->qual,5))
 SELECT INTO value(mic_order_extractfile)
  FROM (dummyt d  WITH seq = cur_list_size)
  WHERE cur_list_size > 0
  DETAIL
   col 0, health_system_id, v_bar,
   health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].order_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].micro_order_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_mic_orders->qual[d.seq].
      first_ctnr_drawn_dt_tm_txt,0,cnvtdatetimeutc(edw_mic_orders->qual[d.seq].
       first_ctnr_drawn_dt_tm_txt,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].first_ctnr_drawn_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_mic_orders->qual[d.seq].first_ctnr_drawn_dt_tm_txt,
     cnvtint(edw_mic_orders->qual[d.seq].first_ctnr_drawn_tm_zn),"HHmmsscc"),"00000000","0",
    "        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_mic_orders->qual[d.seq].
      first_ctnr_received_dt_tm_txt,0,cnvtdatetimeutc(edw_mic_orders->qual[d.seq].
       first_ctnr_received_dt_tm_txt,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].first_ctnr_received_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_mic_orders->qual[d.seq].first_ctnr_received_dt_tm_txt,
     cnvtint(edw_mic_orders->qual[d.seq].first_ctnr_received_tm_zn),"HHmmsscc"),"00000000","0",
    "        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].specimen_received_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].first_ctnr_coll_method_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].first_ctnr_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].first_specimen_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].frst_perf_svc_res_dept_hier_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].first_cntr_units_ref,16))), v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].first_cntr_volume)), v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].nbr_of_containers)),
   v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].nbr_of_specimens)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_mic_orders->qual[d.seq].
      first_creation_dt_tm_txt,0,cnvtdatetimeutc(edw_mic_orders->qual[d.seq].first_creation_dt_tm_txt,
       3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].creation_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_mic_orders->qual[d.seq].first_creation_dt_tm_txt,
     cnvtint(edw_mic_orders->qual[d.seq].creation_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].first_specimen_entr_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].first_specimen_coll_prsnl,16))),
   v_bar,
   CALL print(trim(replace(edw_mic_orders->qual[d.seq].first_specimen_source_comment,str_find,
     str_replace,3))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_mic_orders->qual[d.seq].
      completed_dt_tm_txt,0,cnvtdatetimeutc(edw_mic_orders->qual[d.seq].completed_dt_tm_txt,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].completed_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_mic_orders->qual[d.seq].completed_dt_tm_txt,cnvtint(
      edw_mic_orders->qual[d.seq].completed_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   "0", v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].test_cnt)),
   v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].order_nbr,16))), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].collection_priority_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_mic_orders->qual[d.seq].
      central_collection_dt_tm_txt,0,cnvtdatetimeutc(edw_mic_orders->qual[d.seq].
       central_collection_dt_tm_txt,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].central_collection_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_mic_orders->qual[d.seq].central_collection_dt_tm_txt,
     cnvtint(edw_mic_orders->qual[d.seq].central_collection_tm_zn),"HHmmsscc"),"00000000","0",
    "        ","0",
    "1")), v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].lab_type_flg)),
   v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].continuing_order_ind)), v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].order_positive_ind)), v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].status_ref,16))),
   v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].specific_source)), v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].specific_source_axis)), v_bar,
   CALL print(trim(substring(1,255,replace(edw_mic_orders->qual[d.seq].source_site_freetext,str_find,
      str_replace,3)))),
   v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].first_specimen_site_ref,16))), v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].sus_nbr_ver)), v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].sus_ver_count)),
   v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].collected_ind)), v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].frozen_section_requested_ind)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_mic_orders->qual[d.seq].
      culture_start_dt_tm_txt,0,cnvtdatetimeutc(edw_mic_orders->qual[d.seq].culture_start_dt_tm_txt,3
       )),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_mic_orders->qual[d.seq].culture_start_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_mic_orders->qual[d.seq].culture_start_dt_tm_txt,cnvtint
     (edw_mic_orders->qual[d.seq].culture_start_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(edw_mic_orders->qual[d.seq].nosocoimal_ind)),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, "1",
   v_bar, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "011 05/13/16 mf025696"
END GO
