CREATE PROGRAM edw_create_cds_batch_content:dba
 SELECT INTO value(cdsctnt_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(cdsctnt->qual[d.seq].cds_batch_cntnt_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(cdsctnt->qual[d.seq].cds_batch_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,cdsctnt->qual[d.seq].activity_dt_tm,0,
      cnvtdatetimeutc(cdsctnt->qual[d.seq].activity_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))
   ), v_bar,
   CALL print(trim(cnvtstring(cdsctnt->qual[d.seq].activity_tm_zn))),
   v_bar,
   CALL print(trim(cnvtstring(cdsctnt->qual[d.seq].activity_tm_vld_flg))), v_bar,
   CALL print(trim(cdsctnt->qual[d.seq].cds_row_error_ind,3)), v_bar,
   CALL print(trim(cnvtstring(cdsctnt->qual[d.seq].cds_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(cdsctnt->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(cdsctnt->qual[d.seq].cds_org,16))), v_bar,
   CALL print(trim(cnvtstring(cdsctnt->qual[d.seq].parent_entity_sk,16))),
   v_bar,
   CALL print(trim(replace(cdsctnt->qual[d.seq].parent_entity_name,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cdsctnt->qual[d.seq].update_del_flg,3)), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1
 ;end select
 SET script_version = "139498 15-AUG-2007 SB013134"
END GO
