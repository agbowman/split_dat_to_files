CREATE PROGRAM edw_create_ce_event_note:dba
 SELECT INTO value(ce_note_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].ce_event_note_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].event_note_sk,16))), v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].event_sk,16))), v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].note_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].note_format_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ce_event_note_info->qual[d.seq].
      valid_from_dt_tm,0,cnvtdatetimeutc(ce_event_note_info->qual[d.seq].valid_from_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(ce_event_note_info->qual[d.seq].valid_from_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ce_event_note_info->qual[d.seq].
      valid_until_dt_tm,0,cnvtdatetimeutc(ce_event_note_info->qual[d.seq].valid_until_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(ce_event_note_info->qual[d.seq].valid_until_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].entry_method_ref,16))), v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].note_prsnl,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ce_event_note_info->qual[d.seq].note_dt_tm,0,
      cnvtdatetimeutc(ce_event_note_info->qual[d.seq].note_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].note_tm_zn,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(ce_event_note_info->qual[d.seq].note_dt_tm,cnvtint(
      default_time_zone),"MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].record_status_ref,16))), v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].compression_ref,16))), v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].checksum,16))),
   v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].src_long_text_sk,16))), v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].non_chartable_flg,16))), v_bar,
   CALL print(trim(cnvtstring(ce_event_note_info->qual[d.seq].importance_flg,16))),
   v_bar,
   CALL print(trim(replace(ce_event_note_info->qual[d.seq].note_text,str_find,str_replace,3))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 35000, maxrow = 1,
   append
 ;end select
 CALL echo(build("CE_NOTE Count = ",curqual))
 CALL edwupdatescriptstatus("CE_NOTE",curqual,"0","0")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 01/17/12 SM016593"
END GO
