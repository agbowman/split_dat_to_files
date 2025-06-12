CREATE PROGRAM bbt_get_dispense_blocking:dba
 RECORD reply(
   1 dispense_block_id = f8
   1 product_cd = f8
   1 product_cd_disp = c40
   1 allow_override_ind = i2
   1 active_ind = i2
   1 updt_cnt = i4
   1 qual[*]
     2 block_product_id = f8
     2 dispense_block_id = f8
     2 product_cd = f8
     2 product_cd_disp = c40
     2 active_ind = i2
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET qual_cnt = 0
 SET stat = alterlist(reply->qual,10)
 SELECT INTO "nl:"
  db.product_cd, x = uar_get_code_display(db.product_cd), db.dispense_block_id,
  db.active_ind, dbp.block_product_id, dbp.product_cd,
  y = uar_get_code_display(dbp.product_cd), dbp.active_ind
  FROM bb_dspns_block db,
   (dummyt d_dbp  WITH seq = 1),
   bb_dspns_block_product dbp
  PLAN (db
   WHERE (db.product_cd=request->product_cd)
    AND db.dispense_block_id != null
    AND db.dispense_block_id > 0
    AND (((request->return_inactive_ind != 1)
    AND db.active_ind=1) OR ((request->return_inactive_ind=1))) )
   JOIN (d_dbp
   WHERE d_dbp.seq=1)
   JOIN (dbp
   WHERE db.dispense_block_id=dbp.dispense_block_id
    AND dbp.block_product_id != null
    AND dbp.block_product_id > 0
    AND dbp.active_ind=1)
  ORDER BY db.dispense_block_id, dbp.block_product_id
  HEAD REPORT
   qual_cnt = 0, reply->dispense_block_id = db.dispense_block_id, reply->product_cd = db.product_cd,
   reply->allow_override_ind = db.allow_override_ind, reply->active_ind = db.active_ind, reply->
   updt_cnt = db.updt_cnt
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].block_product_id = dbp.block_product_id, reply->qual[qual_cnt].
   dispense_block_id = dbp.dispense_block_id, reply->qual[qual_cnt].product_cd = dbp.product_cd,
   reply->qual[qual_cnt].active_ind = dbp.active_ind, reply->qual[qual_cnt].updt_cnt = dbp.updt_cnt
  WITH counter, outerjoin(d_dbp)
 ;end select
 SET stat = alterlist(reply->qual,qual_cnt)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
