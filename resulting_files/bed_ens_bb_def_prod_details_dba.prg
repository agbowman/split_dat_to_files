CREATE PROGRAM bed_ens_bb_def_prod_details:dba
 FREE SET reply
 RECORD reply(
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
 DECLARE repsze = i4
 DECLARE prodcat_cd = f8
 DECLARE prodclass_cd = f8
 DECLARE product_code_value = f8
 DECLARE active_cd = f8
 DECLARE inactive_cd = f8
 DECLARE hours_val = i4
 DECLARE days_val = i4
 DECLARE def_auto_ind = i2
 DECLARE def_directed_ind = i2
 DECLARE def_max_exp_unit = vc
 DECLARE def_max_exp_val = i4
 DECLARE def_calc_exp_from_draw_ind = i2
 DECLARE def_volume_def = i4
 DECLARE def_dispense_ind = i2
 DECLARE def_min_bef_quar = i4
 DECLARE def_validate_antibody_ind = i2
 DECLARE def_validate_transf_req_ind = i2
 DECLARE def_int_units_ind = i2
 DECLARE def_def_storage_temp = vc
 DECLARE def_def_storage_temp_cd = f8
 DECLARE q_def_storage_temp = vc
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE")
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET repsze = size(request->prodlist,5)
 FOR (ii = 1 TO repsze)
   IF ((request->prodlist[ii].action_flag=1))
    SET product_code_value = 0
    SELECT INTO "nl:"
     FROM br_bb_product bp
     PLAN (bp
      WHERE (bp.product_id=request->prodlist[ii].product_id))
     DETAIL
      product_code_value = bp.product_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Unable to read br_bb_product for product_id ",cnvtstring(request->
       prodlist[ii].product_id))
     GO TO exit_script
    ENDIF
    IF (product_code_value=0)
     SET error_flag = "T"
     SET error_msg = concat("No product_cd found for product_id: ",cnvtstring(request->prodlist[ii].
       product_id))
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     FROM product_index pi
     PLAN (pi
      WHERE pi.product_cd=product_code_value)
     DETAIL
      prodcat_cd = pi.product_cat_cd, prodclass_cd = pi.product_class_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Unable to read product_index for product_cd ",cnvtstring(
       product_code_value))
     GO TO exit_script
    ENDIF
    SET def_auto_ind = 0
    SET def_directed_ind = 0
    SET def_max_exp_unit = " "
    SET def_max_exp_val = 0
    SET def_calc_exp_from_draw_ind = 0
    SET def_volume_def = 0
    SET def_dispense_ind = 0
    SET def_min_bef_quar = 0
    SET def_validate_antibody_ind = 0
    SET def_validate_transf_req_ind = 0
    SET def_int_units_ind = 0
    SET def_def_storage_temp = " "
    SELECT INTO "nl:"
     FROM br_bb_product bp
     PLAN (bp
      WHERE bp.product_cd=product_code_value)
     DETAIL
      def_auto_ind = bp.auto_ind, def_directed_ind = bp.directed_ind, def_max_exp_unit = bp
      .max_exp_unit,
      def_max_exp_val = bp.max_exp_val, def_calc_exp_from_draw_ind = bp.calc_exp_from_draw_ind,
      def_volume_def = bp.volume_def,
      def_dispense_ind = bp.dispense_ind, def_min_bef_quar = bp.min_bef_quar,
      def_validate_antibody_ind = bp.validate_antibody_ind,
      def_validate_transf_req_ind = bp.validate_transf_req_ind, def_int_units_ind = bp.int_units_ind,
      def_def_storage_temp = bp.def_storage_temp
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Unable to read br_bb_product for product_cd ",cnvtstring(
       product_code_value))
     GO TO exit_script
    ENDIF
    IF (cnvtupper(def_max_exp_unit)="DAYS")
     SET days_val = def_max_exp_val
     SET hours_val = 0
    ELSEIF (cnvtupper(def_max_exp_unit)="HOURS")
     SET hours_val = def_max_exp_val
     SET days_val = 0
    ENDIF
    SET q_storage_temp = trim(cnvtupper(cnvtalphanum(def_def_storage_temp)))
    IF (def_def_storage_temp > " ")
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=1663
        AND cv.active_ind=1
        AND cv.display_key=q_storage_temp)
      DETAIL
       def_def_storage_temp_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET def_def_storage_temp_cd = 0
     ENDIF
    ENDIF
    UPDATE  FROM product_index pi
     SET pi.autologous_ind = def_auto_ind, pi.directed_ind = def_directed_ind, pi.max_days_expire =
      days_val,
      pi.max_hrs_expire = hours_val, pi.drawn_dt_tm_ind = def_calc_exp_from_draw_ind, pi
      .default_volume = def_volume_def,
      pi.allow_dispense_ind = def_dispense_ind, pi.auto_quarantine_min = def_min_bef_quar, pi
      .validate_ag_ab_ind = def_validate_antibody_ind,
      pi.validate_trans_req_ind = def_validate_transf_req_ind, pi.intl_units_ind = def_int_units_ind,
      pi.storage_temp_cd = def_def_storage_temp_cd,
      pi.auto_bill_item_cd = 0.0, pi.active_ind = 1, pi.active_status_cd = active_cd,
      pi.active_status_dt_tm = cnvtdatetime(curdate,curtime), pi.active_status_prsnl_id = reqinfo->
      updt_id, pi.updt_applctx = reqinfo->updt_applctx,
      pi.updt_cnt = (pi.updt_cnt+ 1), pi.updt_dt_tm = cnvtdatetime(curdate,curtime), pi.updt_id =
      reqinfo->updt_id,
      pi.updt_task = reqinfo->updt_task
     WHERE pi.product_cd=product_code_value
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Unable to update product_index for product_cd ",cnvtstring(
       product_code_value))
     GO TO exit_script
    ENDIF
    UPDATE  FROM code_value cv
     SET cv.active_ind = 1, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.active_type_cd =
      active_cd,
      cv.active_status_prsnl_id = reqinfo->updt_id, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id =
      reqinfo->updt_id,
      cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     WHERE cv.code_value=product_code_value
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Unable to update code_value for product_cd: ",cnvtstring(
       product_code_value))
     GO TO exit_script
    ENDIF
   ELSE
    SET error_flag = "T"
    SET error_msg = concat("Invalid action flag value for product_cd: ",cnvtstring(product_code_value
      ))
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_ENS_BB_DEF_PROD_DETAILS  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
