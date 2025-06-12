CREATE PROGRAM edw_create_ap_slide_files:dba
 SELECT INTO value(ap_slide_extractfile)
  FROM (dummyt d  WITH seq = cur_list_size)
  WHERE (slide->qual[d.seq].ap_slide_sk > 0)
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_id)),
   v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(slide->qual[d.seq].ap_slide_sk,16))), v_bar,
   CALL print(trim(cnvtstring(slide->qual[d.seq].ap_block_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(slide->qual[d.seq].ap_specimen_sk,16))), v_bar,
   CALL print(trim(cnvtstring(slide->qual[d.seq].ap_case_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,slide->qual[d.seq].discard_dt_tm,0,
      cnvtdatetimeutc(slide->qual[d.seq].discard_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))
   ),
   v_bar,
   CALL print(trim(cnvtstring(slide->qual[d.seq].discard_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(slide->qual[d.seq].discard_dt_tm,cnvtint(slide->qual[d.seq]
      .discard_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(slide->qual[d.seq].discard_reason_ref,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,slide->qual[d.seq].orig_storage_dt_tm,0,
      cnvtdatetimeutc(slide->qual[d.seq].orig_storage_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(slide->qual[d.seq].orig_storage_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(slide->qual[d.seq].orig_storage_dt_tm,cnvtint(slide->qual[d
      .seq].orig_storage_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(build(slide->qual[d.seq].special_stain)), v_bar,
   CALL print(build(slide->qual[d.seq].slide_seq)), v_bar,
   CALL print(trim(replace(slide->qual[d.seq].origin_modifier,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(slide->qual[d.seq].stain_task_assay_sk,16))), v_bar,
   CALL print(trim(cnvtstring(slide->qual[d.seq].task_assay_sk,16))), v_bar,
   CALL print(trim(replace(slide->qual[d.seq].slide_label,str_find,str_replace,3),3)),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, "1",
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 04/28/2020 BS074648"
END GO
