CREATE PROGRAM edw_create_enc_info:dba
 SELECT INTO value(enc_info_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE (enc_info->qual[d.seq].encntr_info_sk > 0)
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(enc_info->qual[d.seq].encounter_nk)), v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].encounter_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].encntr_info_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_info->qual[d.seq].src_beg_effective_dt_tm,
      0,cnvtdatetimeutc(enc_info->qual[d.seq].src_beg_effective_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].src_beg_effective_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(enc_info->qual[d.seq].src_beg_effective_dt_tm,cnvtint(
      enc_info->qual[d.seq].src_beg_effective_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_info->qual[d.seq].src_end_effective_dt_tm,
      0,cnvtdatetimeutc(enc_info->qual[d.seq].src_end_effective_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].src_end_effective_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(enc_info->qual[d.seq].src_end_effective_dt_tm,cnvtint(
      enc_info->qual[d.seq].src_end_effective_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].info_sub_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].info_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].value_long_text_sk,16))), v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].priority_seq))), v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].value_ref,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_info->qual[d.seq].value_dt_tm,0,
      cnvtdatetimeutc(enc_info->qual[d.seq].value_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss")
    )), v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].value_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(enc_info->qual[d.seq].value_dt_tm,cnvtint(enc_info->qual[d
      .seq].value_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].value_numeric,16))), v_bar,
   CALL print(trim(enc_info->qual[d.seq].value_txt)), v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].active_ind))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].chartable_ind))),
   v_bar,
   CALL print(trim(cnvtstring(enc_info->qual[d.seq].value_code_set))), v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "002 05/05/17 mf025696"
END GO
