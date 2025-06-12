CREATE PROGRAM edw_create_container_file:dba
 DECLARE icontainer_count = i4 WITH protect, constant(size(edw_container->qual,5))
 SELECT INTO value(container_extractfile)
  FROM (dummyt d  WITH seq = icontainer_count)
  WHERE icontainer_count > 0
  DETAIL
   col 0, health_system_id, v_bar,
   health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].container_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].parent_container_sk,16))), v_bar,
   CALL print(trim(edw_container->qual[d.seq].additional_labels)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_container->qual[d.seq].label_dt_tm,0,
      cnvtdatetimeutc(edw_container->qual[d.seq].label_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].specimen_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].storage_rack_cell_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].collection_list_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].transfer_list_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].specimen_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].spec_cntnr_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].coll_class_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].spec_hndl_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].current_location_ref,16))),
   v_bar,
   CALL print(trim(edw_container->qual[d.seq].remaining_volume)), v_bar,
   CALL print(trim(edw_container->qual[d.seq].volume)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_container->qual[d.seq].drawn_dt_tm,0,
      cnvtdatetimeutc(edw_container->qual[d.seq].drawn_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].drawn_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_container->qual[d.seq].received_dt_tm,0,
      cnvtdatetimeutc(edw_container->qual[d.seq].received_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].received_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].collection_method_ref,16))), v_bar,
   CALL print(trim(evaluate(edw_container->qual[d.seq].units_ref,0.0,blank_field,cnvtstring(
      edw_container->qual[d.seq].units_ref,16)))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_container->qual[d.seq].
      original_storage_dt_tm,0,cnvtdatetimeutc(edw_container->qual[d.seq].original_storage_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_container->qual[d.seq].
      suggested_discard_dt_tm,0,cnvtdatetimeutc(edw_container->qual[d.seq].suggested_discard_dt_tm,3)
      ),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_container->qual[d.seq].discard_dt_tm,0,
      cnvtdatetimeutc(edw_container->qual[d.seq].discard_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].task_log_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].coll_comment_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].on_robotics_line_flg))), v_bar,
   CALL print(trim(edw_container->qual[d.seq].instr_login_ind)),
   v_bar,
   CALL print(trim(edw_container->qual[d.seq].auto_print_aliquot_ind)), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].storage_status_ref,16))), v_bar,
   extract_dt_tm_fmt,
   v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].label_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].drawn_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].received_tm_zn))),
   v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].original_storage_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].suggested_discard_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(edw_container->qual[d.seq].discard_tm_zn))),
   v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1
 ;end select
 SET script_version = "005 05/25/07 JW014069"
END GO
