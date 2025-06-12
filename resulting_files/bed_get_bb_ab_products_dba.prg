CREATE PROGRAM bed_get_bb_ab_products:dba
 FREE SET reply
 RECORD reply(
   1 categories[*]
     2 prod_cat_code_value = f8
     2 display = vc
     2 red_cell_ind = i2
     2 products[*]
       3 prod_code_value = f8
       3 display = vc
       3 dispense_block_id = f8
       3 override_ind = i2
       3 autologous_ind = i2
       3 directed_ind = i2
       3 bad_data_ind = i2
       3 bad_block_prod_ind = i2
       3 block_prod[*]
         4 blck_prod_code_value = f8
         4 display = vc
         4 inactive_ind = i2
         4 not_allow_dispense_ind = i2
         4 red_cell_ind = i2
         4 autologous_ind = i2
         4 directed_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET bprod_code = 0.0
 SET dprod_code = 0.0
 SET bprod_code = uar_get_code_by("MEANING",1606,"BLOOD")
 SET dprod_code = uar_get_code_by("MEANING",1606,"DERIVATIVE")
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM product_index pi,
   product_category pc,
   bb_dspns_block bb,
   code_value cv,
   code_value cv2
  PLAN (pc
   WHERE pc.product_class_cd IN (bprod_code, dprod_code)
    AND pc.active_ind=1)
   JOIN (pi
   WHERE pi.product_cat_cd=pc.product_cat_cd
    AND pi.product_class_cd=pc.product_class_cd
    AND pi.allow_dispense_ind=1
    AND pi.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=pi.product_cd
    AND cv.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=pc.product_cat_cd
    AND cv2.active_ind=1)
   JOIN (bb
   WHERE bb.product_cd=outerjoin(pi.product_cd))
  ORDER BY pc.product_cat_cd, pi.product_cd, bb.dispense_block_id,
   bb.product_cd
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->categories,100)
  HEAD pc.product_cat_cd
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->categories,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->categories[tcnt].prod_cat_code_value = pc.product_cat_cd, reply->categories[tcnt].display
    = cv2.display, reply->categories[tcnt].red_cell_ind = pc.red_cell_product_ind,
   pcnt = 0, ptcnt = 0, stat = alterlist(reply->categories[tcnt].products,100)
  HEAD pi.product_cd
   pcnt = (pcnt+ 1), ptcnt = (ptcnt+ 1)
   IF (pcnt > 100)
    stat = alterlist(reply->categories[tcnt].products,(ptcnt+ 100)), pcnt = 1
   ENDIF
   reply->categories[tcnt].products[ptcnt].prod_code_value = pi.product_cd, reply->categories[tcnt].
   products[ptcnt].display = cv.display, reply->categories[tcnt].products[ptcnt].directed_ind = pi
   .directed_ind,
   reply->categories[tcnt].products[ptcnt].autologous_ind = pi.autologous_ind, reply->categories[tcnt
   ].products[ptcnt].dispense_block_id = bb.dispense_block_id
   IF (bb.active_ind=1)
    reply->categories[tcnt].products[ptcnt].override_ind = bb.allow_override_ind
   ENDIF
  FOOT  pc.product_cat_cd
   stat = alterlist(reply->categories[tcnt].products,ptcnt)
  FOOT REPORT
   stat = alterlist(reply->categories,tcnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO tcnt)
  SET ptcnt = size(reply->categories[x].products,5)
  IF (ptcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ptcnt)),
     bb_dspns_block bb,
     bb_dspns_block_product bp,
     product_index pi,
     product_category pc,
     code_value cv
    PLAN (d
     WHERE (reply->categories[x].products[d.seq].dispense_block_id > 0))
     JOIN (bb
     WHERE (bb.dispense_block_id=reply->categories[x].products[d.seq].dispense_block_id)
      AND bb.active_ind=1)
     JOIN (bp
     WHERE bp.dispense_block_id=bb.dispense_block_id
      AND bp.active_ind=1)
     JOIN (pi
     WHERE pi.product_cd=outerjoin(bp.product_cd))
     JOIN (pc
     WHERE pc.product_cat_cd=outerjoin(pi.product_cat_cd))
     JOIN (cv
     WHERE cv.code_value=outerjoin(bp.product_cd))
    ORDER BY d.seq, bp.product_cd
    HEAD d.seq
     bcnt = 0, btcnt = 0, stat = alterlist(reply->categories[x].products[d.seq].block_prod,100)
    HEAD bp.product_cd
     bcnt = (bcnt+ 1), btcnt = (btcnt+ 1)
     IF (bcnt > 100)
      stat = alterlist(reply->categories[x].products[d.seq].block_prod,(btcnt+ 100)), bcnt = 1
     ENDIF
     reply->categories[x].products[d.seq].block_prod[btcnt].blck_prod_code_value = bp.product_cd,
     reply->categories[x].products[d.seq].block_prod[btcnt].display = cv.display, reply->categories[x
     ].products[d.seq].block_prod[btcnt].autologous_ind = pi.autologous_ind,
     reply->categories[x].products[d.seq].block_prod[btcnt].directed_ind = pi.directed_ind, reply->
     categories[x].products[d.seq].block_prod[btcnt].red_cell_ind = pc.red_cell_product_ind
     IF (((pi.allow_dispense_ind=0) OR (((cv.code_value=0) OR (((pi.product_cd=0) OR (((pc
     .product_cat_cd=0) OR (((cv.active_ind=0) OR (((pi.active_ind=0) OR (pc.active_ind=0)) )) )) ))
     )) )) )
      reply->categories[x].products[d.seq].bad_block_prod_ind = 1
      IF (pi.allow_dispense_ind=0)
       reply->categories[x].products[d.seq].block_prod[btcnt].not_allow_dispense_ind = 1
      ENDIF
     ENDIF
     IF (((cv.code_value=0) OR (((pi.product_cd=0) OR (((pc.product_cat_cd=0) OR (((cv.active_ind=0)
      OR (((pi.active_ind=0) OR (pc.active_ind=0)) )) )) )) )) )
      reply->categories[x].products[d.seq].block_prod[btcnt].inactive_ind = 1
     ELSE
      IF ((reply->categories[x].red_cell_ind=1)
       AND (reply->categories[x].products[d.seq].autologous_ind=1))
       IF (((pi.autologous_ind=1) OR (((pc.red_cell_product_ind=0) OR ( NOT (pc.product_class_cd IN (
       bprod_code, dprod_code)))) )) )
        reply->categories[x].products[d.seq].bad_data_ind = 1
       ENDIF
      ENDIF
      IF ((reply->categories[x].red_cell_ind=0)
       AND (reply->categories[x].products[d.seq].autologous_ind=1))
       IF (((pi.autologous_ind=1) OR (((pc.red_cell_product_ind=1) OR ( NOT (pc.product_class_cd IN (
       bprod_code, dprod_code)))) )) )
        reply->categories[x].products[d.seq].bad_data_ind = 1
       ENDIF
      ENDIF
      IF ((reply->categories[x].red_cell_ind=1)
       AND (reply->categories[x].products[d.seq].directed_ind=1))
       IF (((pi.autologous_ind=1) OR (((pi.directed_ind=1) OR (((pc.red_cell_product_ind=0) OR (
        NOT (pc.product_class_cd IN (bprod_code, dprod_code)))) )) )) )
        reply->categories[x].products[d.seq].bad_data_ind = 1
       ENDIF
      ENDIF
      IF ((reply->categories[x].red_cell_ind=0)
       AND (reply->categories[x].products[d.seq].directed_ind=1))
       IF (((pi.autologous_ind=1) OR (((pi.directed_ind=1) OR (((pc.red_cell_product_ind=1) OR (
        NOT (pc.product_class_cd IN (bprod_code, dprod_code)))) )) )) )
        reply->categories[x].products[d.seq].bad_data_ind = 1
       ENDIF
      ENDIF
     ENDIF
    FOOT  d.seq
     stat = alterlist(reply->categories[x].products[d.seq].block_prod,btcnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
