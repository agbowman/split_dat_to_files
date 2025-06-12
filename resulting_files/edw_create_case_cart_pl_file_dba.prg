CREATE PROGRAM edw_create_case_cart_pl_file:dba
 SELECT INTO value(ccpl_extractfile)
  FROM (dummyt d  WITH seq = value(ccpl_cnt))
  WHERE ccpl_cnt > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].surgical_case_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].case_cart_pick_lst_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].document_type_ref,16))), v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].doc_terminated_reason_ref,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,case_cart_pick_list_info->qual[d.seq].
      doc_terminated_dt_tm,0,cnvtdatetimeutc(case_cart_pick_list_info->qual[d.seq].
       doc_terminated_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].doc_terminated_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(case_cart_pick_list_info->qual[d.seq].doc_terminated_dt_tm,
     cnvtint(case_cart_pick_list_info->qual[d.seq].doc_terminated_tm_zn),"HHmmsscc"),"00000000","0",
    "        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].doc_terminated_by_prsnl,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,case_cart_pick_list_info->qual[d.seq].
      case_cart_finalized_dt_tm,0,cnvtdatetimeutc(case_cart_pick_list_info->qual[d.seq].
       case_cart_finalized_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].case_cart_finalized_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(case_cart_pick_list_info->qual[d.seq].
     case_cart_finalized_dt_tm,cnvtint(case_cart_pick_list_info->qual[d.seq].
      case_cart_finalized_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,case_cart_pick_list_info->qual[d.seq].
      case_cart_verfd_dt_tm,0,cnvtdatetimeutc(case_cart_pick_list_info->qual[d.seq].
       case_cart_verfd_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].case_cart_verfd_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(case_cart_pick_list_info->qual[d.seq].case_cart_verfd_dt_tm,
     cnvtint(case_cart_pick_list_info->qual[d.seq].case_cart_verfd_tm_zn),"HHmmsscc"),"00000000","0",
    "        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].case_cart_verfd_by_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].surgical_area_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].pick_list_item,16))), v_bar,
   CALL print(trim(replace(case_cart_pick_list_info->qual[d.seq].ft_item_desc,str_find,str_replace,3)
    )), v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].fill_loc,16))),
   v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].return_loc,16))), v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].wasted_reason_ref,16))), v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].fill_qty)),
   v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].hold_qty)), v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].open_qty)), v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].used_qty)),
   v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].requested_qty)), v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].return_qty)), v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].wasted_qty)),
   v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].item_type_flg)), v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].parent_case_cart_pick_lst_sk,16))
   ), v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].charge_duration)),
   v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].charge_unit_qty)), v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].charge_qty)), v_bar,
   CALL print(trim(cnvtstring(case_cart_pick_list_info->qual[d.seq].cost_type_ref,16))),
   v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].avg_cost_amt)), v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].last_cost_amt)), v_bar, "3",
   v_bar,
   CALL print(trim(extract_dt_tm_fmt)), v_bar,
   CALL print(trim(case_cart_pick_list_info->qual[d.seq].active_ind)), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 CALL echo(build("# Of Rows Written:",curqual))
 SET script_version = "001 01/24/2007 yc3429"
END GO
