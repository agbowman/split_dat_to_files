CREATE PROGRAM edw_create_gen_lab_order_files:dba
 SELECT INTO value(gen_lab_order_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].order_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].gen_lab_order_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,gen_lab_info->qual[d.seq].
      first_ctnr_drawn_dt_tm,0,cnvtdatetimeutc(gen_lab_info->qual[d.seq].first_ctnr_drawn_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].first_ctnr_drawn_tm_zn,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(gen_lab_info->qual[d.seq].first_ctnr_drawn_dt_tm,cnvtint(
      gen_lab_info->qual[d.seq].first_ctnr_drawn_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,gen_lab_info->qual[d.seq].
      first_ctnr_received_dt_tm,0,cnvtdatetimeutc(gen_lab_info->qual[d.seq].first_ctnr_received_dt_tm,
       3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].first_ctnr_received_tm_zn,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(gen_lab_info->qual[d.seq].first_ctnr_received_dt_tm,cnvtint
     (gen_lab_info->qual[d.seq].first_ctnr_received_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(gen_lab_info->qual[d.seq].specimen_received_prsnl)), v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].first_ctnr_coll_method_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].first_ctnr_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].first_specimen_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].frst_perf_svc_res_dept_hier_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].first_cntr_units_ref,16))), v_bar,
   CALL print(trim(gen_lab_info->qual[d.seq].first_cntr_volume)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,gen_lab_info->qual[d.seq].
      cntr_first_in_lab_dt_tm,0,cnvtdatetimeutc(gen_lab_info->qual[d.seq].cntr_first_in_lab_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].cntr_first_in_lab_tm_zn,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(gen_lab_info->qual[d.seq].cntr_first_in_lab_dt_tm,cnvtint(
      gen_lab_info->qual[d.seq].cntr_first_in_lab_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(build(cnvtstring(gen_lab_info->qual[d.seq].nbr_of_containers,16))),
   v_bar,
   CALL print(build(cnvtstring(gen_lab_info->qual[d.seq].nbr_of_specimens,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,gen_lab_info->qual[d.seq].
      first_creation_dt_tm,0,cnvtdatetimeutc(gen_lab_info->qual[d.seq].first_creation_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].first_creation_tm_zn,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(gen_lab_info->qual[d.seq].first_creation_dt_tm,cnvtint(
      gen_lab_info->qual[d.seq].first_creation_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].first_specimen_entr_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].first_specimen_coll_prsnl,16))),
   v_bar,
   CALL print(trim(gen_lab_info->qual[d.seq].first_specimen_source_comment)), v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].collection_priority_ref,16))), v_bar,
   CALL print(trim(substring(1,255,replace(gen_lab_info->qual[d.seq].source_site_freetext,str_find,
      str_replace,3)))),
   v_bar,
   CALL print(trim(gen_lab_info->qual[d.seq].collected_ind)), v_bar,
   CALL print(trim(gen_lab_info->qual[d.seq].route_level_flg)), v_bar, "3",
   v_bar,
   CALL print(trim(extract_dt_tm_fmt)), v_bar,
   "1", v_bar, v_bar,
   v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].order_sk,16))), v_bar,
   v_bar, v_bar, v_bar,
   v_bar, v_bar, v_bar,
   CALL print(trim(cnvtstring(gen_lab_info->qual[d.seq].first_specimen_site_ref,16))), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "005 05/13/16 MF025696"
END GO
