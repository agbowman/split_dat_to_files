CREATE PROGRAM bed_ens_bb_prodcat
 FREE SET reply
 RECORD reply(
   1 prodcat_list[*]
     2 prodcat_id = f8
     2 prodcat_code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc
 DECLARE error_flag = vc
 DECLARE numrows = i4
 DECLARE prodcat_id = f8
 DECLARE display = vc
 DECLARE description = vc
 DECLARE dup = vc
 DECLARE hold_code_value = f8
 DECLARE next_code = f8
 DECLARE active_cd = f8
 DECLARE inactive_cd = f8
 DECLARE auth_data_status_cd = f8
 DECLARE repcnt = i4
 DECLARE selected_ind = i2
 DECLARE class_mean = vc
 DECLARE class_cd = f8
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET repcnt = 0
 SET numrows = size(request->prodcat_list,5)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1)
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE"
    AND cv.active_ind=1)
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH"
    AND cv.active_ind=1)
  DETAIL
   auth_data_status_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO numrows)
   IF ((request->prodcat_list[x].action_flag=1))
    CALL add_prodcat(x)
   ELSEIF ((request->prodcat_list[x].action_flag=2))
    CALL update_prodcat(x)
   ELSEIF ((request->prodcat_list[x].action_flag=3))
    CALL remove_prodcat(x)
   ELSEIF ((request->prodcat_list[x].action_flag=0))
    SET stat = x
   ELSE
    SET error_flag = "T"
    SET error_msg = concat("Invalid action_flag for prodcat_id: ",cnvtstring(request->prodcat_list[x]
      .prodcat_id)," Action flag: ",cnvtstring(request->prodcat_list[x].action_flag))
    GO TO exit_script
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE add_prodcat(x)
   SELECT INTO "nl"
    FROM br_bb_prodcat bc
    PLAN (bc
     WHERE (bc.prodcat_id=request->prodcat_list[x].prodcat_id))
    DETAIL
     prodcat_id = bc.prodcat_id, display = bc.display, description = bc.description,
     selected_ind = bc.selected_ind, class_mean = trim(bc.product_class_mean)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Unable to add product category from prodcat_id: ",cnvtstring(request->
      prodcat_list[x].prodcat_id)," Product category not found on BR_BB_PRODCAT table.")
    GO TO exit_script
   ENDIF
   SET class_cd = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=1606
      AND cv.cdf_meaning=class_mean
      AND cv.active_ind=1)
    DETAIL
     class_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (class_cd=0.0)
    SET error_flag = "T"
    SET error_msg = concat("Unable to read product class from prodcat_id: ",cnvtstring(request->
      prodcat_list[x].prodcat_id)," Product class meaning = ",class_mean)
    GO TO exit_script
   ENDIF
   SET dup = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=1605
      AND cnvtupper(trim(cv.display))=cnvtupper(trim(display)))
    DETAIL
     hold_code_value = cv.code_value, dup = "Y"
    WITH nocounter
   ;end select
   IF (dup="N")
    SET hold_code_value = 0.0
    SET next_code = 0.0
    EXECUTE cpm_next_code
    INSERT  FROM code_value cv
     SET cv.active_ind = 0, cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime), cv.cdf_meaning
       = "",
      cv.cki = "", cv.code_set = 1605, cv.code_value = next_code,
      cv.collation_seq = 0, cv.concept_cki = "", cv.definition = description,
      cv.description = description, cv.display = display, cv.display_key = cnvtupper(cnvtalphanum(
        display)),
      cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), cv.active_ind = 0, cv
      .active_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.active_type_cd = inactive_cd, cv.data_status_cd = auth_data_status_cd, cv.data_status_dt_tm
       = cnvtdatetime(curdate,curtime3),
      cv.data_status_prsnl_id = reqinfo->updt_id, cv.active_status_prsnl_id = reqinfo->updt_id, cv
      .updt_id = reqinfo->updt_id,
      cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = 0, cv.updt_task = reqinfo->
      updt_task,
      cv.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET hold_code_value = next_code
    ELSE
     SET error_flag = "T"
     SET error_msg = concat("Error creating code value on code set 1604 for product_id: ",cnvtstring(
       request->product_list[x].product_id))
     GO TO exit_script
    ENDIF
    INSERT  FROM product_category pc
     SET pc.product_cat_cd = hold_code_value, pc.product_class_cd = class_cd, pc.rh_required_ind = 0,
      pc.confirm_required_ind = 0, pc.red_cell_product_ind = 0, pc.xmatch_required_ind = 0,
      pc.storage_temp_cd = 0.0, pc.default_ship_cond_cd = 0.0, pc.default_vis_insp_cd = 0.0,
      pc.default_unit_measure_cd = 0.0, pc.prompt_vol_ind = 0, pc.prompt_alternate_ind = 0,
      pc.prompt_segment_ind = 0, pc.special_testing_ind = 0, pc.crossmatch_tag_ind = 0,
      pc.component_tag_ind = 0, pc.valid_aborh_compat_ind = 0, pc.pilot_label_ind = 0,
      pc.active_ind = 0, pc.active_status_cd = inactive_cd, pc.active_status_dt_tm = cnvtdatetime(
       curdate,curtime),
      pc.active_status_prsnl_id = reqinfo->updt_id, pc.updt_cnt = 0, pc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      pc.updt_id = reqinfo->updt_id, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_task = reqinfo
      ->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat(
      "Unable to add product category to product_category table for prodcat_id: ",cnvtstring(request
       ->prodcat_list[x].prodcat_id))
     GO TO exit_script
    ENDIF
   ENDIF
   UPDATE  FROM br_bb_prodcat bc
    SET bc.prodcat_cd = hold_code_value, bc.selected_ind = 1, bc.updt_applctx = reqinfo->updt_applctx,
     bc.updt_cnt = (bc.updt_cnt+ 1), bc.updt_dt_tm = cnvtdatetime(curdate,curtime), bc.updt_id =
     reqinfo->updt_id,
     bc.updt_task = reqinfo->updt_task, bc.active_ind = 0
    WHERE (bc.prodcat_id=request->prodcat_list[x].prodcat_id)
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(
     "Unable to update product category on br_bb_prodcat table for prodcat_id: ",cnvtstring(request->
      prodcat_list[x].prodcat_id))
    GO TO exit_script
   ENDIF
   SET repcnt = (repcnt+ 1)
   SET stat = alterlist(reply->prodcat_list,repcnt)
   SET reply->prodcat_list[repcnt].prodcat_code_value = hold_code_value
   SET reply->prodcat_list[repcnt].prodcat_id = request->prodcat_list[x].prodcat_id
 END ;Subroutine
 SUBROUTINE update_prodcat(x)
   SET error_flag = "T"
   SET error_msg = "Product category update not supported - program terminating"
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE remove_prodcat(x)
   SET hold_code_value = 0.0
   SELECT INTO "nl:"
    FROM br_bb_prodcat bc
    PLAN (bc
     WHERE (bc.prodcat_id=request->prodcat_list[x].prodcat_id))
    DETAIL
     hold_code_value = bc.prodcat_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Invalid product category to remove: ",cnvtstring(request->prodcat_list[x]
      .prodcat_id))
    GO TO exit_script
   ENDIF
   IF (hold_code_value > 0.0)
    UPDATE  FROM code_value cv
     SET cv.active_ind = 0, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.active_type_cd =
      inactive_cd,
      cv.active_status_prsnl_id = reqinfo->updt_id, cv.updt_id = reqinfo->updt_id, cv.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
      updt_applctx
     WHERE cv.code_value=hold_code_value
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error updating code value to remove product category from prodcat id: ",
      cnvtstring(request->prodcat_list[x].prodcat_id))
     GO TO exit_script
    ENDIF
    UPDATE  FROM product_category pc
     SET pc.active_ind = 0, pc.active_status_cd = inactive_cd, pc.active_status_dt_tm = cnvtdatetime(
       curdate,curtime),
      pc.active_status_prsnl_id = reqinfo->updt_id, pc.updt_cnt = (pc.updt_cnt+ 1), pc.updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      pc.updt_id = reqinfo->updt_id, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_task = reqinfo
      ->updt_task
     WHERE pc.product_cat_cd=hold_code_value
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat(
      "Error updating product_category to remove product category from prodcat id: ",cnvtstring(
       request->prodcat_list[x].prodcat_id))
     GO TO exit_script
    ENDIF
    UPDATE  FROM product_index pi
     SET pi.product_cat_cd = 0.0
     WHERE pi.product_cat_cd=hold_code_value
     WITH nocounter
    ;end update
   ENDIF
   UPDATE  FROM br_bb_prodcat bc
    SET bc.selected_ind = 0, bc.updt_applctx = reqinfo->updt_applctx, bc.updt_cnt = (bc.updt_cnt+ 1),
     bc.updt_dt_tm = cnvtdatetime(curdate,curtime), bc.updt_id = reqinfo->updt_id, bc.updt_task =
     reqinfo->updt_task,
     bc.active_ind = 0
    WHERE (bc.prodcat_id=request->prodcat_list[x].prodcat_id)
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(
     "Unable to inactivate product category on br_bb_prodcat table for prodcat_id: ",cnvtstring(
      request->prodcat_list[x].prodcat_id))
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_BB_PRODCAT","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
