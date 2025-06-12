CREATE PROGRAM bbt_chg_pool:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET nbr_to_chg = size(request->qual,5)
 SET y = 0
 SET idx = 0
 SET failed = "F"
 SET pool_updt_cnt = 0
 SET pool_active_ind = 0
 SET pool_active_dt_tm = cnvtdatetime(curdate,curtime3)
 SET pool_inactive_dt_tm = cnvtdatetime(curdate,curtime3)
 SET comp_updt_cnt = 0
 SET comp_active_ind = 0
 SET comp_active_dt_tm = cnvtdatetime(curdate,curtime3)
 SET comp_inactive_dt_tm = cnvtdatetime(curdate,curtime3)
 IF ((request->option_changed=1))
  SELECT INTO "nl:"
   p.option_id
   FROM pool_option p
   WHERE (p.option_id=request->option_id)
   DETAIL
    pool_active_ind = p.active_ind, pool_updt_cnt = p.updt_cnt, pool_active_dt_tm = p
    .active_status_dt_tm
   WITH nocounter, forupdate(p)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.operationname = "lock"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "Pooling Option"
   SET reply->status_data.targetobjectvalue = "Lock failed"
  ENDIF
  IF ((request->updt_cnt != pool_updt_cnt))
   SET failed = "T"
   SET reply->status_data.operationname = "change"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "Pooling Option"
   SET reply->status_data.targetobjectvalue = "Update count mismatch"
  ELSE
   UPDATE  FROM pool_option p
    SET p.new_product_cd = request->new_product_cd, p.prompt_vol_ind = request->prompt_vol_ind, p
     .calculate_vol_ind = request->calculate_vol_ind,
     p.default_exp_hrs = request->default_exp_hrs, p.product_nbr_prefix = request->product_nbr_prefix,
     p.generate_prod_nbr_ind = request->generate_prod_nbr_ind,
     p.default_supplier_id = request->default_supplier_id, p.require_assign_ind = request->
     require_assign_ind, p.allow_no_aborh_ind = request->allow_no_aborh_ind,
     p.active_ind = request->active_ind, p.active_status_cd = 0, p.active_status_dt_tm = cnvtdatetime
     (curdate,curtime3),
     p.active_status_prsnl_id = reqinfo->updt_id, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx
    WHERE (p.option_id=request->option_id)
    WITH counter
   ;end update
   IF (curqual=0)
    SET failed = "T"
   ENDIF
   IF (failed="T")
    SET reply->status_data.status = "Z"
    SET reply->status_data.operationname = "change"
    SET reply->status_data.operationstatus = "F"
    SET reply->status_data.targetobjectname = "pool_option"
    SET reply->status_data.targetobjectvalue = "update failed"
    ROLLBACK
    GO TO end_script
   ENDIF
  ENDIF
 ENDIF
 FOR (idx = 1 TO nbr_to_chg)
   IF ((request->qual[idx].product_changed=1))
    IF ((request->qual[idx].add_product=1))
     SELECT INTO "nl:"
      c.option_id, c.product_cd
      FROM component c
      WHERE (c.option_id=request->option_id)
       AND (c.product_cd=request->qual[idx].product_cd)
      WITH nocounter, forupdate(c)
     ;end select
     IF (curqual > 0)
      UPDATE  FROM component c
       SET c.active_ind = 1, c.active_status_cd = 0, c.active_status_dt_tm = cnvtdatetime(curdate,
         curtime3),
        c.active_status_prsnl_id = reqinfo->updt_id, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
        updt_applctx
       WHERE (c.product_cd=request->qual[idx].product_cd)
        AND (c.option_id=request->option_id)
       WITH counter
      ;end update
      IF (curqual=0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "change"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "component"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].product_cd
       SET failed = "T"
       GO TO row_failed
      ENDIF
      GO TO row_failed
     ENDIF
     INSERT  FROM component c
      SET c.option_id = request->option_id, c.product_cd = request->qual[idx].product_cd, c
       .active_ind = request->qual[idx].active_ind,
       c.active_status_cd = 0, c.active_status_dt_tm = cnvtdatetime(curdate,curtime3), c
       .active_status_prsnl_id = reqinfo->updt_id,
       c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id,
       c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
      WITH counter
     ;end insert
     IF (curqual=0)
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].operationname = "insert"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "component"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].product_cd
      SET failed = "T"
      GO TO row_failed
     ENDIF
    ELSE
     SELECT INTO "nl:"
      c.option_id, c.product_cd
      FROM component c
      WHERE (c.option_id=request->option_id)
       AND (c.product_cd=request->qual[idx].product_cd)
      DETAIL
       comp_active_ind = c.active_ind, comp_updt_cnt = c.updt_cnt, comp_active_dt_tm = c
       .active_status_dt_tm
      WITH nocounter, forupdate(c)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].operationname = "lock"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "Component"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = "Lock failed"
     ENDIF
     IF ((request->qual[idx].updt_cnt != comp_updt_cnt))
      SET failed = "T"
      SET reply->status_data.operationname = "change"
      SET reply->status_data.operationstatus = "F"
      SET reply->status_data.targetobjectname = "Component"
      SET reply->status_data.targetobjectvalue = "Update count mismatch"
     ELSE
      UPDATE  FROM component c
       SET c.active_ind = 0, c.active_status_cd = 0, c.active_status_dt_tm = cnvtdatetime(curdate,
         curtime3),
        c.active_status_prsnl_id = reqinfo->updt_id, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
        updt_applctx
       WHERE (c.product_cd=request->qual[idx].product_cd)
        AND (c.option_id=request->option_id)
       WITH counter
      ;end update
      IF (curqual=0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "change"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "component"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].product_cd
       SET failed = "T"
       GO TO row_failed
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF ((request->system_assign_changed=1))
  SELECT INTO "nl:"
   p.pool_option_id
   FROM pooled_product p
   WHERE (p.pool_option_id=request->option_id)
    AND p.active_ind=1
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET next_code = 0.0
   EXECUTE cpm_next_code
   INSERT  FROM pooled_product p
    SET p.pool_option_nbr_id = next_code, p.pool_option_id = request->option_id, p.pool_nbr = request
     ->pool_nbr,
     p.year = request->year, p.active_ind = 1, p.active_status_cd = 0,
     p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
     updt_id, p.updt_cnt = 0,
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
     reqinfo->updt_task,
     p.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "pooled_product"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = request->pool_nbr
    SET failed = "T"
    ROLLBACK
    GO TO end_script
   ELSE
    SET reply->status_data.status = "S"
    COMMIT
    GO TO end_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   p.pool_option_id
   FROM pooled_product p
   WHERE (p.pool_option_id=request->option_id)
    AND p.active_ind=1
   DETAIL
    pool_active_ind = p.active_ind, pool_updt_cnt = p.updt_cnt, pool_active_dt_tm = p
    .active_status_dt_tm
   WITH nocounter, forupdate(p)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.operationname = "lock"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "Pooled Product"
   SET reply->status_data.targetobjectvalue = "Lock failed"
  ENDIF
  IF ((request->pooled_updt_cnt != pool_updt_cnt))
   SET failed = "T"
   SET reply->status_data.operationname = "change"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "Pooled Product"
   SET reply->status_data.targetobjectvalue = "Update count mismatch"
  ELSE
   UPDATE  FROM pooled_product p
    SET p.active_ind = 0, p.active_status_cd = 0, p.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3),
     p.active_status_prsnl_id = reqinfo->updt_id, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx
    WHERE (p.pool_option_id=request->option_id)
     AND p.active_ind=1
    WITH counter
   ;end update
   IF (curqual=0)
    SET failed = "T"
   ENDIF
   IF (failed="T")
    SET reply->status_data.status = "Z"
    SET reply->status_data.operationname = "change"
    SET reply->status_data.operationstatus = "F"
    SET reply->status_data.targetobjectname = "pooled_product"
    SET reply->status_data.targetobjectvalue = "update failed"
    ROLLBACK
    GO TO end_script
   ENDIF
   SET next_code = 0.0
   EXECUTE cpm_next_code
   INSERT  FROM pooled_product p
    SET p.pool_option_nbr_id = next_code, p.pool_option_id = request->option_id, p.pool_nbr = request
     ->pool_nbr,
     p.year = request->year, p.active_ind = 1, p.active_status_cd = 0,
     p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
     updt_id, p.updt_cnt = 0,
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
     reqinfo->updt_task,
     p.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "pooled_product"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = request->pool_nbr
    SET failed = "T"
    ROLLBACK
    GO TO end_script
   ENDIF
  ENDIF
 ENDIF
#row_failed
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "change"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "table"
  SET reply->status_data.targetobjectvalue = "component"
  ROLLBACK
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
#end_script
END GO
