CREATE PROGRAM edw_create_order_recon:dba
 SELECT INTO value(ord_recon_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(concat(trim(cnvtstring(edw_order_recon->qual[d.seq].order_recon_id,16)),"~",trim(
     cnvtstring(edw_order_recon->qual[d.seq].order_recon_detail_id,16)))), v_bar,
   CALL print(trim(cnvtstring(edw_order_recon->qual[d.seq].order_recon_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_recon->qual[d.seq].order_nbr,16))), v_bar,
   CALL print(trim(replace(edw_order_recon->qual[d.seq].order_mnemonic,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_recon->qual[d.seq].performed_prsnl_id,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_order_recon->qual[d.seq].performed_dt_tm,
      0,cnvtdatetimeutc(edw_order_recon->qual[d.seq].performed_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_order_recon->qual[d.seq].performed_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_order_recon->qual[d.seq].performed_dt_tm,cnvtint(
      edw_order_recon->qual[d.seq].performed_tm_zn),"HHmmsscc"),"00000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_order_recon->qual[d.seq].updt_dt_tm,0,
      cnvtdatetimeutc(edw_order_recon->qual[d.seq].updt_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(edw_order_recon->qual[d.seq].updt_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_order_recon->qual[d.seq].updt_dt_tm,cnvtint(
      edw_order_recon->qual[d.seq].updt_tm_zn),"HHmmsscc"),"00000000","0","                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_order_recon->qual[d.seq].updt_id))), v_bar,
   CALL print(trim(edw_order_recon->qual[d.seq].recon_type_flg)), v_bar,
   CALL print(trim(edw_order_recon->qual[d.seq].no_known_meds_ind)),
   v_bar,
   CALL print(trim(replace(edw_order_recon->qual[d.seq].clinical_display_line,str_find,str_replace,3),
    3)), v_bar,
   CALL print(trim(replace(edw_order_recon->qual[d.seq].simplified_display_line,str_find,str_replace,
     3),3)), v_bar,
   CALL print(trim(edw_order_recon->qual[d.seq].continue_order_ind)),
   v_bar,
   CALL print(trim(replace(edw_order_recon->qual[d.seq].recon_order_action_meaning,str_find,
     str_replace,3),3)), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar,
   CALL print(trim(cnvtstring(edw_order_recon->qual[d.seq].order_recon_detail_id,16),3)), v_bar,
   CALL print(trim(cnvtstring(edw_order_recon->qual[d.seq].encntr_id,16),3)), v_bar,
   CALL print(trim(edw_order_recon->qual[d.seq].encntr_nk)),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 5000, maxrow = 1, append
 ;end select
END GO
