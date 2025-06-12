CREATE PROGRAM bed_get_br_bb_prodcat:dba
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
       3 selected_ind = i2
       3 nbr_rel_products = i4
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
 DECLARE nbr_rel_products = i4
 DECLARE prodcat_cd = f8
 DECLARE blood_found = vc
 DECLARE derivative_found = vc
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET blood_class_cd = 0.0
 SET derivative_class_cd = 0.0
 SET classcnt = 0
 SET catcnt = 0
 SET nbr_rel_products = 0
 SET blood_found = "N"
 SET derivative_found = "N"
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
  FROM br_bb_prodcat bc
  PLAN (bc)
  ORDER BY bc.product_class_mean, bc.display
  HEAD bc.product_class_mean
   classcnt = (classcnt+ 1), catcnt = 0, stat = alterlist(reply->prodclass_list,classcnt),
   reply->prodclass_list[classcnt].prodclass_meaning = bc.product_class_mean
   IF (cnvtupper(bc.product_class_mean)="BLOOD")
    reply->prodclass_list[classcnt].prodclass_code_value = blood_class_cd, reply->prodclass_list[
    classcnt].prodclass_display = blood_class_disp, blood_found = "Y"
   ELSEIF (cnvtupper(bc.product_class_mean)="DERIVATIVE")
    reply->prodclass_list[classcnt].prodclass_code_value = derivative_class_cd, reply->
    prodclass_list[classcnt].prodclass_display = derivative_class_disp, derivative_found = "Y"
   ELSE
    reply->prodclass_list[classcnt].prodclass_code_value = 0.0, reply->prodclass_list[classcnt].
    prodclass_display = " "
   ENDIF
  DETAIL
   catcnt = (catcnt+ 1), stat = alterlist(reply->prodclass_list[classcnt].prodcat_list,catcnt), reply
   ->prodclass_list[classcnt].prodcat_list[catcnt].prodcat_desc = bc.description,
   reply->prodclass_list[classcnt].prodcat_list[catcnt].prodcat_display = bc.display, reply->
   prodclass_list[classcnt].prodcat_list[catcnt].prodcat_id = bc.prodcat_id, reply->prodclass_list[
   classcnt].prodcat_list[catcnt].selected_ind = bc.selected_ind
  WITH nocounter
 ;end select
 FOR (ii = 1 TO classcnt)
  SET tcnt = size(reply->prodclass_list[ii].prodcat_list,5)
  FOR (jj = 1 TO tcnt)
    SET prodcat_cd = 0.0
    SELECT INTO "nl:"
     FROM br_bb_prodcat bc
     PLAN (bc
      WHERE (bc.prodcat_id=reply->prodclass_list[ii].prodcat_list[jj].prodcat_id))
     DETAIL
      prodcat_cd = bc.prodcat_cd
     WITH nocounter
    ;end select
    SET nbr_rel_products = 0
    IF (prodcat_cd > 0.0)
     SELECT INTO "nl:"
      FROM product_index pi
      PLAN (pi
       WHERE pi.product_cat_cd=prodcat_cd
        AND pi.active_ind=1)
      DETAIL
       nbr_rel_products = (nbr_rel_products+ 1)
      WITH nocounter
     ;end select
    ENDIF
    SET reply->prodclass_list[ii].prodcat_list[jj].nbr_rel_products = nbr_rel_products
  ENDFOR
 ENDFOR
 CASE (classcnt)
  OF 0:
   SET classcnt = (classcnt+ 2)
   SET stat = alterlist(reply->prodclass_list,classcnt)
   SET reply->prodclass_list[1].prodclass_meaning = "BLOOD"
   SET reply->prodclass_list[1].prodclass_code_value = blood_class_cd
   SET reply->prodclass_list[1].prodclass_display = blood_class_disp
   SET reply->prodclass_list[2].prodclass_meaning = "DERIVATIVE"
   SET reply->prodclass_list[2].prodclass_code_value = derivative_class_cd
   SET reply->prodclass_list[2].prodclass_display = derivative_class_disp
  OF 1:
   SET classcnt = (classcnt+ 1)
   SET stat = alterlist(reply->prodclass_list,classcnt)
   IF (blood_found="Y")
    SET reply->prodclass_list[2].prodclass_meaning = "DERIVATIVE"
    SET reply->prodclass_list[2].prodclass_code_value = derivative_class_cd
    SET reply->prodclass_list[2].prodclass_display = derivative_class_disp
   ELSEIF (derivative_found="Y")
    SET reply->prodclass_list[2].prodclass_meaning = "BLOOD"
    SET reply->prodclass_list[2].prodclass_code_value = blood_class_cd
    SET reply->prodclass_list[2].prodclass_display = blood_class_disp
   ENDIF
 ENDCASE
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_BR_BB_PRODCAT  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
