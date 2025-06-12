CREATE PROGRAM edw_create_pm_post_doc:dba
 SELECT INTO value(pm_post_doc_extractfile)
  FROM (dummyt d  WITH seq = size(edw_pm_post_doc->qual,5))
  WHERE (edw_pm_post_doc->qual[d.seq].pm_post_doc_sk > 0)
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_pm_post_doc->qual[d.seq].pm_post_doc_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pm_post_doc->qual[d.seq].pm_post_doc_ref_sk,16))),
   v_bar,
   CALL print(trim(replace(edw_pm_post_doc->qual[d.seq].parent_entity_name,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pm_post_doc->qual[d.seq].parent_entity_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pm_post_doc->qual[d.seq].print_dt_tm,0,
      cnvtdatetimeutc(edw_pm_post_doc->qual[d.seq].print_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pm_post_doc->qual[d.seq].print_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pm_post_doc->qual[d.seq].print_dt_tm,cnvtint(
      edw_pm_post_doc->qual[d.seq].print_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(build(edw_pm_post_doc->qual[d.seq].manual_create_ind)),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pm_post_doc->qual[d.seq].create_dt_tm,0,
      cnvtdatetimeutc(edw_pm_post_doc->qual[d.seq].create_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_pm_post_doc->qual[d.seq].create_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pm_post_doc->qual[d.seq].create_dt_tm,cnvtint(
      edw_pm_post_doc->qual[d.seq].create_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_pm_post_doc->qual[d.seq].create_prsnl_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pm_post_doc->qual[d.seq].active_dt_tm,0,
      cnvtdatetimeutc(edw_pm_post_doc->qual[d.seq].active_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_pm_post_doc->qual[d.seq].active_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pm_post_doc->qual[d.seq].active_dt_tm,cnvtint(
      edw_pm_post_doc->qual[d.seq].active_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(build(edw_pm_post_doc->qual[d.seq].src_active_ind,3)), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "000 07/21/2008 kp010433 179281"
END GO
