CREATE PROGRAM cps_get_inc_orders_pg_tst:dba
 FREE SET request
 RECORD request(
   1 phys_id = f8
   1 person_id = f8
   1 page_context
     2 ranges
       3 s_range_table_alias = vc
       3 s_range_column_name = vc
       3 d_earliest = dq8
       3 d_latest = dq8
     2 directives
       3 n_page_size = i2
       3 n_page_direction = i2
       3 n_initial_search_ind = i2
     2 sort_columns[*]
       3 s_table_alias = vc
       3 s_column_name = vc
       3 s_table_join_alias = vc
       3 s_column_join_name = vc
       3 n_sort_index = i2
       3 n_descending_ind = i2
       3 n_start_at_type = i2
       3 s_start_at_value = vc
       3 l_start_at_value = i4
       3 f_start_at_value = f8
       3 d_start_at_value = dq8
 )
 FREE SET reply
 RECORD reply(
   1 page_context
     2 n_more_ind = i2
   1 qual_knt = i4
   1 qual[*]
     2 order_id = f8
     2 name_full_formatted = vc
     2 person_id = f8
     2 encntr_id = f8
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_mean = c12
     2 order_mnemonic = vc
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_desc = c60
     2 activity_type_mean = c12
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 last_update_provider_id = f8
     2 order_detail_display_line = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 catalog_type_desc = c60
     2 catalog_type_mean = c12
     2 synonym_id = f8
     2 oe_format_id = f8
     2 ref_text_mask = i4
     2 last_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->phys_id = 18663784.00
 SET request->person_id = 0.00
 SET request->page_context.ranges.s_range_table_alias = "o"
 SET request->page_context.ranges.s_range_column_name = "orig_order_dt_tm"
 SET request->page_context.ranges.d_earliest = cnvtdatetime("29-MAY-1970 10:18:00")
 SET request->page_context.ranges.d_latest = cnvtdatetime("8-JUN-2006 10:18:00")
 SET request->page_context.directives.n_page_size = 50
 SET request->page_context.directives.n_page_direction = 1
 SET request->page_context.directives.n_initial_search_ind = 1
 SET stat = alterlist(request->page_context.sort_columns,2)
 SET request->page_context.sort_columns[1].s_table_alias = "o"
 SET request->page_context.sort_columns[1].s_column_name = "orig_order_dt_tm"
 SET request->page_context.sort_columns[1].s_table_join_alias = ""
 SET request->page_context.sort_columns[1].s_column_join_name = ""
 SET request->page_context.sort_columns[1].n_sort_index = 1
 SET request->page_context.sort_columns[1].n_descending_ind = 0
 SET request->page_context.sort_columns[1].n_start_at_type = 4
 SET request->page_context.sort_columns[1].s_start_at_value = ""
 SET request->page_context.sort_columns[2].s_table_alias = "o"
 SET request->page_context.sort_columns[2].s_column_name = "order_id"
 SET request->page_context.sort_columns[2].s_table_join_alias = ""
 SET request->page_context.sort_columns[2].s_column_join_name = ""
 SET request->page_context.sort_columns[2].n_sort_index = 2
 SET request->page_context.sort_columns[2].n_descending_ind = 0
 SET request->page_context.sort_columns[2].n_start_at_type = 3
 SET request->page_context.sort_columns[2].s_start_at_value = ""
 EXECUTE cps_get_inc_orders_pg
 CALL echorecord(reply)
END GO
