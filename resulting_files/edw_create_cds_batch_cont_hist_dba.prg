CREATE PROGRAM edw_create_cds_batch_cont_hist:dba
 SELECT INTO value(cdsctnth_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   cdsh_file_cnt = (cdsh_file_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(cdsctnth->qual[d.seq].h_cds_batch_cntnt_sk,16))), v_bar,
   CALL print(trim(cnvtstring(cdsctnth->qual[d.seq].cds_batch_cntnt_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(cdsctnth->qual[d.seq].cds_batch_sk,16))), v_bar,
   CALL print(trim(cdsctnth->qual[d.seq].cds_row_error_ind,3)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,cdsctnth->qual[d.seq].activity_dt_tm,0,
      cnvtdatetimeutc(cdsctnth->qual[d.seq].activity_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm")
    )),
   v_bar,
   CALL print(trim(cnvtstring(cdsctnth->qual[d.seq].activity_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(cdsctnth->qual[d.seq].activity_dt_tm,cnvtint(cdsctnth->
      qual[d.seq].activity_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(cdsctnth->qual[d.seq].cds_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(cdsctnth->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(cdsctnth->qual[d.seq].cds_org,16))), v_bar,
   CALL print(trim(cnvtstring(cdsctnth->qual[d.seq].parent_entity_sk,16))),
   v_bar,
   CALL print(trim(replace(cdsctnth->qual[d.seq].parent_entity_name,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,cdsctnth->qual[d.seq].transaction_dt_tm_txt,0,
      cnvtdatetimeutc(cdsctnth->qual[d.seq].transaction_dt_tm_txt,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(cdsctnth->qual[d.seq].transaction_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(cdsctnth->qual[d.seq].transaction_dt_tm_txt,cnvtint(
      cdsctnth->qual[d.seq].transaction_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cdsctnth->qual[d.seq].update_del_flg,3)), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 01/20/2010 BZ016640"
END GO
