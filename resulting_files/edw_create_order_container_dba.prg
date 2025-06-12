CREATE PROGRAM edw_create_order_container:dba
 SELECT INTO value(ord_cont_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(concat(trim(cnvtstring(edw_order_container->qual[d.seq].order_sk,16)),"~",trim(
     cnvtstring(edw_order_container->qual[d.seq].container_sk,16)),"~",trim(cnvtstring(
      edw_order_container->qual[d.seq].event_sequence_nbr,16)))), v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].order_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].container_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].parent_container_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].event_sequence_nbr,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].event_type_ref,16))), v_bar,
   CALL print(trim(edw_order_container->qual[d.seq].coll_status_flg)), v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].reason_missed_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].reason_missed_prsnl,16))), v_bar,
   CALL print(trim(edw_order_container->qual[d.seq].additional_labels)), v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].specimen_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].specimen_container_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].specimen_handle_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_order_container->qual[d.seq].drawn_dt_tm,
      0,cnvtdatetimeutc(edw_order_container->qual[d.seq].drawn_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].drawn_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_order_container->qual[d.seq].drawn_dt_tm,cnvtint(
      edw_order_container->qual[d.seq].drawn_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].drawn_prsnl,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_order_container->qual[d.seq].label_dt_tm,
      0,cnvtdatetimeutc(edw_order_container->qual[d.seq].label_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].label_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_order_container->qual[d.seq].label_dt_tm,cnvtint(
      edw_order_container->qual[d.seq].label_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_order_container->qual[d.seq].
      received_dt_tm,0,cnvtdatetimeutc(edw_order_container->qual[d.seq].received_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].received_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_order_container->qual[d.seq].received_dt_tm,cnvtint(
      edw_order_container->qual[d.seq].received_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].received_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].volume,16))), v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].remaining_volume,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_container->qual[d.seq].volume_units_ref,16))), v_bar,
   "1", v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
