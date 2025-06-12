CREATE PROGRAM bed_get_bb_prod_and_cat_dups:dba
 FREE SET reply
 RECORD reply(
   1 products[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 active_ind = i2
     2 category_display = vc
   1 categories[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 active_ind = i2
     2 nbr_rel_products = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 dups[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 active_ind = i2
 )
 SET reply->status_data.status = "F"
 SET dcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=1604
   AND cv.active_ind=1
  ORDER BY cnvtupper(cv.display)
  DETAIL
   dcnt = (dcnt+ 1), stat = alterlist(temp->dups,dcnt), temp->dups[dcnt].code_value = cv.code_value,
   temp->dups[dcnt].display = cv.display, temp->dups[dcnt].description = cv.description, temp->dups[
   dcnt].active_ind = cv.active_ind
  WITH nocounter
 ;end select
 SET rcnt = 0
 DECLARE prev_display = vc
 SET prev_display = " "
 DECLARE last_one_added = f8
 SET last_one_added = 0
 FOR (d = 1 TO dcnt)
  IF (cnvtupper(temp->dups[d].display)=cnvtupper(prev_display))
   IF ((temp->dups[(d - 1)].code_value != last_one_added))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->products,rcnt)
    SET reply->products[rcnt].code_value = temp->dups[(d - 1)].code_value
    SET reply->products[rcnt].display = temp->dups[(d - 1)].display
    SET reply->products[rcnt].description = temp->dups[(d - 1)].description
    SET reply->products[rcnt].active_ind = temp->dups[(d - 1)].active_ind
   ENDIF
   SET rcnt = (rcnt+ 1)
   SET stat = alterlist(reply->products,rcnt)
   SET reply->products[rcnt].code_value = temp->dups[d].code_value
   SET reply->products[rcnt].display = temp->dups[d].display
   SET reply->products[rcnt].description = temp->dups[d].description
   SET reply->products[rcnt].active_ind = temp->dups[d].active_ind
   SET last_one_added = temp->dups[d].code_value
  ENDIF
  SET prev_display = temp->dups[d].display
 ENDFOR
 IF (rcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rcnt),
    product_index pi,
    code_value cv
   PLAN (d)
    JOIN (pi
    WHERE (pi.product_cd=reply->products[d.seq].code_value)
     AND pi.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=pi.product_cat_cd
     AND cv.active_ind=1)
   DETAIL
    reply->products[d.seq].category_display = cv.display
   WITH nocounter
  ;end select
 ENDIF
 SET dcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=1605
   AND cv.active_ind=1
  ORDER BY cnvtupper(cv.display)
  DETAIL
   dcnt = (dcnt+ 1), stat = alterlist(temp->dups,dcnt), temp->dups[dcnt].code_value = cv.code_value,
   temp->dups[dcnt].display = cv.display, temp->dups[dcnt].description = cv.description, temp->dups[
   dcnt].active_ind = cv.active_ind
  WITH nocounter
 ;end select
 SET rcnt = 0
 DECLARE prev_display = vc
 SET prev_display = " "
 DECLARE last_one_added = f8
 SET last_one_added = 0
 FOR (d = 1 TO dcnt)
  IF (cnvtupper(temp->dups[d].display)=cnvtupper(prev_display))
   IF ((temp->dups[(d - 1)].code_value != last_one_added))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->categories,rcnt)
    SET reply->categories[rcnt].code_value = temp->dups[(d - 1)].code_value
    SET reply->categories[rcnt].display = temp->dups[(d - 1)].display
    SET reply->categories[rcnt].description = temp->dups[(d - 1)].description
    SET reply->categories[rcnt].active_ind = temp->dups[(d - 1)].active_ind
   ENDIF
   SET rcnt = (rcnt+ 1)
   SET stat = alterlist(reply->categories,rcnt)
   SET reply->categories[rcnt].code_value = temp->dups[d].code_value
   SET reply->categories[rcnt].display = temp->dups[d].display
   SET reply->categories[rcnt].description = temp->dups[d].description
   SET reply->categories[rcnt].active_ind = temp->dups[d].active_ind
   SET last_one_added = temp->dups[d].code_value
  ENDIF
  SET prev_display = temp->dups[d].display
 ENDFOR
 IF (rcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rcnt),
    product_index pi
   PLAN (d)
    JOIN (pi
    WHERE (pi.product_cat_cd=reply->categories[d.seq].code_value)
     AND pi.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    nbr_products = 0
   DETAIL
    nbr_products = (nbr_products+ 1)
   FOOT  d.seq
    reply->categories[d.seq].nbr_rel_products = nbr_products
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
