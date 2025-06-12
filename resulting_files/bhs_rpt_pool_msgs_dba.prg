CREATE PROGRAM bhs_rpt_pool_msgs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "SYSDATE",
  "End Date Time" = "SYSDATE"
  WITH outdev, s_beg_dt_tm, s_end_dt_tm
 FREE RECORD m_rec
 RECORD m_rec(
   1 pool[*]
     2 f_prsnl_grp_id = f8
     2 s_prsnl_grp = vc
     2 l_tot_opened = i4
     2 l_tot_pend = i4
     2 l_tot_close_del = i4
     2 l_tot_msgs = i4
     2 l_tot_opened_90d = i4
     2 l_tot_pend_90d = i4
     2 l_tot_close_del_90d = i4
     2 l_tot_msgs_90d = i4
     2 l_tot_msgs_30d = i4
 ) WITH protect
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_pool_grp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",19189,"POOLGROUP"))
 DECLARE mf_opened_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"OPENED"))
 DECLARE mf_pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"PENDING"))
 DECLARE mf_deleted_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"DELETED"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",79,"COMPLETE"))
 CALL echo(build2("mf_POOL_GRP_CD: ",mf_pool_grp_cd))
 CALL echo(build2("mf_OPENED_CD: ",mf_opened_cd))
 CALL echo(build2("mf_PENDING_CD: ",mf_pending_cd))
 CALL echo(build2("mf_DELETED_CD: ",mf_deleted_cd))
 CALL echo(build2("mf_COMPLETED_CD: ",mf_completed_cd))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_90d_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_90d_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_filename = vc WITH protect, noconstant(concat("bhs_rpt_pool_msgs_",trim(format(sysdate,
     "mmddyyhhmmss;;d"),3),".csv"))
 CALL echo(ms_filename)
 IF (validate(request->batch_selection)=0)
  SET ms_beg_dt_tm = concat(trim( $S_BEG_DT_TM,3)," 00:00:00")
  SET ms_end_dt_tm = concat(trim( $S_END_DT_TM,3)," 23:59:59")
 ELSE
  SET ms_beg_dt_tm = trim(format(cnvtlookbehind("1,D",sysdate),"dd-mmm-yyyy 00:00:00;;d"),3)
  SET ms_end_dt_tm = trim(format(cnvtlookbehind("1,D",sysdate),"dd-mmm-yyyy 23:59:59;;d"),3)
 ENDIF
 SET ms_90d_beg_dt_tm = trim(format(datetimefind(cnvtlookbehind("90,D",sysdate),"D","B","B"),
   "dd-mmm-yyyy 00:00:00;;d"),3)
 SET ms_90d_end_dt_tm = trim(format(sysdate,"dd-mmm-yyyy 23:59:59;;d"),3)
 CALL echo(build2("ms_90d_beg_dt_tm: ",ms_90d_beg_dt_tm))
 CALL echo(build2("ms_90d_end_dt_tm: ",ms_90d_end_dt_tm))
 SELECT INTO "nl:"
  FROM task_activity_assignment taa,
   task_activity ta,
   prsnl_group pg
  PLAN (pg
   WHERE pg.prsnl_group_id > 0
    AND pg.active_ind=1
    AND pg.end_effective_dt_tm > sysdate
    AND pg.prsnl_group_class_cd=mf_pool_grp_cd)
   JOIN (taa
   WHERE taa.assign_prsnl_group_id=pg.prsnl_group_id
    AND taa.active_ind=1
    AND taa.beg_eff_dt_tm BETWEEN cnvtdatetime(ms_90d_beg_dt_tm) AND cnvtdatetime(ms_90d_end_dt_tm)
    AND taa.task_status_cd IN (mf_opened_cd, mf_pending_cd, mf_deleted_cd, mf_completed_cd))
   JOIN (ta
   WHERE ta.task_id=taa.task_id
    AND ta.active_ind=1
    AND ta.task_create_dt_tm BETWEEN cnvtdatetime(ms_90d_beg_dt_tm) AND cnvtdatetime(ms_90d_end_dt_tm
    ))
  ORDER BY pg.prsnl_group_name, ta.task_create_dt_tm
  HEAD REPORT
   pl_pool_cnt = 0, pl_msg_cnt = 0, pl_msg_cnt_90d = 0
  HEAD pg.prsnl_group_name
   pl_pool_cnt += 1, pl_msg_cnt = 0, pl_msg_cnt_90d = 0,
   CALL alterlist(m_rec->pool,pl_pool_cnt), m_rec->pool[pl_pool_cnt].f_prsnl_grp_id = pg
   .prsnl_group_id, m_rec->pool[pl_pool_cnt].s_prsnl_grp = trim(pg.prsnl_group_name,3)
  DETAIL
   pl_msg_cnt_90d += 1
   IF (ta.task_create_dt_tm >= cnvtlookbehind("30,D",sysdate))
    m_rec->pool[pl_pool_cnt].l_tot_msgs_30d += 1
   ENDIF
   IF (taa.task_status_cd=mf_opened_cd)
    m_rec->pool[pl_pool_cnt].l_tot_opened_90d += 1
   ELSEIF (taa.task_status_cd=mf_pending_cd)
    m_rec->pool[pl_pool_cnt].l_tot_pend_90d += 1
   ELSEIF (taa.task_status_cd IN (mf_deleted_cd, mf_completed_cd))
    m_rec->pool[pl_pool_cnt].l_tot_close_del_90d += 1
   ENDIF
   IF (ta.task_create_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
    pl_msg_cnt += 1
    IF (taa.task_status_cd=mf_opened_cd)
     m_rec->pool[pl_pool_cnt].l_tot_opened += 1
    ELSEIF (taa.task_status_cd=mf_pending_cd)
     m_rec->pool[pl_pool_cnt].l_tot_pend += 1
    ELSEIF (taa.task_status_cd IN (mf_deleted_cd, mf_completed_cd))
     m_rec->pool[pl_pool_cnt].l_tot_close_del += 1
    ENDIF
   ENDIF
  FOOT  pg.prsnl_group_name
   m_rec->pool[pl_pool_cnt].l_tot_msgs = pl_msg_cnt, m_rec->pool[pl_pool_cnt].l_tot_msgs_90d =
   pl_msg_cnt_90d
  WITH nocounter
 ;end select
 IF (size(m_rec->pool,5) > 0)
  CALL echo("select into file")
  SELECT INTO value(ms_filename)
   FROM (dummyt d  WITH seq = value(size(m_rec->pool,5)))
   ORDER BY d.seq
   HEAD REPORT
    ms_tmp = concat(
     '"DATE","POOL_NAME","TOTAL_MSGS_OPENED","TOTAL_MSGS_PENDING","TOTAL_MSGS_CLOSED_DELETED","TOTAL_MSGS",',
     '"TOTAL_MSGS_OPENED_LAST_90_D","TOTAL_MSGS_PENDING_LAST_90_D","TOTAL_MSGS_CLOSED_DELETED_LAST_90_D",',
     '"TOTAL_MSGS_LAST_90_D","TOTAL_MSGS_LAST_30_D"'), col 0, row + 1,
    ms_tmp
   HEAD d.seq
    ms_tmp = concat('"',substring(1,11,ms_beg_dt_tm),'",','"',m_rec->pool[d.seq].s_prsnl_grp,
     '",','"',trim(cnvtstring(m_rec->pool[d.seq].l_tot_opened),3),'",','"',
     trim(cnvtstring(m_rec->pool[d.seq].l_tot_pend),3),'",','"',trim(cnvtstring(m_rec->pool[d.seq].
       l_tot_close_del),3),'",',
     '"',trim(cnvtstring(m_rec->pool[d.seq].l_tot_msgs),3),'",','"',trim(cnvtstring(m_rec->pool[d.seq
       ].l_tot_opened_90d),3),
     '",','"',trim(cnvtstring(m_rec->pool[d.seq].l_tot_pend_90d),3),'",','"',
     trim(cnvtstring(m_rec->pool[d.seq].l_tot_close_del_90d),3),'",','"',trim(cnvtstring(m_rec->pool[
       d.seq].l_tot_msgs_90d),3),'",',
     '"',trim(cnvtstring(m_rec->pool[d.seq].l_tot_msgs_30d),3),'"'), col 0, row + 1,
    ms_tmp
   FOOT REPORT
    col 0, row + 1, '"*** END REPORT ***",,,,,,,,,'
   WITH nocounter, maxrow = 1, format,
    separator = " ", maxcol = 500
  ;end select
 ELSE
  CALL echo("no records found")
  SELECT INTO value(ms_filename)
   FROM dummyt d
   HEAD REPORT
    ms_tmp = concat(
     '"DATE","POOL_NAME","TOTAL_MSGS_OPENED","TOTAL_MSGS_PENDING","TOTAL_MSGS_CLOSED_DELETED","TOTAL_MSGS",',
     '"TOTAL_MSG_PENDING_LAST_90_D","TOTAL_MSGS_CLOSED_DELETED_LAST_90_D","TOTAL_MSGS_LAST_90_D",',
     '"TOTAL_MSGS_LAST_30_D"'), col 0, ms_tmp,
    col 0, row + 1, ms_tmp,
    col 0, "NO MSGS FOUND", col 0,
    row + 1, "*** END REPORT ***"
   WITH nocounter
  ;end select
 ENDIF
 IF (findfile(ms_filename)=1)
  SET ms_tmp = concat("Pool Msgs: ",substring(1,11,ms_beg_dt_tm))
  IF (size(m_rec->pool,5)=0)
   SET ms_tmp = concat(ms_tmp," No Records Found")
  ENDIF
  EXECUTE bhs_ma_email_file
  CALL emailfile(value(ms_filename),ms_filename,"cispoolsmessagesreport@baystatehealth.org",ms_tmp,1)
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
