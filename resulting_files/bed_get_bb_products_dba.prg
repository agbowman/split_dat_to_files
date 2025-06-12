CREATE PROGRAM bed_get_bb_products:dba
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
       3 item_num = i4
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
 DECLARE ccnt = i4 WITH protect, noconstant(0)
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM product_category c,
   product_index p
  PLAN (c
   WHERE c.valid_aborh_compat_ind=1
    AND c.active_ind=1)
   JOIN (p
   WHERE p.product_cat_cd=c.product_cat_cd
    AND p.active_ind=1)
  ORDER BY p.product_cat_cd
  HEAD p.product_cat_cd
   pcnt = 0, ccnt = (ccnt+ 1), stat = alterlist(reply->cqual,ccnt),
   reply->cqual[ccnt].category_code_value = p.product_cat_cd, reply->cqual[ccnt].category_disp =
   uar_get_code_display(p.product_cat_cd), reply->cqual[ccnt].category_desc =
   uar_get_code_description(p.product_cat_cd)
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(reply->cqual[ccnt].pqual,pcnt), reply->cqual[ccnt].pqual[pcnt].
   product_code_value = p.product_cd,
   reply->cqual[ccnt].pqual[pcnt].product_disp = uar_get_code_display(p.product_cd), reply->cqual[
   ccnt].pqual[pcnt].product_desc = uar_get_code_description(p.product_cd)
  WITH nocounter
 ;end select
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
 ELSEIF (ccnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
