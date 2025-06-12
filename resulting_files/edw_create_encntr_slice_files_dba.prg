CREATE PROGRAM edw_create_encntr_slice_files:dba
 SELECT INTO value(encntr_slice_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(replace(enc_slice->qual[d.seq].encounter_nk,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(enc_slice->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(enc_slice->qual[d.seq].encntr_slice_sk,16))), v_bar,
   CALL print(build(enc_slice->qual[d.seq].active_ind_txt)),
   v_bar,
   CALL print(trim(cnvtstring(enc_slice->qual[d.seq].encntr_slice_flg))), v_bar,
   CALL print(trim(cnvtstring(enc_slice->qual[d.seq].encntr_slice_type_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_slice->qual[d.seq].start_dt_tm,0,
      cnvtdatetimeutc(enc_slice->qual[d.seq].start_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"
     ))),
   v_bar,
   CALL print(trim(cnvtstring(enc_slice->qual[d.seq].start_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(enc_slice->qual[d.seq].start_dt_tm,cnvtint(enc_slice->qual[
      d.seq].start_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_slice->qual[d.seq].end_dt_tm,0,
      cnvtdatetimeutc(enc_slice->qual[d.seq].end_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))
   ),
   v_bar,
   CALL print(trim(cnvtstring(enc_slice->qual[d.seq].end_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(enc_slice->qual[d.seq].end_dt_tm,cnvtint(enc_slice->qual[d
      .seq].end_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "005 05/05/17 mf025696"
END GO
