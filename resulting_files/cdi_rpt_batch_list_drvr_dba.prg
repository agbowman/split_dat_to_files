CREATE PROGRAM cdi_rpt_batch_list_drvr:dba
 PROMPT
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Begin Time" = "CURTIME",
  "End Time" = "CURTIME",
  "Batch Class" = "",
  "All Batch Classes" = "0"
  WITH begin_date, end_date, begin_time,
  end_time, batch_class, all_batch_classes
 DECLARE vcstartdatetime = vc WITH noconstant(""), protect
 DECLARE vcenddatetime = vc WITH noconstant(""), protect
 DECLARE vcbcname = vc WITH noconstant(""), protect
 DECLARE vcallbc = vc WITH noconstant(""), protect
 DECLARE tp = vc WITH protect
 DECLARE bccount = i4 WITH noconstant(0), protect
 DECLARE num = i4
 DECLARE pos = i4
 DECLARE tempnum = i4 WITH noconstant(0), public
 DECLARE queue_cd = f8 WITH noconstant(0.0), protect
 DECLARE reason_cd = f8 WITH noconstant(0.0), protect
 DECLARE interval = dq8 WITH noconstant(cnvtdatetime(cnvtdate(00000000),cnvtint(1))), protect
 DECLARE translog_cnt = i4 WITH noconstant(0), protect
 DECLARE cur_prep_cnt = i4 WITH private, noconstant(0)
 SET vcstartdatetime = build2(parameter(1,0)," ",parameter(3,0))
 SET vcenddatetime = build2(parameter(2,0)," ",parameter(4,0))
 SET vcallbc = build(parameter(6,0))
 SET queue_cd = uar_get_code_by("MEANING",257571,"AUTO_INDEX")
 SET reason_cd = uar_get_code_by("MEANING",257572,"VALIDATE_MAN")
 IF (vcallbc="1")
  SELECT DISTINCT
   b.batchclass
   FROM cdi_ac_batch b
   WHERE b.cdi_ac_batch_id != 0
   ORDER BY b.batchclass
   DETAIL
    bccount = (bccount+ 1)
    IF (bccount > size(batch_class->qual,5))
     stat = alterlist(batch_class->qual,(bccount+ 9))
    ENDIF
    batch_class->qual[bccount].bcname = b.batchclass, batch_class->qual[bccount].bccount = 0
    IF (bccount=1)
     batch_lyt->batch_classes = b.batchclass
    ELSE
     batch_lyt->batch_classes = concat(batch_lyt->batch_classes,", ",b.batchclass)
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(batch_class->qual,bccount)
 ELSE
  SET tp = reflect(parameter(5,0))
  IF (substring(1,1,tp)="L")
   WHILE (reflect(parameter(5,(bccount+ 1))) > " ")
     SET bccount = (bccount+ 1)
     IF (bccount > size(batch_class->qual,5))
      SET stat = alterlist(batch_class->qual,(bccount+ 9))
     ENDIF
     SET batch_class->qual[bccount].bcname = build(parameter(5,bccount))
     SET batch_class->qual[bccount].bccount = 0
     IF (bccount=1)
      SET batch_lyt->batch_classes = build(parameter(5,bccount))
     ELSE
      SET batch_lyt->batch_classes = concat(batch_lyt->batch_classes,", ",build(parameter(5,bccount))
       )
     ENDIF
   ENDWHILE
   SET stat = alterlist(batch_class->qual,bccount)
  ELSEIF (substring(1,1,tp)="C")
   SET bccount = 1
   SET stat = alterlist(batch_class->qual,bccount)
   SET batch_class->qual[bccount].bcname = build(parameter(5,0))
   SET batch_class->qual[bccount].bccount = 0
   SET batch_lyt->batch_classes = build(parameter(5,0))
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  ca.batchname, c.ecp_cnt, c.combined_cnt,
  c.cur_auto_cnt, c.cur_man_cnt, c.man_create_cnt,
  c.man_del_cnt, c.complete_cnt, c.create_dt_tm,
  c.ac_rel_cnt, c.ac_rel_dt_tm, c.ac_rel_cnt,
  cab.modulename, c.external_batch_ident
  FROM cdi_batch_summary c,
   cdi_ac_batch ca,
   cdi_ac_batchmodule cab,
   cdi_ac_formtype f,
   cdi_trans_log ctl
  PLAN (c
   WHERE c.create_dt_tm >= cnvtdatetime(vcstartdatetime)
    AND c.create_dt_tm <= cnvtdatetime(vcenddatetime))
   JOIN (ca
   WHERE c.cdi_ac_batch_id=ca.cdi_ac_batch_id
    AND c.cdi_ac_batch_id != 0
    AND expand(num,1,size(batch_class->qual,5),ca.batchclass,batch_class->qual[num].bcname))
   JOIN (cab
   WHERE outerjoin(ca.cdi_ac_batch_id)=cab.cdi_ac_batch_id)
   JOIN (f
   WHERE outerjoin(cab.batchmoduleid)=f.batchmoduleid)
   JOIN (ctl
   WHERE outerjoin(c.external_batch_ident)=ctl.external_batch_ident
    AND outerjoin(queue_cd)=ctl.cdi_queue_cd
    AND outerjoin(reason_cd)=ctl.reason_cd
    AND outerjoin((c.create_dt_tm - 1)) < ctl.create_dt_tm
    AND outerjoin((c.create_dt_tm+ 1)) > ctl.create_dt_tm)
  ORDER BY c.cdi_ac_batch_id, ctl.cdi_trans_log_id, cab.startdatetime DESC
  HEAD REPORT
   row_cnt = 0, batch_lyt->total_pages = 0, stat = alterlist(batch_lyt->batch_details,50)
  HEAD c.cdi_ac_batch_id
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ENDIF
   batch_lyt->batch_details[row_cnt].batch_name = ca.batchname, batch_lyt->batch_details[row_cnt].
   batch_class = ca.batchclass, pos = locateval(tempnum,1,size(batch_class->qual,5),ca.batchclass,
    batch_class->qual[tempnum].bcname)
   IF (pos > 0)
    batch_class->qual[pos].bccount = (batch_class->qual[pos].bccount+ 1), batch_lyt->total_batches =
    (batch_lyt->total_batches+ 1)
   ENDIF
   batch_lyt->batch_details[row_cnt].external_batch_ident = c.external_batch_ident, batch_lyt->
   batch_details[row_cnt].ecp_cnt = c.ecp_cnt, batch_lyt->batch_details[row_cnt].combined_cnt = c
   .combined_cnt,
   batch_lyt->batch_details[row_cnt].cur_auto_cnt = c.cur_auto_cnt, batch_lyt->batch_details[row_cnt]
   .cur_man_cnt = c.cur_man_cnt, batch_lyt->batch_details[row_cnt].man_create_cnt = c.man_create_cnt,
   batch_lyt->batch_details[row_cnt].man_del_cnt = c.man_del_cnt, batch_lyt->batch_details[row_cnt].
   complete_cnt = c.complete_cnt, batch_lyt->batch_details[row_cnt].create_dt_tm = c.create_dt_tm,
   batch_lyt->batch_details[row_cnt].ac_rel_cnt = c.ac_rel_cnt, batch_lyt->batch_details[row_cnt].
   ac_rel_dt_tm = c.ac_rel_dt_tm
   IF (c.auto_comp_cnt > 0)
    batch_lyt->batch_details[row_cnt].avgautotime = (c.tot_auto_time/ c.auto_comp_cnt)
   ENDIF
   IF (c.man_comp_cnt > 0)
    batch_lyt->batch_details[row_cnt].avgmantime = (c.tot_man_time/ c.man_comp_cnt)
   ENDIF
   IF (c.prep_comp_cnt > 0)
    batch_lyt->batch_details[row_cnt].avgpreptime = (c.tot_prep_time/ c.prep_comp_cnt)
   ENDIF
   batch_lyt->batch_details[row_cnt].ac_qc_time = c.ac_qc_time, batch_lyt->batch_details[row_cnt].
   ac_rec_time = c.ac_rec_time, batch_lyt->batch_details[row_cnt].ac_rel_time = c.ac_rel_time,
   batch_lyt->batch_details[row_cnt].ac_scan_time = c.ac_scan_time, batch_lyt->batch_details[row_cnt]
   .ac_valid_time = c.ac_valid_time, batch_lyt->batch_details[row_cnt].ac_verify_time = c
   .ac_verify_time,
   batch_lyt->batch_details[row_cnt].totalactime = (((((c.ac_qc_time+ c.ac_rec_time)+ c.ac_rel_time)
   + c.ac_scan_time)+ c.ac_valid_time)+ c.ac_verify_time), batch_lyt->batch_details[row_cnt].docsinac
    = (batch_lyt->batch_details[row_cnt].docsinac+ f.documents)
   IF (c.prep_comp_cnt > 0)
    cur_prep_cnt = (((c.ac_rel_cnt - c.prep_comp_cnt) - c.ecp_cnt) - c.combined_cnt)
   ELSE
    cur_prep_cnt = 0
   ENDIF
   batch_lyt->batch_details[row_cnt].totaldocs = ((((cur_prep_cnt+ c.cur_man_cnt)+ c.cur_auto_cnt)+ c
   .complete_cnt)+ (c.wqm_create_cnt - c.wqm_del_cnt))
   IF (cab.modulename=null)
    batch_lyt->batch_details[row_cnt].nextacmodule = "Completed"
   ELSE
    batch_lyt->batch_details[row_cnt].nextacmodule = cab.modulename
   ENDIF
   batch_lyt->total_docs = (batch_lyt->total_docs+ batch_lyt->batch_details[row_cnt].totaldocs),
   batch_lyt->total_ip_docs = (((batch_lyt->total_ip_docs+ (((c.ac_rel_cnt - c.prep_comp_cnt) - c
   .ecp_cnt) - c.combined_cnt))+ c.cur_man_cnt)+ c.cur_auto_cnt), batch_lyt->total_completed_docs = (
   batch_lyt->total_completed_docs+ c.complete_cnt),
   batch_lyt->batch_details[row_cnt].index_nonmatch_cnt = 0, translog_cnt = 0
  HEAD ctl.cdi_trans_log_id
   IF (ctl.cdi_trans_log_id != null)
    batch_lyt->batch_details[row_cnt].index_nonmatch_cnt = (batch_lyt->batch_details[row_cnt].
    index_nonmatch_cnt+ 1)
   ENDIF
   translog_cnt = (translog_cnt+ 1)
  HEAD cab.startdatetime
   IF (translog_cnt=1)
    batch_lyt->total_pages = (batch_lyt->total_pages+ cab.pagesscanned), batch_lyt->batch_details[
    row_cnt].scanned_pgs_cnt = (batch_lyt->batch_details[row_cnt].scanned_pgs_cnt+ cab.pagesscanned)
   ENDIF
  FOOT REPORT
   stat = alterlist(batch_lyt->batch_details,row_cnt)
  WITH nocounter
 ;end select
END GO
