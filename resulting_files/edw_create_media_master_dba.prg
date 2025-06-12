CREATE PROGRAM edw_create_media_master:dba
 SELECT INTO value(media_master_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].media_master_sk,16))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].person_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].encounter_nk,16))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].media_master_org,16))),
   v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].media_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].parent_media_master_sk,16))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].permanent_loc_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].current_loc_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,media_master->qual[d.seq].create_dt_tm,0,
      cnvtdatetimeutc(media_master->qual[d.seq].create_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].create_dt_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(media_master->qual[d.seq].create_dt_tm,cnvtint(media_master
      ->qual[d.seq].create_dt_tm),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].create_prsnl))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].return_loc_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].media_status_ref,16))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].episode,16))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].volume_nbr,16))),
   v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].storage_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,media_master->qual[d.seq].movement_dt_tm,0,
      cnvtdatetimeutc(media_master->qual[d.seq].movement_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].movement_dt_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(media_master->qual[d.seq].movement_dt_tm,cnvtint(
      media_master->qual[d.seq].movement_dt_tm),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,media_master->qual[d.seq].
      src_beg_effective_dt_tm,0,cnvtdatetimeutc(media_master->qual[d.seq].src_beg_effective_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].src_beg_effective_dt_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(media_master->qual[d.seq].src_beg_effective_dt_tm,cnvtint(
      media_master->qual[d.seq].src_beg_effective_dt_tm),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,media_master->qual[d.seq].
      src_end_effective_dt_tm,0,cnvtdatetimeutc(media_master->qual[d.seq].src_end_effective_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].src_end_effective_dt_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(media_master->qual[d.seq].src_end_effective_dt_tm,cnvtint(
      media_master->qual[d.seq].src_end_effective_dt_tm),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].active_ind,16))), v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].prev_internal_loc_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(media_master->qual[d.seq].contributor_system_ref,16))), v_bar,
   CALL print(trim(replace(media_master->qual[d.seq].frame,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(media_master->qual[d.seq].freetext_roll_frame,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(media_master->qual[d.seq].media_comment,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(media_master->qual[d.seq].roll,str_find,str_replace,3))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
