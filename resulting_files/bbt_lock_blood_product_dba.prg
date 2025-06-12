CREATE PROGRAM bbt_lock_blood_product:dba
 RECORD reply(
   1 product_updt_cnt = i4
   1 product_updt_dt_tm = dq8
   1 product_updt_id = f8
   1 product_updt_task = i4
   1 product_updt_applctx = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET failed = "F"
 SELECT INTO "nl:"
  p.product_id, p.locked_ind, p.updt_cnt
  FROM product p
  PLAN (p
   WHERE (p.product_id=request->product_id))
  DETAIL
   cur_updt_cnt = p.updt_cnt
 ;end select
 SET reply->product_updt_cnt = (cur_updt_cnt+ 1)
 SET reply->product_updt_dt_tm = cnvtdatetime(sysdate)
 SET reply->product_updt_id = reqinfo->updt_id
 SET reply->product_updt_task = reqinfo->updt_task
 SET reply->product_updt_applctx = reqinfo->updt_applctx WITH nocounter, forupdate(p)
 IF (curqual != 1)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF ((request->updt_cnt != cur_updt_cnt))
  SET failed = "T"
  SET reply->status_data.status = "C"
  GO TO exit_script
 ENDIF
 UPDATE  FROM product p
  SET p.locked_ind = 1, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
   p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
   updt_applctx
  PLAN (p
   WHERE (p.product_id=request->product_id)
    AND ((p.locked_ind = null) OR (p.locked_ind=0))
    AND (p.updt_cnt=request->updt_cnt))
  WITH nocounter
 ;end update
 IF (curqual != 1)
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
