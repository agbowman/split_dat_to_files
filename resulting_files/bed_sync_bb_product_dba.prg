CREATE PROGRAM bed_sync_bb_product:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET cat
 RECORD cat(
   1 qual[*]
     2 prodcat_cd = f8
     2 prodcat_disp = vc
     2 prodcat_desc = vc
     2 class_mean = vc
     2 rh_required_ind = i2
     2 confirm_required_ind = i2
     2 red_cell_product_ind = i2
     2 xmatch_required_ind = i2
     2 storage_temp_cd = f8
     2 storage_temp_disp = vc
     2 default_ship_cond_cd = f8
     2 default_ship_cond_disp = vc
     2 default_unit_measure_cd = f8
     2 default_unit_measure_disp = vc
     2 default_vis_insp_cd = f8
     2 default_vis_insp_disp = vc
     2 prompt_vol_ind = i2
     2 prompt_alternate_ind = i2
     2 prompt_segment_ind = i2
     2 crossmatch_tag_ind = i2
     2 component_tag_ind = i2
     2 pilot_label_ind = i2
     2 valid_aborh_compat_ind = i2
     2 selected_ind = i2
     2 active_ind = i2
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = 0
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 id = f8
     2 disp = vc
     2 sel_ind = i2
 )
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_bb_prodcat b
  PLAN (b)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].id = b.prodcat_id,
   temp->qual[cnt].disp = b.display, temp->qual[cnt].sel_ind = b.selected_ind
  WITH nocounter
 ;end select
 DELETE  FROM br_bb_prodcat b
  WHERE b.autobuild_ind=0
  WITH nocounter
 ;end delete
 SET cnt = 0
 SELECT INTO "nl:"
  FROM product_category pc,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   code_value cv4
  PLAN (pc
   WHERE pc.product_cat_cd > 0)
   JOIN (cv1
   WHERE cv1.code_value=pc.default_ship_cond_cd)
   JOIN (cv2
   WHERE cv2.code_value=pc.default_unit_measure_cd)
   JOIN (cv3
   WHERE cv3.code_value=pc.product_cat_cd)
   JOIN (cv4
   WHERE cv4.code_value=pc.product_class_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(cat->qual,cnt), cat->qual[cnt].rh_required_ind = pc
   .rh_required_ind,
   cat->qual[cnt].confirm_required_ind = pc.confirm_required_ind, cat->qual[cnt].red_cell_product_ind
    = pc.red_cell_product_ind, cat->qual[cnt].xmatch_required_ind = pc.xmatch_required_ind,
   cat->qual[cnt].default_ship_cond_cd = pc.default_ship_cond_cd, cat->qual[cnt].
   default_ship_cond_disp = cv1.display, cat->qual[cnt].default_unit_measure_cd = pc
   .default_unit_measure_cd,
   cat->qual[cnt].default_unit_measure_disp = cv2.display, cat->qual[cnt].prompt_vol_ind = pc
   .prompt_vol_ind, cat->qual[cnt].prompt_alternate_ind = pc.prompt_alternate_ind,
   cat->qual[cnt].prompt_segment_ind = pc.prompt_segment_ind, cat->qual[cnt].crossmatch_tag_ind = pc
   .crossmatch_tag_ind, cat->qual[cnt].component_tag_ind = pc.component_tag_ind,
   cat->qual[cnt].pilot_label_ind = pc.pilot_label_ind, cat->qual[cnt].valid_aborh_compat_ind = pc
   .valid_aborh_compat_ind, cat->qual[cnt].prodcat_cd = pc.product_cat_cd,
   cat->qual[cnt].prodcat_disp = cv3.display, cat->qual[cnt].prodcat_desc = cv3.description, cat->
   qual[cnt].class_mean = cv4.cdf_meaning,
   cat->qual[cnt].active_ind = pc.active_ind
   IF (pc.active_ind=1)
    cat->qual[cnt].selected_ind = 1
   ELSE
    cat->qual[cnt].selected_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    product_index p
   PLAN (d
    WHERE (cat->qual[d.seq].active_ind=0))
    JOIN (p
    WHERE (p.product_cat_cd=cat->qual[d.seq].prodcat_cd)
     AND p.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    cat->qual[d.seq].selected_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO cnt)
   SET cat_found_by_cd = 0
   SET cat_found_by_disp = 0
   SELECT INTO "nl:"
    FROM br_bb_prodcat b
    PLAN (b
     WHERE (b.prodcat_cd=cat->qual[x].prodcat_cd))
    DETAIL
     cat_found_by_cd = 1
    WITH nocounter
   ;end select
   IF (cat_found_by_cd=0)
    SELECT INTO "nl:"
     FROM br_bb_prodcat b
     PLAN (b
      WHERE (b.display=cat->qual[x].prodcat_disp))
     DETAIL
      cat_found_by_disp = 1
     WITH nocounter
    ;end select
   ENDIF
   IF (cat_found_by_cd=1)
    SET ierrcode = 0
    UPDATE  FROM br_bb_prodcat b
     SET b.display = cat->qual[x].prodcat_disp, b.red_cell_ind = cat->qual[x].red_cell_product_ind, b
      .rh_req_ind = cat->qual[x].rh_required_ind,
      b.aborh_conf_req_ind = cat->qual[x].confirm_required_ind, b.val_compat_ind = cat->qual[x].
      valid_aborh_compat_ind, b.xm_req_ind = cat->qual[x].xmatch_required_ind,
      b.uom_def = cat->qual[x].default_unit_measure_disp, b.ship_cond_def = cat->qual[x].
      default_ship_cond_disp, b.prompt_for_vol_ind = cat->qual[x].prompt_vol_ind,
      b.seg_num_ind = cat->qual[x].prompt_segment_ind, b.alternate_id_ind = cat->qual[x].
      prompt_alternate_ind, b.xm_tag_req_ind = cat->qual[x].crossmatch_tag_ind,
      b.comp_tag_req_ind = cat->qual[x].component_tag_ind, b.pilot_label_req_ind = cat->qual[x].
      pilot_label_ind, b.selected_ind = cat->qual[x].selected_ind,
      b.updt_id = reqinfo->updt_id, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = cat->
      qual[x].active_ind
     PLAN (b
      WHERE (b.prodcat_cd=cat->qual[x].prodcat_cd))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ELSEIF (cat_found_by_disp=1)
    SET ierrcode = 0
    UPDATE  FROM br_bb_prodcat b
     SET b.prodcat_cd = cat->qual[x].prodcat_cd, b.red_cell_ind = cat->qual[x].red_cell_product_ind,
      b.rh_req_ind = cat->qual[x].rh_required_ind,
      b.aborh_conf_req_ind = cat->qual[x].confirm_required_ind, b.val_compat_ind = cat->qual[x].
      valid_aborh_compat_ind, b.xm_req_ind = cat->qual[x].xmatch_required_ind,
      b.uom_def = cat->qual[x].default_unit_measure_disp, b.ship_cond_def = cat->qual[x].
      default_ship_cond_disp, b.prompt_for_vol_ind = cat->qual[x].prompt_vol_ind,
      b.seg_num_ind = cat->qual[x].prompt_segment_ind, b.alternate_id_ind = cat->qual[x].
      prompt_alternate_ind, b.xm_tag_req_ind = cat->qual[x].crossmatch_tag_ind,
      b.comp_tag_req_ind = cat->qual[x].component_tag_ind, b.pilot_label_req_ind = cat->qual[x].
      pilot_label_ind, b.selected_ind = cat->qual[x].selected_ind,
      b.updt_id = reqinfo->updt_id, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = cat->
      qual[x].active_ind
     PLAN (b
      WHERE (b.display=cat->qual[x].prodcat_disp))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ELSE
    INSERT  FROM br_bb_prodcat b
     SET b.prodcat_id = seq(bedrock_seq,nextval), b.display = cat->qual[x].prodcat_disp, b
      .description =
      IF ((cat->qual[x].prodcat_desc > " ")) cat->qual[x].prodcat_desc
      ELSE cat->qual[x].prodcat_disp
      ENDIF
      ,
      b.prodcat_cd = cat->qual[x].prodcat_cd, b.product_class_mean = cat->qual[x].class_mean, b
      .red_cell_ind = cat->qual[x].red_cell_product_ind,
      b.rh_req_ind = cat->qual[x].rh_required_ind, b.aborh_conf_req_ind = cat->qual[x].
      confirm_required_ind, b.val_compat_ind = cat->qual[x].valid_aborh_compat_ind,
      b.xm_req_ind = cat->qual[x].xmatch_required_ind, b.uom_def = cat->qual[x].
      default_unit_measure_disp, b.ship_cond_def = cat->qual[x].default_ship_cond_disp,
      b.prompt_for_vol_ind = cat->qual[x].prompt_vol_ind, b.seg_num_ind = cat->qual[x].
      prompt_segment_ind, b.alternate_id_ind = cat->qual[x].prompt_alternate_ind,
      b.xm_tag_req_ind = cat->qual[x].crossmatch_tag_ind, b.comp_tag_req_ind = cat->qual[x].
      component_tag_ind, b.pilot_label_req_ind = cat->qual[x].pilot_label_ind,
      b.selected_ind = cat->qual[x].selected_ind, b.updt_id = reqinfo->updt_id, b.updt_cnt = 0,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_task = reqinfo->updt_task, b.updt_applctx
       = reqinfo->updt_applctx,
      b.active_ind = cat->qual[x].active_ind
     PLAN (b)
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 SET cnt = size(temp->qual,5)
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_bb_prodcat b
   PLAN (d)
    JOIN (b
    WHERE (b.display=temp->qual[d.seq].disp))
   ORDER BY d.seq
   HEAD d.seq
    temp->qual[d.seq].id = b.prodcat_id
   WITH nocounter
  ;end select
  UPDATE  FROM br_bb_prodcat b,
    (dummyt d  WITH seq = value(cnt))
   SET b.selected_ind = temp->qual[d.seq].sel_ind
   PLAN (d)
    JOIN (b
    WHERE (b.prodcat_id=temp->qual[d.seq].id)
     AND b.selected_ind=0)
   WITH nocounter
  ;end update
 ENDIF
 FREE SET prod
 RECORD prod(
   1 qual[*]
     2 product_cd = f8
     2 product_disp = vc
     2 product_desc = vc
     2 autologous_ind = i2
     2 directed_ind = i2
     2 allow_dispense_ind = i2
     2 default_volume = i4
     2 max_days_expire = i4
     2 max_hrs_expire = i4
     2 default_supplier_id = f8
     2 default_supplier_disp = vc
     2 synonym_id = f8
     2 synonym_disp = vc
     2 auto_quarantine_min = i4
     2 intl_units_ind = i2
     2 validate_ag_ab_ind = i2
     2 validate_trans_req_ind = i2
     2 storage_temp_cd = f8
     2 storage_temp_disp = vc
     2 drawn_dt_tm_ind = i2
     2 max_exp = i4
     2 max_exp_unit = vc
     2 prodcat_cd = f8
     2 prodcat_id = f8
     2 aliquot_ind = i2
     2 active_ind = i2
 )
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 id = f8
     2 disp = vc
     2 sel_ind = i2
 )
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_bb_product b
  PLAN (b
   WHERE b.prodcat_id=0)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].id = b.product_id,
   temp->qual[cnt].disp = b.display, temp->qual[cnt].sel_ind = b.selected_ind
  WITH nocounter
 ;end select
 DELETE  FROM br_bb_product b
  WHERE b.autobuild_ind=0
   AND b.product_cd > 0
  WITH nocounter
 ;end delete
 SET cnt = 0
 SELECT INTO "nl:"
  FROM product_index pi,
   code_value cv,
   code_value cv2,
   organization o,
   order_catalog_synonym ocs
  PLAN (pi)
   JOIN (cv
   WHERE cv.code_value=pi.storage_temp_cd)
   JOIN (cv2
   WHERE cv2.code_value=pi.product_cd)
   JOIN (o
   WHERE o.organization_id=pi.default_supplier_id)
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(pi.synonym_id))
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(prod->qual,cnt), prod->qual[cnt].product_cd = pi.product_cd,
   prod->qual[cnt].product_disp = cv2.display, prod->qual[cnt].product_desc = cv2.description, prod->
   qual[cnt].autologous_ind = pi.autologous_ind,
   prod->qual[cnt].directed_ind = pi.directed_ind, prod->qual[cnt].allow_dispense_ind = pi
   .allow_dispense_ind, prod->qual[cnt].default_volume = pi.default_volume,
   prod->qual[cnt].max_days_expire = pi.max_days_expire, prod->qual[cnt].max_hrs_expire = pi
   .max_hrs_expire
   IF (pi.max_days_expire > 0)
    prod->qual[cnt].max_exp = pi.max_days_expire, prod->qual[cnt].max_exp_unit = "Days"
   ELSEIF (pi.max_hrs_expire > 0)
    prod->qual[cnt].max_exp = pi.max_hrs_expire, prod->qual[cnt].max_exp_unit = "Hours"
   ENDIF
   prod->qual[cnt].default_supplier_id = pi.default_supplier_id, prod->qual[cnt].
   default_supplier_disp = o.org_name, prod->qual[cnt].synonym_id = pi.synonym_id,
   prod->qual[cnt].synonym_disp = ocs.mnemonic, prod->qual[cnt].auto_quarantine_min = pi
   .auto_quarantine_min, prod->qual[cnt].intl_units_ind = pi.intl_units_ind,
   prod->qual[cnt].validate_ag_ab_ind = pi.validate_ag_ab_ind, prod->qual[cnt].validate_trans_req_ind
    = pi.validate_trans_req_ind, prod->qual[cnt].storage_temp_cd = pi.storage_temp_cd,
   prod->qual[cnt].storage_temp_disp = cv.display, prod->qual[cnt].drawn_dt_tm_ind = pi
   .drawn_dt_tm_ind, prod->qual[cnt].prodcat_cd = pi.product_cat_cd,
   prod->qual[cnt].aliquot_ind = pi.aliquot_ind, prod->qual[cnt].active_ind = pi.active_ind
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_bb_prodcat b
   PLAN (d
    WHERE (prod->qual[d.seq].prodcat_cd > 0))
    JOIN (b
    WHERE (b.prodcat_cd=prod->qual[d.seq].prodcat_cd))
   ORDER BY d.seq
   HEAD d.seq
    prod->qual[d.seq].prodcat_id = b.prodcat_id
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO cnt)
   SET prod_found_by_cd = 0
   SET prod_found_by_disp = 0
   SET prod_id = 0
   SET sel_ind = 0
   SET cat_id = 0
   SELECT INTO "nl:"
    FROM br_bb_product b
    PLAN (b
     WHERE (b.product_cd=prod->qual[x].product_cd))
    DETAIL
     prod_found_by_cd = 1, prod_id = b.product_id, sel_ind = b.selected_ind,
     cat_id = b.prodcat_id
    WITH nocounter
   ;end select
   IF (prod_found_by_cd=0)
    SELECT INTO "nl:"
     FROM br_bb_product b
     PLAN (b
      WHERE cnvtupper(b.display)=cnvtupper(prod->qual[x].product_disp)
       AND ((b.autobuild_ind=1) OR (b.product_cd=0)) )
     DETAIL
      prod_found_by_disp = 1, prod_id = b.product_id, sel_ind = b.selected_ind,
      cat_id = b.prodcat_id
     WITH nocounter
    ;end select
   ENDIF
   IF (prod_found_by_cd=1)
    SET ierrcode = 0
    UPDATE  FROM br_bb_product b
     SET b.display = prod->qual[x].product_disp, b.description = prod->qual[x].product_desc, b
      .auto_ind = prod->qual[x].autologous_ind,
      b.directed_ind = prod->qual[x].directed_ind, b.max_exp_val = prod->qual[x].max_exp, b
      .max_exp_unit = prod->qual[x].max_exp_unit,
      b.calc_exp_from_draw_ind = prod->qual[x].drawn_dt_tm_ind, b.volume_def = prod->qual[x].
      default_volume, b.def_supplier = prod->qual[x].default_supplier_disp,
      b.aborh_conf_test_name = prod->qual[x].synonym_disp, b.dispense_ind = prod->qual[x].
      allow_dispense_ind, b.min_bef_quar = prod->qual[x].auto_quarantine_min,
      b.validate_antibody_ind = prod->qual[x].validate_ag_ab_ind, b.validate_transf_req_ind = prod->
      qual[x].validate_trans_req_ind, b.int_units_ind = prod->qual[x].intl_units_ind,
      b.def_storage_temp = prod->qual[x].storage_temp_disp, b.selected_ind =
      IF ((prod->qual[x].active_ind=1)) 1
      ELSEIF ((prod->qual[x].active_ind=0)
       AND (prod->qual[x].prodcat_cd=0)
       AND sel_ind=1) 1
      ELSE 0
      ENDIF
      , b.prodcat_id =
      IF ((prod->qual[x].prodcat_id > 0)) prod->qual[x].prodcat_id
      ELSE cat_id
      ENDIF
      ,
      b.updt_id = reqinfo->updt_id, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = prod->
      qual[x].active_ind,
      b.aliquot_ind = prod->qual[x].aliquot_ind
     PLAN (b
      WHERE b.product_id=prod_id)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ELSEIF (prod_found_by_disp=1)
    SET ierrcode = 0
    UPDATE  FROM br_bb_product b
     SET b.product_cd = prod->qual[x].product_cd, b.auto_ind = prod->qual[x].autologous_ind, b
      .directed_ind = prod->qual[x].directed_ind,
      b.max_exp_val = prod->qual[x].max_exp, b.max_exp_unit = prod->qual[x].max_exp_unit, b
      .calc_exp_from_draw_ind = prod->qual[x].drawn_dt_tm_ind,
      b.volume_def = prod->qual[x].default_volume, b.def_supplier = prod->qual[x].
      default_supplier_disp, b.aborh_conf_test_name = prod->qual[x].synonym_disp,
      b.dispense_ind = prod->qual[x].allow_dispense_ind, b.min_bef_quar = prod->qual[x].
      auto_quarantine_min, b.validate_antibody_ind = prod->qual[x].validate_ag_ab_ind,
      b.validate_transf_req_ind = prod->qual[x].validate_trans_req_ind, b.int_units_ind = prod->qual[
      x].intl_units_ind, b.def_storage_temp = prod->qual[x].storage_temp_disp,
      b.selected_ind =
      IF ((prod->qual[x].active_ind=1)) 1
      ELSEIF ((prod->qual[x].active_ind=0)
       AND (prod->qual[x].prodcat_cd=0)
       AND sel_ind=1) 1
      ELSE 0
      ENDIF
      , b.prodcat_id =
      IF ((prod->qual[x].prodcat_id > 0)) prod->qual[x].prodcat_id
      ELSE cat_id
      ENDIF
      , b.updt_id = reqinfo->updt_id,
      b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.active_ind = prod->qual[x].active_ind, b.aliquot_ind
       = prod->qual[x].aliquot_ind
     PLAN (b
      WHERE b.product_id=prod_id)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ELSE
    SET ierrcode = 0
    INSERT  FROM br_bb_product b
     SET b.product_id = seq(bedrock_seq,nextval), b.product_cd = prod->qual[x].product_cd, b
      .prodcat_id = prod->qual[x].prodcat_id,
      b.display = prod->qual[x].product_disp, b.description = prod->qual[x].product_desc, b.auto_ind
       = prod->qual[x].autologous_ind,
      b.directed_ind = prod->qual[x].directed_ind, b.max_exp_val = prod->qual[x].max_exp, b
      .max_exp_unit = prod->qual[x].max_exp_unit,
      b.calc_exp_from_draw_ind = prod->qual[x].drawn_dt_tm_ind, b.volume_def = prod->qual[x].
      default_volume, b.def_supplier = prod->qual[x].default_supplier_disp,
      b.aborh_conf_test_name = prod->qual[x].synonym_disp, b.dispense_ind = prod->qual[x].
      allow_dispense_ind, b.min_bef_quar = prod->qual[x].auto_quarantine_min,
      b.validate_antibody_ind = prod->qual[x].validate_ag_ab_ind, b.validate_transf_req_ind = prod->
      qual[x].validate_trans_req_ind, b.int_units_ind = prod->qual[x].intl_units_ind,
      b.def_storage_temp = prod->qual[x].storage_temp_disp, b.selected_ind =
      IF ((prod->qual[x].active_ind=1)) 1
      ELSE 0
      ENDIF
      , b.updt_id = reqinfo->updt_id,
      b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_task = reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.active_ind = prod->qual[x].active_ind, b.aliquot_ind
       = prod->qual[x].aliquot_ind
     PLAN (b)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET cnt = size(temp->qual,5)
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_bb_product b
   PLAN (d)
    JOIN (b
    WHERE (b.display=temp->qual[d.seq].disp)
     AND b.prodcat_id=0)
   ORDER BY d.seq
   HEAD d.seq
    temp->qual[d.seq].id = b.product_id
   WITH nocounter
  ;end select
  UPDATE  FROM br_bb_product b,
    (dummyt d  WITH seq = value(cnt))
   SET b.selected_ind = temp->qual[d.seq].sel_ind
   PLAN (d)
    JOIN (b
    WHERE (b.product_id=temp->qual[d.seq].id))
   WITH nocounter
  ;end update
 ENDIF
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 id = f8
 )
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_bb_product b,
   br_bb_product b2
  PLAN (b
   WHERE b.prodcat_id > 0)
   JOIN (b2
   WHERE cnvtupper(b2.display)=cnvtupper(b.display)
    AND b2.prodcat_id=0)
  HEAD b2.product_id
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].id = b2.product_id
  WITH nocounter
 ;end select
 IF (cnt > 0)
  DELETE  FROM br_bb_product b,
    (dummyt d  WITH seq = value(cnt))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.product_id=temp->qual[d.seq].id))
   WITH nocounter
  ;end delete
 ENDIF
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 id = f8
 )
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_bb_product b
  PLAN (b
   WHERE b.prodcat_id > 0
    AND  NOT ( EXISTS (
   (SELECT
    c.prodcat_id
    FROM br_bb_prodcat c
    WHERE c.prodcat_id=b.prodcat_id))))
  HEAD b.prodcat_id
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].id = b.prodcat_id
  WITH nocounter
 ;end select
 IF (cnt > 0)
  UPDATE  FROM br_bb_product b,
    (dummyt d  WITH seq = value(cnt))
   SET b.prodcat_id = 0
   PLAN (d)
    JOIN (b
    WHERE (b.prodcat_id=temp->qual[d.seq].id))
   WITH nocounter
  ;end update
 ENDIF
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 code_value = f8
     2 active_ind = i2
     2 display = vc
     2 description = vc
 )
 SET cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1604
    AND cv.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    b.product_id
    FROM br_bb_product b
    WHERE b.product_cd=cv.code_value))))
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].code_value = cv.code_value,
   temp->qual[cnt].active_ind = cv.active_ind, temp->qual[cnt].display = cv.display, temp->qual[cnt].
   description = cv.description
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SET ierrcode = 0
  INSERT  FROM br_bb_product b,
    (dummyt d  WITH seq = cnt)
   SET b.product_id = seq(bedrock_seq,nextval), b.product_cd = temp->qual[d.seq].code_value, b
    .prodcat_id = 0,
    b.display = temp->qual[d.seq].display, b.description = temp->qual[d.seq].description, b
    .selected_ind = temp->qual[d.seq].active_ind,
    b.updt_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime),
    b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1
   PLAN (d)
    JOIN (b)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
