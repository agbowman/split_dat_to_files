CREATE PROGRAM bed_get_bbt_product_indices:dba
 RECORD reply(
   1 prodclass_list[*]
     2 prodclass_code_value = f8
     2 prodclass_display = vc
     2 prodcat_list[*]
       3 prodcat_code_value = f8
       3 prodcat_display = vc
       3 prodindex_list[*]
         4 prodindex_code_value = f8
         4 prodindex_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE prod_class_cnt = i4
 DECLARE prod_cat_cnt = i4
 DECLARE prod_idx_cnt = i4
 SELECT INTO "nl:"
  FROM product_index pi,
   product_category pc
  PLAN (pi
   WHERE pi.active_ind=1)
   JOIN (pc
   WHERE pc.active_ind=1
    AND pc.product_cat_cd=pi.product_cat_cd
    AND pc.product_class_cd > 0)
  ORDER BY pc.product_class_cd, pc.product_cat_cd
  HEAD pc.product_class_cd
   prod_class_cnt = (prod_class_cnt+ 1), stat = alterlist(reply->prodclass_list,prod_class_cnt),
   reply->prodclass_list[prod_class_cnt].prodclass_code_value = pc.product_class_cd,
   reply->prodclass_list[prod_class_cnt].prodclass_display = uar_get_code_display(pc.product_class_cd
    ), prod_cat_cnt = 0
  HEAD pc.product_cat_cd
   prod_cat_cnt = (prod_cat_cnt+ 1), stat = alterlist(reply->prodclass_list[prod_class_cnt].
    prodcat_list,prod_cat_cnt), reply->prodclass_list[prod_class_cnt].prodcat_list[prod_cat_cnt].
   prodcat_code_value = pc.product_cat_cd,
   reply->prodclass_list[prod_class_cnt].prodcat_list[prod_cat_cnt].prodcat_display =
   uar_get_code_display(pc.product_cat_cd), prod_idx_cnt = 0
  DETAIL
   prod_idx_cnt = (prod_idx_cnt+ 1), stat = alterlist(reply->prodclass_list[prod_class_cnt].
    prodcat_list[prod_cat_cnt].prodindex_list,prod_idx_cnt), reply->prodclass_list[prod_class_cnt].
   prodcat_list[prod_cat_cnt].prodindex_list[prod_idx_cnt].prodindex_code_value = pi.product_cd,
   reply->prodclass_list[prod_class_cnt].prodcat_list[prod_cat_cnt].prodindex_list[prod_idx_cnt].
   prodindex_display = uar_get_code_display(pi.product_cd)
  WITH nocounter
 ;end select
 CALL bederrorcheck("SELECT_ERR")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
