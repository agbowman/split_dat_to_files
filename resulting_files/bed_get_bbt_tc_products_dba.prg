CREATE PROGRAM bed_get_bbt_tc_products:dba
 FREE SET reply
 RECORD reply(
   1 cqual[*]
     2 category_code_value = f8
     2 category_disp = vc
     2 category_desc = vc
     2 pqual[*]
       3 product_code_value = f8
       3 product_disp = vc
       3 product_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET ccnt = 0
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM product_index p,
   code_value cv,
   code_value cv2
  PLAN (p
   WHERE p.product_cat_cd > 0)
   JOIN (cv
   WHERE cv.code_value=p.product_cat_cd
    AND cv.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=p.product_cd
    AND cv2.active_ind=1)
  ORDER BY cv.description, cv2.description
  HEAD p.product_cat_cd
   pcnt = 0, ccnt = (ccnt+ 1), stat = alterlist(reply->cqual,ccnt),
   reply->cqual[ccnt].category_code_value = p.product_cat_cd, reply->cqual[ccnt].category_disp = cv
   .display, reply->cqual[ccnt].category_desc = cv.description
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(reply->cqual[ccnt].pqual,pcnt), reply->cqual[ccnt].pqual[pcnt].
   product_code_value = p.product_cd,
   reply->cqual[ccnt].pqual[pcnt].product_disp = cv2.display, reply->cqual[ccnt].pqual[pcnt].
   product_desc = cv2.description
  WITH nocounter
 ;end select
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
