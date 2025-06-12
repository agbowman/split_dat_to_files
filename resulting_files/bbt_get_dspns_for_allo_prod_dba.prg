CREATE PROGRAM bbt_get_dspns_for_allo_prod:dba
 RECORD reply(
   1 qual[*]
     2 product_cd = f8
     2 product_disp = c40
     2 allow_override_ind = i2
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
  db.product_cd
  FROM bb_dspns_block db,
   bb_dspns_block_product dbp
  PLAN (dbp
   WHERE (dbp.product_cd=request->product_cd)
    AND dbp.block_product_id != null
    AND dbp.block_product_id > 0
    AND dbp.active_ind=1)
   JOIN (db
   WHERE db.dispense_block_id=dbp.dispense_block_id
    AND db.dispense_block_id != null
    AND db.dispense_block_id > 0
    AND db.active_ind=1)
  ORDER BY db.product_cd
  HEAD db.product_cd
   qual_cnt += 1
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].product_cd = db.product_cd, reply->qual[qual_cnt].allow_override_ind = db
   .allow_override_ind
  WITH counter
 ;end select
 SET stat = alterlist(reply->qual,qual_cnt)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
