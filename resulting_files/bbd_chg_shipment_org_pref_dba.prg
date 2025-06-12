CREATE PROGRAM bbd_chg_shipment_org_pref:dba
 RECORD reply(
   1 org_shipment_id = f8
   1 new_task_assay_count = i2
   1 assayqual[*]
     2 accept_pos_test_id = f8
     2 task_assay_cd = f8
   1 new_quar_reason_count = i2
   1 reasonqual[*]
     2 accept_quar_reason_id = f8
     2 quar_reason_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET y = 0
 SET new_accept_pos_test_id = 0.0
 SET new_accept_quar_reason_id = 0.0
 SET new_org_shipment_id = 0.0
 SET reply->status_data.status = "F"
 SET failed = "F"
 DECLARE stat = i2 WITH protect, noconstant(0)
 IF ((request->add_org_shipment=1))
  DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
  SET new_pathnet_seq = 0
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    new_pathnet_seq = seqn
   WITH format, nocounter
  ;end select
  SET new_org_shipment_id = new_pathnet_seq
  SET reply->org_shipment_id = new_org_shipment_id
  INSERT  FROM org_shipment o
   SET o.org_shipment_id = new_org_shipment_id, o.organization_id = request->organization_id, o
    .destroy_once_expired_ind = request->destroy_expired_ind,
    o.req_testing_complete_ind = request->req_testing_ind, o.accept_expired_prod_ind = request->
    accept_expired_ind, o.accept_pos_result_ind = request->accept_pos_result_ind,
    o.accept_quarantined_prod_ind = request->accept_quar_products_ind, o.active_ind = 1, o
    .active_status_cd = reqdata->active_status_cd,
    o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
    updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    o.updt_id = reqinfo->updt_id, o.updt_cnt = 0, o.updt_task = reqinfo->updt_task,
    o.updt_applctx = reqinfo->updt_applctx, o.inventory_area_cd = request->inventory_area_cd
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "org_shipment"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "organization preference insert"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->update_org_shipment=1))
  SET reply->org_shipment_id = request->org_shipment_id
  SELECT INTO "nl:"
   o.*
   FROM org_shipment o
   WHERE (o.org_shipment_id=request->org_shipment_id)
    AND (o.updt_cnt=request->updt_cnt)
   WITH counter, forupdate(o)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].targetobjectname = "org_shipment"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "organization preference lock"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  UPDATE  FROM org_shipment o
   SET o.destroy_once_expired_ind =
    IF ((request->chg_destroy_expired_ind=1)) request->destroy_expired_ind
    ELSE o.destroy_once_expired_ind
    ENDIF
    , o.req_testing_complete_ind =
    IF ((request->chg_req_testing_ind=1)) request->req_testing_ind
    ELSE o.req_testing_complete_ind
    ENDIF
    , o.accept_expired_prod_ind =
    IF ((request->chg_accept_expired_ind=1)) request->accept_expired_ind
    ELSE o.accept_expired_prod_ind
    ENDIF
    ,
    o.accept_pos_result_ind =
    IF ((request->chg_accept_pos_result_ind=1)) request->accept_pos_result_ind
    ELSE o.accept_pos_result_ind
    ENDIF
    , o.accept_quarantined_prod_ind =
    IF ((request->chg_accept_quar_products_ind=1)) request->accept_quar_products_ind
    ELSE o.accept_quarantined_prod_ind
    ENDIF
    , o.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    o.active_status_prsnl_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o
    .updt_id = reqinfo->updt_id,
    o.updt_cnt = (request->updt_cnt+ 1), o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->
    updt_applctx
   WHERE (o.org_shipment_id=request->org_shipment_id)
    AND (o.updt_cnt=request->updt_cnt)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "org_shipment"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "update organization preference"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (y = 1 TO request->quar_reason_count)
   IF ((request->reasonqual[y].add_row=1))
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET new_accept_quar_reason_id = new_pathnet_seq
    SET reply->new_quar_reason_count = (reply->new_quar_reason_count+ 1)
    SET stat = alterlist(reply->reasonqual,reply->new_quar_reason_count)
    SET reply->reasonqual[reply->new_quar_reason_count].accept_quar_reason_id =
    new_accept_quar_reason_id
    SET reply->reasonqual[reply->new_quar_reason_count].quar_reason_cd = request->reasonqual[y].
    quar_reason_cd
    INSERT  FROM accept_quar_reason r
     SET r.accept_quar_reason_id = new_accept_quar_reason_id, r.org_shipment_id =
      IF ((request->add_org_shipment=1)) new_org_shipment_id
      ELSE request->reasonqual[y].org_shipment_id
      ENDIF
      , r.quar_reason_cd = request->reasonqual[y].quar_reason_cd,
      r.active_ind = 1, r.active_status_cd = reqdata->active_status_cd, r.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      r.active_status_prsnl_id = reqinfo->updt_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r
      .updt_id = reqinfo->updt_id,
      r.updt_cnt = 0, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].targetobjectname = "accept_quar_reason"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "organization preference insert"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
   ELSE
    SELECT INTO "nl:"
     r.*
     FROM accept_quar_reason r
     WHERE (r.accept_quar_reason_id=request->reasonqual[y].accept_quar_reason_id)
      AND (r.updt_cnt=request->reasonqual[y].updt_cnt)
     WITH counter, forupdate(r)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].targetobjectname = "accept_quar_reason"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "organization preference lock"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
    UPDATE  FROM accept_quar_reason r
     SET r.active_status_cd = reqdata->inactive_status_cd, r.active_ind = 0, r.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      r.active_status_prsnl_id = reqinfo->updt_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r
      .updt_id = reqinfo->updt_id,
      r.updt_cnt = (request->reasonqual[y].updt_cnt+ 1), r.updt_task = reqinfo->updt_task, r
      .updt_applctx = reqinfo->updt_applctx
     WHERE (r.accept_quar_reason_id=request->reasonqual[y].accept_quar_reason_id)
      AND (r.updt_cnt=request->reasonqual[y].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].targetobjectname = "accept_quar_reason"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "update organization preference"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
    UPDATE  FROM accept_quar_prod_r q
     SET q.active_status_cd = reqdata->inactive_status_cd, q.active_ind = 0, q.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      q.active_status_prsnl_id = reqinfo->updt_id, q.updt_dt_tm = cnvtdatetime(curdate,curtime3), q
      .updt_id = reqinfo->updt_id,
      q.updt_cnt = (q.updt_cnt+ 1), q.updt_task = reqinfo->updt_task, q.updt_applctx = reqinfo->
      updt_applctx
     WHERE (q.accept_quar_reason_id=request->reasonqual[y].accept_quar_reason_id)
      AND q.active_ind=1
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
