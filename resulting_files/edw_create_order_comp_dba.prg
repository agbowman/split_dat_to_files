CREATE PROGRAM edw_create_order_comp:dba
 SELECT INTO value(ord_comp_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(concat(trim(cnvtstring(edw_order_comp->qual[d.seq].order_comp_id,16)),"~",trim(
     cnvtstring(edw_order_comp->qual[d.seq].order_comp_detail_id,16)))), v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].order_comp_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].order_nbr,16))), v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].performed_prsnl_id,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_order_comp->qual[d.seq].performed_dt_tm,0,
      cnvtdatetimeutc(edw_order_comp->qual[d.seq].performed_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].performed_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_order_comp->qual[d.seq].performed_dt_tm,cnvtint(
      edw_order_comp->qual[d.seq].performed_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(build(edw_order_comp->qual[d.seq].encntr_compliance_status_flag)),
   v_bar,
   CALL print(build(edw_order_comp->qual[d.seq].no_known_home_meds_ind)), v_bar,
   CALL print(build(edw_order_comp->qual[d.seq].unable_to_obtain_ind)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_order_comp->qual[d.seq].
      compliance_capture_dt_tm,0,cnvtdatetimeutc(edw_order_comp->qual[d.seq].compliance_capture_dt_tm,
       3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].compliance_capture_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_order_comp->qual[d.seq].compliance_capture_dt_tm,
     cnvtint(edw_order_comp->qual[d.seq].compliance_capture_tm_zn),"HHmmsscc"),"00000000","0",
    "        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_order_comp->qual[d.seq].
      last_occured_dt_tm,0,cnvtdatetimeutc(edw_order_comp->qual[d.seq].last_occured_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].last_occured_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_order_comp->qual[d.seq].last_occured_dt_tm,cnvtint(
      edw_order_comp->qual[d.seq].last_occured_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_order_comp->qual[d.seq].updt_dt_tm,0,
      cnvtdatetimeutc(edw_order_comp->qual[d.seq].updt_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].updt_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_order_comp->qual[d.seq].updt_dt_tm,cnvtint(
      edw_order_comp->qual[d.seq].updt_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].updt_id))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].compliance_status_cd))), v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].information_source_cd))), v_bar,
   CALL print(trim(replace(edw_order_comp->qual[d.seq].long_text,str_find,str_replace,3))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].order_comp_detail_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_comp->qual[d.seq].encntr_id,16))), v_bar,
   CALL print(trim(edw_order_comp->qual[d.seq].encntr_nk)), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
