CREATE PROGRAM edw_create_bb_person_aborh:dba
 SELECT INTO value(bbprsabo_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(bb_person_aborh_info->qual[d.seq].bb_person_aborh_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_person_aborh_info->qual[d.seq].abo_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,bb_person_aborh_info->qual[d.seq].
      src_begin_effective_dt_tm,0,cnvtdatetimeutc(bb_person_aborh_info->qual[d.seq].
       src_begin_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(bb_person_aborh_info->qual[d.seq].src_begin_effective_dt_tm,
     cnvtint(default_time_zone),"MMddyyyyHHmmss"),"00000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(trim(cnvtstring(bb_person_aborh_info->qual[d.seq].contributor_system_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,bb_person_aborh_info->qual[d.seq].
      end_effective_dt_tm,0,cnvtdatetimeutc(bb_person_aborh_info->qual[d.seq].end_effective_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(bb_person_aborh_info->qual[d.seq].end_effective_dt_tm,
     cnvtint(default_time_zone),"MMddyyyyHHmmss"),"00000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,bb_person_aborh_info->qual[d.seq].
      last_verified_dt_tm,0,cnvtdatetimeutc(bb_person_aborh_info->qual[d.seq].last_verified_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(bb_person_aborh_info->qual[d.seq].last_verified_dt_tm,
     cnvtint(default_time_zone),"MMddyyyyHHmmss"),"00000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(trim(cnvtstring(bb_person_aborh_info->qual[d.seq].person_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_person_aborh_info->qual[d.seq].rh_ref,16))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar,
   CALL print(trim(cnvtstring(bb_person_aborh_info->qual[d.seq].active_ind,16))), v_bar,
   row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 35000, maxrow = 1,
   append
 ;end select
 CALL echo(build("BBPRSABO Count = ",curqual))
 CALL edwupdatescriptstatus("BBPRSABO",curqual,"0","0")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 01/25/2012 SM016593"
END GO
