CREATE PROGRAM bed_ens_bb_prodcat_details:dba
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
 DECLARE catcnt = i4
 DECLARE active_cd = f8
 DECLARE ship_cond_def = vc
 DECLARE uom_def = vc
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET catcnt = size(request->prodcat_list,5)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.active_ind=1
    AND cv.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (ii = 1 TO catcnt)
   IF ((((request->prodcat_list[ii].action_flag=1)) OR ((request->prodcat_list[ii].action_flag=2))) )
    UPDATE  FROM product_category pc
     SET pc.rh_required_ind = request->prodcat_list[ii].rh_req_ind, pc.confirm_required_ind = request
      ->prodcat_list[ii].aborh_conf_req_ind, pc.red_cell_product_ind = request->prodcat_list[ii].
      red_cell_ind,
      pc.xmatch_required_ind = request->prodcat_list[ii].xm_req_ind, pc.default_ship_cond_cd =
      request->prodcat_list[ii].ship_cond_def_code_value, pc.default_unit_measure_cd = request->
      prodcat_list[ii].uom_def_code_value,
      pc.prompt_vol_ind = request->prodcat_list[ii].prompt_for_vol_ind, pc.prompt_alternate_ind =
      request->prodcat_list[ii].alternate_id_ind, pc.prompt_segment_ind = request->prodcat_list[ii].
      seg_num_ind,
      pc.crossmatch_tag_ind = request->prodcat_list[ii].xm_tag_req_ind, pc.component_tag_ind =
      request->prodcat_list[ii].comp_tag_req_ind, pc.pilot_label_ind = request->prodcat_list[ii].
      pilot_label_req_ind,
      pc.valid_aborh_compat_ind = request->prodcat_list[ii].val_compat_ind, pc.active_ind = 1, pc
      .active_status_cd = active_cd,
      pc.active_status_dt_tm = cnvtdatetime(curdate,curtime), pc.active_status_prsnl_id = reqinfo->
      updt_id, pc.updt_cnt = (pc.updt_cnt+ 1),
      pc.updt_id = reqinfo->updt_id, pc.updt_dt_tm = cnvtdatetime(curdate,curtime), pc.updt_task =
      reqinfo->updt_task,
      pc.updt_applctx = reqinfo->updt_applctx
     WHERE (pc.product_cat_cd=request->prodcat_list[ii].prodcat_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error updating product category details for ",cnvtstring(request->
       prodcat_list[ii].prodcat_cd))
     GO TO exit_script
    ENDIF
    UPDATE  FROM code_value cv
     SET cv.active_ind = 1, cv.active_type_cd = active_cd, cv.active_dt_tm = cnvtdatetime(curdate,
       curtime),
      cv.active_status_prsnl_id = reqinfo->updt_id, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id =
      reqinfo->updt_id,
      cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_task = reqinfo->updt_task, cv
      .updt_applctx = reqinfo->updt_applctx
     WHERE (cv.code_value=request->prodcat_list[ii].prodcat_code_value)
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error updating product category code value for ",cnvtstring(request->
       prodcat_list[ii].prodcat_code_value))
     GO TO exit_script
    ENDIF
    SET ship_cond_def = " "
    IF ((request->prodcat_list[ii].ship_cond_def_code_value > 0.0))
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE (cv.code_value=request->prodcat_list[ii].ship_cond_def_code_value))
      DETAIL
       ship_cond_def = trim(cv.display)
      WITH nocounter
     ;end select
    ENDIF
    SET uom_def = " "
    IF ((request->prodcat_list[ii].uom_def_code_value > 0.0))
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE (cv.code_value=request->prodcat_list[ii].uom_def_code_value))
      DETAIL
       uom_def = trim(cv.display)
      WITH nocounter
     ;end select
    ENDIF
    UPDATE  FROM br_bb_prodcat bc
     SET bc.rh_req_ind = request->prodcat_list[ii].rh_req_ind, bc.aborh_conf_req_ind = request->
      prodcat_list[ii].aborh_conf_req_ind, bc.red_cell_ind = request->prodcat_list[ii].red_cell_ind,
      bc.xm_req_ind = request->prodcat_list[ii].xm_req_ind, bc.ship_cond_def = ship_cond_def, bc
      .uom_def = uom_def,
      bc.prompt_for_vol_ind = request->prodcat_list[ii].prompt_for_vol_ind, bc.alternate_id_ind =
      request->prodcat_list[ii].alternate_id_ind, bc.seg_num_ind = request->prodcat_list[ii].
      seg_num_ind,
      bc.xm_tag_req_ind = request->prodcat_list[ii].xm_tag_req_ind, bc.comp_tag_req_ind = request->
      prodcat_list[ii].comp_tag_req_ind, bc.pilot_label_req_ind = request->prodcat_list[ii].
      pilot_label_req_ind,
      bc.val_compat_ind = request->prodcat_list[ii].val_compat_ind, bc.new_prodcat_ind = 0, bc
      .updt_cnt = (bc.updt_cnt+ 1),
      bc.updt_id = reqinfo->updt_id, bc.updt_dt_tm = cnvtdatetime(curdate,curtime), bc.updt_task =
      reqinfo->updt_task,
      bc.updt_applctx = reqinfo->updt_applctx, bc.active_ind = 1
     WHERE (bc.prodcat_cd=request->prodcat_list[ii].prodcat_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error updating bedrock product category details for ",cnvtstring(request
       ->prodcat_list[ii].prodcat_code_value))
     GO TO exit_script
    ENDIF
   ELSEIF ((request->prodcat_list[ii].action_flag=0))
    SET error_flag = "T"
    SET error_msg = concat(
     "Action flag = 0.  No change transactions not supported.  Product category cd: ",cnvtstring(
      request->prodcat_list[ii].prodcat_code_value))
    GO TO exit_script
   ELSEIF ((request->prodcat_list[ii].action_flag=3))
    SET error_flag = "T"
    SET error_msg = concat("Action flag = 3.  Deletes not supported.  Product category cd: ",
     cnvtstring(request->prodcat_list[ii].prodcat_code_value))
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_ENS_BB_PRODCAT_DETAILS  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
