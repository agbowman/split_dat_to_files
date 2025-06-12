CREATE PROGRAM cps_get_order_notify_pg_tst:dba
 FREE SET request
 RECORD request(
   1 f_phys_id = f8
   1 patient_id = f8
   1 caused_by_flags[*]
     2 caused_by_flag = i2
   1 type_flags[*]
     2 type_flag = i2
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
   1 notification[*]
     2 order_notification_id = f8
     2 action_sequence = i4
     2 from_prsnl_id = f8
     2 notification_type_flag = i4
     2 notification_dt_tm = dq8
     2 caused_by_flag = i4
     2 notification_reason_cd = f8
     2 notification_reason_disp = c40
     2 notification_comment = vc
     2 notification_status_flag = i4
     2 status_change_dt_tm = dq8
     2 order_id = f8
     2 encntr_id = f8
     2 order_action_type_cd = f8
     2 order_action_type_disp = c40
     2 loc_facility_cd = f8
     2 last_updt_cnt = i4
     2 last_action_seq = i4
     2 last_ingred_action_seq = i4
     2 found_originator = i2
     2 oe_format_id = f8
     2 person_id = f8
     2 name_last_key = vc
     2 order_status_cd = f8
     2 drug_ingred_knt = i4
     2 drug_ingred[*]
       3 catalog_cd = f8
       3 cki = vc
       3 source_identifier = vc
       3 source_vocab_mean = vc
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 stop_type_cd = f8
     2 projected_stop_dt_tm = dq8
     2 clinical_display_line = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 order_mnemonic = vc
     2 med_order_type_cd = f8
     2 additive_count_for_ivpb = i4
     2 ingredient[*]
       3 hna_order_mnemonic = vc
       3 order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 ingredient_type_flag = i2
       3 strength = f8
       3 strength_unit = f8
       3 volume = f8
       3 volume_unit = f8
       3 freetext_dose = vc
       3 freq_cd = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 originator_id = f8
     2 get_comment_ind = i2
     2 order_comment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->f_phys_id = 18663784.000000
 SET stat = alterlist(request->caused_by_flags,2)
 SET request->caused_by_flags[1].caused_by_flag = 0
 SET stat = alterlist(request->type_flags,1)
 SET request->type_flags[1].type_flag = 1
 SET request->page_context.ranges.s_range_table_alias = "n"
 SET request->page_context.ranges.s_range_column_name = "notification_dt_tm"
 SET request->page_context.ranges.d_earliest = cnvtdatetime("03-DEC-2005 18:24:34")
 SET request->page_context.ranges.d_latest = cnvtdatetime("04-NOV-2007 18:32:59")
 SET request->page_context.directives.n_page_size = 100
 SET request->page_context.directives.n_page_direction = 1
 SET request->page_context.directives.n_initial_search_ind = 1
 SET pn_col_count = 0
 SET stat = alterlist(request->page_context.sort_columns,2)
 SET pn_col_count = (pn_col_count+ 1)
 SET request->page_context.sort_columns[pn_col_count].s_table_alias = "p"
 SET request->page_context.sort_columns[pn_col_count].s_column_name = "name_last_key"
 SET request->page_context.sort_columns[pn_col_count].s_table_join_alias = "n"
 SET request->page_context.sort_columns[pn_col_count].s_column_join_name = "person_id"
 SET request->page_context.sort_columns[pn_col_count].n_sort_index = 1
 SET request->page_context.sort_columns[pn_col_count].n_descending_ind = 0
 SET request->page_context.sort_columns[pn_col_count].n_start_at_type = 1
 SET request->page_context.sort_columns[pn_col_count].s_start_at_value = "MORTIMER"
 SET pn_col_count = (pn_col_count+ 1)
 SET stat = alterlist(request->page_context.sort_columns,pn_col_count)
 SET request->page_context.sort_columns[pn_col_count].s_table_alias = "n"
 SET request->page_context.sort_columns[pn_col_count].s_column_name = "order_notification_id"
 SET request->page_context.sort_columns[pn_col_count].n_sort_index = 2
 SET request->page_context.sort_columns[pn_col_count].n_descending_ind = 0
 SET request->page_context.sort_columns[pn_col_count].n_start_at_type = 3
 SET request->page_context.sort_columns[pn_col_count].f_start_at_value = 31823395.00
 EXECUTE cps_get_order_notify_pg
 CALL echorecord(reply)
END GO
