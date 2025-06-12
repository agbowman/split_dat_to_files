CREATE PROGRAM edw_create_implant_log_file:dba
 SELECT INTO value(implant_log_extractfile)
  FROM (dummyt d  WITH seq = value(il_cnt))
  WHERE il_cnt > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(implant_log_info->qual[d.seq].surgical_case_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(implant_log_info->qual[d.seq].implant_log_sk,16))), v_bar,
   CALL print(trim(cnvtstring(implant_log_info->qual[d.seq].perioperative_doc_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(implant_log_info->qual[d.seq].doc_terminated_reason_ref,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,implant_log_info->qual[d.seq].
      doc_terminated_dt_tm,0,cnvtdatetimeutc(implant_log_info->qual[d.seq].doc_terminated_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(implant_log_info->qual[d.seq].doc_terminated_tm_zn,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(implant_log_info->qual[d.seq].doc_terminated_dt_tm,cnvtint(
      implant_log_info->qual[d.seq].doc_terminated_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(implant_log_info->qual[d.seq].doc_terminated_by_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(implant_log_info->qual[d.seq].segment_ref,16))), v_bar,
   CALL print(trim(cnvtstring(implant_log_info->qual[d.seq].cultured_ind,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,implant_log_info->qual[d.seq].
      expiration_dt_tm,0,cnvtdatetimeutc(implant_log_info->qual[d.seq].expiration_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(implant_log_info->qual[d.seq].expiration_tm_zn,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(implant_log_info->qual[d.seq].expiration_dt_tm,cnvtint(
      implant_log_info->qual[d.seq].expiration_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(implant_log_info->qual[d.seq].implanted_by_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(implant_log_info->qual[d.seq].implant_item,16))), v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].ft_implant,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].implanted_site_txt,str_find,str_replace,3),3
    )), v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].implanted_size_txt,str_find,str_replace,3),3
    )), v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].implant_batch_nbr,str_find,str_replace,3),3)
   ),
   v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].implant_catalog_nbr,str_find,str_replace,3),
    3)), v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].ecri_device_code,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].implant_lot_nbr,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].implant_serial_nbr,str_find,str_replace,3),3
    )), v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].implant_manufacturer_txt,str_find,
     str_replace,3),3)), v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].implant_manufacturer_ecri_code,str_find,
     str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].implant_model_nbr,str_find,str_replace,3),3)
   ), v_bar,
   "3", v_bar,
   CALL print(trim(extract_dt_tm_fmt)),
   v_bar, "1", v_bar,
   CALL print(trim(replace(implant_log_info->qual[d.seq].quantity,str_find,str_replace,3),3)), v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "003 11/14/2016 mf025696"
END GO
