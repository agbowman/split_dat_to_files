CREATE PROGRAM edw_create_scd_story:dba
 SELECT INTO value(scd_sty_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(replace(scd_story->qual[d.seq].encounter_nk,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].encounter_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].scd_story_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].person_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].note_author_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].entry_mode_ref,16))), v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].event_sk,16))), v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].note_completion_status_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].documentation_type_ref,16))), v_bar,
   CALL print(trim(replace(scd_story->qual[d.seq].title,str_find,str_replace,3))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,scd_story->qual[d.seq].note_signed_dt_tm,0,
      cnvtdatetimeutc(scd_story->qual[d.seq].note_signed_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].note_signed_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(scd_story->qual[d.seq].note_signed_dt_tm,cnvtint(scd_story
      ->qual[d.seq].note_signed_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].signed_prsnl,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,scd_story->qual[d.seq].first_addendum_dt_tm,0,
      cnvtdatetimeutc(scd_story->qual[d.seq].first_addendum_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].first_addendum_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(scd_story->qual[d.seq].first_addendum_dt_tm,cnvtint(
      scd_story->qual[d.seq].first_addendum_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].first_addendum_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,scd_story->qual[d.seq].last_addendum_dt_tm,0,
      cnvtdatetimeutc(scd_story->qual[d.seq].last_addendum_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].last_addendum_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(scd_story->qual[d.seq].last_addendum_dt_tm,cnvtint(
      scd_story->qual[d.seq].last_addendum_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].last_addendum_prsnl,16))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(scd_story->qual[d.seq].active_ind))), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
