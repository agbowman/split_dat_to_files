CREATE PROGRAM cdi_upd_batch_summary:dba
 IF (validate(reply->status_data.status)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE rows_to_update_count = i4 WITH noconstant(0), public
 DECLARE req_size = i4 WITH noconstant(0), protect
 DECLARE affected_rows = i4 WITH noconstant(0), protect
 DECLARE inserted_rows = i4 WITH noconstant(0), protect
 DECLARE updated_rows = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET req_size = value(size(batch_summary_rec->qual,5))
 IF (req_size > 0)
  SELECT INTO "NL:"
   bs.updt_cnt
   FROM cdi_batch_summary bs,
    (dummyt d  WITH seq = req_size)
   PLAN (d)
    JOIN (bs
    WHERE (bs.external_batch_ident=batch_summary_rec->qual[d.seq].external_batch_ident)
     AND bs.create_dt_tm=cnvtdatetime(batch_summary_rec->qual[d.seq].create_dt_tm))
   DETAIL
    rows_to_update_count = (rows_to_update_count+ 1), batch_summary_rec->qual[d.seq].update_rec = 1
   WITH nocounter, forupdatewait(bs)
  ;end select
  IF (rows_to_update_count > 0)
   UPDATE  FROM cdi_batch_summary bs,
     (dummyt d  WITH seq = req_size)
    SET bs.cdi_ac_batch_id = evaluate(batch_summary_rec->qual[d.seq].cdi_ac_batch_id,0.0,bs
      .cdi_ac_batch_id,batch_summary_rec->qual[d.seq].cdi_ac_batch_id), bs.ecp_cnt = (
     batch_summary_rec->qual[d.seq].ecp_cnt+ bs.ecp_cnt), bs.combined_cnt = (batch_summary_rec->qual[
     d.seq].combined_cnt+ bs.combined_cnt),
     bs.cur_auto_cnt = (batch_summary_rec->qual[d.seq].cur_auto_cnt+ bs.cur_auto_cnt), bs
     .auto_comp_cnt = (batch_summary_rec->qual[d.seq].auto_comp_cnt+ bs.auto_comp_cnt), bs
     .tot_auto_time = (batch_summary_rec->qual[d.seq].tot_auto_time+ bs.tot_auto_time),
     bs.cur_man_cnt = (batch_summary_rec->qual[d.seq].cur_man_cnt+ bs.cur_man_cnt), bs.man_comp_cnt
      = (batch_summary_rec->qual[d.seq].man_comp_cnt+ bs.man_comp_cnt), bs.tot_man_time = (
     batch_summary_rec->qual[d.seq].tot_man_time+ bs.tot_man_time),
     bs.man_create_cnt = (batch_summary_rec->qual[d.seq].man_create_cnt+ bs.man_create_cnt), bs
     .man_del_cnt = (batch_summary_rec->qual[d.seq].man_del_cnt+ bs.man_del_cnt), bs.complete_cnt = (
     batch_summary_rec->qual[d.seq].complete_cnt+ bs.complete_cnt),
     bs.prep_comp_cnt = (batch_summary_rec->qual[d.seq].prep_comp_cnt+ bs.prep_comp_cnt), bs
     .tot_prep_time = (batch_summary_rec->qual[d.seq].tot_prep_time+ bs.tot_prep_time), bs.ac_rel_cnt
      = (batch_summary_rec->qual[d.seq].ac_rel_cnt+ bs.ac_rel_cnt),
     bs.ac_rel_dt_tm = evaluate(batch_summary_rec->qual[d.seq].ac_rel_dt_tm,0.0,bs.ac_rel_dt_tm,
      cnvtdatetime(batch_summary_rec->qual[d.seq].ac_rel_dt_tm)), bs.ac_scan_time = (
     batch_summary_rec->qual[d.seq].ac_scan_time+ bs.ac_scan_time), bs.ac_valid_time = (
     batch_summary_rec->qual[d.seq].ac_valid_time+ bs.ac_valid_time),
     bs.ac_rec_time = (batch_summary_rec->qual[d.seq].ac_rec_time+ bs.ac_rec_time), bs.ac_verify_time
      = (batch_summary_rec->qual[d.seq].ac_verify_time+ bs.ac_verify_time), bs.ac_qc_time = (
     batch_summary_rec->qual[d.seq].ac_qc_time+ bs.ac_qc_time),
     bs.ac_rel_time = (batch_summary_rec->qual[d.seq].ac_rel_time+ bs.ac_rel_time), bs.updt_cnt = (bs
     .updt_cnt+ 1), bs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bs.updt_task = reqinfo->updt_task, bs.updt_id = reqinfo->updt_id, bs.updt_applctx = reqinfo->
     updt_applctx,
     bs.pharmacy_cnt = (batch_summary_rec->qual[d.seq].cur_pharmacy_cnt+ bs.pharmacy_cnt), bs
     .pharmacy_comp_cnt = (batch_summary_rec->qual[d.seq].pharmacy_comp_cnt+ bs.pharmacy_comp_cnt),
     bs.tot_pharmacy_time = (batch_summary_rec->qual[d.seq].tot_pharmacy_time+ bs.tot_pharmacy_time),
     bs.pharmacy_del_cnt = (batch_summary_rec->qual[d.seq].pharmacy_del_cnt+ bs.pharmacy_del_cnt), bs
     .wqm_create_cnt = (batch_summary_rec->qual[d.seq].wq_create_cnt+ bs.wqm_create_cnt), bs
     .wqm_del_cnt = (batch_summary_rec->qual[d.seq].wq_combined_cnt+ bs.wqm_del_cnt)
    PLAN (d)
     JOIN (bs
     WHERE (bs.external_batch_ident=batch_summary_rec->qual[d.seq].external_batch_ident)
      AND bs.create_dt_tm=cnvtdatetime(batch_summary_rec->qual[d.seq].create_dt_tm)
      AND (batch_summary_rec->qual[d.seq].update_rec=1))
    WITH nocounter, status(batch_summary_rec->qual[d.seq].status)
   ;end update
   SELECT INTO "NL:"
    d.seq
    FROM (dummyt d  WITH seq = req_size)
    DETAIL
     updated_rows = (updated_rows+ batch_summary_rec->qual[d.seq].status)
    WITH nocounter
   ;end select
   IF (updated_rows < rows_to_update_count)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (rows_to_update_count < req_size)
   INSERT  FROM cdi_batch_summary bs,
     (dummyt d  WITH seq = req_size)
    SET bs.cdi_batch_summary_id = seq(cdi_seq,nextval), bs.external_batch_ident = batch_summary_rec->
     qual[d.seq].external_batch_ident, bs.create_dt_tm = cnvtdatetime(batch_summary_rec->qual[d.seq].
      create_dt_tm),
     bs.cdi_ac_batch_id = batch_summary_rec->qual[d.seq].cdi_ac_batch_id, bs.ecp_cnt =
     batch_summary_rec->qual[d.seq].ecp_cnt, bs.combined_cnt = batch_summary_rec->qual[d.seq].
     combined_cnt,
     bs.cur_auto_cnt = batch_summary_rec->qual[d.seq].cur_auto_cnt, bs.auto_comp_cnt =
     batch_summary_rec->qual[d.seq].auto_comp_cnt, bs.tot_auto_time = batch_summary_rec->qual[d.seq].
     tot_auto_time,
     bs.cur_man_cnt = batch_summary_rec->qual[d.seq].cur_man_cnt, bs.man_comp_cnt = batch_summary_rec
     ->qual[d.seq].man_comp_cnt, bs.tot_man_time = batch_summary_rec->qual[d.seq].tot_man_time,
     bs.man_create_cnt = batch_summary_rec->qual[d.seq].man_create_cnt, bs.man_del_cnt =
     batch_summary_rec->qual[d.seq].man_del_cnt, bs.complete_cnt = batch_summary_rec->qual[d.seq].
     complete_cnt,
     bs.ac_rel_cnt = batch_summary_rec->qual[d.seq].ac_rel_cnt, bs.ac_rel_dt_tm = evaluate(
      batch_summary_rec->qual[d.seq].ac_rel_dt_tm,0.0,cnvtdatetime("01-JAN-1900"),cnvtdatetime(
       batch_summary_rec->qual[d.seq].ac_rel_dt_tm)), bs.prep_comp_cnt = batch_summary_rec->qual[d
     .seq].prep_comp_cnt,
     bs.tot_prep_time = batch_summary_rec->qual[d.seq].tot_prep_time, bs.ac_scan_time =
     batch_summary_rec->qual[d.seq].ac_scan_time, bs.ac_valid_time = batch_summary_rec->qual[d.seq].
     ac_valid_time,
     bs.ac_rec_time = batch_summary_rec->qual[d.seq].ac_rec_time, bs.ac_verify_time =
     batch_summary_rec->qual[d.seq].ac_verify_time, bs.ac_qc_time = batch_summary_rec->qual[d.seq].
     ac_qc_time,
     bs.ac_rel_time = batch_summary_rec->qual[d.seq].ac_rel_time, bs.updt_cnt = 0, bs.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     bs.updt_task = reqinfo->updt_task, bs.updt_id = reqinfo->updt_id, bs.updt_applctx = reqinfo->
     updt_applctx,
     bs.pharmacy_cnt = batch_summary_rec->qual[d.seq].cur_pharmacy_cnt, bs.pharmacy_comp_cnt =
     batch_summary_rec->qual[d.seq].pharmacy_comp_cnt, bs.tot_pharmacy_time = batch_summary_rec->
     qual[d.seq].tot_pharmacy_time,
     bs.pharmacy_del_cnt = batch_summary_rec->qual[d.seq].pharmacy_del_cnt, bs.wqm_create_cnt =
     batch_summary_rec->qual[d.seq].wq_create_cnt, bs.wqm_del_cnt = batch_summary_rec->qual[d.seq].
     wq_combined_cnt
    PLAN (d)
     JOIN (bs
     WHERE (batch_summary_rec->qual[d.seq].update_rec=0))
    WITH nocounter, status(batch_summary_rec->qual[d.seq].status)
   ;end insert
   SELECT INTO "NL:"
    d.seq
    FROM (dummyt d  WITH seq = req_size)
    DETAIL
     inserted_rows = (inserted_rows+ batch_summary_rec->qual[d.seq].status)
    WITH nocounter
   ;end select
   IF (((inserted_rows+ updated_rows) < req_size))
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_batch_summary"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
