CREATE PROGRAM bed_get_br_bb_product:dba
 FREE SET reply
 RECORD reply(
   1 prodclass_list[*]
     2 prodclass_display = vc
     2 prodclass_meaning = vc
     2 prodclass_code_value = f8
     2 prodcat_list[*]
       3 prodcat_display = vc
       3 prodcat_desc = vc
       3 prodcat_id = f8
       3 product_list[*]
         4 product_display = vc
         4 product_desc = vc
         4 product_id = f8
         4 selected_ind = i2
         4 active_ind = i2
         4 autobuild_ind = i2
         4 product_code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 DECLARE blood_class_cd = f8
 DECLARE blood_class_disp = vc
 DECLARE derivative_class_cd = f8
 DECLARE derivative_class_disp = vc
 DECLARE classcnt = i4
 DECLARE catcnt = i4
 DECLARE prodcnt = i4
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET blood_class_cd = 0.0
 SET derivative_class_cd = 0.0
 SET classcnt = 0
 SET catcnt = 0
 SET prodcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1606
    AND cv.active_ind=1
    AND cv.cdf_meaning="BLOOD")
  DETAIL
   blood_class_cd = cv.code_value, blood_class_disp = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1606
    AND cv.active_ind=1
    AND cv.cdf_meaning="DERIVATIVE")
  DETAIL
   derivative_class_cd = cv.code_value, derivative_class_disp = cv.display
  WITH nocounter
 ;end select
 IF (((blood_class_cd=0.0) OR (derivative_class_cd=0.0)) )
  SET error_flag = "T"
  SET error_msg = "Product Class not defined for BLOOD or DERIVATIVE - program terminating"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM br_bb_product bp,
   br_bb_prodcat bc
  PLAN (bp
   WHERE bp.display > " ")
   JOIN (bc
   WHERE bc.prodcat_id=bp.prodcat_id)
  ORDER BY bc.product_class_mean, bc.prodcat_id, bp.display
  HEAD bc.product_class_mean
   classcnt = (classcnt+ 1), catcnt = 0, stat = alterlist(reply->prodclass_list,classcnt),
   reply->prodclass_list[classcnt].prodclass_meaning = bc.product_class_mean
   IF (cnvtupper(bc.product_class_mean)="BLOOD")
    reply->prodclass_list[classcnt].prodclass_code_value = blood_class_cd, reply->prodclass_list[
    classcnt].prodclass_display = blood_class_disp
   ELSE
    reply->prodclass_list[classcnt].prodclass_code_value = derivative_class_cd, reply->
    prodclass_list[classcnt].prodclass_display = derivative_class_disp
   ENDIF
  HEAD bc.prodcat_id
   catcnt = (catcnt+ 1), prodcnt = 0, stat = alterlist(reply->prodclass_list[classcnt].prodcat_list,
    catcnt),
   reply->prodclass_list[classcnt].prodcat_list[catcnt].prodcat_desc = bc.description, reply->
   prodclass_list[classcnt].prodcat_list[catcnt].prodcat_display = bc.display, reply->prodclass_list[
   classcnt].prodcat_list[catcnt].prodcat_id = bc.prodcat_id
  DETAIL
   prodcnt = (prodcnt+ 1), stat = alterlist(reply->prodclass_list[classcnt].prodcat_list[catcnt].
    product_list,prodcnt), reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt]
   .product_desc = bp.description,
   reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt].product_display = bp
   .display, reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt].product_id =
   bp.product_id, reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt].
   selected_ind = bp.selected_ind,
   reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt].autobuild_ind = bp
   .autobuild_ind, reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt].
   active_ind = bp.active_ind, reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[
   prodcnt].product_code_value = bp.product_cd
  WITH nocounter
 ;end select
 SET classcnt = (classcnt+ 1)
 SET stat = alterlist(reply->prodclass_list,classcnt)
 SET reply->prodclass_list[classcnt].prodclass_meaning = "Unassigned"
 SET reply->prodclass_list[classcnt].prodclass_code_value = 0.0
 SET reply->prodclass_list[classcnt].prodclass_display = "Unassigned"
 SELECT INTO "nl:"
  FROM br_bb_product bp
  PLAN (bp
   WHERE bp.prodcat_id=0
    AND bp.display > " ")
  ORDER BY bp.prodcat_id, bp.display
  HEAD bp.prodcat_id
   catcnt = 1, prodcnt = 0, stat = alterlist(reply->prodclass_list[classcnt].prodcat_list,catcnt),
   reply->prodclass_list[classcnt].prodcat_list[catcnt].prodcat_desc = "Unassigned", reply->
   prodclass_list[classcnt].prodcat_list[catcnt].prodcat_display = "Unassigned", reply->
   prodclass_list[classcnt].prodcat_list[catcnt].prodcat_id = 0.0
  DETAIL
   prodcnt = (prodcnt+ 1), stat = alterlist(reply->prodclass_list[classcnt].prodcat_list[catcnt].
    product_list,prodcnt), reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt]
   .product_desc = bp.description,
   reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt].product_display = bp
   .display, reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt].product_id =
   bp.product_id, reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt].
   selected_ind = bp.selected_ind,
   reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt].autobuild_ind = bp
   .autobuild_ind, reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[prodcnt].
   active_ind = bp.active_ind, reply->prodclass_list[classcnt].prodcat_list[catcnt].product_list[
   prodcnt].product_code_value = bp.product_cd
  WITH nocounter
 ;end select
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_BR_BB_PRODUCT  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
