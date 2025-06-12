CREATE PROGRAM bhs_med_rec_rpt_detail:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH ms_outdev, ms_begin_dt, ms_end_dt
 RECORD m_rec(
   1 m_list[*]
     2 ms_node_name = vc
     2 ms_trans_date = vc
     2 ms_trans_time = vc
     2 ms_timer_name = vc
     2 ms_sub_timer_name = vc
     2 ms_total_time_in_sec = vc
     2 ms_executable_name = vc
     2 ms_user_name = vc
     2 ms_syn_nbr = vc
     2 ms_oid_nbr = vc
     2 ms_ord_as_mnemonic = vc
     2 ms_hna_ord_mnemonic = vc
     2 ms_syn_name = vc
     2 ms_syn_type = vc
     2 mn_virt_view = i2
     2 ml_hide_flag = i4
     2 ms_ord_det_disp_ln = vc
     2 mf_synonym_id = f8
 ) WITH protect
 DECLARE ml_find_comma(x=vc(ref),n=i4) = i4 WITH protect
 DECLARE ml_find_char(x=vc(ref),n=i4,c=vc) = i4 WITH protect
 DECLARE ml_find_next_char(x=vc(ref),c=vc,ml_dmt_position=i4) = i4 WITH protect
 DECLARE ml_find_char_worker(x=vc,n=i4,c=vc,ml_dmt_position=i4) = i4 WITH protect
 DECLARE ms_nth_arg(x=vc,n=i4,c=vc) = vc WITH protect
 DECLARE ms_next_arg(x=vc,c=vc) = vc WITH protect
 DECLARE ms_p_start_dt = vc WITH protect, constant(cnvtupper( $MS_BEGIN_DT))
 DECLARE ms_p_end_dt = vc WITH protect, constant(cnvtupper( $MS_END_DT))
 DECLARE ml_start_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_end_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_retpos = i4 WITH protect, noconstant(0)
 DECLARE ml_found = i4 WITH protect, noconstant(0)
 DECLARE ms_str = vc WITH protect, noconstant("")
 DECLARE ml_len = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_stat_snaps dm,
   dm_stat_snaps_values dmv
  WHERE dmv.dm_stat_snap_id=dm.dm_stat_snap_id
   AND dm.stat_snap_dt_tm >= cnvtdatetime(ms_p_start_dt)
   AND (dm.stat_snap_dt_tm < (cnvtdatetime(ms_p_end_dt)+ 1))
   AND dm.snapshot_type="RTMS_DISCRETE"
   AND dmv.stat_name != "NO_NEW_DATA"
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt = (ml_cnt+ 1),
   CALL alterlist(m_rec->m_list,ml_cnt), m_rec->m_list[ml_cnt].ms_node_name = dm.node_name,
   m_rec->m_list[ml_cnt].ms_trans_date = ms_nth_arg(dmv.stat_clob_val,1,","), m_rec->m_list[ml_cnt].
   ms_trans_time = ms_nth_arg(dmv.stat_clob_val,2,","), m_rec->m_list[ml_cnt].ms_timer_name =
   ms_nth_arg(dmv.stat_clob_val,4,","),
   m_rec->m_list[ml_cnt].ms_sub_timer_name = ms_nth_arg(dmv.stat_clob_val,14,","), m_rec->m_list[
   ml_cnt].ms_total_time_in_sec = ms_nth_arg(dmv.stat_clob_val,5,","), m_rec->m_list[ml_cnt].
   ms_executable_name = ms_nth_arg(dmv.stat_clob_val,7,","),
   m_rec->m_list[ml_cnt].ms_user_name = ms_nth_arg(dmv.stat_clob_val,10,","), m_rec->m_list[ml_cnt].
   ms_syn_nbr = substring((findstring("syn:",dmv.stat_clob_val,1,0)+ 4),((findstring("oid:",dmv
     .stat_clob_val,1,0) - findstring("syn:",dmv.stat_clob_val,1,0)) - 5),dmv.stat_clob_val), m_rec->
   m_list[ml_cnt].ms_oid_nbr = substring((findstring("oid:",dmv.stat_clob_val,1,0)+ 4),((findstring(
     ",",dmv.stat_clob_val,findstring("oid:",dmv.stat_clob_val,1,0),0) - findstring("oid:",dmv
     .stat_clob_val,1,0)) - 5),dmv.stat_clob_val)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   orders o,
   (dummyt d  WITH seq = size(m_rec->m_list,5))
  PLAN (d)
   JOIN (o
   WHERE o.order_id=cnvtreal(m_rec->m_list[d.seq].ms_oid_nbr))
   JOIN (ocs
   WHERE ocs.synonym_id=o.synonym_id)
  DETAIL
   m_rec->m_list[d.seq].ms_syn_name = ocs.mnemonic, m_rec->m_list[d.seq].ms_syn_type =
   uar_get_code_display(ocs.mnemonic_type_cd), m_rec->m_list[d.seq].ml_hide_flag = ocs.hide_flag,
   m_rec->m_list[d.seq].mn_virt_view = 0, m_rec->m_list[d.seq].ms_ord_as_mnemonic = o
   .ordered_as_mnemonic, m_rec->m_list[d.seq].ms_hna_ord_mnemonic = o.hna_order_mnemonic,
   m_rec->m_list[d.seq].ms_ord_det_disp_ln = o.order_detail_display_line, m_rec->m_list[d.seq].
   mf_synonym_id = ocs.synonym_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(m_rec->m_list,5)),
   ocs_facility_r ofr
  PLAN (d)
   JOIN (ofr
   WHERE (ofr.synonym_id=m_rec->m_list[d.seq].mf_synonym_id))
  DETAIL
   m_rec->m_list[d.seq].mn_virt_view = 1
  WITH nocounter
 ;end select
 SELECT INTO  $MS_OUTDEV
  trans_date = trim(substring(1,10,m_rec->m_list[d.seq].ms_trans_date)), trans_time = trim(substring(
    1,10,m_rec->m_list[d.seq].ms_trans_time)), timer_name = trim(substring(1,100,m_rec->m_list[d.seq]
    .ms_timer_name)),
  sub_timer_name = trim(substring(1,50,m_rec->m_list[d.seq].ms_sub_timer_name)), exe_name = trim(
   substring(1,50,m_rec->m_list[d.seq].ms_executable_name)), user_name = trim(substring(1,50,m_rec->
    m_list[d.seq].ms_user_name)),
  total_time_in_sec = trim(substring(1,10,m_rec->m_list[d.seq].ms_total_time_in_sec)), syn_nbr = trim
  (substring(1,50,m_rec->m_list[d.seq].ms_syn_nbr)), syn_name = trim(substring(1,300,m_rec->m_list[d
    .seq].ms_syn_name)),
  syn_type = trim(substring(1,100,m_rec->m_list[d.seq].ms_syn_type)), hide_flag = m_rec->m_list[d.seq
  ].ml_hide_flag, virt_view = m_rec->m_list[d.seq].mn_virt_view,
  oid_nbr = trim(substring(1,50,m_rec->m_list[d.seq].ms_oid_nbr)), ord_as_mnemonic = trim(substring(1,
    200,m_rec->m_list[d.seq].ms_ord_as_mnemonic)), hna_ord_mnemonic = trim(substring(1,300,m_rec->
    m_list[d.seq].ms_hna_ord_mnemonic)),
  ord_det_disp_ln = trim(substring(1,1500,m_rec->m_list[d.seq].ms_ord_det_disp_ln))
  FROM (dummyt d  WITH seq = size(m_rec->m_list,5))
  PLAN (d)
  WITH nocounter, formfeed = none, format,
   separator = " "
 ;end select
 SUBROUTINE ml_find_comma(x,n)
   RETURN(ml_find_char(x,n,","))
 END ;Subroutine
 SUBROUTINE ml_find_next_char(x,c,ml_dmt_position)
   RETURN(ml_find_char_worker(x,1,c,ml_dmt_position))
 END ;Subroutine
 SUBROUTINE ml_find_char(x,n,c)
   RETURN(ml_find_char_worker(x,n,c,0))
 END ;Subroutine
 SUBROUTINE ml_find_char_worker(x,n,c,ml_dmt_position)
   SET ml_retpos = 1
   SET ml_found = 0
   WHILE (ml_retpos != 0
    AND ml_found != n)
     SET ml_retpos = findstring(c,x,(ml_dmt_position+ 1))
     SET ml_dmt_position = ml_retpos
     IF (ml_dmt_position)
      SET ml_found = (ml_found+ 1)
     ENDIF
   ENDWHILE
   RETURN(ml_dmt_position)
 END ;Subroutine
 SUBROUTINE ms_next_arg(x,c)
   SET ml_len = size(x)
   SET ml_start_pos = ml_end_pos
   SET ml_start_pos = ml_find_next_char(x,c,ml_start_pos)
   IF (ml_start_pos=0)
    RETURN(trim(ms_str))
   ELSE
    SET ml_end_pos = ml_find_next_char(x,c,ml_start_pos)
    IF (ml_end_pos=0)
     SET ml_end_pos = ml_len
    ELSE
     SET ml_end_pos = (ml_end_pos - 1)
    ENDIF
    SET ml_start_pos = (ml_start_pos+ 1)
    IF (ml_start_pos > ml_end_pos)
     RETURN(trim(ms_str))
    ELSE
     RETURN(substring(ml_start_pos,((ml_end_pos - ml_start_pos)+ 1),x))
    ENDIF
   ENDIF
   RETURN(trim(ms_str))
 END ;Subroutine
 SUBROUTINE ms_nth_arg(x,n,c)
   SET ml_len = size(x)
   SET ml_start_pos = 0
   SET ml_end_pos = 0
   IF (ml_len < 1)
    RETURN(trim(ms_str))
   ENDIF
   IF (n < 1)
    RETURN(trim(ms_str))
   ELSE
    IF (n=1)
     SET ml_start_pos = 1
    ELSE
     SET ml_start_pos = ml_find_char(x,(n - 1),c)
     IF (ml_start_pos=ml_len)
      RETURN(trim(ms_str))
     ELSEIF (ml_start_pos=0)
      SET ml_start_pos = 1
     ELSE
      SET ml_start_pos = (ml_start_pos+ 1)
     ENDIF
    ENDIF
    SET ml_end_pos = ml_find_next_char(x,c,(ml_start_pos - 1))
    IF (ml_end_pos=1)
     RETURN(trim(ms_str))
    ELSEIF (ml_end_pos=0)
     SET ml_end_pos = ml_len
    ELSE
     SET ml_end_pos = (ml_end_pos - 1)
    ENDIF
    SET ms_str = substring(ml_start_pos,((ml_end_pos - ml_start_pos)+ 1),x)
   ENDIF
   RETURN(trim(ms_str))
 END ;Subroutine
 FREE RECORD m_rec
END GO
