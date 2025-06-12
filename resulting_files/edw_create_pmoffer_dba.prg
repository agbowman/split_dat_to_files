CREATE PROGRAM edw_create_pmoffer:dba
 SELECT INTO value(pmoffer_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].pmoffer_inst_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].encounter_sk,16))),
   v_bar,
   CALL print(trim(edw_pmoffer->qual[d.seq].encounter_nk)), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].schedule_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].admit_offer_outcome_cd,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pmoffer->qual[d.seq].appt_dt_tm,0,
      cnvtdatetimeutc(edw_pmoffer->qual[d.seq].appt_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))
   ), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pmoffer->qual[d.seq].appt_dt_tm,cnvtint(edw_pmoffer->
      qual[d.seq].time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].attendance_cd,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pmoffer->qual[d.seq].cancel_dt_tm,0,
      cnvtdatetimeutc(edw_pmoffer->qual[d.seq].cancel_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"
     ))), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pmoffer->qual[d.seq].cancel_dt_tm,cnvtint(edw_pmoffer->
      qual[d.seq].time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pmoffer->qual[d.seq].dna_dt_tm,0,
      cnvtdatetimeutc(edw_pmoffer->qual[d.seq].dna_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pmoffer->qual[d.seq].dna_dt_tm,cnvtint(edw_pmoffer->
      qual[d.seq].time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pmoffer->qual[d.seq].offer_dt_tm,0,
      cnvtdatetimeutc(edw_pmoffer->qual[d.seq].offer_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm")
    )), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pmoffer->qual[d.seq].offer_dt_tm,cnvtint(edw_pmoffer->
      qual[d.seq].time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pmoffer->qual[d.seq].offer_made_dt_tm,0,
      cnvtdatetimeutc(edw_pmoffer->qual[d.seq].offer_made_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pmoffer->qual[d.seq].offer_made_dt_tm,cnvtint(
      edw_pmoffer->qual[d.seq].time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].offer_type_cd,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].outcome_of_attendance_cd,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].pat_initiated_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].reasonable_offer_ind,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].remove_from_wl_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].sch_reason_cd,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pmoffer->qual[d.seq].tci_dt_tm,0,
      cnvtdatetimeutc(edw_pmoffer->qual[d.seq].tci_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pmoffer->qual[d.seq].tci_dt_tm,cnvtint(edw_pmoffer->
      qual[d.seq].time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].wl_reason_for_removal_cd,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pmoffer->qual[d.seq].wl_removal_dt_tm,0,
      cnvtdatetimeutc(edw_pmoffer->qual[d.seq].wl_removal_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pmoffer->qual[d.seq].wl_removal_dt_tm,cnvtint(
      edw_pmoffer->qual[d.seq].time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].active_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].arrived_on_time_ind,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pmoffer->qual[d.seq].updt_dt_tm,0,
      cnvtdatetimeutc(edw_pmoffer->qual[d.seq].active_status_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pmoffer->qual[d.seq].updt_dt_tm,cnvtint(edw_pmoffer->
      qual[d.seq].time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].updt_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pmoffer->qual[d.seq].archive_ind,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
