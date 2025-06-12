CREATE PROGRAM edw_create_user_defined_hist:dba
 SELECT INTO value(user_defined_hist_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE (user_defined_hist->qual[d.seq].user_defined_hist_sk > 0)
  DETAIL
   usrdf_file_cnt = (usrdf_file_cnt+ 1), col 0, health_system_source_id,
   v_bar,
   CALL print(trim(cnvtstring(user_defined_hist->qual[d.seq].user_defined_hist_sk,16))), v_bar,
   CALL print(build(user_defined_hist->qual[d.seq].src_active_ind)), v_bar,
   CALL print(trim(cnvtstring(user_defined_hist->qual[d.seq].parent_entity_sk,16))),
   v_bar,
   CALL print(trim(replace(user_defined_hist->qual[d.seq].parent_entity_name,str_find,str_replace,3),
    3)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,user_defined_hist->qual[d.seq].
      transaction_dt_tm,0,cnvtdatetimeutc(user_defined_hist->qual[d.seq].transaction_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(user_defined_hist->qual[d.seq].transaction_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(user_defined_hist->qual[d.seq].transaction_dt_tm,cnvtint(
      user_defined_hist->qual[d.seq].transaction_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(user_defined_hist->qual[d.seq].user_defined_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(user_defined_hist->qual[d.seq].value_ref,16))),
   v_bar,
   CALL print(trim(replace(user_defined_hist->qual[d.seq].value_ref_code_set,str_find,str_replace,3),
    3)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,user_defined_hist->qual[d.seq].value_dt_tm,0,
      cnvtdatetimeutc(user_defined_hist->qual[d.seq].value_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(user_defined_hist->qual[d.seq].value_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(user_defined_hist->qual[d.seq].value_dt_tm,cnvtint(
      user_defined_hist->qual[d.seq].value_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(user_defined_hist->qual[d.seq].value_long_text_sk,16))), v_bar,
   CALL print(build(user_defined_hist->qual[d.seq].value_nbr)),
   v_bar,
   CALL print(trim(cnvtstring(user_defined_hist->qual[d.seq].value_type_flg,16))), v_bar,
   extract_dt_tm_fmt, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "003 07/21/2020 BS074648"
END GO
