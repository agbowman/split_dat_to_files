CREATE PROGRAM bed_get_bb_ab_block_prods:dba
 FREE SET reply
 RECORD reply(
   1 products[*]
     2 prod_code_value = f8
     2 block_prods[*]
       3 prod_code_value = f8
       3 display = vc
       3 inactive_ind = i2
       3 not_allow_dispense_ind = i2
       3 red_cell_ind = i2
       3 autologous_ind = i2
       3 directed_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->products,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->products,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->products[x].prod_code_value = request->products[x].prod_code_value
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   bb_dspns_block bb,
   bb_dspns_block_product bp,
   product_index pi,
   product_category pc,
   code_value cv
  PLAN (d)
   JOIN (bb
   WHERE (bb.product_cd=request->products[d.seq].prod_code_value))
   JOIN (bp
   WHERE bp.dispense_block_id=bb.dispense_block_id
    AND bp.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=bp.product_cd
    AND cv.active_ind=1)
   JOIN (pi
   WHERE pi.product_cd=bp.product_cd)
   JOIN (pc
   WHERE pc.product_cat_cd=pi.product_cat_cd)
  ORDER BY d.seq, bp.product_cd
  HEAD d.seq
   bcnt = 0, btcnt = 0, stat = alterlist(reply->products[d.seq].block_prods,100)
  HEAD bp.product_cd
   bcnt = (bcnt+ 1), btcnt = (btcnt+ 1)
   IF (bcnt > 100)
    stat = alterlist(reply->products[d.seq].block_prods,(btcnt+ 100)), bcnt = 1
   ENDIF
   reply->products[d.seq].block_prods[btcnt].prod_code_value = bp.product_cd, reply->products[d.seq].
   block_prods[btcnt].display = cv.display, reply->products[d.seq].block_prods[btcnt].autologous_ind
    = pi.autologous_ind,
   reply->products[d.seq].block_prods[btcnt].directed_ind = pi.directed_ind, reply->products[d.seq].
   block_prods[btcnt].red_cell_ind = pc.red_cell_product_ind
   IF (pi.allow_dispense_ind=0)
    reply->products[d.seq].block_prods[btcnt].not_allow_dispense_ind = 1
   ENDIF
   IF (((cv.code_value=0) OR (((pi.product_cd=0) OR (((pc.product_cat_cd=0) OR (((cv.active_ind=0)
    OR (((pi.active_ind=0) OR (pc.active_ind=0)) )) )) )) )) )
    reply->products[d.seq].block_prods[btcnt].inactive_ind = 1
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->products[d.seq].block_prods,btcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
