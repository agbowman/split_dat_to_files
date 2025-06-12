CREATE PROGRAM edw_create_fhx_activity:dba
 SELECT INTO value(fhxact_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].fhx_activity_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].fhx_activity_group_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].person_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].related_person_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].related_person_reltn_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].fhx_value_flg,16))), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].onset_age,16,4))),
   v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].onset_age_prec_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].onset_age_unit_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].activity_org,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].course_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].life_cycle_status_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].activity_nomen,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].severity_ref,16))), v_bar,
   CALL print(trim(replace(edw_fhx_activity->qual[d.seq].type_mean,str_find,str_replace,3))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_fhx_activity->qual[d.seq].
      src_beg_effect_dt_tm,0,cnvtdatetimeutc(edw_fhx_activity->qual[d.seq].src_beg_effect_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_fhx_activity->qual[d.seq].src_beg_effect_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_fhx_activity->qual[d.seq].
      src_end_effect_dt_tm,0,cnvtdatetimeutc(edw_fhx_activity->qual[d.seq].src_end_effect_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_fhx_activity->qual[d.seq].src_end_effect_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(trim(edw_fhx_activity->qual[d.seq].active_ind)),
   v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].create_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_fhx_activity->qual[d.seq].create_dt_tm,0,
      cnvtdatetimeutc(edw_fhx_activity->qual[d.seq].create_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_fhx_activity->qual[d.seq].create_dt_tm,edw_fhx_activity
     ->qual[d.seq].create_tm_zn,"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].create_tm_zn,16))), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].inactivate_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_fhx_activity->qual[d.seq].
      inactivate_dt_tm,0,cnvtdatetimeutc(edw_fhx_activity->qual[d.seq].inactivate_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_fhx_activity->qual[d.seq].inactivate_dt_tm,
     edw_fhx_activity->qual[d.seq].inactivate_tm_zn,"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].inactivate_tm_zn,16))), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].first_review_prsnl,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_fhx_activity->qual[d.seq].
      first_review_dt_tm,0,cnvtdatetimeutc(edw_fhx_activity->qual[d.seq].first_review_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_fhx_activity->qual[d.seq].first_review_dt_tm,
     edw_fhx_activity->qual[d.seq].first_review_tm_zn,"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].first_review_tm_zn,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].last_review_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_fhx_activity->qual[d.seq].
      last_review_dt_tm,0,cnvtdatetimeutc(edw_fhx_activity->qual[d.seq].last_review_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_fhx_activity->qual[d.seq].last_review_dt_tm,
     edw_fhx_activity->qual[d.seq].last_review_tm_zn,"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_fhx_activity->qual[d.seq].last_review_tm_zn,16))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 04/12/12 RP019504"
END GO
