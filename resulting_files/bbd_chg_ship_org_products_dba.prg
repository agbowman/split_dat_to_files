CREATE PROGRAM bbd_chg_ship_org_products:dba
 RECORD reply(
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
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET new_accept_pos_prod_id = 0.0
 SET new_accept_quar_prod_id = 0.0
 FOR (y = 1 TO request->task_assay_count)
   IF ((request->assayqual[y].add_row=1))
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET new_accept_pos_prod_id = new_pathnet_seq
    INSERT  FROM accept_pos_prod_r t
     SET t.accept_pos_prod_id = new_accept_pos_prod_id, t.accept_pos_test_id = request->assayqual[y].
      accept_pos_test_id, t.product_cd = request->assayqual[y].product_cd,
      t.active_ind = 1, t.active_status_cd = reqdata->active_status_cd, t.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      t.active_status_prsnl_id = reqinfo->updt_id, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t
      .updt_id = reqinfo->updt_id,
      t.updt_cnt = 0, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].targetobjectname = "accept_pos_prod_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "organization preference insert"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
   ELSE
    SELECT INTO "nl:"
     t.*
     FROM accept_pos_prod_r t
     WHERE (t.accept_pos_prod_id=request->assayqual[y].accept_pos_prod_id)
      AND (t.updt_cnt=request->assayqual[y].updt_cnt)
     WITH counter, forupdate(t)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].targetobjectname = "accept_pos_prod_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "organization preference lock"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].targetobjectname = "accept_pos_prod_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "update organization preference"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
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
    SET new_accept_quar_prod_id = new_pathnet_seq
    INSERT  FROM accept_quar_prod_r r
     SET r.accept_quar_prod_id = new_accept_quar_prod_id, r.accept_quar_reason_id = request->
      reasonqual[y].accept_quar_reason_id, r.product_cd = request->reasonqual[y].product_cd,
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
     SET reply->status_data.subeventstatus[1].targetobjectname = "accept_quar_prod_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "organization preference insert"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
   ELSE
    SELECT INTO "nl:"
     r.*
     FROM accept_quar_prod_r r
     WHERE (r.accept_quar_prod_id=request->reasonqual[y].accept_quar_prod_id)
      AND (r.updt_cnt=request->reasonqual[y].updt_cnt)
     WITH counter, forupdate(r)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].targetobjectname = "accept_quar_prod_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "organization preference lock"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
    UPDATE  FROM accept_quar_prod_r r
     SET r.active_status_cd = reqdata->inactive_status_cd, r.active_ind = 0, r.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      r.active_status_prsnl_id = reqinfo->updt_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r
      .updt_id = reqinfo->updt_id,
      r.updt_cnt = (request->reasonqual[y].updt_cnt+ 1), r.updt_task = reqinfo->updt_task, r
      .updt_applctx = reqinfo->updt_applctx
     WHERE (r.accept_quar_prod_id=request->reasonqual[y].accept_quar_prod_id)
      AND (r.updt_cnt=request->reasonqual[y].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].targetobjectname = "accept_quar_prod_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "update organization preference"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
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
