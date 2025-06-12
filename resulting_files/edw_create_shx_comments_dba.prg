CREATE PROGRAM edw_create_shx_comments:dba
 SELECT INTO value(shx_com_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_shx_comment->qual[d.seq].shx_comment_inst_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_comment->qual[d.seq].shx_activity_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_shx_comment->qual[d.seq].shx_activity_group_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_comment->qual[d.seq].long_text_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_comment->qual[d.seq].comment_prsnl_sk,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_shx_comment->qual[d.seq].comment_dt_tm,0,
      cnvtdatetimeutc(edw_shx_comment->qual[d.seq].comment_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_shx_comment->qual[d.seq].comment_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_shx_comment->qual[d.seq].comment_dt_tm,cnvtint(
      edw_shx_comment->qual[d.seq].comment_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")),
   v_bar, "3", v_bar,
   CALL print(trim(cnvtstring(edw_shx_comment->qual[d.seq].active_ind))), v_bar, extract_dt_tm_fmt,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
