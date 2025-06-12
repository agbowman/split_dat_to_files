CREATE PROGRAM cdi_add_ac_data:dba
 IF (validate(reply)=0)
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
 FREE RECORD batch_summary_rec
 RECORD batch_summary_rec(
   1 qual[*]
     2 external_batch_ident = i4
     2 create_dt_tm = dq8
     2 cdi_ac_batch_id = f8
     2 ecp_cnt = i4
     2 combined_cnt = i4
     2 cur_auto_cnt = i4
     2 auto_comp_cnt = i4
     2 tot_auto_time = f8
     2 cur_man_cnt = i4
     2 man_comp_cnt = i4
     2 tot_man_time = f8
     2 man_create_cnt = i4
     2 man_del_cnt = i4
     2 complete_cnt = i4
     2 ac_rel_cnt = i4
     2 ac_rel_dt_tm = dq8
     2 prep_comp_cnt = i4
     2 tot_prep_time = f8
     2 ac_scan_time = f8
     2 ac_valid_time = f8
     2 ac_rec_time = f8
     2 ac_verify_time = f8
     2 ac_qc_time = f8
     2 ac_rel_time = f8
     2 update_rec = i2
     2 status = i4
     2 cur_pharmacy_cnt = i4
     2 pharmacy_comp_cnt = i4
     2 tot_pharmacy_time = f8
     2 pharmacy_del_cnt = i4
     2 wq_combined_cnt = i4
     2 wq_create_cnt = i4
 )
 DECLARE batch_rows = i4 WITH noconstant(0), protect
 DECLARE batch_module_rows = i4 WITH noconstant(0), protect
 DECLARE module_launch_rows = i4 WITH noconstant(0), protect
 DECLARE form_type_rows = i4 WITH noconstant(0), protect
 DECLARE batch_summary_rows = i4 WITH noconstant(0), protect
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE affected_rows = i4 WITH noconstant(0), protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE interval = dq8 WITH noconstant(cnvtdatetime(cnvtdate(00000000),cnvtint(1))), protect
 DECLARE q_release = vc WITH constant("RELEASE.EXE"), protect
 DECLARE q_quality_control = vc WITH constant("QC.EXE"), protect
 DECLARE q_recognition_server = vc WITH constant("FP.EXE"), protect
 DECLARE q_validation = vc WITH constant("INDEX.EXE"), protect
 DECLARE q_scan = vc WITH constant("SCAN.EXE"), protect
 DECLARE q_verification = vc WITH constant("VERIFY.EXE"), protect
 SET batch_rows = value(size(request->batch,5))
 SET batch_module_rows = value(size(request->batchmodule,5))
 SET module_launch_rows = value(size(request->modulelaunch,5))
 SET form_type_rows = value(size(request->formtype,5))
 SET reply->status_data.status = "F"
 IF (module_launch_rows > 0)
  SELECT INTO "NL:"
   b.modulelaunchid
   FROM cdi_ac_module_launch b,
    (dummyt d  WITH seq = value(module_launch_rows))
   PLAN (d)
    JOIN (b
    WHERE (request->modulelaunch[d.seq].modulelaunchid=b.modulelaunchid))
   HEAD REPORT
    count = 0
   DETAIL
    count += 1, request->modulelaunch[d.seq].rec_exists = 1
   WITH nocounter
  ;end select
  SET rec_exists_num = 0
  SELECT INTO "NL:"
   d.seq
   FROM (dummyt d  WITH seq = module_launch_rows)
   DETAIL
    rec_exists_num += request->modulelaunch[d.seq].rec_exists
   WITH nocounter
  ;end select
  IF (module_launch_rows > rec_exists_num)
   INSERT  FROM (dummyt d  WITH seq = module_launch_rows),
     cdi_ac_module_launch l
    SET l.cdi_ac_module_launch_id = seq(cdi_seq,nextval), l.modulelaunchid = request->modulelaunch[d
     .seq].modulelaunchid, l.startdatetime = cnvtdatetime(request->modulelaunch[d.seq].startdatetime),
     l.enddatetime = cnvtdatetime(request->modulelaunch[d.seq].enddatetime), l.moduleuniqueid =
     request->modulelaunch[d.seq].moduleuniqueid, l.modulename = request->modulelaunch[d.seq].
     modulename,
     l.userid = request->modulelaunch[d.seq].userid, l.username = request->modulelaunch[d.seq].
     username, l.stationid = request->modulelaunch[d.seq].stationid,
     l.siteid = request->modulelaunch[d.seq].siteid, l.inprocesstid = request->modulelaunch[d.seq].
     inprocesstid, l.orphaned = request->modulelaunch[d.seq].orphaned,
     l.completedtid = request->modulelaunch[d.seq].completedtid, l.updt_applctx = reqinfo->
     updt_applctx, l.updt_cnt = 0,
     l.updt_dt_tm = cnvtdatetime(sysdate), l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->
     updt_task
    PLAN (d
     WHERE (request->modulelaunch[d.seq].rec_exists != 1))
     JOIN (l)
    WITH nocounter, status(request->modulelaunch[d.seq].status)
   ;end insert
   SET affected_rows = 0
   SELECT INTO "NL:"
    d.seq
    FROM (dummyt d  WITH seq = module_launch_rows)
    DETAIL
     affected_rows += request->modulelaunch[d.seq].status
    WITH nocounter
   ;end select
   IF ((affected_rows < (module_launch_rows - rec_exists_num)))
    SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_ac_module_launch"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (rec_exists_num > 0)
   UPDATE  FROM (dummyt d  WITH seq = module_launch_rows),
     cdi_ac_module_launch l
    SET l.startdatetime = cnvtdatetime(request->modulelaunch[d.seq].startdatetime), l.enddatetime =
     cnvtdatetime(request->modulelaunch[d.seq].enddatetime), l.moduleuniqueid = request->
     modulelaunch[d.seq].moduleuniqueid,
     l.modulename = request->modulelaunch[d.seq].modulename, l.userid = request->modulelaunch[d.seq].
     userid, l.username = request->modulelaunch[d.seq].username,
     l.stationid = request->modulelaunch[d.seq].stationid, l.siteid = request->modulelaunch[d.seq].
     siteid, l.inprocesstid = request->modulelaunch[d.seq].inprocesstid,
     l.orphaned = request->modulelaunch[d.seq].orphaned, l.completedtid = request->modulelaunch[d.seq
     ].completedtid, l.updt_applctx = reqinfo->updt_applctx,
     l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(sysdate), l.updt_id = reqinfo->updt_id,
     l.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (request->modulelaunch[d.seq].rec_exists=1))
     JOIN (l
     WHERE (request->modulelaunch[d.seq].modulelaunchid=l.modulelaunchid))
    WITH nocounter, status(request->modulelaunch[d.seq].status)
   ;end update
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_ac_module_launch"
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    CALL echo(build("Failed to update cdi_ac_module_launch: ",errmsg))
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (batch_rows > 0)
  SELECT INTO "NL:"
   FROM cdi_batch_summary bs,
    (dummyt d  WITH seq = value(batch_rows))
   PLAN (d)
    JOIN (bs
    WHERE (request->batch[d.seq].external_batch_ident=bs.external_batch_ident)
     AND bs.create_dt_tm > cnvtdatetime((request->batch[d.seq].createdatetime - interval))
     AND bs.create_dt_tm < cnvtdatetime((request->batch[d.seq].createdatetime+ interval)))
   DETAIL
    request->batch[d.seq].createdatetime = bs.create_dt_tm
   WITH nocounter
  ;end select
  SET rec_exists_num = 0
  SELECT INTO "NL:"
   b.external_batch_ident, b.create_dt_tm
   FROM cdi_ac_batch b,
    (dummyt d  WITH seq = batch_rows)
   PLAN (d)
    JOIN (b
    WHERE (request->batch[d.seq].external_batch_ident=b.external_batch_ident)
     AND cnvtdatetime(request->batch[d.seq].createdatetime)=b.create_dt_tm)
   DETAIL
    rec_exists_num += 1, request->batch[d.seq].rec_exists = 1
   WITH nocounter
  ;end select
  IF (batch_rows > rec_exists_num)
   INSERT  FROM (dummyt d  WITH seq = value(batch_rows)),
     cdi_ac_batch b
    SET b.cdi_ac_batch_id = seq(cdi_seq,nextval), b.external_batch_ident = request->batch[d.seq].
     external_batch_ident, b.batchname = request->batch[d.seq].batchname,
     b.creationstationid = request->batch[d.seq].creationstationid, b.creationuserid = request->
     batch[d.seq].creationuserid, b.creationusername = request->batch[d.seq].creationusername,
     b.batchclass = request->batch[d.seq].batchclass, b.batchclassdescription = request->batch[d.seq]
     .batchclassdescription, b.transferid = request->batch[d.seq].transferid,
     b.create_dt_tm = cnvtdatetime(request->batch[d.seq].createdatetime), b.updt_applctx = reqinfo->
     updt_applctx, b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
     updt_task
    PLAN (d
     WHERE (request->batch[d.seq].rec_exists != 1))
     JOIN (b)
    WITH nocounter, status(request->batch[d.seq].status)
   ;end insert
   SET affected_rows = 0
   SELECT INTO "NL:"
    d.seq
    FROM (dummyt d  WITH seq = batch_rows)
    DETAIL
     affected_rows += request->batch[d.seq].status
    WITH nocounter
   ;end select
   IF ((affected_rows < (batch_rows - rec_exists_num)))
    SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_ac_batch"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (batch_module_rows > 0)
  SELECT INTO "NL:"
   b.cdi_ac_batch_id, b.create_dt_tm
   FROM cdi_ac_batch b,
    (dummyt d  WITH seq = value(batch_module_rows))
   PLAN (d)
    JOIN (b
    WHERE (request->batchmodule[d.seq].external_batch_ident=b.external_batch_ident))
   ORDER BY b.external_batch_ident, b.cdi_ac_batch_id
   DETAIL
    request->batchmodule[d.seq].cdi_ac_batch_id = b.cdi_ac_batch_id, request->batchmodule[d.seq].
    create_dt_tm = b.create_dt_tm
   WITH nocounter
  ;end select
  SET rec_exists_num = 0
  SELECT INTO "NL:"
   bm.batchmoduleid
   FROM cdi_ac_batchmodule bm,
    (dummyt d  WITH seq = batch_module_rows)
   PLAN (d)
    JOIN (bm
    WHERE (request->batchmodule[d.seq].batchmoduleid=bm.batchmoduleid))
   DETAIL
    rec_exists_num += 1, request->batchmodule[d.seq].rec_exists = 1
   WITH nocounter
  ;end select
  IF (batch_module_rows > rec_exists_num)
   INSERT  FROM (dummyt d  WITH seq = batch_module_rows),
     cdi_ac_batchmodule b
    SET b.cdi_ac_batchmodule_id = seq(cdi_seq,nextval), b.batchmoduleid = request->batchmodule[d.seq]
     .batchmoduleid, b.external_batch_ident = request->batchmodule[d.seq].external_batch_ident,
     b.batchdescription = request->batchmodule[d.seq].batchdescription, b.modulelaunchid = request->
     batchmodule[d.seq].modulelaunchid, b.modulecloseuniqueid = request->batchmodule[d.seq].
     modulecloseuniqueid,
     b.modulename = request->batchmodule[d.seq].modulename, b.startdatetime = cnvtdatetime(request->
      batchmodule[d.seq].startdatetime), b.enddatetime = cnvtdatetime(request->batchmodule[d.seq].
      enddatetime),
     b.batchstatus = request->batchmodule[d.seq].batchstatus, b.priority = request->batchmodule[d.seq
     ].priority, b.expectedpages = request->batchmodule[d.seq].expectedpages,
     b.expecteddocs = request->batchmodule[d.seq].expecteddocs, b.deleted = request->batchmodule[d
     .seq].deleted, b.pagesperdocument = request->batchmodule[d.seq].pagesperdocument,
     b.pagesscanned = request->batchmodule[d.seq].pagesscanned, b.pagesdeleted = request->
     batchmodule[d.seq].pagesdeleted, b.documentscreated = request->batchmodule[d.seq].
     documentscreated,
     b.documentsdeleted = request->batchmodule[d.seq].documentsdeleted, b.changedformtypes = request
     ->batchmodule[d.seq].changedformtypes, b.pagesreplaced = request->batchmodule[d.seq].
     pagesreplaced,
     b.errorcode = request->batchmodule[d.seq].errorcode, b.errortext = request->batchmodule[d.seq].
     errortext, b.orphaned = request->batchmodule[d.seq].orphaned,
     b.transferid = request->batchmodule[d.seq].transferid, b.cdi_ac_batch_id = request->batchmodule[
     d.seq].cdi_ac_batch_id, b.updt_applctx = reqinfo->updt_applctx,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (request->batchmodule[d.seq].rec_exists != 1))
     JOIN (b)
    WITH nocounter, status(request->batchmodule[d.seq].status)
   ;end insert
   SET affected_rows = 0
   SELECT INTO "NL:"
    d.seq
    FROM (dummyt d  WITH seq = batch_module_rows)
    DETAIL
     affected_rows += request->batchmodule[d.seq].status
    WITH nocounter
   ;end select
   IF ((affected_rows < (batch_module_rows - rec_exists_num)))
    SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_ac_batchmodule"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "NL:"
   d.seq, cdi_ac_batch_id = request->batchmodule[d.seq].cdi_ac_batch_id
   FROM (dummyt d  WITH seq = batch_module_rows)
   ORDER BY cdi_ac_batch_id
   HEAD cdi_ac_batch_id
    batch_summary_rows += 1
    IF (mod(batch_summary_rows,10)=1)
     stat = alterlist(batch_summary_rec->qual,(batch_summary_rows+ 9))
    ENDIF
    batch_summary_rec->qual[batch_summary_rows].external_batch_ident = request->batchmodule[d.seq].
    external_batch_ident, batch_summary_rec->qual[batch_summary_rows].create_dt_tm = request->
    batchmodule[d.seq].create_dt_tm, batch_summary_rec->qual[batch_summary_rows].cdi_ac_batch_id =
    request->batchmodule[d.seq].cdi_ac_batch_id,
    batch_summary_rec->qual[batch_summary_rows].update_rec = 0
   WITH nocounter
  ;end select
  SET stat = alterlist(batch_summary_rec->qual,batch_summary_rows)
 ENDIF
 IF (form_type_rows > 0)
  SELECT INTO "NL:"
   b.formtypeentryid
   FROM cdi_ac_formtype b,
    (dummyt d  WITH seq = form_type_rows)
   PLAN (d)
    JOIN (b
    WHERE (request->formtype[d.seq].formtypeentryid=b.formtypeentryid))
   HEAD REPORT
    count = 0
   DETAIL
    count += 1, request->formtype[d.seq].rec_exists = 1
   WITH nocounter
  ;end select
  SET rec_exists_num = 0
  SELECT INTO "NL:"
   d.seq
   FROM (dummyt d  WITH seq = form_type_rows)
   DETAIL
    rec_exists_num += request->formtype[d.seq].rec_exists
   WITH nocounter
  ;end select
  IF (form_type_rows > rec_exists_num)
   INSERT  FROM (dummyt d  WITH seq = form_type_rows),
     cdi_ac_formtype b
    SET b.cdi_ac_formtype_id = seq(cdi_seq,nextval), b.formtypeentryid = request->formtype[d.seq].
     formtypeentryid, b.batchmoduleid = request->formtype[d.seq].batchmoduleid,
     b.formtypename = request->formtype[d.seq].formtypename, b.docclassname = request->formtype[d.seq
     ].docclassname, b.documents = request->formtype[d.seq].documents,
     b.rejecteddocs = request->formtype[d.seq].rejecteddocs, b.pages = request->formtype[d.seq].pages,
     b.rejectedpages = request->formtype[d.seq].rejectedpages,
     b.ks_manual = request->formtype[d.seq].ks_manual, b.ks_ocrrepair = request->formtype[d.seq].
     ks_ocrrepair, b.ks_icrrepair = request->formtype[d.seq].ks_icrrepair,
     b.ks_bcrepair = request->formtype[d.seq].ks_bcrepair, b.ks_omrrepair = request->formtype[d.seq].
     ks_omrrepair, b.completeddocs = request->formtype[d.seq].completeddocs,
     b.completedpages = request->formtype[d.seq].completedpages, b.transferid = request->formtype[d
     .seq].transferid, b.updt_applctx = reqinfo->updt_applctx,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (request->formtype[d.seq].rec_exists != 1))
     JOIN (b)
    WITH nocounter, status(request->formtype[d.seq].status)
   ;end insert
   SET affected_rows = 0
   SELECT INTO "NL:"
    d.seq
    FROM (dummyt d  WITH seq = form_type_rows)
    DETAIL
     affected_rows += request->formtype[d.seq].status
    WITH nocounter
   ;end select
   IF ((affected_rows < (form_type_rows - rec_exists_num)))
    SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_ac_formtype"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (batch_summary_rows > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = batch_summary_rows),
    cdi_ac_batchmodule m,
    cdi_ac_module_launch ml,
    cdi_ac_formtype f
   PLAN (d)
    JOIN (m
    WHERE (batch_summary_rec->qual[d.seq].cdi_ac_batch_id=m.cdi_ac_batch_id))
    JOIN (ml
    WHERE m.modulelaunchid=ml.modulelaunchid)
    JOIN (f
    WHERE (f.batchmoduleid= Outerjoin(m.batchmoduleid)) )
   ORDER BY m.cdi_ac_batch_id, m.cdi_ac_batchmodule_id
   HEAD REPORT
    count = 0
   HEAD m.cdi_ac_batch_id
    count += 1
   HEAD m.cdi_ac_batchmodule_id
    CASE (cnvtupper(ml.moduleuniqueid))
     OF q_release:
      batch_summary_rec->qual[d.seq].ac_rel_dt_tm = cnvtdatetime(m.enddatetime),batch_summary_rec->
      qual[d.seq].ac_rel_time = (datetimediff(m.enddatetime,m.startdatetime,5)+ batch_summary_rec->
      qual[d.seq].ac_rel_time)
     OF q_quality_control:
      batch_summary_rec->qual[d.seq].ac_qc_time = (datetimediff(m.enddatetime,m.startdatetime,5)+
      batch_summary_rec->qual[d.seq].ac_qc_time)
     OF q_recognition_server:
      batch_summary_rec->qual[d.seq].ac_rec_time = (datetimediff(m.enddatetime,m.startdatetime,5)+
      batch_summary_rec->qual[d.seq].ac_rec_time)
     OF q_validation:
      batch_summary_rec->qual[d.seq].ac_valid_time = (datetimediff(m.enddatetime,m.startdatetime,5)+
      batch_summary_rec->qual[d.seq].ac_valid_time)
     OF q_scan:
      batch_summary_rec->qual[d.seq].ac_scan_time = (datetimediff(m.enddatetime,m.startdatetime,5)+
      batch_summary_rec->qual[d.seq].ac_scan_time)
     OF q_verification:
      batch_summary_rec->qual[d.seq].ac_verify_time = (datetimediff(m.enddatetime,m.startdatetime,5)
      + batch_summary_rec->qual[d.seq].ac_verify_time)
    ENDCASE
   DETAIL
    CASE (cnvtupper(ml.moduleuniqueid))
     OF q_release:
      batch_summary_rec->qual[d.seq].ac_rel_cnt = (f.completeddocs+ batch_summary_rec->qual[d.seq].
      ac_rel_cnt)
    ENDCASE
   WITH nocounter
  ;end select
  IF (count > 0)
   EXECUTE cdi_upd_batch_summary
   IF ((reply->status_data.status != "S"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_upd_batch_summary"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD batch_summary_rec
END GO
