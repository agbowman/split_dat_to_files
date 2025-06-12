CREATE PROGRAM bbt_add_pool:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET pool_option_next = 0
 SET reply->status_data.status = "F"
 SET nbr_to_add = size(request->qual,5)
 SET y = 0
 SET idx = 0
 SET failed = "F"
 SET next_code = 0.0
 EXECUTE cpm_next_code
 SET pool_option_next = next_code
 INSERT  FROM pool_option p
  SET p.option_id = next_code, p.new_product_cd = request->new_product_cd, p.description = request->
   description,
   p.prompt_vol_ind = request->prompt_vol_ind, p.calculate_vol_ind = request->calculate_vol_ind, p
   .default_exp_hrs = request->default_exp_hrs,
   p.product_nbr_prefix = request->product_nbr_prefix, p.generate_prod_nbr_ind = request->
   generate_prod_nbr_ind, p.default_supplier_id = request->default_supplier_id,
   p.require_assign_ind = request->require_assign_ind, p.allow_no_aborh_ind = request->
   allow_no_aborh_ind, p.active_ind = request->active_ind,
   p.active_status_cd = 0, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
   .active_status_prsnl_id = reqinfo->updt_id,
   p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
   p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx
  WITH counter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "add"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "pool_option"
  SET reply->status_data.targetobjectvalue = "pool option not added"
  ROLLBACK
  GO TO end_script
 ENDIF
 FOR (idx = 1 TO nbr_to_add)
  INSERT  FROM component c
   SET c.option_id = pool_option_next, c.product_cd = request->qual[idx].product_cd, c.active_ind =
    request->qual[idx].active_ind,
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
 ENDFOR
 SET next_code = 0.0
 EXECUTE cpm_next_code
 INSERT  FROM pooled_product p
  SET p.pool_option_nbr_id = next_code, p.pool_option_id = pool_option_next, p.pool_nbr = request->
   pool_nbr,
   p.year = request->year, p.active_ind = 1, p.active_status_cd = 0,
   p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
   updt_id, p.updt_cnt = 0,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo
   ->updt_task,
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
#row_failed
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "add"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "component"
  SET reply->status_data.targetobjectvalue = "component not added"
  ROLLBACK
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
#end_script
END GO
