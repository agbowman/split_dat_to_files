CREATE PROGRAM bed_ens_bb_ab_products_b:dba
 FREE SET reply
 RECORD reply(
   1 products[*]
     2 prod_code_value = f8
     2 dispense_block_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET tqual
 RECORD tqual(
   1 tqual[*]
     2 block_id = f8
     2 override_ind = i2
 )
 FREE SET tqual2
 RECORD tqual2(
   1 tqual2[*]
     2 action_flag = i2
     2 block_id = f8
     2 prod_code = f8
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET active_code = 0.0
 SET active_code = uar_get_code_by("MEANING",48,"ACTIVE")
 SET inactive_code = 0.0
 SET inactive_code = uar_get_code_by("MEANING",48,"INACTIVE")
 SET req_size = size(request->products,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SET stat = alterlist(tqual->tqual,req_size)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_size)),
   bb_dspns_block bb
  PLAN (d
   WHERE (request->products[d.seq].dispense_block_id > 0))
   JOIN (bb
   WHERE (bb.dispense_block_id=request->products[d.seq].dispense_block_id)
    AND bb.active_ind=0)
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), tqual->tqual[cnt].block_id = bb.dispense_block_id, tqual->tqual[cnt].override_ind
    = request->products[d.seq].override_ind,
   request->products[d.seq].action_flag = 4
  FOOT REPORT
   stat = alterlist(tqual->tqual,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SET ierrcode = 0
  UPDATE  FROM bb_dspns_block_product b,
    (dummyt d  WITH seq = value(cnt))
   SET b.active_ind = 0, b.active_status_cd = inactive_code, b.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    b.active_status_prsnl_id = reqinfo->updt_id, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (b
    WHERE (b.dispense_block_id=tqual->tqual[d.seq].block_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("UPDATE 1")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM bb_dspns_block b,
    (dummyt d  WITH seq = value(cnt))
   SET b.allow_override_ind = tqual->tqual[d.seq].override_ind, b.active_ind = 1, b.active_status_cd
     = active_code,
    b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
    updt_id, b.updt_cnt = (b.updt_cnt+ 1),
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
    reqinfo->updt_task,
    b.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (b
    WHERE (b.dispense_block_id=tqual->tqual[d.seq].block_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("UPDATE 2")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM bb_dspns_block b,
   (dummyt d  WITH seq = value(req_size))
  SET b.allow_override_ind = request->products[d.seq].override_ind, b.updt_cnt = (b.updt_cnt+ 1), b
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (request->products[d.seq].action_flag IN (0, 1, 2))
    AND (request->products[d.seq].dispense_block_id > 0))
   JOIN (b
   WHERE (b.dispense_block_id=request->products[d.seq].dispense_block_id)
    AND b.active_ind=1)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("UPDATE 3")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM bb_dspns_block b,
   (dummyt d  WITH seq = value(req_size))
  SET b.allow_override_ind = request->products[d.seq].override_ind, b.active_ind = 1, b
   .active_status_cd = active_code,
   b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
   updt_id, b.updt_cnt = (b.updt_cnt+ 1),
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
   ->updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->products[d.seq].action_flag IN (0, 1, 2))
    AND (request->products[d.seq].dispense_block_id > 0))
   JOIN (b
   WHERE (b.dispense_block_id=request->products[d.seq].dispense_block_id)
    AND b.active_ind=0)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("UPDATE 4")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  j = seq(pathnet_seq,nextval)"##################;rp0"
  FROM dual du,
   (dummyt d  WITH seq = value(req_size))
  PLAN (d
   WHERE (request->products[d.seq].action_flag IN (0, 1))
    AND (request->products[d.seq].dispense_block_id=0))
   JOIN (du)
  DETAIL
   request->products[d.seq].dispense_block_id = cnvtreal(j), request->products[d.seq].action_flag = 5
  WITH format, counter
 ;end select
 SET ierrcode = 0
 INSERT  FROM bb_dspns_block b,
   (dummyt d  WITH seq = value(req_size))
  SET b.dispense_block_id = request->products[d.seq].dispense_block_id, b.product_cd = request->
   products[d.seq].prod_code_value, b.allow_override_ind = request->products[d.seq].override_ind,
   b.active_ind = 1, b.active_status_cd = active_code, b.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3),
   b.active_status_prsnl_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (request->products[d.seq].action_flag=5))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("INSERT 1")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET cnt = 0
 FOR (x = 1 TO req_size)
  SET sub_size = size(request->products[x].block_prods,5)
  FOR (y = 1 TO sub_size)
    IF ((request->products[x].block_prods[y].action_flag IN (1, 3)))
     SET cnt = (cnt+ 1)
     SET stat = alterlist(tqual2->tqual2,cnt)
     SET tqual2->tqual2[cnt].action_flag = request->products[x].block_prods[y].action_flag
     SET tqual2->tqual2[cnt].block_id = request->products[x].dispense_block_id
     SET tqual2->tqual2[cnt].prod_code = request->products[x].block_prods[y].prod_code_value
    ENDIF
  ENDFOR
 ENDFOR
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM bb_dspns_block_product b,
   (dummyt d  WITH seq = value(cnt))
  SET b.active_ind = 0, b.active_status_cd = inactive_code, b.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3),
   b.active_status_prsnl_id = reqinfo->updt_id, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (tqual2->tqual2[d.seq].action_flag=3))
   JOIN (b
   WHERE (b.dispense_block_id=tqual2->tqual2[d.seq].block_id)
    AND (b.product_cd=tqual2->tqual2[d.seq].prod_code))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("UPDATE 5")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM bb_dspns_block_product b,
   (dummyt d  WITH seq = value(cnt))
  SET b.block_product_id = seq(pathnet_seq,nextval), b.dispense_block_id = tqual2->tqual2[d.seq].
   block_id, b.product_cd = tqual2->tqual2[d.seq].prod_code,
   b.active_ind = 1, b.active_status_cd = active_code, b.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3),
   b.active_status_prsnl_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (tqual2->tqual2[d.seq].action_flag=1))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("INSERT 2")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->products,req_size)
 FOR (x = 1 TO req_size)
  SET reply->products[x].dispense_block_id = request->products[x].dispense_block_id
  SET reply->products[x].prod_code_value = request->products[x].prod_code_value
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
