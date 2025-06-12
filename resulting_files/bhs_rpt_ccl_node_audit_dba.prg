CREATE PROGRAM bhs_rpt_ccl_node_audit:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 ccl[*]
     2 s_object_name_grp = vc
     2 s_object_name = vc
     2 s_nodes = vc
     2 s_compiled_by = vc
     2 s_compile_dt_tm = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE ms_file_name = vc WITH protect, constant(concat("bhs_rpt_ccl_node_audit_",trim(format(
     sysdate,"mmddyyhhmm;;d"),3),".csv"))
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="BHS_OPS_CCL_NODE_AUDIT"
   AND di.info_char != "1236"
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->ccl,pl_cnt), m_rec->ccl[pl_cnt].s_object_name_grp = trim(di.info_name,3),
   ms_tmp = trim(cnvtupper(substring(1,(findstring(":",di.info_name) - 1),di.info_name)),3), m_rec->
   ccl[pl_cnt].s_object_name = trim(ms_tmp,3), m_rec->ccl[pl_cnt].s_nodes = trim(di.info_char,3)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dprotect dp
  PLAN (dp
   WHERE expand(ml_exp,1,size(m_rec->ccl,5),dp.object_name,m_rec->ccl[ml_exp].s_object_name)
    AND dp.object="P")
  HEAD dp.object_name
   ml_idx = locateval(ml_loc,1,size(m_rec->ccl,5),dp.object_name,m_rec->ccl[ml_loc].s_object_name),
   m_rec->ccl[ml_idx].s_compiled_by = dp.user_name, m_rec->ccl[ml_idx].s_compile_dt_tm = concat(trim(
     format(dp.datestamp,"mm/dd/yy;;d"),3)," ",trim(format(dp.timestamp,"hh:mm;;d"),3))
  WITH nocounter, expand = 1
 ;end select
 GO TO exit_script
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
