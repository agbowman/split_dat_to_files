CREATE PROGRAM edw_create_ap_specimen:dba
 SELECT INTO value(ap_specimen_extractfile)
  FROM (dummyt d  WITH seq = size(edw_ap_specimen->qual,5))
  WHERE (edw_ap_specimen->qual[d.seq].ap_specimen_sk > 0)
  DETAIL
   irecordcnt = (irecordcnt+ 1), col 0, health_system_id,
   v_bar, health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].ap_specimen_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].ap_case_sk,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_ap_specimen->qual[d.seq].collection_dt_tm,
      0,cnvtdatetimeutc(edw_ap_specimen->qual[d.seq].collection_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].collection_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_ap_specimen->qual[d.seq].collection_dt_tm,cnvtint(
      edw_ap_specimen->qual[d.seq].collection_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_ap_specimen->qual[d.seq].discard_dt_tm,0,
      cnvtdatetimeutc(edw_ap_specimen->qual[d.seq].discard_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].discard_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_ap_specimen->qual[d.seq].discard_dt_tm,cnvtint(
      edw_ap_specimen->qual[d.seq].discard_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].discard_reason_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].inadequacy_reason_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_ap_specimen->qual[d.seq].
      orig_storage_dt_tm,0,cnvtdatetimeutc(edw_ap_specimen->qual[d.seq].orig_storage_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].orig_storage_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_ap_specimen->qual[d.seq].orig_storage_dt_tm,cnvtint(
      edw_ap_specimen->qual[d.seq].orig_storage_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_ap_specimen->qual[d.seq].received_dt_tm,0,
      cnvtdatetimeutc(edw_ap_specimen->qual[d.seq].received_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].received_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_ap_specimen->qual[d.seq].received_dt_tm,cnvtint(
      edw_ap_specimen->qual[d.seq].received_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].received_fixative_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].received_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].specimen_ref,16))), v_bar,
   CALL print(trim(replace(edw_ap_specimen->qual[d.seq].specimen_desc,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(edw_ap_specimen->qual[d.seq].specimen_label,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_ap_specimen->qual[d.seq].comment_long_text_sk,16))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   "1", v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 04/29/2020 ss077455"
END GO
