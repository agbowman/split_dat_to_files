CREATE PROGRAM edw_create_fin_charge_events:dba
 SELECT INTO value(fin_charge_event_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].fin_charge_event_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(build(edw_charge_event->qual[d.seq].encounter_nk)), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].master_charge_event_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].primary_charge_event_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].bill_item_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].master_bill_item_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].primary_bill_item_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].order_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].contributor_system_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].person_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].collection_priority_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].report_priority_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].perf_location_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].charge_event_hlthpln,16))), v_bar,
   CALL print(build(edw_charge_event->qual[d.seq].epsdt_ind)),
   v_bar,
   CALL print(build(edw_charge_event->qual[d.seq].cancelled_ind)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_charge_event->qual[d.seq].cancelled_dt_tm,
      0,cnvtdatetimeutc(edw_charge_event->qual[d.seq].cancelled_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].cancelled_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_charge_event->qual[d.seq].cancelled_dt_tm,cnvtint(
      edw_charge_event->qual[d.seq].cancelled_dt_tm),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].cancelled_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].ordered_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_charge_event->qual[d.seq].abn_status_ref,16))), v_bar,
   CALL print(trim(edw_charge_event->qual[d.seq].accession)), v_bar,
   CALL print(build(edw_charge_event->qual[d.seq].active_ind)),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 05/23/16 mf025696"
END GO
